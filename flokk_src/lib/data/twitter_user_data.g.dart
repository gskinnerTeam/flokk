// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitter_user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitterUser _$TwitterUserFromJson(Map<String, dynamic> json) {
  return TwitterUser()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..screenName = json['screen_name'] as String? ?? ''
    ..location = json['location'] as String
    ..description = json['description'] as String
    ..url = json['url'] as String
    ..protected = json['protected'] as bool
    ..verified = json['verified'] as bool
    ..followersCount = json['followers_count'] as int? ?? 0
    ..friendsCount = json['friends_count'] as int? ?? 0
    ..listedCount = json['listed_count'] as int? ?? 0
    ..statusesCount = json['statuses_count'] as int? ?? 0
    ..profileImageUrl = json['profile_image_url_https'] as String? ?? ''
    ..profileBackgroundImageUrl =
        json['profile_background_image_url_https'] as String? ?? ''
    ..profileUseBackgroundImage =
        json['profile_use_background_image'] as bool? ?? false;
}

Map<String, dynamic> _$TwitterUserToJson(TwitterUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'screen_name': instance.screenName,
      'location': instance.location,
      'description': instance.description,
      'url': instance.url,
      'protected': instance.protected,
      'verified': instance.verified,
      'followers_count': instance.followersCount,
      'friends_count': instance.friendsCount,
      'listed_count': instance.listedCount,
      'statuses_count': instance.statusesCount,
      'profile_image_url_https': instance.profileImageUrl,
      'profile_background_image_url_https': instance.profileBackgroundImageUrl,
      'profile_use_background_image': instance.profileUseBackgroundImage,
    };
