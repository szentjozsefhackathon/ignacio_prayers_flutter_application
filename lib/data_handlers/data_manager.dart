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

  Versions? _localVersions;
  Versions? get localVersions => _localVersions;

  DateTime? _lastUpdateCheck;
  DateTime? get lastUpdateCheck => _lastUpdateCheck;

  Future<void> _updateLocalVersions(Versions newLocalVersions) async {
    final map = newLocalVersions.toJson();
    await _versions.saveLocalData(json.encode(map));
    _localVersions = newLocalVersions;
    log.info('Local versions updated to $map');
  }

  Future<Versions> checkForUpdates({required bool stopOnError}) async {
    final localVersionsExist = await _versions.localDataExists;
    _localVersions = localVersionsExist ? (await _versions.data) : null;
    log.info('Local versions: ${_localVersions?.toJson()}');

    // Load server version data
    final serverVersions = await _versions.serverData;
    log.info('Server versions: ${serverVersions.toJson()}');

    _lastUpdateCheck = DateTime.now();

    // Check if the data needs to be updated
    final oldVersion = _localVersions?.data;
    final newVersion = serverVersions.data;
    if (oldVersion != newVersion) {
      await _prayerGroups.downloadAndSaveData();
      await _prayerGroups.data; // new data applied
      log.info('Updating data from version $oldVersion to $newVersion');
      await _updateLocalVersions(
        _localVersions == null
            ? serverVersions.copyWith(images: '', voices: '')
            : _localVersions!.copyWith(data: newVersion),
      );
    }
    return serverVersions;
  }

  Future<bool> updateImages(Versions serverVersions) async {
    final oldVersion = _localVersions?.images;
    final newVersion = serverVersions.images;
    if (oldVersion != newVersion) {
      final serverData = await _images.serverData;
      if (await _images.syncFiles(serverData, stopOnError: true)) {
        log.info('Image files updated from version $oldVersion to $newVersion');
        await _updateLocalVersions(
          _localVersions == null
              ? serverVersions.copyWith(images: newVersion, voices: '')
              : _localVersions!.copyWith(images: newVersion),
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> updateVoices(Versions serverVersions) async {
    final oldVersion = _localVersions?.voices;
    final newVersion = serverVersions.voices;
    if (oldVersion != newVersion) {
      final serverData = await _voices.serverData;
      if (await _voices.syncFiles(serverData, stopOnError: true)) {
        log.info('Voice files updated from version $oldVersion to $newVersion');
        await _updateLocalVersions(
          _localVersions == null
              ? serverVersions.copyWith(voices: newVersion, images: '')
              : _localVersions!.copyWith(voices: newVersion),
        );
        return true;
      }
    }
    return false;
  }
}
