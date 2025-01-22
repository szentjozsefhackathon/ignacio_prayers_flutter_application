const _kServerUrl = 'http://4.231.10.139/api'; // TODO: move this to env?
const kCheckVersionUrl = '$_kServerUrl/api/json/check-versions';
const kDownloadDataUrl = '$_kServerUrl/api/json/download-data';
const kImageListUrl = '$_kServerUrl/api/media/sync-images';
const kVoicesListUrl = '$_kServerUrl/api/media/sync-voices';

String mediaApiUrl(String mediaType, String filename) =>
    '$_kServerUrl/api/media/$mediaType/$filename';
