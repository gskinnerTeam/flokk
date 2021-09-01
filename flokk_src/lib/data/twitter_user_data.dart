import 'package:json_annotation/json_annotation.dart';

part 'twitter_user_data.g.dart';

@JsonSerializable()
class TwitterUser {
  int id = 0;
  String name = "";

  @JsonKey(name: "screen_name", defaultValue: "")
  String screenName = "";

  String location = "";
  String description = " = " "";
  String url = "";

  //@JsonKey(defaultValue: false)
  bool protected = false;

  //@JsonKey(defaultValue: false)
  bool verified = false;

  @JsonKey(name: "followers_count", defaultValue: 0)
  int followersCount = 0;

  @JsonKey(name: "friends_count", defaultValue: 0)
  int friendsCount = 0;

  @JsonKey(name: "listed_count", defaultValue: 0)
  int listedCount = 0;

  @JsonKey(name: "statuses_count", defaultValue: 0)
  int statusesCount = 0;

  @JsonKey(name: "profile_image_url_https", defaultValue: '')
  String profileImageUrl = "";

  @JsonKey(name: "profile_background_image_url_https", defaultValue: '')
  String profileBackgroundImageUrl = "";

  @JsonKey(name: "profile_use_background_image", defaultValue: false)
  bool profileUseBackgroundImage = false;

  TwitterUser();

  factory TwitterUser.fromJson(Map<String, dynamic> json) =>
      _$TwitterUserFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterUserToJson(this);
}
