import 'package:flutter/material.dart';

import '../data_descriptors/prayer.dart';
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 600.0,
                child: Text(
                  prayer.description,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerSettingsPage(
                          prayer: prayer,
                          dataManager: dataManager,
                        ),
                      ),
                    );
                  },
                  child: const Text('Setup Prayer'),
                ),
              ),
            ],
          ),
        ),
      );
}
