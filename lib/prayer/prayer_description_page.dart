import 'package:flutter/material.dart';
import 'package:ignacio_prayers_flutter_application/constants/hungarian_language_constants.dart';

import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';
import 'prayer_settings_page.dart';


class PrayerDescriptionPage extends StatelessWidget {
  final Prayer prayer;
  final DataManager dataManager;

  const PrayerDescriptionPage({Key? key, required this.prayer, required this.dataManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                width:600.0,
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
                          builder: (context) => PrayerSettingsPage(prayer: prayer, dataManager: dataManager),
                        ),
                      );
                    },
                    child: const Text(SETUP_PRAYER),
                  ),
              ),
            ],
          ),
        ),
      );
  }
}