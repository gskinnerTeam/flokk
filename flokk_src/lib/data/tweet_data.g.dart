// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tweet _$TweetFromJson(Map<String, dynamic> json) {
  return Tweet()
    ..id = json['id_str'] as String
    ..text = json['full_text'] as String
    ..truncated = json['truncated'] as bool? ?? false
    ..retweeted = json['retweeted'] as bool? ?? false
    ..retweetCount = json['retweet_count'] as int? ?? 0
    ..favoriteCount = json['favorite_count'] as int? ?? 0
    ..createdAtString = json['created_at'] as String
    ..user = TwitterUser.fromJson(json['user'] as Map<String, dynamic>);
}

Map<String, dynamic> _$TweetToJson(Tweet instance) => <String, dynamic>{
      'id_str': instance.id,
      'full_text': instance.text,
      'truncated': instance.truncated,
      'retweeted': instance.retweeted,
      'retweet_count': instance.retweetCount,
      'favorite_count': instance.favoriteCount,
      'created_at': instance.createdAtString,
      'user': instance.user.toJson(),
    };
