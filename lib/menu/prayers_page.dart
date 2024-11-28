// lib/page_two.dart
import 'package:flutter/material.dart';
import 'package:ignacio_prayers_flutter_application/data_descriptors/prayer.dart';
import '../data_handlers/data_manager.dart';
import '../prayer/prayer_description_page.dart';
import 'package:grouped_list/grouped_list.dart';
import 'dart:io';

class PrayersPage extends StatelessWidget {
  final List<Prayer> prayers;
  final String title;
  final DataManager dataManager;

  PrayersPage({required this.title, required this.prayers, required this.dataManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title)
        ),
        body: ListView.builder(
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            dataManager.imagesManager.getLocalFile(prayer.image);
            return ListTile(
              title: Text(prayer.title),
              subtitle: Text(prayer.description),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrayerDescriptionPage(
                      prayer: prayer,
                      dataManager: dataManager,
                      ),
                    ),
                );
              },
            );
          },
        ),
    );
  }
}