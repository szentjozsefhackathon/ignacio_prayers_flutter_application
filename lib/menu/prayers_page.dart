import 'package:flutter/material.dart';

import '../data/prayer_group.dart';
import '../prayer/prayer_image.dart';
import '../routes.dart';

class PrayersPage extends StatelessWidget {
  const PrayersPage({super.key, required this.group});

  final PrayerGroup group;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: MediaQuery.of(context).size.height * 0.3,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(group.title),
            background: PrayerImage(
              name: group.image,
              opacity: const AlwaysStoppedAnimation(.3),
              errorBuilder: null,
            ),
            collapseMode: CollapseMode.parallax,
          ),
        ),
        group.prayers.isEmpty
            ? const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
            : SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 200,
                  mainAxisSpacing: 8,
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 8,
                ),
                itemCount: group.prayers.length,
                itemBuilder: (context, index) {
                  final prayer = group.prayers[index];
                  return Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            Routes.prayer(group, prayer),
                            arguments: [group, prayer],
                          ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: PrayerImage(name: prayer.image),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                prayer.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    ),
  );
}
