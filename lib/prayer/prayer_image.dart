import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data_handlers/data_manager.dart';

class PrayerImage extends StatelessWidget {
  const PrayerImage({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        DataManager.instance.images.getDownloadUri(name).toString(),
      );
    }

    return FutureBuilder(
      future: DataManager.instance.images.getLocalFile(name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
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
    );
  }
}
