import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/cupertino.dart';

class UpdateContactLabelsCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  UpdateContactLabelsCommand(BuildContext c) : super(c);

  Future<ContactData?> execute(ContactData contact) async {
    Log.p("[UpdateContactLabelsCommand]");
    await executeAuthServiceCmd(() async {
      //Get the existing labels for contact
      List<GroupData> existingGroups = contactsModel.getContactById(contact.id)?.groupList ?? [];

      //The updated labels for contact
      List<GroupData> updatedGroups = contact.groupList;

      List<GroupData> removeFrom = existingGroups.where((x) => !updatedGroups.any((y) => y.id == x.id)).toList();
      List<GroupData> addTo = updatedGroups.where((x) => !existingGroups.any((y) => y.id == x.id)).toList();

      ServiceResult result = ServiceResult(null, HttpResponse.empty());
      //Remove contact from groups they are no longer in
      for (var n in removeFrom) {
        result = await googleRestService.groups.modify(authModel.googleAccessToken, n, removeContacts: [contact]);
        print("Removed: ${n.name} from ${contact.nameFull}");
      }

      //Add contact to groups they are not in
      for (var n in addTo) {
        result = await googleRestService.groups.modify(authModel.googleAccessToken, n, addContacts: [contact]);
        print("Added: ${n.name} to ${contact.nameFull}");
      }
      return result;
    });
    return contactsModel.getContactById(contact.id);
  }
}
