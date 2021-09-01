import 'dart:convert';

import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:googleapis/people/v1.dart';
import 'package:tuple/tuple.dart';

class GoogleRestContactGroupsService {
  Future<ServiceResult<Tuple2<List<GroupData>, String>>> get(String accessToken,
      {String nextPageToken = ""}) async {
    String url = "https://people.googleapis.com/v1/contactGroups"
        "?access_token=$accessToken"
        "&pageSize=1000";

    if (nextPageToken.isNotEmpty) {
      url += "&pageToken=$nextPageToken";
    }

    HttpResponse response = await HttpClient.get(url);
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    List<GroupData> groups = [];
    String token = "";
    if (response.success == true) {
      Map<String, dynamic> data = jsonDecode(response.body);
      token = data["nextPageToken"] ?? "";
      List<dynamic> groupsData = data["contactGroups"];
      for (Map<String, dynamic> n in groupsData) {
        GroupData group = groupFromJson(n);
        groups.add(group);
      }
    }
    return ServiceResult(
        Tuple2<List<GroupData>, String>(groups, token), response);
  }

  Future<ServiceResult<GroupData>> getById(
      String accessToken, String groupId) async {
    String url = "https://people.googleapis.com/v1/$groupId"
        "?access_token=$accessToken"
        "&maxMembers=1000";

    HttpResponse response = await HttpClient.get(url);
    //print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    GroupData? group;
    if (response.success == true) {
      group = groupFromJson(jsonDecode(response.body));
    }
    return ServiceResult(group, response);
  }

  Future<ServiceResult<GroupData>> create(
      String accessToken, GroupData group) async {
    String url = "https://people.googleapis.com/v1/contactGroups";

    HttpResponse response = await HttpClient.post(url,
        headers: {"Authorization": "Bearer $accessToken"},
        body: jsonEncode({"contactGroup": groupToJson(group)}));
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    GroupData? newGroup;
    if (response.success == true) {
      Map<String, dynamic> data = jsonDecode(response.body);
      newGroup = groupFromJson(data);
    }
    return ServiceResult(newGroup, response);
  }

  Future<ServiceResult<void>> delete(
      String accessToken, GroupData group) async {
    String url = "https://people.googleapis.com/v1/${group.id}";

    HttpResponse response = await HttpClient.delete(
      url,
      headers: {"Authorization": "Bearer $accessToken"},
    );
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    return ServiceResult(null, response);
  }

  Future<ServiceResult<void>> modify(String accessToken, GroupData group,
      {List<ContactData> addContacts = const <ContactData>[],
      List<ContactData> removeContacts = const <ContactData>[]}) async {
    String url = "https://people.googleapis.com/v1/${group.id}/members:modify";

    Map<String, dynamic> data = {};
    if (addContacts.isNotEmpty) {
      data["resourceNamesToAdd"] = addContacts.map((x) => x.id).toList();
    }
    if (removeContacts.isNotEmpty) {
      data["resourceNamesToRemove"] = removeContacts.map((x) => x.id).toList();
    }

    HttpResponse response = await HttpClient.post(
      url,
      headers: {"Authorization": "Bearer $accessToken"},
      body: jsonEncode(data),
    );
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    return ServiceResult(null, response);
  }

  Future<ServiceResult<GroupData>> set(
      String accessToken, GroupData group) async {
    String url = "https://people.googleapis.com/v1/${group.id}";

    HttpResponse response = await HttpClient.put(url,
        headers: {"Authorization": "Bearer $accessToken"},
        body: jsonEncode({"contactGroup": groupToJson(group)}));
    print("REQUEST: $url /// RESPONSE: ${response.statusCode}");
    GroupData? updatedContact;
    if (response.success == true) {
      //updated contact group returned from server
      Map<String, dynamic> data = jsonDecode(response.body);
      updatedContact = groupFromJson(data);
    }
    return ServiceResult(updatedContact, response);
  }

  GroupData groupFromJson(Map<String, dynamic> json) {
    final g = ContactGroup.fromJson(json);
    //print(g.name);
    final groupData = GroupData()
      ..id = g.resourceName ?? ""
      ..etag = g.etag ?? ""
      ..name = g.name ?? ""
      ..memberCount = g.memberCount ?? 0
      ..members = g.memberResourceNames ?? [];

    switch (g.groupType) {
      case "GROUP_TYPE_UNSPECIFIED":
        groupData.groupType = GroupType.Unspecified;
        break;
      case "USER_CONTACT_GROUP":
        groupData.groupType = GroupType.UserContactGroup;
        break;
      case "SYSTEM_CONTACT_GROUP":
        groupData.groupType = GroupType.SystemContactGroup;
        break;
      default:
        groupData.groupType = GroupType.Unspecified;
    }

    return groupData;
  }

  Map<String, dynamic> groupToJson(GroupData group) {
    final contactGroup = ContactGroup()
      ..resourceName = group.id
      ..etag = group.etag
      ..name = group.name
      ..memberCount = group.memberCount
      ..memberResourceNames = group.members;
    return contactGroup.toJson();
  }
}
