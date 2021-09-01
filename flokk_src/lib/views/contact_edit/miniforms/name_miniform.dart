import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactNameMiniForm extends BaseMiniForm {
  ContactNameMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.name, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.user,
      hasContent: () => c.hasName,
      formBuilder: () {
        /// Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => SeparatedColumn(
            separatorBuilder: () => VSpace(Insets.sm * .5),
            children: <Widget>[
              buildTextInput(
                  context, "First Name", c.nameGiven, (v) => c.nameGiven = v,
                  autoFocus: isSelected),
              buildTextInput(context, "Middle Name", c.nameMiddle,
                  (v) => c.nameMiddle = v),
              buildTextInput(
                  context, "Last Name", c.nameFamily, (v) => c.nameFamily = v),
              buildDualTextInput(
                  context,
                  "Prefix",
                  c.namePrefix,
                  (v) => c.namePrefix = v,
                  "Suffix",
                  c.nameSuffix,
                  (v) => c.nameSuffix = v),
            ],
          ).padding(right: rightPadding),
        );
      },
    );
  }
}
