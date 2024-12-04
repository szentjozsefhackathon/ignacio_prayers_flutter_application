import 'prayer_step.dart';
import 'data_descriptor.dart';
class Prayer implements DataDescriptor{
    String title;
    String description;
    String image;
    List<String> voiceOptions;
    int minTimeInMinutes;
    List<PrayerStep> steps;

    Prayer({
        required this.title,
        required this.description,
        required this.image,
        required this.voiceOptions,
        required this.minTimeInMinutes,
        required this.steps,
    });

    factory Prayer.fromJson(Map<String, dynamic> json) => Prayer(
        title: json["title"],
        description: json["description"],
        image: json["image"],
        voiceOptions: List<String>.from(json["voice_options"].map((x) => x)),
        minTimeInMinutes: json["minTimeInMinutes"],
        steps: List<PrayerStep>.from(json["steps"].map((x) => PrayerStep.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "image": image,
        "voice_options": List<dynamic>.from(voiceOptions.map((x) => x)),
        "minTimeInMinutes": minTimeInMinutes,
        "steps": List<dynamic>.from(steps.map((x) => x.toJson())),
    };

    int getWeightSum(){
        int sum = 0;
        for (var step in steps){
            sum += step.timeInSeconds;
        }
        return sum;
    }
}
