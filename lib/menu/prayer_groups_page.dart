import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data_handlers/data_manager.dart';
import '../data_descriptors/prayer_group.dart';
import '../data_descriptors/data_list.dart'; // Import Json data descriptors
import 'prayers_page.dart';
import '../settings/settings_page.dart';
import 'dart:io';

class PrayerGroupsPage extends StatefulWidget {
  final DataManager dataManager;
  const PrayerGroupsPage({super.key, required this.title, required this.dataManager});

  final String title;

  @override
  State<PrayerGroupsPage> createState() => _PrayerGroupsPageState();
}

class _PrayerGroupsPageState extends State<PrayerGroupsPage> {
  DataList<PrayerGroup> _items = DataList<PrayerGroup>(items: []); 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prayerGroups = await widget.dataManager.prayerGroupDataManager.data;
    setState(() {
      _items = prayerGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
                actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 4,
                mainAxisExtent: 200,
                crossAxisSpacing: 4,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrayersPage(
                              title: item.title,
                              prayers: item.prayers,
                              dataManager: widget.dataManager,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: FutureBuilder<dynamic>(
                            future: widget.dataManager.imagesManager.getFile(item.image),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError || !snapshot.hasData) { // !snapshot.data!.existsSync()
                                return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                              } else {
                                if(kIsWeb){
                                  // For web: Use Image.network with a URL
                                  return Image.network(
                                    snapshot.data!, 
                                    fit: BoxFit.cover
                                    );
                                }
                                else{
                                  // For other platforms: Use Image.file
                                  return Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        // Overlay for Title
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(8.0),
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
  }
}