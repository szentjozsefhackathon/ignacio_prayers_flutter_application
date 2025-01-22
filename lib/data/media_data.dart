import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part 'media_data.g.dart';

@JsonSerializable()
class MediaData extends DataDescriptor {
  MediaData({
    required this.name,
    required this.path,
    required this.size,
    required this.lastModified,
  });

  factory MediaData.fromJson(Json json) => _$MediaDataFromJson(json);

  final String name;
  final String path;
  final int size;
  final DateTime lastModified;

  @override
  Json toJson() => _$MediaDataToJson(this);

  @override
  String toString() => '$name ($path)';
}
