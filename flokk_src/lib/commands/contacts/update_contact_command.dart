import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/commands/social/refresh_social_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';

class UpdateContactCommand extends AbstractCommand with AuthorizedServiceCommandMixin {
  UpdateContactCommand(BuildContext c) : super(c);

  Future<ContactData> execute(ContactData contact, {bool updateSocial: false, bool tryAgainOnError = true}) async {
    if (contact == ContactData() || AppModel.forceIgnoreGoogleApiCalls) return ContactData();
    Log.p("[UpdateContactCommand]");

    ServiceResult<ContactData> result = await executeAuthServiceCmd(() async {
      ServiceResult<ContactData> result;
      if (contact.isNew) {
        /// Update remote database
        result = await googleRestService.contacts.create(authModel.googleAccessToken, contact);
        if (result.success) {
          result.content!.isRecentlyAdded = true;
          contactsModel.addContact(result.content!);
        }
      } else {
        // Check whether git or twitter changed, if they did we want to reset their cooldowns
        ContactData oldContact = contactsModel.getContactById(contact.id);
        bool gitChanged = oldContact.gitUsername != contact.gitUsername;
        if (gitChanged) {
          githubModel.removeEvents(oldContact.gitUsername);
          githubModel.scheduleSave();
          contactsModel.clearGitCooldown(contact);
          updateSocial = contact.hasGit;
        }
        bool twitterChanged = oldContact.twitterHandle != contact.twitterHandle;
        if (twitterChanged) {
          twitterModel.removeTweets(oldContact.twitterHandle);
          twitterModel.scheduleSave();
          contactsModel.clearTwitterCooldown(contact);
          updateSocial = contact.hasTwitter;
        }

        /// Update local data optimistically
        contactsModel.swapContactById(contact);

        //Attempt to fetch social (does nothing if no social handles available)
        if (updateSocial) RefreshSocialCommand(context).execute([contact]);

        /// Update remote database
        result = await googleRestService.contacts.set(authModel.googleAccessToken, contact);

        /// Since we get back the updated object, we can inject it straight into the model to keep us in sync
        print("Success: ${result.success}, etag=${contact.etag}");
        if (result.success) {
          ContactData? updatedContact = result.content;
          if (updatedContact != null) {
            contactsModel.swapContactById(updatedContact);
            if (appModel.selectedContact.googleId == updatedContact.googleId) {
              appModel.selectedContact = updatedContact;
            }
          }
        } else if (tryAgainOnError &&
            result.response.statusCode == 400 &&
            result.response.body.contains("person.etag")) {
          //ignore the error to stop error popup
          ignoreErrors = true;
          await RefreshContactsCommand(context).execute(skipGroups: true);
          //try again with updated etag
          contact.etag = contactsModel.getContactById(contact.id).etag;
          execute(contact, tryAgainOnError: false);
        }
      }

      return result;
    });
    return result.success ? result.content! : ContactData();
  }
}
