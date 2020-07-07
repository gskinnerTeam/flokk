import 'package:flokk/_internal/universal_picker/universal_picker.dart';
import 'package:flokk/commands/contacts/delete_contact_command.dart';
import 'package:flokk/commands/contacts/update_contact_command.dart';
import 'package:flokk/commands/contacts/update_pic_command.dart';
import 'package:flokk/commands/dialogs/show_discard_warning_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactSectionType {
  static String name = "name";
  static String label = "label";
  static String email = "email";
  static String phone = "phone";
  static String github = "github";
  static String twitter = "twitter";
  static String address = "address";
  static String birthday = "birthday";
  static String job = "job";
  static String events = "event";
  static String websites = "link";
  static String notes = "notes";
  static String relationship = "relationship";
}

class ContactEditForm extends StatefulWidget {
  final ContactData contact;
  final ContactsModel contactsModel;
  final Function(ContactData contact) onEditComplete;
  final String initialSection;

  const ContactEditForm({Key key, this.contact, this.contactsModel, this.onEditComplete, this.initialSection})
      : super(key: key);

  @override
  ContactEditFormState createState() => ContactEditFormState();
}

class ContactEditFormState extends State<ContactEditForm> {
  ContactData tmpContact;
  bool isLoading = false;
  String currentSection;

  // Convenience lookup method for the mini-forms.
  // Since they are stateless, and use a lot of internal buildMethods, it's a lot less
  // boilerplate if they can just fetch the theme here,
  AppTheme get theme => Provider.of(context, listen: false);

  bool get isDirty {
    if (tmpContact == null) return false;
    // Create a copy of our tmp object, and strip it of empty listItems,
    var tc = tmpContact.copy().trimLists();
    return !tc.equals(widget.contact);
  }

  @override
  void initState() {
    tmpContact = widget.contact.copy();
    currentSection = widget.initialSection;
    super.initState();
  }

  @override
  void didUpdateWidget(ContactEditForm oldWidget) {
    if (tmpContact == null || oldWidget.contact != widget.contact) {
      tmpContact = widget.contact.copy();
    }
    super.didUpdateWidget(oldWidget);
  }

  void handleSavePressed() async {
    bool success = true;
    print("================= SAVE PRESSED ======================");

    /// Strip contact of any empty list items before saving
    ContactData contact = tmpContact.copy().trimLists();

    // Adding a new contact?
    if (contact.isNew) {
      //Prevent them from adding an empty contact
      if (contact.equals(ContactData())) {
        success = false;
        await Dialogs.show(OkCancelDialog(
          message: "You can not add a completely empty contact. Add some info!",
          onOkPressed: () => Navigator.pop(context),
        ));
      }
      //Continue to add new contact
      else {
        setState(() => isLoading = true);
        // Wait for add-new command to complete, since it would be overly complicated to create a tmpUser
        contact = await UpdateContactCommand(context).execute(contact, updateSocial: contact.hasAnySocial);
        // Upload their image if it's changed
        if (tmpContact.hasNewProfilePic) {
          UpdatePicCommand(context).execute(contact, tmpContact.profilePicBase64);
        }
        // If we have a valid contact here, all is good
        success = contact != null;
        if(mounted){
          setState(() => isLoading = false);
        }
      }
    } else {
      // Updating a contact, don't wait, just assume it will work. Data will get updated locally.
      UpdateContactCommand(context).execute(contact, updateSocial: !contact.hasSameSocial(widget.contact));
      // Upload their image if it's changed.
      if (tmpContact.hasNewProfilePic) {
        UpdatePicCommand(context).execute(contact, tmpContact.profilePicBase64);
      }
    }
    if (success) {
      widget.onEditComplete?.call(contact);
      //Edit is complete, make sure this contact is the currently selected
      context?.read<AppModel>()?.selectedContact = contact;

    }
  }

  void handleDeletePressed() async => await DeleteContactCommand(context).execute([widget.contact]);

  void handleCancelPressed() async {
    bool doCancel = true;
    if (isDirty) {
      doCancel = await ShowDiscardWarningCommand(context).execute();
    }
    if (doCancel ?? false) {
      /// If we're cancelling a new contact, return null indicating that it should be discarded
      widget.onEditComplete?.call(tmpContact.isNew ? null : widget.contact);
    }
  }

  void handleSectionChanged(String section) {
    setState(() => currentSection = section);
  }

  void rebuild() => setState(() {});

  void handlePhotoPressed() async {
    final picker = UniversalPicker(accept: "image/");
    picker.onChange = (String e) {
      tmpContact.profilePicBase64 = picker.base64Data;
      tmpContact.profilePicBytes = picker.byteData;
      tmpContact.hasNewProfilePic = true;
    };

    picker.open();
  }

  @override
  Widget build(BuildContext context) => ContactEditFormView(this);
}
