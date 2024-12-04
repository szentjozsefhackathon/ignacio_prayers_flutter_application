import 'package:ignacio_prayers_flutter_application/data_descriptors/data_descriptor.dart';
import 'package:ignacio_prayers_flutter_application/data_descriptors/prayer_group.dart';
import 'package:ignacio_prayers_flutter_application/data_descriptors/versions.dart';
import '../data_descriptors/data_list.dart'; // Import Json data descriptors


import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'exceptions.dart';
import 'dart:convert';
import '../constants/constants.dart'; // Import the constants file

// TODO: move to Hive or SQLite

enum DataType { single, list }

class DataSetManager<T extends DataDescriptor>{
  final log = Logger('DataTypeManager');
  final String dataKey;
  final String dataUrlEndpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final DataType dataType;

  Future<dynamic>? _data; // Backing field for caching

  DataSetManager({
    required this.dataKey,
    required this.dataUrlEndpoint,
    required this.fromJson,
    required this.dataType,
  }) {
    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL; // Set the log level to ALL
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  // Lazy initialization of data
  Future<dynamic> get data async {
    try {
      _data ??= _readLocalData(); // Cache the result
      return await _data!;
    } on NoLocalDataException catch (e) {
      log.warning('No local data found, attempting to fetch from server: $e');
      await downloadAndSaveData();
      return await _readLocalData();
    } catch (e, stackTrace) {
      log.severe('Failed to load data: $e', e, stackTrace);
      throw DataLoadingException('Failed to load data', e);
    }
  }

  Future<dynamic> get serverData async {
    final response = await _fetchServerData();
    if (dataType == DataType.single) {
      return fromJson(json.decode(response));
    } else {
      return DataList<T>.fromJson(json.decode(response), fromJson);
    }
  }

  Future<String> _fetchServerData() async {
    final response = await http.get(Uri.parse(SERVER_URL + dataUrlEndpoint));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      log.warning('Failed to fetch data from server: ${response.statusCode}');
      throw Exception('Failed to fetch data from server');
    }
  }
  
  Future<void> downloadAndSaveData() async {
    final response = await _fetchServerData();
    await saveLocalData(response);
  }

  Future<void> saveLocalData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, jsonData);
    log.info('Data saved to storage');
  }

  Future<dynamic> _readLocalData() async {
    log.info('Reading data from storage');
    try{
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(dataKey);

      if (jsonData == null) {
        log.warning('No local data found');
        throw NoLocalDataException('No local data found');
      }

      if (dataType == DataType.single) {
        return fromJson(json.decode(jsonData));
      } else {
        return DataList<T>.fromJson(json.decode(jsonData), fromJson);
      }
    } catch (e, stackTrace) {
      log.severe('Error reading local data: $e', e, stackTrace);
      rethrow; // Propagate the exception to the caller
    }
  }
}

// For Debugging
void main() async {
  DataSetManager<PrayerGroup> dataManager = DataSetManager<PrayerGroup>(
      dataKey: PRAYER_GROUP_KEY,
      dataUrlEndpoint: DOWNLOAD_DATA_URL_ENDPOINT,
      fromJson: PrayerGroup.fromJson,
      dataType: DataType.list,
    );

  final serverdata = await dataManager.serverData;
  print('Server data downloaded: $serverdata');

  final data = await dataManager.data;
  final test_data = data.items[0].title;
  print('Data downloaded: $test_data');

  final data2 = await dataManager.data;
  await dataManager.downloadAndSaveData();
  final data3 = await dataManager.data; // this data is not up to date but its is ok, itt will apply next rerun

  final test_data4 = data2.items[0].title;
  print('Data downloaded: $test_data4');

  DataSetManager<Versions> versionsDataManager = DataSetManager<Versions>(
      dataKey: VERSIONS_KEY,
      dataUrlEndpoint: CHECK_VERSION_URL_ENDPOINT,
      fromJson: Versions.fromJson,
      dataType: DataType.single,
    );

  final data4 = await versionsDataManager.data;
  final test_data2 = data4.data;
  print('Data downloaded: $test_data2');
}