import 'package:flutter/material.dart';

import '../data/prayer_group.dart';
import '../data_handlers/data_manager.dart';
import '../routes.dart';

class PrayersPage extends StatelessWidget {
  const PrayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final group = context.getRouteArgument<PrayerGroup>();

    return Scaffold(
      appBar: AppBar(title: Text(group.title)),
      body: group.prayers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 8,
                mainAxisExtent: 200,
                crossAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: group.prayers.length,
              itemBuilder: (context, index) {
                final prayer = group.prayers[index];
                return Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.prayerDescription,
                      arguments: prayer,
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: FutureBuilder(
                            future: DataManager.instance.images
                                .getLocalFile(prayer.image),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                // !snapshot.data!.existsSync()
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              } else {
                                return Image.file(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                        ),
                        // Overlay for Title
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
    );
  }
}
