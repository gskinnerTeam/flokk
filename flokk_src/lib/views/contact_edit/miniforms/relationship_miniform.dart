import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactRelationshipMiniForm extends BaseMiniForm {
  final double maxDropdownHeight;

  ContactRelationshipMiniForm(ContactEditFormState form,
      {Key? key, required this.maxDropdownHeight})
      : super(form, ContactSectionType.relationship, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.relationship,
      hasContent: () => c.hasRelationship,
      formBuilder: () {
        // Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) => buildColumnOfTextWithDropdown<RelationData>(
            context,
            "Person",
            "Relationship",
            maxDropdownHeight: maxDropdownHeight,
            itemList: c.relationList,
            newItemBuilder: () => RelationData(),
            isEmpty: (RelationData i) => i.isEmpty,
            getValue: (i) => i.person,
            setValue: (i, value) => i.person = value,
            getType: (i) => i.type,
            setType: (i, type) => i.type = type,
            types: [
              "Spouse",
              "Child",
              "Mother",
              "Father",
              "Parent",
              "Brother",
              "Sister",
              "Friend",
              "Relative",
              "Manager",
              "Assistant",
              "Reference",
              "Partner",
              "Domestic Partner"
            ],
          ),
        );
      },
    );
  }
}
