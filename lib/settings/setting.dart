import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _darkMode = "System"; // Default value
  final List<String> _darkModeOptions = ["Dark", "Light", "System"];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getString('dark_mode') ?? "System";
    });
  }

  Future<void> _savePreferences(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dark_mode', mode);

    // Apply the theme change
    switch (mode) {
      case "Dark":
        ThemeMode.dark;
        break;
      case "Light":
        ThemeMode.light;
        break;
      default:
        ThemeMode.system;
        break;
    }

    setState(() {
      _darkMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Dark Mode"),
            subtitle: Text(_darkMode),
            trailing: DropdownButton<String>(
              value: _darkMode,
              onChanged: (newValue) {
                if (newValue != null) {
                  _savePreferences(newValue);
                }
              },
              items: _darkModeOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
