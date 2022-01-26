import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';

class UpdatePicCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  UpdatePicCommand(BuildContext c) : super(c);

  Future<bool> execute(ContactData contact, String base64Pic) async {
    if (AppModel.forceIgnoreGoogleApiCalls) return false;
    Log.p("[UpdatePicCommand]");

    ServiceResult result = await executeAuthServiceCmd(() async {
      ServiceResult result =
          await googleRestService.contacts.updatePic(authModel.googleAccessToken, contact, base64Pic);
      if (result.success) {
        contact.profilePic = result.content.profilePic;
        contact.isDefaultPic = result.content.isDefaultPic;
        await RefreshContactsCommand(context).execute();
      }
      return result;
    });
    return result.success;
  }
}
