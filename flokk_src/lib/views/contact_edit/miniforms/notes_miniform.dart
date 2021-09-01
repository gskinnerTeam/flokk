import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactNotesMiniForm extends BaseMiniForm {
  ContactNotesMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.notes, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.note,
      hasContent: () => c.hasNotes,
      formBuilder: () {
        /// Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => SeparatedColumn(
            children: <Widget>[
              buildTextInput(
                context,
                "Notes",
                c.notes,
                (v) => c.notes = v,
                autoFocus: isSelected,
                maxLines: null,
              )
            ],
          ).padding(right: rightPadding),
        );
      },
    );
  }
}
