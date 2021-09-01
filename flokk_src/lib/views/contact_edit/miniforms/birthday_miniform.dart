import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/controls/textfield_with_date_picker_row.dart';
import 'package:flutter/material.dart';

class ContactBirthdayMiniForm extends BaseMiniForm {
  ContactBirthdayMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.birthday, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.birthday,
      hasContent: () => c.hasBirthday,
      formBuilder: () {
        return TextfieldWithDatePickerRow(
          this,
          hint: "Birthday",
          isSelected: isSelected,
          initialValue: c.birthday.text,
          onDateChanged: (string, date) {
            c.birthday.text = string;
            c.birthday.date = date;
          },
        );
      },
    );
  }
}
