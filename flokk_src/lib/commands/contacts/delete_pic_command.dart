import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';
import 'package:flutter/src/widgets/framework.dart';

class DeletePicCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  DeletePicCommand(BuildContext c) : super(c);

  Future<bool> execute(ContactData contact) async {
    if (AppModel.forceIgnoreGoogleApiCalls) return false;
    Log.p("[DeletePicCommand]");

    bool doDelete = await Dialogs.show(
      OkCancelDialog(
        message: "Are you sure you want to delete profile pic?",
        okLabel: "Yes",
        cancelLabel: "No",
        onOkPressed: () => rootNav?.pop(true),
        onCancelPressed: () => rootNav?.pop(false),
      ),
    );
    if (!doDelete) return false;

    //TODO: replace the profile pic
    //Update local data optimistically
    ServiceResult result = await executeAuthServiceCmd(() async {
      //Update remove database
      ServiceResult result = await googleRestService.contacts.deletePic(authModel.googleAccessToken, contact);
      //Request succeeded?
      if (result.success) {
        RefreshContactsCommand(context).execute();
      }
      return result;
    });
    return result.success;
  }
}
