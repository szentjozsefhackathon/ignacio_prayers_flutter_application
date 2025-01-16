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

  factory Versions.fromJson(Map<String, dynamic> json) => _$VersionsFromJson(json);

  String data;
  String images;
  String voices;

  @override
  Map<String, dynamic> toJson() => _$VersionsToJson(this);
}
