import 'dart:convert';

import 'package:logging/logging.dart';

import '../data/media_data.dart';
import '../data/prayer_group.dart';
import '../data/versions.dart';
import '../urls.dart';
import 'data_set_manager.dart';
import 'media_manager.dart';

// TODO: make this a povider

const _kPrayerGroup = 'prayerGroupsData';
const _kVersions = 'versionsData';
const _kImages = 'images';
const _kVoices = 'voices';

class DataManager {
  static final log = Logger('DataManager');

  // initialize the data managers
  // versionsDataManager is used to manage the versions data
  final _versionsDataManager = DataSetManager<Versions>(
    dataKey: _kVersions,
    dataUrlEndpoint: Uri.parse(kCheckVersionUrl),
    fromJson: Versions.fromJson,
    dataType: DataType.single,
  );

  // prayerGroupDataManager is used to manage the prayer group data
  final _prayerGroupDataManager = DataSetManager<PrayerGroup>(
    dataKey: _kPrayerGroup,
    dataUrlEndpoint: Uri.parse(kDownloadDataUrl),
    fromJson: PrayerGroup.fromJson,
    dataType: DataType.list,
  );

  // imagesDataManager is used to manage the images data
  final _imagesDataManager = DataSetManager<MediaData>(
    dataKey: _kImages,
    dataUrlEndpoint: Uri.parse(kImageListUrl),
    fromJson: MediaData.fromJson,
    dataType: DataType.list,
  );

  // voicesDataManager is used to manage the voices data
  final _voicesDataManager = DataSetManager<MediaData>(
    dataKey: _kVoices,
    dataUrlEndpoint: Uri.parse(kVoicesListUrl),
    fromJson: MediaData.fromJson,
    dataType: DataType.list,
  );

  final MediaManager _imagesManager = MediaManager(mediaType: _kImages);

  final MediaManager _voicesManager = MediaManager(mediaType: _kVoices);

  Future<void> checkForUpdates() async {
    // Load local version data
    bool updated = false;
    try {
      final localVersions = await _versionsDataManager.data;
      log.info('Local versions data : ${localVersions.toJson()}');
      // Load server version data
      final serverVersions = await _versionsDataManager.serverData;
      log.info('Server versions data : ${serverVersions.toJson()}');

      // Check if the data needs to be updated
      if (localVersions.data != serverVersions.data) {
        await _prayerGroupDataManager.downloadAndSaveData();
        await _prayerGroupDataManager.data; // new data applied
        log.info(
          'Local data updated from version ${localVersions.data} to ${serverVersions.data}',
        );
        updated = true;
      }

      // Check if the map data needs to be updated
      if (localVersions.images != serverVersions.images) {
        final imagesServerDatas = await _imagesDataManager.serverData;

        await imagesManager.syncFiles(imagesServerDatas);
        log.info(
          'Image files updated from version ${localVersions.images} to ${serverVersions.images}',
        );
        updated = true;
      }

      // Check if the voices need to be updated
      if (localVersions.voices != serverVersions.voices) {
        final voicesServerDatas = await _voicesDataManager.serverData;

        await voicesManager.syncFiles(voicesServerDatas);
        log.info(
          'Voice files updated from version ${localVersions.voices} to ${serverVersions.voices}',
        );
        updated = true;
      }

      // Save the new version data
      if (updated) {
        await _versionsDataManager.saveLocalData(
          json.encoder.convert(serverVersions.toJson()),
        );
        final newLocalVersions = await _versionsDataManager.data;
        log.info(
          'Local versions data updated to : ${newLocalVersions.toJson()}',
        );
      }
    } catch (e) {
      // log.warning('Failed to load local data: $e');
      rethrow;
    }
  }

  DataSetManager<PrayerGroup> get prayerGroupDataManager =>
      _prayerGroupDataManager;
  // DataSetManager<MediaData> get imagesDataManager => _imagesDataManager;
  // DataSetManager<MediaData> get voicesDataManager => _voicesDataManager;
  MediaManager get imagesManager => _imagesManager;
  MediaManager get voicesManager => _voicesManager;
}
