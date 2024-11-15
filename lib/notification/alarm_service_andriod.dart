// alarm_service_android.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';

void initializeAlarmService() async {
  // Ensure that plugin services are initialized so that `AndroidAlarmManager` can be used.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the AndroidAlarmManager plugin.
  await AndroidAlarmManager.initialize();
}

void setAlarm() {
  // Schedule the alarm to run after 3 seconds.
  AndroidAlarmManager.oneShot(
    const Duration(seconds: 3),
    // Ensure we have a unique alarm ID.
    0,
    alarmCallback,
    exact: true,
    wakeup: true,
  );
}

// The callback function that will be called when the alarm triggers.
void alarmCallback() {
  print('Alarm triggered on Android!');
}