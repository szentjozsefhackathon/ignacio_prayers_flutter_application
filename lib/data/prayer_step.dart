import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part 'prayer_step.g.dart';

enum PrayerStepType { fix, flex }

@JsonSerializable()
class PrayerStep extends DataDescriptor {
  PrayerStep({
    required this.description,
    required this.voices,
    required this.timeInSeconds,
    required this.type,
  });

  factory PrayerStep.fromJson(Json json) => _$PrayerStepFromJson(json);

  final String description;
  final List<String> voices;
  final int timeInSeconds;

  @JsonKey(fromJson: _prayerStepTypeFromJson, toJson: _prayerStepTypeToJson)
  final PrayerStepType type;

  static PrayerStepType _prayerStepTypeFromJson(String json) =>
      PrayerStepType.values.singleWhere((t) => t.name.toUpperCase() == json);

  static String _prayerStepTypeToJson(PrayerStepType object) =>
      object.name.toUpperCase();

  @override
  Json toJson() => _$PrayerStepToJson(this);
}
