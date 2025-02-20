import 'package:flutter/material.dart';

import '../data/prayer.dart';
import '../routes.dart';

class PrayerDescriptionPage extends StatelessWidget {
  const PrayerDescriptionPage({
    super.key,
    required this.prayer,
  });

  final Prayer prayer;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(prayer.title),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              kMinInteractiveDimension * 2,
            ),
            child: Container(
              constraints: BoxConstraints.loose(const Size.fromWidth(600)),
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
          onPressed: () => Navigator.pushNamed(
            context,
            Routes.prayerSettings(prayer),
            arguments: prayer,
          ),
          tooltip: 'Ima beállítása',
          child: const Icon(Icons.check_rounded),
        ),
      );
}
