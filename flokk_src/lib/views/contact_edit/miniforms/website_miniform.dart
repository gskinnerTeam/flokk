import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactWebsiteMiniForm extends BaseMiniForm {
  ContactWebsiteMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.websites, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.link,
      hasContent: () => c.hasLink,
      formBuilder: () {
        // Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => buildColumnOfTextWithDropdown<WebsiteData>(
              context, "Link", "Type",
              itemList: c.websiteList,
              types: ["Blog", "Home Page", "Profile", "Work"],
              newItemBuilder: () => WebsiteData(),
              isEmpty: (WebsiteData i) => i.isEmpty,
              getValue: (i) => i.href,
              setValue: (i, value) => i.href = value,
              getType: (i) => i.type,
              setType: (i, type) => i.type = type),
        );
      },
    );
  }
}
