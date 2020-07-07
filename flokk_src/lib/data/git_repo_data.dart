import 'package:flokk/data/contact_data.dart';
import 'package:github/github.dart';

class GitRepo {
  //Populated at runtime
  List<ContactData> contacts;
  DateTime latestActivityDate; //shown in UI

  //Serialized to json
  Repository repository;
  DateTime lastUpdated;

  GitRepo();

  factory GitRepo.fromJson(Map<String, dynamic> json) {
    return GitRepo()
      ..repository = json["repository"] == null ? null : Repository.fromJson(json["repository"] as Map<String, dynamic>)
      ..lastUpdated = json["lastUpdated"] == null ? null : DateTime.parse(json['lastUpdated'] as String);
  }

  Map<String, dynamic> toJson() => {"repository": repository, "lastUpdated": lastUpdated?.toIso8601String()};
}
