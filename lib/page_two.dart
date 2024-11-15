// lib/page_two.dart
import 'package:flutter/material.dart';
import 'package:ignacio_prayers_flutter_application/data_descriptors/prayer.dart';

class PageTwo extends StatelessWidget {
  final List<Prayer> prayers;
  final String title;

  PageTwo({required this.title, required this.prayers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: prayers.length,
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          return ListTile(
            title: Text(prayer.title),
            subtitle: Text(prayer.description),
          );
        },
      ),
    );
  }
}