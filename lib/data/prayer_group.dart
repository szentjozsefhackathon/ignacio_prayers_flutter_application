import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'prayer.dart';

part 'prayer_group.g.dart';

@JsonSerializable()
class PrayerGroup extends DataDescriptor {
  PrayerGroup({
    required this.title,
    required this.image,
    required this.prayers,
  });

  factory PrayerGroup.fromJson(Json json) => _$PrayerGroupFromJson(json);

  final String title;
  final String image;
  final List<Prayer> prayers;

  @override
  Json toJson() => _$PrayerGroupToJson(this);
}
