import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';

import 'theme.dart' show kColorSchemeSeed;

export 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;
export 'package:timezone/timezone.dart' show TZDateTime, local;

class Notifications with ChangeNotifier {
  static final _log = Logger('Notifications');
  final _n = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'emlekezteto',
    'Emlékeztető értesítések',
    importance: Importance.high,
  );

  bool? _hasPermission;
  bool? get hasPermission => _hasPermission;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final initialized = await _n.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
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
    if (initialized != true) {
      return;
    }

    if (Platform.isAndroid) {
      _n
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    _hasPermission = await _checkPermissions();
    notifyListeners();
  }

  void _onDidReceiveNotificationResponse(NotificationResponse details) {
    _log.fine('onDidReceiveNotificationResponse payload: ${details.payload}');
  }

  Future<bool?> _checkPermissions() async {
    bool? result;
    if (Platform.isAndroid) {
      final impl = _n.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      result = await impl?.areNotificationsEnabled();
      if (result == true) {
        result = await impl?.canScheduleExactNotifications();
      }
    } else if (Platform.isIOS) {
      result = await _n
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions()
          .then((r) => r?.isEnabled);
    } else if (Platform.isMacOS) {
      result = await _n
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions()
          .then((r) => r?.isEnabled);
    } else {
      throw UnimplementedError(
        'requestPermissions is not implemented on ${Platform.operatingSystem}',
      );
    }
    return result;
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
    if (result != null && result != _hasPermission) {
      _hasPermission = result;
      notifyListeners();
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
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          color: kColorSchemeSeed,
          priority: Priority.high,
          importance: _androidChannel.importance,
          category: AndroidNotificationCategory.reminder,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
        linux: const LinuxNotificationDetails(
          resident: true,
          urgency: LinuxNotificationUrgency.normal,
        ),
        windows: const WindowsNotificationDetails(
          scenario: WindowsNotificationScenario.reminder,
        ),
      ),
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

class NotificationsSwitchListTile extends StatelessWidget {
  const NotificationsSwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<Notifications>();
    final hasPermission = notifications.hasPermission;
    if (hasPermission == null) {
      return const SizedBox();
    }
    if (!hasPermission) {
      return ListTile(
        title: const Text('Emlékeztető értesítések'),
        subtitle: Text(
          'Hiányzó engedélyek, érintsd meg itt a beállításhoz!',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        onTap: notifications.requestPermissions,
      );
    }
    return SwitchListTile(
      title: const Text('Emlékeztető értesítések'),
      value: value,
      onChanged: (v) {
        onChanged(v);
        if (!v) {
          notifications.cancelAll();
        }
      },
    );
  }
}

const _kRepeatTypes = {
  DateTimeComponents.time: 'minden nap',
  DateTimeComponents.dayOfWeekAndTime: 'minden hét',
  DateTimeComponents.dayOfMonthAndTime: 'minden hónap',
  DateTimeComponents.dateAndTime: 'minden év',
};

final _kRepeatDateFormats = {
  DateTimeComponents.time: DateFormat(),
  DateTimeComponents.dayOfWeekAndTime: DateFormat.EEEE(),
  DateTimeComponents.dayOfMonthAndTime: DateFormat.d(),
  DateTimeComponents.dateAndTime: DateFormat.MMMMd(),
  null: DateFormat.yMMMMd(),
};

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  Widget _buildAdd(BuildContext context, Notifications notifications) {
    final hasPermission = notifications.hasPermission;
    if (hasPermission == null) {
      return const SizedBox();
    }

    return ListTile(
      title: const Text('Emlékeztető hozzáadása'),
      leading: const Icon(Icons.add_rounded),
      enabled: hasPermission && enabled,
      onTap: () async {
        final result = await showModalBottomSheet<_AddBottomSheetResult>(
          context: context,
          builder: (context) => _AddBottomSheet(),
        );
        if (context.mounted && result != null) {
          notifications.scheduleNotificationAt(
            dateTime: result.dateTime,
            repeat: result.repeat,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<Notifications>();
    return FutureBuilder(
      future: notifications.scheduledNotifications,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return _buildAdd(context, notifications);
        }
        return Column(
          children: [
            _buildAdd(context, notifications),
            ...data.map(
              (n) {
                final [repeatName, dateTimeStr] = n.payload!.split('::');
                final repeat = DateTimeComponents.values.singleWhereOrNull(
                  (c) => c.name == repeatName,
                );
                final dateTime = DateTime.parse(dateTimeStr);
                final subtitle = _kRepeatTypes[repeat];
                return ListTile(
                  title: Text(
                    _kRepeatDateFormats[repeat]!.add_Hm().format(dateTime),
                  ),
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

class _AddBottomSheetResult {
  _AddBottomSheetResult({required this.dateTime, required this.repeat});

  final TZDateTime dateTime;
  final DateTimeComponents repeat;
}

class _AddBottomSheet extends StatefulWidget {
  @override
  State<_AddBottomSheet> createState() => _AddBottomSheetState();
}

class _AddBottomSheetState extends State<_AddBottomSheet> {
  DateTimeComponents _repeat = DateTimeComponents.time;
  late TZDateTime _dateTime;

  static final _monthFormat = DateFormat.MMMM();
  static final _weekdayFormat = DateFormat.EEEE();

  @override
  void initState() {
    super.initState();
    _dateTime = TZDateTime.now(local);
  }

  String _monthLabel([int? month]) => _monthFormat
      .format(month == null ? _dateTime : _dateTime.copyWith(month: month));

  String _weekdayLabel([int? weekday]) => _weekdayFormat
      .format(weekday == null ? _dateTime : _dateTime.copyWithWeekday(weekday));

  Widget _chipWithText(Widget chip, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          chip,
          Text(text),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final ml = MaterialLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              PopupMenuButton(
                itemBuilder: (_) => DateTimeComponents.values
                    .map(
                      (d) => PopupMenuItem(
                        value: d,
                        child: Text(_kRepeatTypes[d]!),
                      ),
                    )
                    .toList(growable: false),
                onSelected: (d) => setState(() => _repeat = d),
                child: Chip(
                  label: Text(_kRepeatTypes[_repeat]!),
                ),
              ),
              if (_repeat == DateTimeComponents.dateAndTime)
                PopupMenuButton(
                  itemBuilder: (_) =>
                      List.generate(DateTime.monthsPerYear, (i) => i + 1)
                          .map(
                            (month) => PopupMenuItem(
                              value: month,
                              child: Text(_monthLabel(month)),
                            ),
                          )
                          .toList(growable: false),
                  onSelected: (month) {
                    setState(
                      () => _dateTime = TZDateTime.from(
                        _dateTime.copyWith(month: month),
                        local,
                      ),
                    );
                  },
                  child: Chip(
                    label: Text(_monthLabel()),
                  ),
                ),
              if (_repeat == DateTimeComponents.dayOfWeekAndTime)
                PopupMenuButton(
                  itemBuilder: (_) => List.generate(
                    DateTime.daysPerWeek,
                    (i) => i + ml.firstDayOfWeekIndex,
                  )
                      .map(
                        (offset) => PopupMenuItem(
                          value: offset,
                          child: Text(_weekdayLabel(offset)),
                        ),
                      )
                      .toList(growable: false),
                  onSelected: (offset) {
                    setState(
                      () => _dateTime = TZDateTime.from(
                        _dateTime.copyWithWeekday(offset),
                        local,
                      ),
                    );
                  },
                  child: Chip(
                    label: Text(_weekdayLabel()),
                  ),
                )
              else if (_repeat == DateTimeComponents.dayOfMonthAndTime ||
                  _repeat == DateTimeComponents.dateAndTime)
                _chipWithText(
                  PopupMenuButton(
                    itemBuilder: (_) => List.generate(31, (i) => i + 1)
                        .map(
                          (day) => PopupMenuItem(
                            value: day,
                            child: Text('$day.'),
                          ),
                        )
                        .toList(growable: false),
                    onSelected: (day) {
                      setState(
                        () => _dateTime = TZDateTime.from(
                          _dateTime.copyWith(day: day),
                          local,
                        ),
                      );
                    },
                    child: Chip(
                      label: Text('${_dateTime.day}.'),
                    ),
                  ),
                  'napján',
                ),
              _chipWithText(
                ActionChip(
                  onPressed: () => showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dateTime),
                  ),
                  label:
                      Text(TimeOfDay.fromDateTime(_dateTime).format(context)),
                ),
                '-kor',
              ),
            ],
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  _AddBottomSheetResult(dateTime: _dateTime, repeat: _repeat),
                ),
                child: Text(ml.okButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(ml.cancelButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  DateTime copyWithWeekday(int weekday) => copyWith(
        day: day + weekday - this.weekday,
      );
}
