import 'dart:convert';

import 'package:logging/logging.dart';

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
  DataManager._();

  static DataManager? _instance;
  // ignore: prefer_constructors_over_static_methods
  static DataManager get instance => _instance ??= DataManager._();

  DataSetManager<Versions> get versions => _versions;
  ListDataSetManager<PrayerGroup> get prayerGroups => _prayerGroups;
  MediaManager get images => _images;
  MediaManager get voices => _voices;

  static final log = Logger('DataManager');

  final _versions = DataSetManager<Versions>(
    dataKey: _kVersions,
    dataUrlEndpoint: Uri.parse(kCheckVersionUrl),
    fromJson: Versions.fromJson,
  );

  final _prayerGroups = ListDataSetManager<PrayerGroup>(
    dataKey: _kPrayerGroup,
    dataUrlEndpoint: Uri.parse(kDownloadDataUrl),
    fromJson: PrayerGroup.fromJson,
  );

  final _images = MediaManager(
    dataKey: _kImages,
    dataUrlEndpoint: Uri.parse(kImageListUrl),
  );

  final _voices = MediaManager(
    dataKey: _kVoices,
    dataUrlEndpoint: Uri.parse(kVoicesListUrl),
  );

  Future<void> checkForUpdates({required bool stopOnError}) async {
    // Load local version data
    bool saveVersions = false;
    bool success;
    try {
      final localVersionsExist = await _versions.localDataExists;
      final localVersions = localVersionsExist ? (await _versions.data) : null;
      log.info('Local versions: ${localVersions?.toJson()}');
      // Load server version data
      final serverVersions = await _versions.serverData;
      log.info('Server versions: ${serverVersions.toJson()}');

      // Check if the data needs to be updated
      if (localVersions?.data != serverVersions.data) {
        await _prayerGroups.downloadAndSaveData();
        await _prayerGroups.data; // new data applied
        log.info(
          'Updating data from version ${localVersions?.data} to ${serverVersions.data}',
        );
        saveVersions = true;
      }

      // Check if the map data needs to be updated
      if (localVersions?.images != serverVersions.images) {
        final imagesServerDatas = await _images.serverData;

        success = await _images.syncFiles(
          imagesServerDatas,
          stopOnError: stopOnError,
        );
        if (success) {
          log.info(
            'Image files updated from version ${localVersions?.images} to ${serverVersions.images}',
          );
          saveVersions = true;
        } else if (localVersions?.images.isNotEmpty ?? true) {
          serverVersions.images = '';
          saveVersions = true;
        }
      }

      // Check if the voices need to be updated
      if (localVersions?.voices != serverVersions.voices) {
        final voicesServerDatas = await _voices.serverData;

        success = await _images.syncFiles(
          voicesServerDatas,
          stopOnError: stopOnError,
        );
        if (success) {
          log.info(
            'Voice files updated from version ${localVersions?.voices} to ${serverVersions.voices}',
          );
          saveVersions = true;
        } else if (localVersions?.voices.isNotEmpty ?? true) {
          serverVersions.voices = '';
          saveVersions = true;
        }
      }

      // Save the new version data
      if (saveVersions) {
        await _versions.saveLocalData(
          json.encoder.convert(serverVersions.toJson()),
        );
        final newLocalVersions = await _versions.data;
        log.info(
          'Local versions updated to ${newLocalVersions.toJson()}',
        );
      }
    } catch (e) {
      // log.warning('Failed to load local data: $e');
      rethrow;
    }
  }
}
