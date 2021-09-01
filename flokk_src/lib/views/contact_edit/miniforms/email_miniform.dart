import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactEmailMiniForm extends BaseMiniForm {
  ContactEmailMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.email, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.mail,
      hasContent: () => c.hasEmail,
      formBuilder: () {
        // Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => buildColumnOfTextWithDropdown<EmailData>(
              context, "Email Address", "Type",
              itemList: c.emailList,
              types: ["Home", "Work", "Other"],
              newItemBuilder: () => EmailData(),
              isEmpty: (EmailData i) => i.isEmpty,
              getValue: (i) => i.value,
              setValue: (i, value) => i.value = value,
              getType: (i) => i.type,
              setType: (i, type) => i.type = type),
        );
      },
    );
  }
}
