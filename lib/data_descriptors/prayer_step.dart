import 'data_descriptor.dart';

class PrayerStep implements DataDescriptor {
  PrayerStep({
    required this.description,
    required this.voices,
    required this.timeInSeconds,
    required this.type,
  });

  factory PrayerStep.fromJson(Map<String, dynamic> json) => PrayerStep(
        description: json['description'],
        voices: List<String>.from(json['voices'].map((x) => x as String)),
        timeInSeconds: json['timeInSeconds'],
        type: prayerStepTypeValues.map[json['type']] ??
            (throw ArgumentError('Invalid type value')),
      );
  String description;
  List<String> voices;
  int timeInSeconds;
  PrayerStepType type;

  @override
  Map<String, dynamic> toJson() => {
        'description': description,
        'voices': voices,
        'timeInSeconds': timeInSeconds,
        'type': type,
      };
}

enum PrayerStepType { fix, flex }

final prayerStepTypeValues = EnumValues({
  'FIX': PrayerStepType.fix,
  'FLEX': PrayerStepType.flex,
});

class EnumValues<T> {
  EnumValues(this.map);
  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
