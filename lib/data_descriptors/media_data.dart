import 'data_descriptor.dart';

class MediaData implements DataDescriptor{
    String name;
    String path;
    int size;
    DateTime lastModified;

    MediaData({
        required this.name,
        required this.path,
        required this.size,
        required this.lastModified,
    });

    @override
    factory MediaData.fromJson(Map<String, dynamic> json) => MediaData(
        name: json["name"],
        path: json["path"],
        size: json["size"],
        lastModified: DateTime.parse(json["lastModified"]),
    );

    @override
    Map<String, dynamic> toJson() => {
        "name": name,
        "path": path,
        "size": size,
        "lastModified": lastModified.toIso8601String(),
    };
}