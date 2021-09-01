import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';

class ContactAddressMiniForm extends BaseMiniForm {
  ContactAddressMiniForm(ContactEditFormState form, {Key? key})
      : super(form, ContactSectionType.address, key: key);

  @override
  Widget build(BuildContext context) {
    List<String> types = ["Home", "Work", "Other"];
    return buildExpandingContainer(
      StyledIcons.address,
      hasContent: () => c.hasAddress,
      formBuilder: () {
        /// Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) {
            if (c.addressList.isEmpty) c.addressList.add(AddressData());
            List<Widget> kids = c.addressList.map<Widget>((a) {
              return SeparatedColumn(
                  key: ObjectKey(a),
                  separatorBuilder: () => VSpace(Insets.xs),
                  children: [
                    /// Street + Type
                    buildTextWithDropdown(
                      context,
                      null,
                      autoFocus: getIsFocused<AddressData>(c.addressList, a),
                      hint: "Street",
                      typeHint: "Type",
                      initialText: a.singleLineStreet,
                      initialType: a.type,
                      types: types.map((e) => e.toUpperCase()).toList(),
                      onTextChanged: (value) =>
                          setFormState(() => a.street = value),
                      onTypeChanged: (value) =>
                          setFormState(() => a.type = value),
                      onDelete: () => handleDeletePressed<AddressData>(
                          context, a, c.addressList),
                      showDelete: !a.isEmpty,
                      typeWidth: 160,
                    ),

                    /// City / State
                    buildDualTextInput(
                      context,
                      "City",
                      a.city,
                      (v) => setFormState(() => a.city = v),
                      "State",
                      a.region,
                      (v) => setFormState(() => a.region = v),
                    ).padding(right: rightPadding),

                    /// Country / Postal Code
                    buildDualTextInput(
                      context,
                      "Postal Code",
                      a.postcode,
                      (v) => setFormState(() => a.postcode = v),
                      "Country",
                      a.country,
                      (v) => setFormState(() => a.country = v),
                    ).padding(right: rightPadding),
//TODO: Put the country-dropdown back in when we have time to debug the height issue.
//                buildTextWithDropdown(
//                  context,
//                  null,
//                  hint: "Postal Code",
//                  typeHint: "Country",
//                  initialText: a.postcode,
//                  initialType: a.country,
//                  types: Countries.all.map((e) => e.toUpperCase()).toList(),
//                  onTextChanged: (value) => setFormState(() => a.postcode = value),
//                  onTypeChanged: (value) => setFormState(() => a.country = value),
//                  showDelete: false,
//                  typeWidth: 160,
//                ),

                    if (c.addressList.indexOf(a) < c.addressList.length - 1)
                      VSpace(Insets.m),
                  ]);
            }).toList();

            /// Maybe add addNew btn
            injectAddNewBtnIfNecessary<AddressData>("Add $sectionType", kids,
                c.addressList, (a) => a.isEmpty, () => AddressData());
            return SeparatedColumn(
                separatorBuilder: () => VSpace(Insets.sm),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: kids);
          },
        );
      },
    );
  }
}
