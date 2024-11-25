import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer.dart';


class PrayerPage extends StatelessWidget {
  final Prayer prayer;
  final DataManager dataManager;

  const PrayerPage({Key? key, required this.prayer, required this.dataManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prayer ${prayer.title}"),
      ),
      body: Center(
        child: Text("Prayer in progress..."),
      ),
    );
  }
}
