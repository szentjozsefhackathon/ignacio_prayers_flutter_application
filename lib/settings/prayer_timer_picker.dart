class MediaManager {
  final syncUrl;
  final downloadUrl;

  MediaManager(this.syncUrl, this.downloadUrl);

  Future<void> checkDiff() async {
    var localData = await getLocalData();
    try {
      final response = await http.get(Uri.parse(syncUrl));
      if (response.statusCode == 200) {
        log.info('Checking server versions');
        final serverVersions = versionsFromJson(response.body);
        if (serverVersions.data != localData.versions.data) {
          log.info('Updating local data');
          localData = await downloadData();
        } else {
          log.info('Local data is up-to-date');
        }

        // if (serverVersions.images != localData.versions.images) {
        //   log.info('Updating image data');
        //   await downloadImages();
        // }
        
        // if (serverVersions.voices != localData.versions.voices) {
        //   log.info('Updating voice data');
        //   await downloadVoices();
        // }

      } else {
        log.warning('Could not fetch data from the server. Using outdated local data.');
        throw Exception('Failed to fetch versions data from the server');
      }
    }catch (e) {
      log.severe('Error downloading data: $e');
      throw Exception('Failed to check versions');
    }
  }

}