import 'package:flokk/data/contact_data.dart';
import 'package:github/github.dart';

class GitRepo {
  //Populated at runtime
  List<ContactData> contacts = const [];
  DateTime latestActivityDate = DateTime.fromMillisecondsSinceEpoch(0); //shown in UI

  //Serialized to json
  Repository repository = Repository();
  DateTime lastUpdated = DateTime.fromMillisecondsSinceEpoch(0);

  GitRepo();

  factory GitRepo.fromJson(Map<String, dynamic> json) {
    return GitRepo()
      ..repository = json["repository"] == null ? Repository() : Repository.fromJson(json["repository"] as Map<String, dynamic>)
      ..lastUpdated = json["lastUpdated"] == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse(json['lastUpdated'] as String);
  }

  Map<String, dynamic> toJson() => {"repository": repository, "lastUpdated": lastUpdated?.toIso8601String()};
}
