import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/google_rest/google_rest_contacts_service.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';
import 'package:flutter/cupertino.dart';

class DeleteContactCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  DeleteContactCommand(BuildContext c) : super(c);

  Future<bool> execute(List<ContactData> contacts, {VoidCallback? onDeleteConfirmed}) async {
    if (contacts.isEmpty || AppModel.forceIgnoreGoogleApiCalls) return false;
    Log.p("[DeleteContactCommand]");
    String txt = contacts.length > 1 ? "these ${contacts.length} contacts" : "this contact";
    bool doDelete = await Dialogs.show(
      OkCancelDialog(
        message: "Are you sure you want to delete $txt?",
        okLabel: "Yes",
        cancelLabel: "No",
        onOkPressed: () => rootNav?.pop(true),
        onCancelPressed: () => rootNav?.pop(false),
      ),
    );
    if (!doDelete) return false;
    onDeleteConfirmed?.call();

    GoogleRestContactsService service = googleRestService.contacts;
    ServiceResult result = await executeAuthServiceCmd(() async {
      /// Update local data optimistically
      for (var c in contacts) {
        contactsModel.removeContact(c);
      }

      /// Create a list of futures
      List<Future<ServiceResult>> futures =
          contacts.map((c) => service.delete(authModel.googleAccessToken, c)).toList();
      // Dispatch them all at once
      List<ServiceResult> results = await Future.wait(futures);
      //Request succeeded?
      ServiceResult result = results[0];
      if (result.success) {
        RefreshContactsCommand(context).execute();
      }
      return result;
    });
    return result.success;
  }
}
