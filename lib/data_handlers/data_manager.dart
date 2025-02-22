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

  DateTime? _lastUpdateCheck;
  DateTime? get lastUpdateCheck => _lastUpdateCheck;

  Future<void> _updateLocalVersions(Versions newLocalVersions) async {
    await _versions.saveLocalData(newLocalVersions);
    log.info('Local versions updated to ${newLocalVersions.toJson()}');
  }

  Future<Versions> checkForUpdates({required bool stopOnError}) async {
    final localVersionsExist = await _versions.localDataExists;
    final localVersions = localVersionsExist ? (await _versions.data) : null;
    log.info('Local versions: ${localVersions?.toJson()}');

    // Load server version data
    final serverVersions = await _versions.serverData;
    log.info('Server versions: ${serverVersions.toJson()}');

    _lastUpdateCheck = DateTime.now();

    // Check if the data needs to be updated
    final oldVersion = localVersions?.data;
    final newVersion = serverVersions.data;
    if (oldVersion != newVersion) {
      await _prayerGroups.downloadAndSaveData();
      log.info('Updating data from version $oldVersion to $newVersion');
      await _updateLocalVersions(
        localVersions == null
            ? serverVersions.copyWith(images: '', voices: '')
            : localVersions.copyWith(data: newVersion),
      );
    }
    return serverVersions;
  }

  Future<bool> updateImages(Versions serverVersions) async {
    final localVersions = _versions.cachedLocalData;
    final oldVersion = localVersions?.images;
    final newVersion = serverVersions.images;
    if (oldVersion != newVersion) {
      final serverData = await _images.serverData;
      if (await _images.syncFiles(serverData, stopOnError: true)) {
        log.info('Image files updated from version $oldVersion to $newVersion');
        await _updateLocalVersions(
          localVersions == null
              ? serverVersions.copyWith(images: newVersion, voices: '')
              : localVersions.copyWith(images: newVersion),
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> updateVoices(Versions serverVersions) async {
    final localVersions = _versions.cachedLocalData;
    final oldVersion = localVersions?.voices;
    final newVersion = serverVersions.voices;
    if (oldVersion != newVersion) {
      final serverData = await _voices.serverData;
      if (await _voices.syncFiles(serverData, stopOnError: true)) {
        log.info('Voice files updated from version $oldVersion to $newVersion');
        await _updateLocalVersions(
          localVersions == null
              ? serverVersions.copyWith(voices: newVersion, images: '')
              : localVersions.copyWith(voices: newVersion),
        );
        return true;
      }
    }
    return false;
  }
}
