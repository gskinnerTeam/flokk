import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_info/contact_info_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Holds the Contact Info and Edit pages, and provides an API to switch between them
class ContactPanel extends StatefulWidget {
  final VoidCallback? onClosePressed;
  final ContactsModel contactsModel;

  const ContactPanel({Key? key, this.onClosePressed, required this.contactsModel}) : super(key: key);

  @override
  ContactPanelState createState() => ContactPanelState();
}

class ContactPanelState extends State<ContactPanel> {
  GlobalKey<ContactInfoPanelState> detailsKey = GlobalKey();
  GlobalObjectKey<ContactEditFormState>? editKey;
  ContactData? _prevContact;

  bool _isEditingContact = false;

  String _initialEditSection = "";

  bool get hasUnsavedChanged => _isEditingContact && (editKey?.currentState?.isDirty ?? false);

  void showEditView(String sectionType) {
    _initialEditSection = sectionType;
    setState(() => _isEditingContact = true);
  }

  void showInfoView() {
    setState(() => _isEditingContact = false);
  }

  void _handleEditPressed(String? startSection) => showEditView(startSection ?? "");

  void _handleEditComplete(ContactData? contact) {
    /// If contact is not null, then we want to switch back to the InfoView
    if (contact != null) {
      showInfoView();
    }

    /// Set selected contact, this will hide the panel if the edit form returns null
    context.read<AppModel>().selectedContact = contact;
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();

    return StyledContainer(
      theme.surface,
      borderRadius: BorderRadius.only(
        topLeft: Corners.s10Radius,
        bottomLeft: Corners.s10Radius,
      ),
      shadows: Shadows.m(theme.accent1Darker),
      child: Consumer<ContactData?>(
        builder: (_, contact, __) {

          /// When contact has been set to null, we want to use the prevContact so we get a clean transition out
          /// Bit of a hack, but not sure how else to maintain state as we slide out.
          contact ??= _prevContact;
          if (contact != null)
            _prevContact = contact;

          /// Anytime we're working on a new contact, we want to be in edit mode
          contact ??= ContactData();
          if (contact.isNew) _isEditingContact = true;

          /// Create a key from each unique contact to make sure we get state-rebuilds when changing Contact
          editKey = GlobalObjectKey(contact);

          return Provider.value(
            /// Pass either the latest contact, or the previous, down the tree
            value: contact,
            child: (_isEditingContact
                    ? ContactEditForm(
                        key: editKey,
                        initialSection: _initialEditSection,
                        contact: contact,
                        contactsModel: widget.contactsModel,
                        onEditComplete: _handleEditComplete,
                      )
                    : ContactInfoPanel(
                        key: detailsKey,
                        onClosePressed: widget.onClosePressed,
                        onEditPressed: _handleEditPressed,
                      ))
                .constrained(
                  width: double.infinity,
                  height: double.infinity,
                )
                .padding(
                  top: Insets.l * .75,
                ),
          );
        },
      ),
    );
  }
}
