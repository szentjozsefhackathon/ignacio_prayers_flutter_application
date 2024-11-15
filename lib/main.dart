import 'package:flutter/material.dart';
import 'package:ignacio_prayers_flutter_application/constants.dart';
import 'package:ignacio_prayers_flutter_application/data_descriptors/prayer.dart';
import 'package:ignacio_prayers_flutter_application/data_descriptors/prayer.dart';
import 'data_handlers/data_manager.dart';
import 'data_descriptors/prayer_group.dart';
import '../data_descriptors/data_list.dart'; // Import Json data descriptors
import 'page_two.dart';
import '/settings/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a new instance of DataManager
  // By creating the instance data will be loaded from shared preferences
  // if the data is not found in shared preferences the data will be downloaded from the server 
  // (this should be applied only downloading thew app and first startup)
  final dataManager = DataManager();

  // if we have valid data we can start the app
  runApp(MyApp(dataManager: dataManager));

  // Check for updates in the background
  // If there are updates the data will be downloaded and saved to shared preferences
  // After the data is saved reload frontend TODO: implement this
  dataManager.checkForUpdates();
}
class MyApp extends StatelessWidget {
  final DataManager dataManager;

  const MyApp({Key? key, required this.dataManager}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter DEMO',dataManager: dataManager),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


// class _HomeScreenState extends State<HomeScreen> {
//   List<dynamic> _items = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final data = await widget.dataManager.getData();
//     setState(() {
//       _items = data;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Grid View')),
//       body: _items.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//               ),
//               itemCount: _items.length,
//               itemBuilder: (context, index) {
//                 final item = _items[index];
//                 return Card(
//                   child: Column(
//                     children: [
//                       Image.network(item['imageUrl']),
//                       Text(item['name']),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }


class MyHomePage extends StatefulWidget {
  final DataManager dataManager;
  const MyHomePage({super.key, required this.title, required this.dataManager});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DataList<PrayerGroup> _items = DataList<PrayerGroup>(items: []); 
  // TODO create images list

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

  // Future<File?> _getImageFile() async {
  //   try {
  //     final file = await widget.dataManager.imagesDataManager(imageName);
  //     if (await file.exists()) {
  //       return file;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     log.severe('Error getting image file: $e');
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
                actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(builder: (context) => PageTwo(title: item.title , prayers: item.prayers)),
                      );
                    },
                    child: Container(
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //     image: AssetImage('assets/images/background.jpg'),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      child: Column(
                        children: [
                          // Image.network(item['imageUrl']),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: Colors.white, // Adjust text color for better visibility
                              backgroundColor: Colors.black54, // Optional: Add background color to text
                            ),
                          ),
                        ],
                      ),
    ),
                  ),
                );
              },
            ),
    );
  }
}