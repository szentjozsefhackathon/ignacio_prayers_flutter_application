import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';

export 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;
export 'package:timezone/timezone.dart' show TZDateTime, local;

class Notifications with ChangeNotifier {
  Notifications() {
    tz.initializeTimeZones();

    _n.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Megnyitás'),
        windows: WindowsInitializationSettings(
          appName: 'Ignáci imák',
          appUserModelId: 'hu.jezsuita.ima.ignaci',
          guid: '349fd997-d211-4ac7-9690-8ed1bb184196',
        ),
      ),
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  static final _log = Logger('Notifications');
  final _n = FlutterLocalNotificationsPlugin();

  void _onDidReceiveNotificationResponse(NotificationResponse details) {
    _log.fine('onDidReceiveNotificationResponse payload: ${details.payload}');
  }

  Future<bool?> requestPermissions() async {
    bool? result;
    if (Platform.isAndroid) {
      final impl = _n.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      result = await impl?.requestNotificationsPermission();
      if (result == true) {
        result = await impl?.requestExactAlarmsPermission();
      }
    } else if (Platform.isIOS) {
      result = await _n
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isMacOS) {
      result = await _n
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else {
      throw UnimplementedError(
        'requestPermissions is not implemented on ${Platform.operatingSystem}',
      );
    }
    return result;
  }

  Future<List<PendingNotificationRequest>> get scheduledNotifications =>
      _n.pendingNotificationRequests();

  Future<void> scheduleNotificationAt({
    required TZDateTime dateTime,
    required DateTimeComponents? repeat,
  }) async {
    final pending = await scheduledNotifications;
    final maxId = pending.map((n) => n.id).maxOrNull ?? 0;
    await _n.zonedSchedule(
      maxId + 1,
      'Ignáci ima',
      'Ignáci ima értesítő',
      dateTime,
      const NotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeat,
      payload: '${repeat?.name ?? ''}::${dateTime.toIso8601String()}',
    );
    notifyListeners();
  }

  Future<void> cancel(int id) async {
    await _n.cancel(id);
    notifyListeners();
  }

  Future<void> cancelAll() async {
    await _n.cancelAll();
    notifyListeners();
  }
}

class PendingNotificationTiles extends StatelessWidget {
  const PendingNotificationTiles({super.key});

  static final _dateTimeFormats = {
    DateTimeComponents.time: DateFormat.Hm(),
    DateTimeComponents.dayOfWeekAndTime: DateFormat.EEEEE().add_Hm(),
    DateTimeComponents.dayOfMonthAndTime: DateFormat.d().add_Hm(),
    DateTimeComponents.dateAndTime: DateFormat.Md().add_Hm(),
    null: DateFormat.yMd().add_Hm(),
  };

  static final _repeatNames = {
    DateTimeComponents.time: 'minden nap',
    DateTimeComponents.dayOfWeekAndTime: 'minden héten',
    DateTimeComponents.dayOfMonthAndTime: 'minden hónapban',
    DateTimeComponents.dateAndTime: 'minden évben',
  };

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<Notifications>();
    return FutureBuilder(
      future: notifications.scheduledNotifications,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return const SizedBox();
        }
        return Column(
          children: [
            ...data.map(
              (n) {
                final [repeatName, dateTimeStr] = n.payload!.split('::');
                final repeat = DateTimeComponents.values
                    .singleWhereOrNull((c) => c.name == repeatName);
                final dateTime = DateTime.parse(dateTimeStr);
                final subtitle = _repeatNames[repeat];
                return ListTile(
                  title: Text(_dateTimeFormats[repeat]!.format(dateTime)),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => notifications.cancel(n.id),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
