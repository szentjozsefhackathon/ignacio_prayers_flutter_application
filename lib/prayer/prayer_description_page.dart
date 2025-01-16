import 'package:flutter/material.dart';

import '../data/prayer.dart';
import '../data_handlers/data_manager.dart';
import 'prayer_settings_page.dart';

class PrayerDescriptionPage extends StatelessWidget {
  const PrayerDescriptionPage({
    super.key,
    required this.prayer,
    required this.dataManager,
  });

  final Prayer prayer;
  final DataManager dataManager;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(prayer.title),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            kMinInteractiveDimension * 2,
          ),
          child: Center(
            child: SizedBox(
              width: 600,
              child: Text(
                prayer.description,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrayerSettingsPage(
                prayer: prayer,
                dataManager: dataManager,
              ),
            ),
          ),
          tooltip: 'Ima beállítása',
          child: const Icon(Icons.check_rounded),
        ),
      );
}
