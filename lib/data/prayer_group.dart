import 'package:diacritic/diacritic.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:slugify/slugify.dart';

import 'common.dart';
import 'prayer.dart';

part 'prayer_group.g.dart';

@JsonSerializable()
class PrayerGroup extends DataDescriptor with SlugMixin {
  PrayerGroup({
    required this.title,
    required this.image,
    required this.prayers,
  }) : slug = slugify(removeDiacritics(title)); // TODO: do this on server side?

  factory PrayerGroup.fromJson(Json json) => _$PrayerGroupFromJson(json);

  final String title;
  final String image;
  final List<Prayer> prayers;

  @override
  Json toJson() => _$PrayerGroupToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  final String slug;
}
