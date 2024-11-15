import 'dart:ffi';

import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Local imports
import '../data_descriptors/prayer_group.dart'; // Import Json data descriptors
import '../data_descriptors/versions.dart'; // Import Json data descriptors
import '../data_descriptors/media_data.dart'; // Import Json data descriptors for the media data
import 'data_set_manager.dart';
import '../constants.dart'; // Import the constants file
import 'media_manager.dart';

class DataManager {
  final log = Logger('DataHandler');

  // initialize the data managers
  // versionsDataManager is used to manage the versions data
  final DataSetManager<Versions> _versionsDataManager = DataSetManager<Versions>(
      dataKey: versionsKey,
      dataUrlEndpoint: checkVersionUrlEndpoint,
      fromJson: Versions.fromJson,
      dataType: DataType.single,
    );
  
  // prayerGroupDataManager is used to manage the prayer group data
  final DataSetManager<PrayerGroup> _prayerGroupDataManager = DataSetManager<PrayerGroup>(
      dataKey: prayerGroupsKey,
      dataUrlEndpoint: downloadDataUrlEndpoint,
      fromJson: PrayerGroup.fromJson,
      dataType: DataType.list,
    );

  // imagesDataManager is used to manage the images data
  final DataSetManager<MediaData> _imagesDataManager = DataSetManager<MediaData>(
      dataKey: imagesKey,
      dataUrlEndpoint: getImagesListUrlEndpoint,
      fromJson: MediaData.fromJson,
      dataType: DataType.list,
    );

  // voicesDataManager is used to manage the voices data
  final DataSetManager<MediaData> _voicesDataManager = DataSetManager<MediaData>(
    dataKey: voicesKey,
    dataUrlEndpoint: getVoicesListUrlEndpoint,
    fromJson: MediaData.fromJson,
    dataType: DataType.list,
  );

  DataManager() {
    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL; // Set the log level to ALL
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> checkForUpdates() async { //TODO: test internet if it can connect to server, try catch and load data again
    // Load local version data
    final localVersions = await _versionsDataManager.data;
    // Load server version data
    final serverVersions = await _versionsDataManager.serverData;

    // Check if the data needs to be updated
    if (localVersions.data != serverVersions.data) {
      await _prayerGroupDataManager.downloadAndSaveData();
      await _prayerGroupDataManager.data; // new data applied
    }

    // Check if the map data needs to be updated
    if (localVersions.images != serverVersions.images) {
      final imagesServerDatas = await _imagesDataManager.serverData;
      MediaManager imagesManager = MediaManager(serverMediaDatas: imagesServerDatas, mediaType: imagesKey);
      await imagesManager.syncFiles();
    }

    // Check if the voices need to be updated
    if (localVersions.voices != serverVersions.voices) {
      final voicesServerDatas = await _voicesDataManager.serverData;
      MediaManager voicesManager = MediaManager(serverMediaDatas: voicesServerDatas, mediaType: voicesKey);
      await voicesManager.syncFiles();
    }

    // Save the new version data
    await _versionsDataManager.saveLocalData(json.encoder.convert(serverVersions.toJson()));
  }

  DataSetManager<PrayerGroup> get prayerGroupDataManager => _prayerGroupDataManager;
  DataSetManager<MediaData> get imagesDataManager => _imagesDataManager;
  DataSetManager<MediaData> get voicesDataManager => _voicesDataManager;
}

// For Debugging
void main() async {
  DataManager dataManager = DataManager();
  await dataManager.checkForUpdates();
}