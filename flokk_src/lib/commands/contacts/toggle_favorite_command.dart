import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/groups/refresh_contact_groups_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/services/google_rest/google_rest_service.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';

class ToggleFavoriteCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  ToggleFavoriteCommand(BuildContext c) : super(c);

  Future<bool> execute(ContactData contact) async {
    Log.p("[ToggleFavoriteCommand]");
    ServiceResult result = await executeAuthServiceCmd(() async {
      GroupData group = contactsModel.allGroups.firstWhere(
        (x) => x.id == GoogleRestService.kStarredGroupId,
        orElse: () => GroupData()..id = GoogleRestService.kStarredGroupId,
      );
      // Toggle the contact optimistically
      contact.isStarred = !contact.isStarred;
      contactsModel.notify();

      ServiceResult result;

      if (contact.isStarred) {
        //add to favorites group
        result = await googleRestService.groups.modify(authModel.googleAccessToken, group, addContacts: [contact]);
      } else {
        //remove from favorites group
        result = await googleRestService.groups.modify(authModel.googleAccessToken, group, removeContacts: [contact]);
      }
      // Dispatch background refresh command to make sure we're in sync
      RefreshContactGroupsCommand(context).execute(onlyStarred: true);
      return result;
    });
    return result.success;
  }
}
