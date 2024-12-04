import 'data_descriptor.dart';
class PrayerStep implements DataDescriptor{
  String description;
  List<String> voices;
  int timeInSeconds;
  PrayerStepType type;

  PrayerStep({
    required this.description,
    required this.voices,
    required this.timeInSeconds,
    required this.type,
  });

  factory PrayerStep.fromJson(Map<String, dynamic> json) {
    return PrayerStep(
      description: json['description'],
      voices: List<String>.from(json["voices"].map((x) => x as String)),
      timeInSeconds: json['timeInSeconds'],
      type: prayerStepTypeValues.map[json['type']] ?? (throw ArgumentError('Invalid type value')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'voices': voices,
      'timeInSeconds': timeInSeconds,
      'type': type,
    };
  }
}

enum PrayerStepType {
    FIX, FLEX
}

final prayerStepTypeValues = EnumValues({
    "FIX": PrayerStepType.FIX,
    "FLEX": PrayerStepType.FLEX
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}