import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

// Local imports
import '../data_descriptors/prayer_group.dart'; // Import Json data descriptors
import '../data_descriptors/versions.dart'; // Import Json data descriptors
import '../data_descriptors/media_data.dart'; // Import Json data descriptors for the media data
import 'data_set_manager.dart';
import '../constants/constants.dart'; // Import the constants file
import 'media_manager.dart';

// TODO: make this a povider
class DataManager {
  final log = Logger('DataHandler');


  DataManager() {
    _setupLogging();
  }

  // initialize the data managers
  // versionsDataManager is used to manage the versions data
  final DataSetManager<Versions> _versionsDataManager = DataSetManager<Versions>(
      dataKey: VERSIONS_KEY,
      dataUrlEndpoint: CHECK_VERSION_URL_ENDPOINT,
      fromJson: Versions.fromJson,
      dataType: DataType.single,
    );
  
  // prayerGroupDataManager is used to manage the prayer group data
  final DataSetManager<PrayerGroup> _prayerGroupDataManager = DataSetManager<PrayerGroup>(
      dataKey: PRAYER_GROUP_KEY,
      dataUrlEndpoint: DOWNLOAD_DATA_URL_ENDPOINT,
      fromJson: PrayerGroup.fromJson,
      dataType: DataType.list,
    );

  // imagesDataManager is used to manage the images data
  final DataSetManager<MediaData> _imagesDataManager = DataSetManager<MediaData>(
      dataKey: IMAGES_KEY,
      dataUrlEndpoint: GET_IMAGE_LIST_URL_ENDPOINT,
      fromJson: MediaData.fromJson,
      dataType: DataType.list,
    );

  // voicesDataManager is used to manage the voices data
  final DataSetManager<MediaData> _voicesDataManager = DataSetManager<MediaData>(
    dataKey: VOICES_KEY,
    dataUrlEndpoint: GET_VOICES_LIST_URL_ENDPOINT,
    fromJson: MediaData.fromJson,
    dataType: DataType.list,
  );

  final MediaManager _imagesManager = MediaManager(mediaType: IMAGES_KEY);

  final MediaManager _voicesManager = MediaManager(mediaType: VOICES_KEY);

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
      // TODO: dont need this in case of Web app
      await imagesManager.syncFiles(imagesServerDatas);
    }

    // Check if the voices need to be updated
    if (localVersions.voices != serverVersions.voices) {
      final voicesServerDatas = await _voicesDataManager.serverData;
      // TODO: dont need this in case of Web app
      await voicesManager.syncFiles(voicesServerDatas);
    }

    // Save the new version data
    await _versionsDataManager.saveLocalData(json.encoder.convert(serverVersions.toJson()));
  }

  DataSetManager<PrayerGroup> get prayerGroupDataManager => _prayerGroupDataManager;
  // DataSetManager<MediaData> get imagesDataManager => _imagesDataManager;
  // DataSetManager<MediaData> get voicesDataManager => _voicesDataManager;
  MediaManager get imagesManager => _imagesManager;
  MediaManager get voicesManager => _voicesManager;
}

// For Debugging
void main() async {
  DataManager dataManager = DataManager();
  await dataManager.checkForUpdates();
}