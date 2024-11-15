import 'prayer_step.dart';

class Prayer{
    String title;
    String description;
    String image;
    int minTimeInMinutes;
    List<PrayerStep> steps;

    Prayer({
        required this.title,
        required this.description,
        required this.image,
        required this.minTimeInMinutes,
        required this.steps,
    });

    factory Prayer.fromJson(Map<String, dynamic> json) => Prayer(
        title: json["title"],
        description: json["description"],
        image: json["image"],
        minTimeInMinutes: json["minTimeInMinutes"],
        steps: List<PrayerStep>.from(json["steps"].map((x) => PrayerStep.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "image": image,
        "minTimeInMinutes": minTimeInMinutes,
        "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
    };
}
