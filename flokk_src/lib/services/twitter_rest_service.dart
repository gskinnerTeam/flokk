import 'dart:convert';
import 'dart:typed_data';

import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/api_keys.dart';
import 'package:flokk/data/tweet_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';

class TwitterRestService {
  //Insert path to CORS proxy, needed for web builds
  final String proxy = kIsWeb ? "http://localhost:8888/" : "";

  Future<ServiceResult<TwitterAuthResult>> getAuth() async {
    final String authUrl = "${proxy}https://api.twitter.com/oauth2/token";
    final String key = Uri.encodeQueryComponent(ApiKeys().twitterKey);
    final String secret = Uri.encodeQueryComponent(ApiKeys().twitterSecret);
    final Uint8List bytes = AsciiEncoder().convert("$key:$secret");
    final String auth = base64Encode(bytes);

    HttpResponse response = await HttpClient.post("$authUrl",
        headers: {
          "Authorization": "Basic $auth",
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
        },
        body: "grant_type=client_credentials");

    TwitterAuthResult? result;
    if (response.success) {
      Map<String, dynamic> data = jsonDecode(response.body);
      result = TwitterAuthResult(
          tokenType: data["token_type"], accessToken: data["access_token"]);
    }

    return ServiceResult(result, response);
  }

  Future<ServiceResult<List<Tweet>>> getTweets(
      String accessToken, String screenName) async {
    String url =
        "${proxy}https://api.twitter.com/1.1/statuses/user_timeline.json"
        "?screen_name=$screenName"
        "&tweet_mode=extended";

    HttpResponse response = await HttpClient.get(url,
        headers: {"Authorization": "Bearer $accessToken"});

    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");

    List<Tweet> tweets = [];
    if (response.success) {
      List<Map<String, dynamic>> tweetsData =
          List.from(jsonDecode(response.body));
      for (int i = 0; i < tweetsData.length; i++) {
        Map<String, dynamic> data = tweetsData[i];
        Tweet t = Tweet.fromJson(data);
        t.text = parse(t.text).documentElement?.text ?? "";
        tweets.add(t);
      }
    }

    return ServiceResult(tweets, response);
  }
}

class TwitterAuthResult {
  final String tokenType;
  final String accessToken;

  TwitterAuthResult({required this.tokenType, required this.accessToken});
}
