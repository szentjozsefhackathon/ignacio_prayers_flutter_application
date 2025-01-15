import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';

import '../data_descriptors/prayer.dart';
import '../data_descriptors/prayer_step.dart';
import '../data_descriptors/user_settings_data.dart';
import '../data_handlers/data_manager.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({
    super.key,
    required this.prayer,
    required this.userSettingsData,
    required this.dataManager,
  });

  final Prayer prayer;
  final DataManager dataManager; // Shared instance of DataManager
  final UserSettingsData userSettingsData;

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> with TickerProviderStateMixin {
  final log = Logger('PrayerPage');

  late AudioPlayer _audioPlayer;
  late List<int> _nextPageTimes = [];
  late int _remainingMillis = 0;
  late int _currentPage = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  late PageController _pageViewController;
  late TabController _tabController;
  late UserSettingsData _userSettingsData;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pageViewController = PageController();
    _tabController =
        TabController(length: widget.prayer.steps.length, vsync: this);
    _userSettingsData = widget.userSettingsData;
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
    _remainingMillis = _userSettingsData.prayerLength * 60 * 1000;
    _startTimer();
    if (_userSettingsData.dnd) _doNotDisturbOn();

    if (_userSettingsData.prayerSoundEnabled) {
      pageAudioPlayer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
      } else {
        setState(() {
          _remainingMillis -= 1000;
          if (_userSettingsData.autoPageTurn) {
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
    setState(() {
      _isRunning = false;
    });
    _audioPlayer.pause();
    loadAudio('csengo.mp3');
    _audioPlayer.setVolume(1.0);
    _audioPlayer.play();
    // Vibration.vibrate(duration: 500);
    if (_userSettingsData.dnd) {
      _doNotDisturbOff();
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void loadAudio(String filename) {
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

  void pageAudioPlayer() {
    _audioPlayer.pause();
    final voiceIndex =
        widget.prayer.voiceOptions.indexOf(_userSettingsData.voiceChoice);
    final filename =
        widget.prayer.steps[_currentPage].voices[voiceIndex]; // match voices
    loadAudio(filename);
    _audioPlayer.setVolume(1.0);
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
    final totalTimeForFlex = _userSettingsData.prayerLength * 60 - totalFixTime;
    var remainingTime = _userSettingsData.prayerLength * 60;
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

  void _doNotDisturbOn() {
    // Implement Do Not Disturb functionality
  }

  void _doNotDisturbOff() {
    // Implement Do Not Disturb functionality
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayer = widget.prayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPrayer.title),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
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
                  padding: const EdgeInsets.all(38.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text("Current page: ${index + 1}"),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 24.0,
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
              ElevatedButton(
                onPressed: _togglePlayPause,
                child: Text(_isRunning ? 'Pause' : 'Start'),
              ),
              Text(
                "Remaining time: ${_remainingMillis ~/ 1000 ~/ 60}:${(_remainingMillis ~/ 1000 % 60).toString().padLeft(2, '0')}",
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
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_isRunning) {
        _audioPlayer.pause();
        _isPaused = true;
        _isRunning = false;
      } else {
        _isPaused = false;
        _startTimer();
        _audioPlayer.play();
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
    if (_userSettingsData.prayerSoundEnabled) {
      pageAudioPlayer();
    } else if (_currentPage > 0 && _userSettingsData.autoPageTurn) {
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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32.0,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == tabController.length - 1) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
