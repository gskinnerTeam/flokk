import 'dart:convert';

import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/_internal/utils/rest_utils.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/services/service_result.dart';

class GoogleRestAuthService {
  final String discoveryUrl =
      "https://accounts.google.com/.well-known/openid-configuration";
  final String authUrl = "https://oauth2.googleapis.com/token";
  final String redirectUri = "https://oauth2.googleapis.com/callback";
  final String deviceCodeGrantType =
      "urn:ietf:params:oauth:grant-type:device_code";
  final String scope = "email https://www.googleapis.com/auth/contacts";

  final String _clientId;
  final String _clientSecret;

  GoogleRestAuthService(this._clientId, this._clientSecret);

  Future<ServiceResult<GoogleAuthEndpointInfo>> getAuthEndpoint() async {
    //print("Request: $discoveryUrl");
    HttpResponse discoverResponse = await HttpClient.get(discoveryUrl);
    //print("Response: ${discoverResponse.statusCode} / ${discoverResponse.body}");
    if (discoverResponse.success) {
      Map<String, dynamic> body = jsonDecode(discoverResponse.body);

      String url = "${body["device_authorization_endpoint"]}?";
      url += RESTUtils.encodeParams({"client_id": _clientId, "scope": scope});
      //print("Request: $url");
      HttpResponse authResponse = await HttpClient.post(url);
      //print("Response: ${authResponse.statusCode} / ${authResponse.body}");

      GoogleAuthEndpointInfo? endpoint;
      if (authResponse.success) {
        Map<String, dynamic> userAuth = jsonDecode(authResponse.body);
        endpoint = GoogleAuthEndpointInfo(
            deviceCode: userAuth["device_code"],
            expiresIn: userAuth["expires_in"],
            interval: userAuth["interval"],
            userCode: userAuth["user_code"],
            verificationUrl: userAuth["verification_url"]);
      }
      return ServiceResult(endpoint, authResponse);
    }
    return ServiceResult(null, discoverResponse);
  }

  Future<ServiceResult<GoogleAuthResults>> authorizeDevice(
          String deviceCode) async =>
      await _getAuthResults(deviceCode: deviceCode);

  Future<ServiceResult<GoogleAuthResults>> refresh(String refreshToken) async =>
      await _getAuthResults(refreshToken: refreshToken);

  Future<ServiceResult<GoogleAuthResults>> _getAuthResults(
      {String deviceCode = "", String refreshToken = ""}) async {
    String grant = !StringUtils.isEmpty(refreshToken)
        ? "refresh_token"
        : deviceCodeGrantType;
    Map<String, String> params = {
      "client_id": _clientId,
      "client_secret": _clientSecret,
      "grant_type": grant
    };
    if (!StringUtils.isEmpty(refreshToken)) {
      params.putIfAbsent("refreshToken", () => refreshToken);
    } else {
      params.putIfAbsent("device_code", () => deviceCode);
    }
    HttpResponse response =
        await HttpClient.post("$authUrl?${RESTUtils.encodeParams(params)}");
    print("Response: ${response.statusCode} / ${response.body}");
    GoogleAuthResults? results;
    if (response.success) {
      Map<String, dynamic> userAccess = jsonDecode(response.body);
      results = GoogleAuthResults(
          accessToken: userAccess["access_token"],
          expiresIn: userAccess["expires_in"],
          refreshToken: userAccess["refresh_token"],
          tokenType: userAccess["token_type"],
          idToken: userAccess["id_token"]);
    }

    return ServiceResult(results, response);
  }
}

class GoogleAuthEndpointInfo {
  final String deviceCode;
  final int expiresIn;
  final int interval;
  final String userCode;
  final String verificationUrl;

  GoogleAuthEndpointInfo(
      {required this.deviceCode,
      required this.expiresIn,
      required this.interval,
      required this.userCode,
      required this.verificationUrl});
}

class GoogleAuthResults {
  final String accessToken;
  final int expiresIn;
  final String? refreshToken;
  final String tokenType;
  final String idToken;
  late Map<String, dynamic> profile;

  String get email => _email;
  late String _email;

  GoogleAuthResults(
      {required this.accessToken,
      required this.expiresIn,
      required this.refreshToken,
      required this.tokenType,
      required this.idToken}) {
    profile = jsonDecode(getProfileFromToken(idToken));
    _email = profile["email"];
  }

  String getProfileFromToken(String idToken) {
    List<String> parts = idToken.split(".");
    var decoder = Base64Codec();
    String payload = decoder.normalize(parts[1]);
    return utf8.decode(decoder.decode(payload));
  }
}
