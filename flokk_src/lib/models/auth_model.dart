import 'package:flokk/_internal/log.dart';
import "package:flokk/_internal/utils/date_utils.dart";
import "package:flokk/_internal/utils/string_utils.dart";
import "package:flokk/models/abstract_model.dart";
import 'package:google_sign_in/google_sign_in.dart';

class AuthModel extends AbstractModel {
  String? googleRefreshToken;
  String? googleEmail;
  String? googleSyncToken;
  DateTime _expiry = DateTime.utc(2099);
  GoogleSignIn? googleSignIn; //instance of google sign in; only set if web

  AuthModel() {
    enableSerialization("auth.dat");
  }

  //Helper method to quickly lookup last known auth state, does not mean user is necessarily verified, the auth token may be expired.
  bool get hasAuthKey => !StringUtils.isEmpty(_googleAccessToken);

  bool get isExpired => expiry.isBefore(DateTime.now());

  DateTime get expiry => _expiry;

  bool get isAuthenticated => !isExpired && hasAuthKey;

  //Using a setExpiry() method instead of a setter, because it's a bit weird to have different values (int for set vs DateTime for get).
  //Setting it with int makes more sense because the auth result returns expiry time in seconds.
  //Getting it with DateTime makes more sense because it's easier to deal with and check against.
  void setExpiry(int seconds) {
    _expiry = DateTime.now().add(Duration(seconds: seconds));
  }

  /////////////////////////////////////////////////////////////////////
  // Access Token
  String? _googleAccessToken;

  String get googleAccessToken => _googleAccessToken ?? "";

  set googleAccessToken(String value) {
    _googleAccessToken = value;
    notifyListeners();
  }

  @override
  void reset([bool notify = true]) {
    Log.p("[AuthModel] Reset");
    _googleAccessToken = null;
    googleRefreshToken = null;
    googleSyncToken = null;
    googleEmail = null;
    _expiry = DateTime.utc(2099);
    googleSignIn?.disconnect();
    super.reset(notify);
  }

  /////////////////////////////////////////////////////////////////////
  // Define serialization methods

  @override
  void copyFromJson(Map<String, dynamic> json) {
    this
      .._googleAccessToken = json["_googleAccessToken"]
      ..googleRefreshToken = json["googleRefreshToken"]
      ..googleSyncToken = json["googleSyncToken"]
      ..googleEmail = json["googleEmail"]
      .._expiry = json["_expiry"] != null ? DateTime.parse(json["_expiry"]) : Dates.epoch;
  }

  @override
  Map<String, dynamic> toJson() => {
        "_googleAccessToken": _googleAccessToken,
        "googleRefreshToken": googleRefreshToken,
        "googleSyncToken": googleSyncToken,
        "googleEmail": googleEmail,
        "_expiry": _expiry.toString()
      };
}
