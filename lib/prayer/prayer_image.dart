import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data_handlers/data_manager.dart';

class PrayerImage extends StatelessWidget {
  const PrayerImage({
    super.key,
    required this.name,
    this.opacity,
  });

  final String name;
  final Animation<double>? opacity;

  Widget _buildError() => const Center(
        child: Icon(
          Icons.broken_image,
          size: 50,
          color: Colors.grey,
        ),
      );

  Widget _buildLoading([double? progress]) => Center(
        child: CircularProgressIndicator(value: progress),
      );

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        DataManager.instance.images.getDownloadUri(name).toString(),
        fit: BoxFit.cover,
        opacity: opacity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return _buildLoading(
            progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          );
        },
        errorBuilder: (context, error, stack) => _buildError(),
      );
    }

    return FutureBuilder(
      future: DataManager.instance.images.getLocalFile(name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          // !snapshot.data!.existsSync()
          return _buildError();
        }
        return Image.file(
          snapshot.data!,
          fit: BoxFit.cover,
          opacity: opacity,
          errorBuilder: (context, error, stack) => _buildError(),
        );
      },
    );
  }
}
