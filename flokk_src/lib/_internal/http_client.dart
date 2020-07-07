import 'dart:convert';

import 'package:flokk/_internal/log.dart';
import 'package:http/http.dart' as http;

enum NetErrorType {
  none,
  disconnected,
  timedOut,
  denied,
}

typedef Future<http.Response> HttpRequest();

class HttpClient {
  static Future<HttpResponse> get(String url, {Map<String, String> headers}) async {
    return await _request(() async {
      return await http.get(url, headers: headers);
    });
  }

  static Future<HttpResponse> post(String url, {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    return await _request(() async {
      return await http.post(url, headers: headers, body: body, encoding: encoding);
    });
  }

  static Future<HttpResponse> put(String url, {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    return await _request(() async {
      return await http.put(url, headers: headers, body: body, encoding: encoding);
    });
  }

  static Future<HttpResponse> patch(String url, {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    return await _request(() async {
      return await http.patch(url, headers: headers, body: body, encoding: encoding);
    });
  }

  static Future<HttpResponse> delete(String url, {Map<String, String> headers}) async {
    return await _request(() async {
      return await http.delete(url, headers: headers);
    });
  }

  static Future<HttpResponse> head(String url, {Map<String, String> headers}) async {
    return await _request(() async {
      return await http.head(url, headers: headers);
    });
  }

  static Future<HttpResponse> _request(HttpRequest request) async {
    http.Response response;
    try {
      response = await request();
    } on Exception catch (e) {
      Log.e("Network call failed. error = ${e.toString()}");
    }
    return HttpResponse(response);
  }
}

class HttpResponse {
  final http.Response raw;

  NetErrorType errorType;

  bool get success => errorType == NetErrorType.none;

  String get body => raw?.body;

  Map<String, String> get headers => raw?.headers;

  int get statusCode => raw?.statusCode ?? -1;

  HttpResponse(this.raw) {
    //No response at all, there must have been a connection error
    if (raw == null)
      errorType = NetErrorType.disconnected;
    //200 means all is good :)
    else if (raw.statusCode == 200)
      errorType = NetErrorType.none;
    //500's, server is probably down
    else if (raw.statusCode >= 500 && raw.statusCode < 600)
      errorType = NetErrorType.timedOut;
    //400's server is denying our request, probably bad auth or malformed request
    else if (raw.statusCode >= 400 && raw.statusCode < 500) errorType = NetErrorType.denied;
  }
}
