import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../alarm_service/services/permission.dart';
import '../data/common.dart';
import '../data/prayer_group.dart';
import '../data_handlers/data_manager.dart';
import '../prayer/prayer_image.dart';
import '../routes.dart';

class PrayerGroupsPage extends StatefulWidget {
  const PrayerGroupsPage({super.key});

  @override
  State<PrayerGroupsPage> createState() => _PrayerGroupsPageState();
}

class _PrayerGroupsPageState extends State<PrayerGroupsPage> {
  DataList<PrayerGroup> _items = DataList(items: []);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          await AlarmPermissions.checkAndroidPhotosPermission();
          await AlarmPermissions.checkAndroidExternalAudioPermission();
          await AlarmPermissions.checkAndroidExternalVideosPermission();
        }

        await DataManager.instance.checkForUpdates(stopOnError: true);
      }

      final prayerGroups = await DataManager.instance.prayerGroups.data;
      if (mounted) {
        setState(() => _items = prayerGroups);
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
      showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Ignáci imák'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, Routes.settings),
            ),
          ],
        ),
        body: _items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 200,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.prayers(item),
                        arguments: item,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: PrayerImage(name: item.image),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );

  void showErrorDialog(String errorMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadData();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
