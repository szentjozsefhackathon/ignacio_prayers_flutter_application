import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_descriptors/prayer.dart';
import '../data_descriptors/user_settings_data.dart';
import '../data_handlers/data_manager.dart';
import '../settings/user_settings_manager.dart';
import 'prayer_page.dart';

class PrayerSettingsPage extends StatefulWidget {
  const PrayerSettingsPage({
    super.key,
    required this.prayer,
    required this.dataManager,
  });

  final Prayer prayer;
  final DataManager dataManager;

  @override
  State<PrayerSettingsPage> createState() => _PrayerSettingsPageState();
}

class _PrayerSettingsPageState extends State<PrayerSettingsPage> {
  // Add any state variables you need to update
  final userSettingsManager = UserSettingsManager();
  UserSettingsData _userSettingsData = UserSettingsData.withDefaults();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userSettingsData = await userSettingsManager.loadUserSettings();
    setState(() {
      _userSettingsData = userSettingsData;
    });
  }

  void _updateUserSettings(UserSettingsData userSettingsData) {
    Future.microtask(() {
      setState(() {
        _userSettingsData = userSettingsData;
      });
      userSettingsManager.saveSaveSettings(userSettingsData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayer = widget.prayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPrayer.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Automatic Page Turn'),
            value: _userSettingsData.autoPageTurn,
            onChanged: (newValue) {
              _userSettingsData.autoPageTurn = newValue;
              _updateUserSettings(_userSettingsData);
            },
          ),
          if (!kIsWeb)
            SwitchListTile(
              title: const Text('Do Not Disturb'),
              value: _userSettingsData.dnd,
              onChanged: (newValue) {
                _userSettingsData.dnd = newValue;
                _updateUserSettings(_userSettingsData);
              },
            ),
          if (currentPrayer.voiceOptions != [])
            ListTile(
              title: const Text('Select Voice'),
              subtitle: Text(_userSettingsData.voiceChoice),
              trailing: DropdownButton<String>(
                //TODO: check if this voice is available
                value: _userSettingsData.voiceChoice,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _userSettingsData.voiceChoice = newValue;
                    _updateUserSettings(_userSettingsData);
                  }
                },
                items: currentPrayer.voiceOptions
                    .map(
                      (voice) => DropdownMenuItem(
                        value: voice,
                        child: Text(voice),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (currentPrayer.voiceOptions != [])
            SwitchListTile(
              title: const Text('Enable Sound'),
              value: _userSettingsData.prayerSoundEnabled,
              onChanged: (newValue) {
                _userSettingsData.prayerSoundEnabled = newValue;
                _updateUserSettings(_userSettingsData);
              },
            )
          else
            const ListTile(
              title: Text('Enable Sound'),
              subtitle: Text('Disabled for this prayer'),
              trailing: Switch(value: false, onChanged: null),
            ),
          ListTile(
            title: const Text('Prayer Length'),
            subtitle: Text('${_userSettingsData.prayerLength} minutes'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    var tempLength = _userSettingsData.prayerLength;
                    return AlertDialog(
                      title: const Text('Set Prayer Length'),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) =>
                            Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Slider(
                              value: tempLength.toDouble(),
                              min: currentPrayer.minTimeInMinutes.toDouble(),
                              max: 60,
                              divisions: 60 - currentPrayer.minTimeInMinutes,
                              label: '$tempLength minutes',
                              onChanged: (value) {
                                setState(() {
                                  tempLength = value.toInt();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _userSettingsData.prayerLength = tempLength;
                            _updateUserSettings(_userSettingsData);
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('More settings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerPage(
                    prayer: currentPrayer,
                    userSettingsData: _userSettingsData,
                    dataManager: widget.dataManager,
                  ),
                ),
              );
            },
            child: const Text('Start Prayer'),
          ),
        ],
      ),
    );
  }
}
