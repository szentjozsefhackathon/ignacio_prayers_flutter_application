import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({super.key, required this.alarmSettings});

  final AlarmSettings alarmSettings;

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isRinging = await Alarm.isRinging(widget.alarmSettings.id);
      if (isRinging) {
        alarmPrint('Alarm ${widget.alarmSettings.id} is still ringing...');
        return;
      }

      alarmPrint('Alarm ${widget.alarmSettings.id} stopped ringing.');
      timer.cancel();
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'You alarm (${widget.alarmSettings.id}) is ringing...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                '🔔🙏',
                style: TextStyle(fontSize: 50),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RawMaterialButton(
                    onPressed: () => Alarm.set(
                      alarmSettings: widget.alarmSettings.copyWith(
                        dateTime: DateTime.now().add(
                          const Duration(minutes: 1),
                        ),
                      ),
                    ),
                    child: Text(
                      'Snooze',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () => Alarm.stop(widget.alarmSettings.id),
                    child: Text(
                      'Stop',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
