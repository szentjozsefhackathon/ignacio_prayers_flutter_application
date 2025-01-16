import 'dart:convert';
import 'dart:io' show SocketException, HttpException;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../data/common.dart';
import 'exceptions.dart';

// TODO: move to Hive or SQLite

enum DataType { single, list }

class DataSetManager<T extends DataDescriptor> {
  DataSetManager({
    required this.dataKey,
    required this.dataUrlEndpoint,
    required this.fromJson,
    required this.dataType,
  });

  static final log = Logger('DataSetManager');

  final String dataKey;
  final String dataUrlEndpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final DataType dataType;

  Future<dynamic>? _data; // Backing field for caching

  // Lazy initialization of data
  Future<dynamic> get data async {
    try {
      try {
        _data ??= _readLocalData(); // Cache the result
        return await _data!;
      } on NoLocalDataException catch (e) {
        log.warning('No local data found, attempting to fetch from server: $e');
        await downloadAndSaveData();
        return await _readLocalData();
      }
    } catch (e, s) {
      log.severe('Failed to load data: $e', e, s);
      // throw DataLoadingException('Failed to load data', e);
      rethrow;
    }
  }

  Future<dynamic> get serverData async {
    try {
      final response = await _fetchServerData();
      if (dataType == DataType.single) {
        return fromJson(json.decode(response));
      } else {
        return DataList<T>.fromJson(json.decode(response), fromJson);
      }
    } catch (e, s) {
      log.severe('Failed to load server data: $e', e, s);
      rethrow;
    }
  }

  Future<String> _fetchServerData() async {
    try {
      final response = await http.get(Uri.parse(kServerUrl + dataUrlEndpoint));
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

  Future<dynamic> _readLocalData() async {
    log.info('Reading data from storage');
    try {
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
    } catch (e, s) {
      log.severe('Error reading local data', e, s);
      rethrow;
    }
  }
}
