import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part 'versions.g.dart';

@JsonSerializable()
class Versions extends DataDescriptor {
  Versions({
    required this.data,
    required this.images,
    required this.voices,
  });

  factory Versions.fromJson(Json json) => _$VersionsFromJson(json);

  String data;
  String images;
  String voices;

  @override
  Json toJson() => _$VersionsToJson(this);

  Versions copyWith({
    String? data,
    String? images,
    String? voices,
  }) =>
      Versions(
        data: data ?? this.data,
        images: images ?? this.images,
        voices: voices ?? this.voices,
      );
}
