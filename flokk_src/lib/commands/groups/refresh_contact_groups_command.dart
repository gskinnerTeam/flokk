import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/google_rest/google_rest_contact_groups_service.dart';
import 'package:flokk/services/google_rest/google_rest_service.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tuple/tuple.dart';

class RefreshContactGroupsCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  RefreshContactGroupsCommand(BuildContext c) : super(c);

  Future<List<GroupData>> execute({bool onlyStarred = false, bool forceUpdate = false}) async {
    Log.p("[RefreshContactGroupsCommand]");

    if (contactsModel.canRefreshContactGroups || forceUpdate || AppModel.ignoreCooldowns) {
      contactsModel.lastUpdatedGroups = DateTime.now();

      await executeAuthServiceCmd(() async {
        GoogleRestContactGroupsService groupsApi = googleRestService.groups;
        ServiceResult<GroupData> result = ServiceResult(null, HttpResponse.empty());
        if (onlyStarred) {
          result =
              await groupsApi.getById(authModel.googleAccessToken, GoogleRestService.kStarredGroupId);
          if (result.success) {
            GroupData? starred = contactsModel.getGroupById(GoogleRestService.kStarredGroupId);
            if (starred != null) {
              starred.members = result.content?.members ?? [];
            } else {
              contactsModel.allGroups.add(result.content!);
            }
          }
        } else {
          ServiceResult<Tuple2<List<GroupData>, String>> result = await groupsApi.get(authModel.googleAccessToken);
          List<GroupData> groups = result.content?.item1 ?? [];
          String nextPageToken = result.content?.item2 ?? "";

          while (nextPageToken != "" && result.success) {
            ServiceResult<Tuple2<List<GroupData>, String>> result =
                await groupsApi.get(authModel.googleAccessToken, nextPageToken: nextPageToken);
            groups.addAll(result.content?.item1 ?? []);
            nextPageToken = result.content?.item2 ?? "";
          }

          if (groups.isNotEmpty && result.success) {
            //Need to fetch each individual group to get members list
            for (int i = 0; i < groups.length; i++) {
              if (groups[i].memberCount > 0 || groups[i].id == GoogleRestService.kStarredGroupId) {
                ServiceResult<GroupData> groupResult =
                    await groupsApi.getById(authModel.googleAccessToken, groups[i].id);
                if (groupResult.success) {
                  groups[i].members = groupResult.content?.members ?? [];
                }
              }
            }
            contactsModel.allGroups = groups;
            contactsModel.scheduleSave();
          }
          Log.p("Groups loaded = ${groups.length}");
        }
        return result;
      });
    }
    return contactsModel.allGroups;
  }
}
