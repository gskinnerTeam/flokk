import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/groups/refresh_contact_groups_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/cupertino.dart';

class RemoveLabelFromContactCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  RemoveLabelFromContactCommand(BuildContext c) : super(c);

  Future<ContactData?> execute(ContactData contact, GroupData group) async {
    Log.p("[RemoveLabelFromContactCommand]");

    await executeAuthServiceCmd(() async {
      ServiceResult result = await googleRestService.groups.modify(authModel.googleAccessToken, group, removeContacts: [contact]);
      if (result.success) {
        //refresh the groups to ensure labels synced
        await RefreshContactGroupsCommand(context).execute(forceUpdate: true);
      }
      return result;
    });
    return contactsModel.getContactById(contact.id);
  }
}
