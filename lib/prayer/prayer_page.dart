import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';
import '../data_descriptors/prayer_step.dart';
import 'dart:async';
import '../constants/constants.dart';

class PrayerPage extends StatefulWidget {
  final Prayer prayer;
  final DataManager dataManager;

  const PrayerPage({Key? key, required this.prayer, required this.dataManager})
      : super(key: key);

  @override
  _PrayerPageState createState() => _PrayerPageState();
}


class _PrayerPageState extends State<PrayerPage> with TickerProviderStateMixin{
  late AudioPlayer _audioPlayer;
  late int _timeInMinutes = 20;
  late bool _voiceEnabled = true;
  late bool _automaticPageTurnEnabled = true;
  late bool _dndEnabled = true;
  late List<int> _nextPageTimes = [];
  late int _remainingMillis = 0;
  late int _currentPage = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this); //TODO: Implement dynamic length
    _loadPreferences();
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

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timeInMinutes = prefs.getInt(PAYER_LEN_KEY) ?? 20;
      _voiceEnabled = prefs.getBool(SOUND_SWITCH_KEY) ?? false;
      _automaticPageTurnEnabled = prefs.getBool(AUTO_PAGE_TURN_SWITCH_KEY) ?? true;
      _dndEnabled = prefs.getBool(DND_KEY) ?? false;
    });
  }

  void _startPrayer() {
    _nextPageTimes = _getOptimalPageTimes();
    _remainingMillis = _timeInMinutes * 60 * 1000;
    _startTimer();
    if (_dndEnabled) _doNotDisturbOn();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
      } else {
        setState(() {
          _remainingMillis -= 1000;
          if (_automaticPageTurnEnabled) {
            for (int time in _nextPageTimes) {
              if (time == _remainingMillis ~/ 1000) {
                _currentPage++;
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

  void _onTimerFinish() {
    setState(() {
      _isRunning = false;
    });
    _audioPlayer.stop();
    widget.dataManager.voicesManager.getLocalFile('csengo.mp3').then((file) {
      _audioPlayer.setAsset(file.path);
    });
    _audioPlayer.setVolume(1.0);
    _audioPlayer.play();
    Vibration.vibrate(duration: 500);
    if (_dndEnabled) _doNotDisturbOff();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void _turnPage() {
    setState(() {
      _currentPage++;
      _audioPlayer.stop();
      if (_voiceEnabled) {
        widget.dataManager.voicesManager.getLocalFile(widget.prayer.steps[_currentPage].voices[0]).then((file) {  // TODO: Implement voice selection
          _audioPlayer.setAsset(file.path);
        });
        _audioPlayer.setVolume(1.0);
        _audioPlayer.play();
      } else if (_currentPage > 0 && _automaticPageTurnEnabled) {
        Vibration.vibrate(duration: 500);
      }
    });
  }

  List<int> _getOptimalPageTimes() {
    List<int> pageTimes = [];
    int totalFixTime = 0;
    int totalFlexTime = 0;
    for (var step in widget.prayer.steps) {
      if (step.type == PrayerStepType.FIX) {
        totalFixTime += step.timeInSeconds;
      } else if (step.type == PrayerStepType.FLEX) {
        totalFlexTime += step.timeInSeconds;
      }
    }
    int totalTimeForFlex = _timeInMinutes * 60 - totalFixTime;
    int remainingTime = _timeInMinutes * 60;
    for (var step in widget.prayer.steps) {
      if (step.type == PrayerStepType.FIX) {
        remainingTime -= step.timeInSeconds;
      } else if (step.type == PrayerStepType.FLEX) {
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
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      // appBar: AppBar(
      //   title: Text("Prayer ${widget.prayer.title}"),
      // ),
      children: <Widget>[
        PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Current page: ${_currentPage + 1}"),
                  Text(widget.prayer.steps[_currentPage].description),
                  Text("Prayer in progress..."),
                  Text("Remaining time: ${_remainingMillis ~/ 1000 ~/ 60}:${(_remainingMillis ~/ 1000 % 60).toString().padLeft(2, '0')}"),
                  ElevatedButton(
                    onPressed: _togglePlayPause,
                    child: Text(_isRunning ? 'Pause' : 'Start'),
                  ),
                ],
              ),
            ),
            Center(
              child: Text('Second Page', style: textTheme.titleLarge),
            ),
            Center(
              child: Text('Third Page', style: textTheme.titleLarge),
            ),
          ],
        ),
        PageIndicator(
          tabController: _tabController,
          currentPageIndex: _currentPageIndex,
          onUpdateCurrentPageIndex: _updateCurrentPageIndex,
          isOnDesktopAndWeb: _isOnDesktopAndWeb,
        ),
      ],
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
      _currentPageIndex = currentPageIndex;
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
              if (currentPageIndex == 2) {
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
