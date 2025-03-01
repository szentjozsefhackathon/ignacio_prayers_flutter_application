import 'dart:async' show Timer;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../data/prayer.dart';
import '../data/prayer_step.dart';
import '../data/settings_data.dart';
import '../data_handlers/data_manager.dart';
import '../settings/dnd.dart' show DndProvider;
import 'prayer_text.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({
    super.key,
    required this.prayer,
  });

  final Prayer prayer;

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> with TickerProviderStateMixin {
  static final log = Logger('PrayerPage');

  late final AudioPlayer _audioPlayer;
  late List<int> _nextPageTimes = [];
  late int _remainingSeconds = 0;
  late int _currentPage = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  late final AnimationController _fabAnimationController;
  Timer? _timer;

  late final PageController _pageViewController;
  late final TabController _tabController;
  late final SettingsData _settings;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pageViewController = PageController();
    _tabController = TabController(
      length: widget.prayer.steps.length,
      vsync: this,
    );
    _settings = context.read<SettingsData>();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startPrayer();
    _tabController.addListener(() {
      if (!mounted || _tabController.indexIsChanging) {
        return;
      }
      setState(() => _currentPage = _tabController.index);
      if (_settings.prayerSoundEnabled) {
        _pageAudioPlayer();
      } else if (_currentPage > 0 && _settings.autoPageTurn) {
        // Vibration.vibrate(duration: 500);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    _pageViewController.dispose();
    _tabController.dispose();
    context.read<DndProvider>().restoreOriginal();
    super.dispose();
  }

  void _startPrayer() {
    _nextPageTimes = _getOptimalPageTimes();
    _remainingSeconds = _settings.prayerLength * 60;
    _startTimer();
    if (_settings.dnd) {
      context.read<DndProvider>().allowAlarmsOnly();
    }
    if (_settings.prayerSoundEnabled) {
      _pageAudioPlayer();
    }
    _fabAnimationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
      } else {
        _remainingSeconds--;
        if (_settings.autoPageTurn) {
          for (final time in _nextPageTimes) {
            if (time == _remainingSeconds) {
              final pageIndex = _nextPageTimes.indexOf(time);
              // we're not going back
              if (pageIndex > _currentPage) {
                _updateCurrentPageIndex(pageIndex);
              }
              break;
            }
          }
        }
        _isRunning = true;
        setState(() {});
      }
      if (_remainingSeconds <= 0) {
        _onTimerFinish();
      }
    });
  }

  Future<void> _onTimerFinish() async {
    setState(() => _isRunning = false);
    _audioPlayer.pause();
    _loadAudio('csengo.mp3');
    _audioPlayer.setVolume(1);
    _audioPlayer.play();
    // Vibration.vibrate(duration: 500);
    context.read<DndProvider>().restoreOriginal();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _loadAudio(String filename) {
    if (kIsWeb) {
      try {
        _audioPlayer.setAudioSource(
          AudioSource.uri(DataManager.instance.voices.getDownloadUri(filename)),
          initialPosition: Duration.zero,
        );
      } catch (e, s) {
        log.severe('Error loading audio', e, s);
      }
    } else {
      DataManager.instance.voices.getLocalFile(filename).then((audio) {
        _audioPlayer.setFilePath(audio.path);
      }).catchError((e, s) {
        log.severe('Error loading audio', e, s);
      });
    }
  }

  void _pageAudioPlayer() {
    if (widget.prayer.voiceOptions.isEmpty) {
      return;
    }
    _audioPlayer.pause();
    final voiceIndex =
        widget.prayer.voiceOptions.indexOf(_settings.voiceChoice);
    // match voices
    final filename = widget.prayer.steps[_currentPage].voices[voiceIndex];
    _loadAudio(filename);
    _audioPlayer.setVolume(1);
    if (_isPaused) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  List<int> _getOptimalPageTimes() {
    final pageTimes = <int>[];
    var totalFixTime = 0;
    var totalFlexTime = 0;
    for (final step in widget.prayer.steps) {
      if (step.type == PrayerStepType.fix) {
        totalFixTime += step.timeInSeconds;
      } else if (step.type == PrayerStepType.flex) {
        totalFlexTime += step.timeInSeconds;
      }
    }
    final totalTimeForFlex = _settings.prayerLength * 60 - totalFixTime;
    var remainingTime = _settings.prayerLength * 60;
    for (final step in widget.prayer.steps) {
      if (step.type == PrayerStepType.fix) {
        remainingTime -= step.timeInSeconds;
      } else if (step.type == PrayerStepType.flex) {
        remainingTime -= totalTimeForFlex * step.timeInSeconds ~/ totalFlexTime;
      }
      pageTimes.add(remainingTime);
    }
    pageTimes.removeLast();
    return pageTimes;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.prayer.title),
          leading: const CloseButton(),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageViewController,
                itemCount: widget.prayer.steps.length,
                onPageChanged: (index) => _tabController.index = index,
                itemBuilder: (context, index) => PrayerText(
                  widget.prayer.steps[index].description,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _isPaused ? 1.0 : .5,
              duration: kThemeAnimationDuration,
              child: Text(
                "Hátralévő idő: ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
              ),
            ),
            Opacity(
              opacity: .25,
              child: PageIndicator(
                tabController: _tabController,
                currentPageIndex: _currentPage,
                onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: AnimatedOpacity(
          opacity: _isPaused ? 1.0 : .5,
          duration: kThemeAnimationDuration,
          child: FloatingActionButton(
            mini: true,
            onPressed: _togglePlayPause,
            tooltip: _isRunning ? 'Szünet' : 'Folytatás',
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _fabAnimationController,
            ),
          ),
        ),
      );

  void _togglePlayPause() {
    setState(() {
      if (_isRunning) {
        _audioPlayer.pause();
        _isPaused = true;
        _isRunning = false;
        _fabAnimationController.reverse();
      } else {
        _isPaused = false;
        _startTimer();
        _audioPlayer.play();
        _fabAnimationController.forward();
      }
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            splashRadius: 16,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == tabController.length - 1) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
