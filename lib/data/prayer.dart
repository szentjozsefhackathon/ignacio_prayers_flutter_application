import 'package:json_annotation/json_annotation.dart';
import 'package:slugify/slugify.dart';

import 'common.dart';
import 'prayer_step.dart';

part 'prayer.g.dart';

@JsonSerializable()
class Prayer extends DataDescriptor with SlugMixin {
  Prayer({
    required this.title,
    required this.description,
    required this.image,
    required this.voiceOptions,
    required this.minTimeInMinutes,
    required this.steps,
  }) : slug = slugify(title); // TODO: do this on server side?

  factory Prayer.fromJson(Json json) => _$PrayerFromJson(json);

  final String title;
  final String description;
  final String image;

  @JsonKey(name: 'voice_options')
  final List<String> voiceOptions;

  final int minTimeInMinutes;
  final List<PrayerStep> steps;

  @override
  Json toJson() => _$PrayerToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  final String slug;

  int get weightSum {
    int sum = 0;
    for (final step in steps) {
      sum += step.timeInSeconds;
    }
    return sum;
  }
}
