import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactJobMiniForm extends BaseMiniForm {
  ContactJobMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.job, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.work,
      hasContent: () => c.hasJob,
      formBuilder: () {
        /// Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => SeparatedColumn(
            children: <Widget>[
              buildTextInput(
                  context, "Company", c.jobCompany, (v) => c.jobCompany = v,
                  autoFocus: isSelected),
              buildTextInput(
                  context, "Job Title", c.jobTitle, (v) => c.jobTitle = v),
            ],
          ).padding(right: rightPadding),
        );
      },
    );
  }
}
