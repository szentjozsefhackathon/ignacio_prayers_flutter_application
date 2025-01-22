import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../data/common.dart';
import '../data/media_data.dart';
import '../urls.dart';

class MediaManager {
  MediaManager({required this.mediaType});

  static final log = Logger('MediaManager');

  final String mediaType;

  Future<void> syncFiles(DataList<MediaData> serverMediaDatas) async {
    // Get local media data from file system
    final localMediaDatas = await _localMediaData;

    // Find files to delete
    final serverFileNames = serverMediaDatas.map((file) => file.name).toSet();
    final filesToDelete = localMediaDatas
        .where((file) => !serverFileNames.contains(file.name))
        .toList();
    // Delete files
    await Future.forEach(filesToDelete, _deleteFile);

    // Find files to update
    final filesToAddOrUpdate = serverMediaDatas.where((serverFile) {
      // Find the corresponding local file
      final localFile = localMediaDatas.firstWhereOrNull(
        (file) => file.name == serverFile.name,
      );
      // Check if the file does not exist locally or if the server file is newer
      return localFile == null ||
          serverFile.lastModified.isAfter(
            localFile.lastModified,
          );
    }).toList();

    // Add or update files
    // TODO: how to reduce http requests?
    await Future.forEach(filesToAddOrUpdate, _downloadAndSaveImage);
  }

  Future<List<MediaData>> get _localMediaData async {
    final appDirectoryPath = await _localPath;
    final directory = Directory(appDirectoryPath);

    final mediaDataList = <MediaData>[];

    if (await directory.exists()) {
      final files = directory
          .list(recursive: true, followLinks: false)
          .where((entity) => entity is File);
      await for (final file in files) {
        final fileStat = await file.stat();
        mediaDataList.add(
          MediaData(
            name: file.uri.pathSegments.last,
            path: file.path,
            size: fileStat.size,
            lastModified: fileStat.modified,
          ),
        );
      }
    } else {
      log.warning('Directory does not exist: $appDirectoryPath');
    }

    return mediaDataList;
  }

  Future<void> _downloadAndSaveImage(MediaData m) async {
    try {
      final response = await http.get(
        Uri.parse(mediaApiUrl(mediaType, m.name)),
      );
      if (response.statusCode == 200) {
        await _saveFile(m, response.bodyBytes);
      } else {
        log.severe('Error downloading file: $m');
        throw Exception('Failed to fetch data from server');
      }
    } catch (e) {
      log.severe('Error during sync $m: $e');
    }
  }

  Future<void> _saveFile(MediaData m, Uint8List imageBytes) async {
    try {
      final file = await getLocalFile(m.name);
      await file.writeAsBytes(imageBytes);
    } catch (e) {
      log.severe('Error saving file $m: $e');
    }
  }

  Future<void> _deleteFile(MediaData m) async {
    try {
      final file = await getLocalFile(m.name);
      await file.delete();
    } catch (e) {
      log.severe('Error deleting file $m: $e');
    }
  }

  Future<File> getLocalFile(String name) async {
    final appDirectoryPath = await _localPath;
    // TODO p.join(appDirectoryPath, filename);
    final fullPath = '$appDirectoryPath/$name';
    return File(fullPath);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = '${directory.path}/$mediaType';
    await ensureDirectoryExists(directoryPath);
    return directoryPath;
  }

  Future<void> ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      // log.info('Directory exists: $directoryPath');
    } else {
      log.info('Directory does not exist. Creating: $directoryPath');
      await directory.create(recursive: true);
      log.info('Directory created: $directoryPath');
    }
  }
}
