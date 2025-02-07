import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data/common.dart';
import '../data/media_data.dart';
import '../urls.dart';
import 'data_set_manager.dart';

class MediaManager extends ListDataSetManager<MediaData> {
  MediaManager({
    required super.dataKey,
    required super.dataUrlEndpoint,
  }) : super(fromJson: MediaData.fromJson);

  Future<bool> syncFiles(
    DataList<MediaData> serverFiles, {
    required bool stopOnError,
  }) async {
    // Get local media data from file system
    final localFiles = await _localFiles;

    // Find files to delete
    final serverFileNames = serverFiles.map((file) => file.name).toSet();
    final filesToDelete = localFiles
        .where((file) => !serverFileNames.contains(file.name))
        .toList();
    // Delete files
    await Future.forEach(filesToDelete, _deleteFile);

    // Find files to update
    final filesToAddOrUpdate = serverFiles.where((serverFile) {
      // Find the corresponding local file
      final localFile = localFiles.firstWhereOrNull(
        (file) => file.name == serverFile.name,
      );
      // Check if the file does not exist locally or if the server file is newer
      return localFile == null ||
          serverFile.lastModified.isAfter(localFile.lastModified);
    }).toList();

    // Add or update files
    // TODO: how to reduce http requests?
    bool success = true;
    for (final file in filesToAddOrUpdate) {
      success &= await _downloadAndSaveFile(file);
      if (!success && stopOnError) {
        return false;
      }
    }
    return success;
  }

  Future<List<MediaData>> get _localFiles async {
    final appDirectoryPath = await _localPath;
    final directory = Directory(appDirectoryPath);

    final list = <MediaData>[];
    if (await directory.exists()) {
      final files = directory
          .list(recursive: true, followLinks: false)
          .where((entity) => entity is File);
      await for (final file in files) {
        final fileStat = await file.stat();
        list.add(
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

    return list;
  }

  Future<bool> _downloadAndSaveFile(MediaData m) async {
    try {
      final response = await http.get(Uri.parse(mediaApiUrl(dataKey, m.name)));
      if (response.statusCode == 200) {
        return await _saveFile(m, response.bodyBytes);
      } else {
        log.severe('Failed to download file: $m');
      }
    } catch (e) {
      log.severe('Error during sync $m: $e');
    }
    return false;
  }

  Future<bool> _saveFile(MediaData m, Uint8List bytes) async {
    try {
      final file = await getLocalFile(m.name);
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      log.severe('Error saving file $m: $e');
    }
    return false;
  }

  Future<bool> _deleteFile(MediaData m) async {
    try {
      final file = await getLocalFile(m.name);
      await file.delete();
      return true;
    } catch (e) {
      log.severe('Error deleting file $m: $e');
    }
    return false;
  }

  Future<File> getLocalFile(String name) async {
    final appDirectoryPath = await _localPath;
    // TODO p.join(appDirectoryPath, filename);
    final fullPath = '$appDirectoryPath/$name';
    return File(fullPath);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = '${directory.path}/$dataKey';
    await ensureDirectoryExists(directoryPath);
    return directoryPath;
  }

  Future<void> ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      // log.info('Directory exists: $directoryPath');
    } else {
      await directory.create(recursive: true);
      log.info('Directory created: $directoryPath');
    }
  }

  @override
  Future<void> deleteLocalData() async {
    final localFiles = await _localFiles;
    await Future.forEach(localFiles, _deleteFile);
    return super.deleteLocalData();
  }
}
