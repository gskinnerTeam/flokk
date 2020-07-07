/*
NOTE: In order to run the the app you must enter at least the Google API keys.
Twitter and Git can be omitted, but the Social features of the app will not work.
Keys should _not_ be committed to a public repo due to per-app API quotas which can quickly be exhausted.
*/
class ApiKeys {
  /// Google
  String googleClientId = "";
  String googleClientSecret = "";
  String googleWebClientId = "";

  /// Twitter
  String twitterKey = "";
  String twitterSecret = "";

  /// GitHub
  String githubKey = "";
  String githubSecret = "";
}
