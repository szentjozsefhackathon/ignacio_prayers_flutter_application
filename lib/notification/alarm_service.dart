// // alarm_service.dart
// import 'package:flutter/material.dart';
// import 'dart:io' show Platform;

// // Conditional imports
// import 'alarm_service_android.dart' if (Platform.isAndroid);
// import 'alarm_service_ios.dart' if (Platform.isIOS);

// void main() async {
//   initializeAlarmService();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Alarm Service',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Alarm Service'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             setAlarm();
//           },
//           child: const Text('Set Alarm'),
//         ),
//       ),
//     );
//   }
// }