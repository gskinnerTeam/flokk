import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/date_sortable_interface.dart';
import 'package:flokk/data/git_event_data.dart';
import 'package:flokk/data/tweet_data.dart';

class SocialContactData {
  /* Populated at runtime */
  ContactData contact = ContactData();
  List<Tweet> tweets = const <Tweet>[];
  List<GitEvent> gitEvents = const <GitEvent>[];

  //The number of new tweets since the last time user checked  (populates the indicator)
  List<Tweet> get newTweets =>
      tweets.where((x) => x.createdAt.isAfter(lastCheckedTweets)).toList();

  //The number of new git events since the last time user checked (populates the indicator)
  List<GitEvent> get newGits =>
      gitEvents.where((x) => x.createdAt.isAfter(lastCheckedGit)).toList();

  //Used to determine the level of activity for most active
  int get points {
    int pts = 0;
    for (var n in gitEvents) {
      switch (n.event.type) {
        case "PushEvent":
        case "ForkEvent":
        case "CreateEvent":
          pts++;
          break;
      }
    }
    pts += tweets.length;
    return pts;
  }

  //Get latest activity (can be GitEvent or Tweet)
  DateSortable get latestActivity {
    List<DateSortable> sorted = [];
    sorted.addAll(tweets);
    sorted.addAll(gitEvents);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.isNotEmpty ? sorted.first : DateSortable();
  }

  /* Serialized to json */
  String contactId = "";

  //Field to be updated whenever the user checks user social feeds
  DateTime lastCheckedTweets = Dates.epoch;

  DateTime lastCheckedGit = Dates.epoch;

  //Field to be updated whenever the data for tweets have been updated
  DateTime lastUpdatedTwitter = Dates.epoch;

  //Field to be updated whenever the data for git events have been updated
  DateTime lastUpdatedGit = Dates.epoch;

  SocialContactData();

  /* Json Serialization */

  //The contact instance will be populated manually in the model, since we don't want to serialze contact data again (already serialized in contacts model)
  factory SocialContactData.fromJson(Map<String, dynamic> json) {
    return SocialContactData()
      ..contactId = json["contactId"] as String
      ..lastCheckedTweets = json["lastCheckedTweets"] == null
          ? Dates.epoch
          : DateTime.parse(json["lastCheckedTweets"] as String)
      ..lastCheckedGit = json["lastCheckedGit"] == null
          ? Dates.epoch
          : DateTime.parse(json["lastCheckedGit"] as String)
      ..lastUpdatedTwitter = json["lastUpdatedTwitter"] == null
          ? Dates.epoch
          : DateTime.parse(json["lastUpdatedTwitter"] as String)
      ..lastUpdatedGit = json["lastUpdatedGit"] == null
          ? Dates.epoch
          : DateTime.parse(json["lastUpdatedGit"] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      "contactId": contactId,
      "lastCheckedTweets": lastCheckedTweets.toIso8601String(),
      "lastCheckedGit": lastCheckedGit.toIso8601String(),
      "lastUpdatedTwitter": lastUpdatedTwitter.toIso8601String(),
      "lastUpdatedGit": lastUpdatedGit.toIso8601String()
    };
  }
}
