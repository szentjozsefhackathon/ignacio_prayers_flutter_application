// Shared Preferencies keys
const String kPrayerGroup = 'prayerGroupsData';
const String kVersions = 'versionsData';
const String kImages = 'images';
const String kVoices = 'voices';

const String kUserSettings = 'userData';

// Settings keys
const String kThemeMode = 'themeMode';
const String kDndEnabled = 'dndEnabled';
const String kDailyNotifierEnabled = 'dailyNotifierEnabled';
const String kDailyNotifierTime = 'dailyNotifierTime';

// Prayer settings keys
const String kAutoPageTurn = 'automaticPageSwitch';
const String kPrayerLen = 'prayerLength';
const String kSoundSwitch = 'soundEnabled';
const String kSelectedVoice = 'selectedVoice';

// Server constants
const String kServerUrl = 'http://4.231.10.139/api';
const String kCheckVersionUrl = '/api/json/check-versions';
const String kDownloadDataUrl = '/api/json/download-data';
const String kImageListUrl = '/api/media/sync-images';
const String kVoicesListUrl = '/api/media/sync-voices';

String kMediaApiUrl(String mediaType, String filename) =>
    'api/media/$mediaType/$filename';
