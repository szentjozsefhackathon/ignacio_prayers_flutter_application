import 'package:flutter/material.dart';

import '../data/prayer.dart';
import '../data/prayer_group.dart';
import 'prayer_image.dart';
import 'prayer_settings_page.dart';

class PrayerDescriptionPage extends StatelessWidget {
  const PrayerDescriptionPage({
    super.key,
    required this.group,
    required this.prayer,
  });

  final PrayerGroup group;
  final Prayer prayer;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              expandedHeight: MediaQuery.of(context).size.height * 0.3,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(prayer.title),
                background: PrayerImage(
                  name: prayer.image,
                  opacity: const AlwaysStoppedAnimation(.3),
                ),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  32,
                  16,
                  kMinInteractiveDimension * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.loose(
                      const Size.fromWidth(600),
                    ),
                    child: Text(
                      prayer.description,
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrayerSettingsPage(prayer: prayer),
            ),
          ),
          tooltip: 'Ima beállítása',
          child: const Icon(Icons.check_rounded),
        ),
      );
}
