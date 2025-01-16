import 'dart:async';

import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../data/prayer.dart';
import '../data/prayer_step.dart';
import '../data/settings_data.dart';
import '../data_handlers/data_manager.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({
    super.key,
    required this.prayer,
    required this.dataManager,
  });

  final Prayer prayer;
  final DataManager dataManager; // Shared instance of DataManager

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> with TickerProviderStateMixin {
  static final log = Logger('PrayerPage');
  final _dndPlugin = DoNotDisturbPlugin();

  late final AudioPlayer _audioPlayer;
  late List<int> _nextPageTimes = [];
  late int _remainingMillis = 0;
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
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void _startPrayer() {
    _nextPageTimes = _getOptimalPageTimes();
    _remainingMillis = _settings.prayerLength * 60 * 1000;
    _startTimer();
    if (_settings.dnd) {
      _doNotDisturbOn();
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
        setState(() {
          _remainingMillis -= 1000;
          if (_settings.autoPageTurn) {
            for (final time in _nextPageTimes) {
              if (time == _remainingMillis ~/ 1000) {
                _turnPage();
              }
            }
          }
          _isRunning = true;
        });
      }
      if (_remainingMillis <= 0) {
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
    if (_settings.dnd) {
      _doNotDisturbOff();
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _loadAudio(String filename) {
    widget.dataManager.voicesManager.getFile(filename).then((audio) {
      if (kIsWeb) {
        // For web: Use URL
        _audioPlayer.setUrl(audio);
      } else {
        // For other platforms: Use local file
        _audioPlayer.setFilePath(audio.path);
      }
    }).catchError((e, s) {
      log.severe('Error loading audio', e, s);
    });
  }

  void _pageAudioPlayer() {
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

  void _turnPage() {
    _currentPage++;
    _updateCurrentPageIndex(_currentPage);
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

  Future<void> _doNotDisturbOn() =>
      _dndPlugin.setInterruptionFilter(InterruptionFilter.all);

  Future<void> _doNotDisturbOff() =>
      _dndPlugin.setInterruptionFilter(InterruptionFilter.none);

  @override
  Widget build(BuildContext context) {
    final currentPrayer = widget.prayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPrayer.title),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            /// [PageView.scrollDirection] defaults to [Axis.horizontal].
            /// Use [Axis.vertical] to scroll vertically.
            controller: _pageViewController,
            itemCount: currentPrayer.steps.length, // Dynamic item count
            onPageChanged: _handlePageViewChanged,
            itemBuilder: (context, index) {
              final step = currentPrayer.steps[index];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(38),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text("Current page: ${index + 1}"),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Hátralévő idő: ${_remainingMillis ~/ 1000 ~/ 60}:${(_remainingMillis ~/ 1000 % 60).toString().padLeft(2, '0')}",
              ),
              PageIndicator(
                tabController: _tabController,
                currentPageIndex: _currentPage,
                onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                isOnDesktopAndWeb: _isOnDesktopAndWeb,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlayPause,
        tooltip: _isRunning ? 'Szünet' : 'Folytatás',
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _fabAnimationController,
        ),
      ),
    );
  }

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

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPage = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _currentPage = index;
    if (_settings.prayerSoundEnabled) {
      _pageAudioPlayer();
    } else if (_currentPage > 0 && _settings.autoPageTurn) {
      // Vibration.vibrate(duration: 500);
    }
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}

/// Page indicator for desktop and web platforms.
///
/// On Desktop and Web, drag gesture for horizontal scrolling in a PageView is disabled by default.
/// You can defined a custom scroll behavior to activate drag gestures,
/// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag.
///
/// In this sample, we use a TabPageSelector to navigate between pages,
/// in order to build natural behavior similar to other desktop applications.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
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
