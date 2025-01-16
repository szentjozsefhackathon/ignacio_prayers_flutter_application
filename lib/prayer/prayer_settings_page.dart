import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/prayer.dart';
import '../data/settings_data.dart';
import '../data_handlers/data_manager.dart';
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
  @override
  Widget build(BuildContext context) {
    final currentPrayer = widget.prayer;
    final settings = context.watch<SettingsData>();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPrayer.title),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Automatikus lapozás'),
            value: settings.autoPageTurn,
            onChanged: (v) => settings.autoPageTurn = v,
          ),
          SwitchListTile(
            title: const Text('Ne zavarjanak'),
            value: settings.dnd,
            onChanged: (v) => settings.dnd = v,
          ),
          if (currentPrayer.voiceOptions.isNotEmpty)
            SwitchListTile(
              title: const Text('Hang'),
              value: settings.prayerSoundEnabled,
              onChanged: (v) => settings.prayerSoundEnabled = v,
            )
          else
            const SwitchListTile(
              title: Text('Hang'),
              subtitle: Text('Nincs ehhez az imához'),
              value: false,
              onChanged: null,
            ),
          ...currentPrayer.voiceOptions.map(
            (voice) => RadioListTile(
              title: Text(voice),
              value: voice,
              // TODO: check if this voice is available
              groupValue: settings.voiceChoice,
              onChanged: settings.prayerSoundEnabled
                  ? (String? v) {
                      if (v != null) {
                        settings.voiceChoice = v;
                      }
                    }
                  : null,
            ),
          ),
          ListTile(
            title: const Text('Ima hossza'),
            subtitle: Text('${settings.prayerLength} perc'),
            trailing: const Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  var length = settings.prayerLength;
                  return AlertDialog(
                    title: const Text('Ima hossza'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) => Slider(
                            value: length.toDouble(),
                            min: currentPrayer.minTimeInMinutes.toDouble(),
                            max: 60,
                            divisions: 60 - currentPrayer.minTimeInMinutes,
                            label: '$length perc',
                            onChanged: (v) => setState(
                              () => length = v.toInt(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Mégsem'),
                      ),
                      TextButton(
                        onPressed: () {
                          settings.prayerLength = length;
                          Navigator.pop(context);
                        },
                        child: const Text('Beállítás'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('További beállítások'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrayerPage(
                prayer: currentPrayer,
                dataManager: widget.dataManager,
              ),
            ),
          );
        },
        tooltip: 'Ima indítása',
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
