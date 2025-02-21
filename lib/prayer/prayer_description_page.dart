import 'package:flutter/material.dart';

import '../data/prayer.dart';
import '../data/prayer_group.dart';
import 'prayer_image.dart';
import 'prayer_settings_page.dart';
import 'prayer_text.dart';

class PrayerDescriptionPage extends StatelessWidget {
  const PrayerDescriptionPage({
    super.key,
    required this.group,
    required this.prayer,
  });

  final PrayerGroup group;
  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: screenSize.height * 0.3,
            flexibleSpace: FlexibleSpaceBar(
              title: screenSize.width > 600
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: group.title),
                          TextSpan(
                            text: ' / ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          TextSpan(text: prayer.title),
                        ],
                      ),
                    )
                  : Text(prayer.title),
              background: PrayerImage(
                name: prayer.image,
                opacity: const AlwaysStoppedAnimation(.3),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverToBoxAdapter(
            child: PrayerText(
              prayer.description,
              padding: const EdgeInsets.fromLTRB(
                16,
                32,
                16,
                kMinInteractiveDimension * 2,
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
}
