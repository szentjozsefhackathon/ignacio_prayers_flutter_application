import 'package:flutter/material.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';
import '../data_descriptors/data_list.dart'; // Import Json data descriptors
import '../settings/settings_page.dart';
import 'dart:io';
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.description,
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerSettingsPage(prayer: prayer, dataManager: dataManager),
                      ),
                    );
                  },
                  child: Text("Setup Prayer"),
                ),
              ],
            ),
          ),
        ),
      );
  }
}