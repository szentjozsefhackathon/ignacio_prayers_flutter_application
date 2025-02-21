import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/prayer.dart';
import '../data/settings_data.dart';
import '../routes.dart';
import 'prayer_page.dart';

class PrayerSettingsPage extends StatefulWidget {
  const PrayerSettingsPage({
    super.key,
    required this.prayer,
  });

  final Prayer prayer;

  @override
  State<PrayerSettingsPage> createState() => _PrayerSettingsPageState();
}

class _PrayerSettingsPageState extends State<PrayerSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsData>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prayer.title),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Automatikus lapozás'),
            value: settings.autoPageTurn,
            onChanged: (v) => settings.autoPageTurn = v,
          ),
          if (!kIsWeb)
            SwitchListTile(
              title: const Text('Ne zavarjanak'),
              value: settings.dnd,
              onChanged: (v) => settings.dnd = v,
            ),
          if (widget.prayer.voiceOptions.isNotEmpty)
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
          ...widget.prayer.voiceOptions.map(
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
                            min: widget.prayer.minTimeInMinutes.toDouble(),
                            max: 60,
                            divisions: 60 - widget.prayer.minTimeInMinutes,
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
            onTap: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrayerPage(prayer: widget.prayer),
          ),
        ),
        tooltip: 'Ima indítása',
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
