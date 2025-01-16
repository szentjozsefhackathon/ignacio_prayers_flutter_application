import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/constants.dart';
import '../data/common.dart';
import '../data/media_data.dart';

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
    await Future.forEach(filesToDelete, (file) async {
      await _deleteFile(file.name);
    });

    // Find files to update
    final filesToAddOrUpdate = serverMediaDatas.where((serverFile) {
      // Find the corresponding local file
      final localFile = localMediaDatas.firstWhere(
        (file) => file.name == serverFile.name,
        orElse: () => MediaData(
          name: '',
          path: '',
          size: 0,
          lastModified: DateTime(0),
        ), // Return empty if missing from local
      );
      // Check if the file does not exist locally or if the server file is newer
      return localFile.name == '' ||
          serverFile.lastModified.isAfter(
            localFile.lastModified,
          ); // Return true if file is missing or newer
    }).toList();

    // Add or update files
    // TODO: how to reduce http requests?
    await Future.forEach(filesToAddOrUpdate, (file) async {
      await _downloadAndSaveImage(file.name);
    });
  }

  Future<List<MediaData>> get _localMediaData async {
    final appDirectoryPath = await _localPath;
    final directory = Directory(appDirectoryPath);

    final mediaDataList = <MediaData>[];

    if (await directory.exists()) {
      await for (final entity
          in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final fileStat = await entity.stat();
          final mediaData = MediaData(
            name: entity.uri.pathSegments.last,
            path: entity.path,
            size: fileStat.size,
            lastModified: fileStat.modified,
          );
          mediaDataList.add(mediaData);
        }
      }
    } else {
      log.warning('Directory does not exist: $appDirectoryPath');
    }

    return mediaDataList;
  }

  Future<void> _downloadAndSaveImage(String filename) async {
    final downloadUrl = _getDownloadUrl(filename);

    try {
      final response = await http.get(downloadUrl);
      if (response.statusCode == 200) {
        await _saveFile(filename, response.bodyBytes);
      } else {
        log.severe('Error downloading file: $filename');
        throw Exception('Failed to fetch data from server');
      }
    } catch (e) {
      log.severe('Error during sync: $e');
    }
  }

  Uri _getDownloadUrl(String filename) =>
      Uri.parse('$kServerUrl/$kMediaApiUrl/$mediaType/$filename');

  Future<void> _saveFile(String filename, Uint8List imageBytes) async {
    try {
      final file = await getLocalFile(filename);
      await file.writeAsBytes(imageBytes);
    } catch (e) {
      log.severe('Error saving file: $e');
    }
  }

  Future<void> _deleteFile(filename) async {
    try {
      final file = await getLocalFile(filename);
      await file.delete();
    } catch (e) {
      log.severe('Error deleting file: $e');
    }
  }

  Future<dynamic> getFile(String filename) async {
    if (kIsWeb) {
      // Return the URL for web
      return _getDownloadUrl(filename).toString();
    } else {
      // Return the local file for non-web platforms
      final file = await getLocalFile(filename);
      return file;
    }
  }

  Future<File> getLocalFile(filename) async {
    final appDirectoryPath = await _localPath;
    // TODO p.join(appDirectoryPath, filename);
    final fullPath = '$appDirectoryPath/$filename';
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
