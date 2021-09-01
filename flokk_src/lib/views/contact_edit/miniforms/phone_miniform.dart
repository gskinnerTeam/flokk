import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactPhoneMiniForm extends BaseMiniForm {
  ContactPhoneMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.phone, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.phone,
      hasContent: () => c.hasPhone,
      formBuilder: () {
        /// Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => buildColumnOfTextWithDropdown<PhoneData>(
              context, "Phone Number", "Type",
              itemList: c.phoneList,
              types: [
                "Work",
                "Other",
                "Mobile",
                "Main",
                "Home Fax",
                "Work Fax",
                "Google Voice",
                "Pager"
              ],
              newItemBuilder: () => PhoneData(),
              isEmpty: (PhoneData i) => i.isEmpty,
              getValue: (i) => i.number,
              setValue: (i, value) => i.number = value,
              getType: (i) => i.type,
              setType: (i, type) => i.type = type),
        );
      },
    );
  }
}
