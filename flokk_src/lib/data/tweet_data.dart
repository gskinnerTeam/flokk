import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/data/date_sortable_interface.dart';
import 'package:flokk/data/twitter_user_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tweet_data.g.dart';

@JsonSerializable(explicitToJson: true)
class Tweet implements DateSortable {
  @JsonKey(name: "id_str")
  String id = "";

  @JsonKey(name: "full_text")
  String text = "";

  @JsonKey(defaultValue: false)
  bool truncated = false;

  @JsonKey(defaultValue: false)
  bool retweeted = false;

  @JsonKey(name: "retweet_count", defaultValue: 0)
  int retweetCount = 0;

  @JsonKey(name: "favorite_count", defaultValue: 0)
  int favoriteCount = 0;

  @JsonKey(name: "created_at")
  String createdAtString = "";

  //Tweet dates use a Date string that is not compatible with DateTime.parse(), have to manually parse
  @override
  @JsonKey(ignore: true)
  DateTime createdAt = Dates.epoch;

  //Url is populated at runtime based on tweet id
  @JsonKey(ignore: true)
  String url = "";

  TwitterUser user = TwitterUser();

  Tweet();

  static DateTime parseTwitterDateTime(String s) {
    final r = RegExp(r"\w+\s(\w+)\s(\d+)\s([\d:]+)\s\+\d{4}\s(\d{4})");
    RegExpMatch? m = r.firstMatch(s);

    String year = m?.group(4) ?? "1970";
    String month = m?.group(1) ?? "01";
    String day = m?.group(2) ?? "01";
    String time = m?.group(3) ?? "00:00:00";

    switch (month) {
      case "Jan":
        month = "01";
        break;
      case "Feb":
        month = "02";
        break;
      case "Mar":
        month = "03";
        break;
      case "Apr":
        month = "04";
        break;
      case "May":
        month = "05";
        break;
      case "Jun":
        month = "06";
        break;
      case "Jul":
        month = "07";
        break;
      case "Aug":
        month = "08";
        break;
      case "Sep":
        month = "09";
        break;
      case "Oct":
        month = "10";
        break;
      case "Nov":
        month = "11";
        break;
      case "Dec":
        month = "12";
        break;
      default:
        month = "01";
        break;
    }

    return DateTime.parse("$year-$month-$day $time Z");
  }

  factory Tweet.fromJson(Map<String, dynamic> json) {
    Tweet tweet = _$TweetFromJson(json);
    tweet.createdAt = parseTwitterDateTime(tweet.createdAtString);
    tweet.url = "https://twitter.com/i/web/status/${tweet.id}";
    return tweet;
  }

  Map<String, dynamic> toJson() => _$TweetToJson(this);

  @override
  bool operator ==(covariant Tweet other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}
