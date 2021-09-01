import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/groups/refresh_contact_groups_command.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/cupertino.dart';

class DeleteLabelCommand extends AbstractCommand
    with AuthorizedServiceCommandMixin {
  DeleteLabelCommand(BuildContext c) : super(c);

  Future<bool> execute(GroupData group) async {
    if (group == GroupData()) return false;
    Log.p("[DeleteLabelCommand]");
    ServiceResult result = await executeAuthServiceCmd(() async {
      ServiceResult result = await googleRestService.groups
          .delete(authModel.googleAccessToken, group);
      if (result.success) {
        //refresh the groups to ensure labels synced
        await RefreshContactGroupsCommand(context).execute(forceUpdate: true);
      }
      return result;
    });
    return result.success;
  }
}
