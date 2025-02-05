import 'dart:convert';
import 'dart:io' show SocketException, HttpException;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/common.dart';
import 'exceptions.dart';

// TODO: move to Hive or SQLite

abstract class DataSetManagerBase<T extends ToJson, Item extends ToJson> {
  DataSetManagerBase({
    required String logName,
    required this.dataKey,
    required this.dataUrlEndpoint,
    required this.fromJson,
  }) : log = Logger('$logName ($dataKey)');

  final Logger log;
  final String dataKey;
  final Uri dataUrlEndpoint;
  final Item Function(Map<String, dynamic>) fromJson;

  T? _cachedData;

  T? get cachedData => _cachedData;

  Future<bool> get localDataExists async =>
      (_cachedData ??= await _readLocalData()) != null;

  // Lazy initialization of data
  Future<T> get data async {
    try {
      T? local = (_cachedData ??= await _readLocalData());
      if (local == null) {
        log.warning('No local data found');
        await downloadAndSaveData();
        local = _cachedData = await _readLocalData();
        if (local == null) {
          throw DataLoadingException('Failed to load downloaded data');
        }
      }
      return local;
    } catch (e, s) {
      log.severe('Failed to load data: $e', e, s);
      rethrow;
    }
  }

  T _decodeData(String data);

  Future<T> get serverData async {
    try {
      final response = await _fetchServerData();
      return _decodeData(response);
    } catch (e, s) {
      log.severe('Failed to load server data: $e', e, s);
      rethrow;
    }
  }

  Future<String> _fetchServerData() async {
    try {
      final response = await http.get(dataUrlEndpoint);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        log.warning('Failed to fetch data from server: ${response.statusCode}');
        throw HttpException('Failed with status code: ${response.statusCode}');
      }
    } on SocketException {
      // Handle "Connection Refused" or "No Internet"
      log.severe('Connection Refused');
      // throw DataLoadingException('Unable to connect to the server. Please check your internet or server.', e);
      throw Exception(
        'No Internet connection or connection refused',
      ); // TODO: Add link to check server availability from browser
    } on http.ClientException {
      // Handle invalid HTTP response
      log.severe('HTTP Error:');
      throw Exception('Invalid response received from the server.');
      // throw DataLoadingException('Invalid response received from the server.', e);
    } on FormatException {
      // Handle invalid JSON
      log.severe('Format Error');
      throw Exception('Invalid response format');
      // throw DataLoadingException('The server URL or response format is invalid.', e);
    } catch (e, s) {
      // Handle any other exceptions
      log.severe('Error: $e', e, s);
      throw Exception('An unexpected error occurred: $e');
      // throw DataLoadingException('An unexpected error occurred:', e);
    }
  }

  Future<void> downloadAndSaveData() async {
    try {
      final response = await _fetchServerData();
      await saveLocalData(response);
    } catch (e, s) {
      log.severe('Failed to download and save data: $e', e, s);
      rethrow;
    }
  }

  Future<void> saveLocalData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, jsonData);
    log.info('Data saved to storage');
  }

  Future<T?> _readLocalData() async {
    log.info('Reading data from storage');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(dataKey);

      if (jsonData == null) {
        log.warning('No local data found');
        return null;
      }
      return _decodeData(jsonData);
    } catch (e, s) {
      log.severe('Error reading local data', e, s);
      rethrow;
    }
  }

  Future<void> deleteLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dataKey);
    _cachedData = null;
    log.info('Data deleted');
  }
}

class DataSetManager<T extends DataDescriptor>
    extends DataSetManagerBase<T, T> {
  DataSetManager({
    required super.dataKey,
    required super.dataUrlEndpoint,
    required super.fromJson,
  }) : super(logName: 'DataSetManager');

  @override
  T _decodeData(String data) => fromJson(json.decode(data));
}

class ListDataSetManager<T extends DataDescriptor>
    extends DataSetManagerBase<DataList<T>, T> {
  ListDataSetManager({
    required super.dataKey,
    required super.dataUrlEndpoint,
    required super.fromJson,
  }) : super(logName: 'ListDataSetManager');

  @override
  DataList<T> _decodeData(String data) =>
      DataList<T>.fromJson(json.decode(data), fromJson);
}
