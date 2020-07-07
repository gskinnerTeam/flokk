import 'package:json_annotation/json_annotation.dart';

part 'twitter_user_data.g.dart';

@JsonSerializable()
class TwitterUser {
  int id;
  String name;

  @JsonKey(name: "screen_name", defaultValue: 0)
  String screenName;

  String location;
  String description;
  String url;

  @JsonKey(defaultValue: false)
  bool protected;

  @JsonKey(defaultValue: false)
  bool verified;

  @JsonKey(name: "followers_count", defaultValue: 0)
  int followersCount;

  @JsonKey(name: "friends_count", defaultValue: 0)
  int friendsCount;

  @JsonKey(name: "listed_count", defaultValue: 0)
  int listedCount;

  @JsonKey(name: "statuses_count", defaultValue: 0)
  int statusesCount;

  @JsonKey(name: "profile_image_url_https")
  String profileImageUrl;

  @JsonKey(name: "profile_background_image_url_https")
  String profileBackgroundImageUrl;

  @JsonKey(name: "profile_use_background_image", defaultValue: false)
  bool profileUseBackgroundImage;

  TwitterUser();

  factory TwitterUser.fromJson(Map<String, dynamic> json) => _$TwitterUserFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterUserToJson(this);
}
