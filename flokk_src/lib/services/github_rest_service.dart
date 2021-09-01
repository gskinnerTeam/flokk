import 'dart:convert';
import 'dart:typed_data';

import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/api_keys.dart';
import 'package:flokk/data/git_event_data.dart';
import 'package:flokk/data/git_repo_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:github/github.dart';

class GithubRestService {
  Map<String, String> _getAuthHeader() {
    final String key = Uri.encodeQueryComponent(ApiKeys().githubKey);
    final String secret = Uri.encodeQueryComponent(ApiKeys().githubSecret);
    final Uint8List bytes = AsciiEncoder().convert("$key:$secret");
    final String auth = base64Encode(bytes);
    return {
      "Authorization": "Basic $auth",
    };
  }

  Future<ServiceResult<List<GitEvent>>> getUserEvents(
      String githubUsername) async {
    String url = "https://api.github.com/users/$githubUsername/events";

    HttpResponse response =
        await HttpClient.get(url, headers: _getAuthHeader());
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");

    List<GitEvent> events = [];
    if (response.success == true) {
      List<Map<String, dynamic>> data = List.from(jsonDecode(response.body));
      for (Map<String, dynamic> n in data) {
        events.add(GitEvent()..event = Event.fromJson(n));
      }
    }
    return ServiceResult(events, response);
  }

  Future<ServiceResult<List<GitRepo>>> getUserRepos(
      String githubUsername) async {
    String url = "https://api.github.com/users/$githubUsername/repos";

    HttpResponse response =
        await HttpClient.get(url, headers: _getAuthHeader());
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");

    List<GitRepo> repos = [];
    if (response.success == true) {
      List<Map<String, dynamic>> data = List.from(jsonDecode(response.body));
      for (Map<String, dynamic> n in data) {
        repos.add(GitRepo()
          ..repository = Repository.fromJson(n)
          ..lastUpdated = DateTime.now());
      }
    }
    return ServiceResult(repos, response);
  }

  Future<ServiceResult<GitRepo>> getRepo(String repoName) async {
    String url = "https://api.github.com/repos/$repoName";

    HttpResponse response =
        await HttpClient.get(url, headers: _getAuthHeader());
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");

    GitRepo? repo;
    if (response.success == true) {
      repo = GitRepo()
        ..repository = Repository.fromJson(jsonDecode(response.body))
        ..lastUpdated = DateTime.now();
    }
    return ServiceResult(repo, response);
  }
}
