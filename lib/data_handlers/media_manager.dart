import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ignacio_prayers_flutter_application/constants/constants.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data_descriptors/media_data.dart'; // Import Json data descriptors for the media data
import '../data_descriptors/data_list.dart'; // Import Json data descriptors
import 'dart:convert';
import 'dart:typed_data';

class MediaManager {
  final log = Logger('MediaManager');
  final String mediaType;

  MediaManager({
    required this.mediaType}){

    _setupLogging();
  
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL; // Set the log level to ALL
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> syncFiles(DataList<MediaData> serverMediaDatas) async {
    // Get local media data from file system
    final localMediaDatas = await _localMediaData;

    // Find files to delete
    final serverFileNames = serverMediaDatas.map((file) => file.name).toSet();
    final filesToDelete = localMediaDatas.where((file) => !serverFileNames.contains(file.name)).toList();
    // Delete files
    await Future.forEach(filesToDelete, (file) async {
      await _deleteFile(file.name);
    });


    // Find files to update
    final filesToAddOrUpdate = serverMediaDatas.where((serverFile) {
      // Find the corresponding local file
      final localFile = localMediaDatas.firstWhere(
        (file) => file.name == serverFile.name,
        orElse: () => MediaData(name: '', path: '', size: 0, lastModified: DateTime(0)), // Return empty if missing from local
      );
      // Check if the file does not exist locally or if the server file is newer
      return localFile.name == '' || serverFile.lastModified.isAfter(localFile.lastModified); // Return true if file is missing or newer
    }).toList();

    // Add or update files
    // TODO: how to reduce http requests?
    await Future.forEach(filesToAddOrUpdate, (file) async {
      await _downloadAndSaveImage(file.name);
    });
  }

  Future<List<MediaData>> get  _localMediaData async {
    final appDirectoryPath = await _localPath;
    final directory = Directory(appDirectoryPath);

    List<MediaData> mediaDataList = [];

    if (await directory.exists()) {
      await for (var entity in directory.list(recursive: true, followLinks: false)) {
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
      final http.Response response = await http.get(downloadUrl);
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

  Uri _getDownloadUrl(String filename) => Uri.parse('$SERVER_URL/$MEDIA_API_URL/$mediaType/$filename');

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
    var fullPath = '$appDirectoryPath/$filename'; // TODO p.join(appDirectoryPath, filename);
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

// For debugging
void main() async {
  final serverJsonData = '[{"name":"csapatbanazigazi.jpg","path":"/app/public/images/csapatbanazigazi.jpg","size":180067,"lastModified":"2025-01-10T10:53:38.000Z"},{"name":"egyeb.jpg","path":"/app/public/images/egyeb.jpg","size":180069,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"eletemritmusa.jpg","path":"/app/public/images/eletemritmusa.jpg","size":219317,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"estiima.jpg","path":"/app/public/images/estiima.jpg","size":68306,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"examen.jpg","path":"/app/public/images/examen.jpg","size":142778,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"ignaciszemlelodes.jpg","path":"/app/public/images/ignaciszemlelodes.jpg","size":289606,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"lelkiutamon.jpg","path":"/app/public/images/lelkiutamon.jpg","size":192187,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"meditaciosima.jpg","path":"/app/public/images/meditaciosima.jpg","size":123743,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"megkulonboztetes.jpg","path":"/app/public/images/megkulonboztetes.jpg","size":75492,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"mindennapokfokusza.jpg","path":"/app/public/images/mindennapokfokusza.jpg","size":165252,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"reflektalvatanulni.jpg","path":"/app/public/images/reflektalvatanulni.jpg","size":120419,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"ritmikusimamod.jpg","path":"/app/public/images/ritmikusimamod.jpg","size":267682,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"szentiras.jpg","path":"/app/public/images/szentiras.jpg","size":78509,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"szivimaja.jpg","path":"/app/public/images/szivimaja.jpg","size":103503,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"temp.jpg","path":"/app/public/images/temp.jpg","size":77068,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"temp2.jpg","path":"/app/public/images/temp2.jpg","size":87361,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"tisztabeszed.jpg","path":"/app/public/images/tisztabeszed.jpg","size":101910,"lastModified":"2024-01-10T10:53:38.000Z"},{"name":"vilagossag.jpg","path":"/app/public/images/vilagossag.jpg","size":154520,"lastModified":"2024-01-10T10:53:38.000Z"}]';

  final serverMediaDatas = DataList<MediaData>.fromJson(json.decode(serverJsonData),MediaData.fromJson);

  MediaManager mediaManager = MediaManager(mediaType: IMAGES_KEY);
  await mediaManager.syncFiles(serverMediaDatas);

}