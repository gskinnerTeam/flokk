import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/groups/refresh_contact_groups_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/services/google_rest/google_rest_contacts_service.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';

class RefreshContactsCommand extends AbstractCommand
    with AuthorizedServiceCommandMixin {
  RefreshContactsCommand(BuildContext c) : super(c);

  Future<ServiceResult> execute({bool skipGroups = false}) async {
    Log.p("[RefreshContactsCommand]");

    ServiceResult<GetContactsResult> result =
        await executeAuthServiceCmd(() async {
      // Check if we have a sync token...
      String syncToken = authModel.googleSyncToken ?? "";
      if (contactsModel.allContacts.isEmpty) {
        syncToken = "";
      }
      ServiceResult<GetContactsResult> result = await googleRestService.contacts
          .getAll(authModel.googleAccessToken, syncToken);
      // Now do we have a sync token?
      syncToken = result.content?.syncToken ?? "";
      List<ContactData> contacts = result.content?.contacts ?? [];
      if (result.success) {
        authModel.googleSyncToken = syncToken;
        //Iterate through returned contacts and either update existing contact or append
        for (ContactData n in contacts) {
          if (contactsModel.allContacts.any((x) => x.id == n.id)) {
            contactsModel.swapContactById(n);
          } else {
            contactsModel.addContact(n);
          }
        }
        contactsModel.allContacts.removeWhere((ContactData c) => c.isDeleted);
        contactsModel.notify();
        contactsModel.scheduleSave();
      }
      //Update the groups?
      if (!skipGroups) {
        await RefreshContactGroupsCommand(context).execute();
      }
      Log.p("Contacts loaded = ${contacts.length}");
      return result;
    });
    return result;
  }
}
