import "package:flokk/_internal/utils/string_utils.dart";
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/tweet_data.dart';
import "package:flokk/models/abstract_model.dart";
import 'package:flokk/models/contacts_model.dart';
import 'package:tuple/tuple.dart';

class TwitterModel extends AbstractModel {
  final expiry = Duration(
      days: 30); //the period of which to cull tweets based on createdAt

  ContactsModel contactsModel;

  TwitterModel(this.contactsModel) {
    enableSerialization("twitter.dat");
  }

  @override
  void scheduleSave() {
    cull();
    super.scheduleSave();
  }

  /// //////////////////////////////////////////////////////////////////
  /// Serialization
  @override
  TwitterModel copyFromJson(Map<String, dynamic> json) {
    _twitterAccessToken = json["_twitterAccessToken"] ?? "";
    Map<String, dynamic> jsonTweetHash =
        json["_tweetHash"] ?? <String, dynamic>{};
    _tweetHash = jsonTweetHash.map((key, value) =>
        MapEntry<String, List<Tweet>>(
            key,
            (value as List?)
                    ?.where((value) => value != null)
                    .map((x) => Tweet.fromJson(x))
                    .toList() ??
                []));
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "_twitterAccessToken": _twitterAccessToken,
      "_tweetHash": _tweetHash
    };
  }

  /// //////////////////////////////////////////////////////////////////
  /// Public API
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  //Helper method to quickly lookup last known auth state, does not mean user is necessarily verified, the auth token may be expired.
  bool get isAuthenticated => !StringUtils.isEmpty(_twitterAccessToken);

  /////////////////////////////////////////////////////////////////////
  // Access Token
  String _twitterAccessToken = "";

  String get twitterAccessToken => _twitterAccessToken;

  set twitterAccessToken(String value) {
    _twitterAccessToken = value;
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////
  // Tweets
  Map<String, List<Tweet>> _tweetHash = {};

  //Get all tweets sorted by time
  List<Tweet> get allTweets {
    final sorted = _tweetHash.values.toList().expand((x) => x).toList();
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  //Get all tweets sorted by popularity
  List<Tweet> get popularTweets {
    List<Tuple2<int, Tweet>> popular = [];
    for (var n in allTweets) {
      int pts = 0;
      pts += n.retweetCount;
      pts += n.favoriteCount;
      popular.add(Tuple2<int, Tweet>(pts, n));
    }
    popular.sort((a, b) => b.item1.compareTo(a.item1));
    return popular.map((x) => x.item2).toList();
  }

  //Get tweets for single contact
  List<Tweet> getTweetsByContact(ContactData contact) {
    return _tweetHash[contact.twitterHandle] ?? [];
  }

  void addTweets(String twitterHandle, List<Tweet> tweets) {
    final current = DateTime.now();
    _tweetHash[twitterHandle] = tweets
        .where((x) => (current.difference(x.createdAt)) < expiry)
        .toList();
    notifyListeners();
  }

  void removeTweets(String twitterHandle) {
    _tweetHash.remove(twitterHandle);
  }

  void cull() {
    final current = DateTime.now();
    for (List<Tweet> n in _tweetHash.values) {
      n.removeWhere((x) => current.difference(x.createdAt) >= expiry);
    }
    _tweetHash.removeWhere((key, value) => value.isEmpty);
    notifyListeners();
  }
}
