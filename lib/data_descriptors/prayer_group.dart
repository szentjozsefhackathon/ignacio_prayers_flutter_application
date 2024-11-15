import 'prayer.dart';
import 'data_descriptor.dart';

class PrayerGroup implements DataDescriptor{
    String title;
    String image;
    List<Prayer> prayers;

    PrayerGroup({
        required this.title,
        required this.image,
        required this.prayers,
    });

    @override
    factory PrayerGroup.fromJson(Map<String, dynamic> json) => PrayerGroup(
        title: json["title"],
        image: json["image"],
        prayers: List<Prayer>.from(json["prayers"].map((x) => Prayer.fromJson(x))),
    );


    @override
    Map<String, dynamic> toJson() => {
        "title": title,
        "image": image,
        "prayers": List<dynamic>.from(prayers.map((x) => x.toJson())),
    };
}