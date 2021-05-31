import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/styled_autocomplete_dropdown.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/controls/textfield_with_date_picker_row.dart';
import 'package:flutter/material.dart';

class ContactEventsMiniForm extends BaseMiniForm {
  ContactEventsMiniForm(ContactEditFormState form, {Key? key}) : super(form, ContactSectionType.events, key: key);

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.calendar,
      hasContent: () => c.hasEvents,
      formBuilder: () {
        //If we've been given an empty list, populate it with at least one item.
        var itemList = c.eventList;
        EventData newItemBuilder() => EventData()..date = DateTime.now();
        if (itemList.isEmpty) itemList.add(newItemBuilder());

        /// Build a list of rows for each item in the list
        List<Widget> kids = itemList.map((item) {
          // Create a TextAndTypeRow widget
          return buildTextWithDatePickerAndDropdown(context, item,
              autoFocus: getIsFocused(itemList, item),
              hint: "Event",
              typeHint: "Type",
              initialText: DateFormats.google.format(item.date),
              initialType: item.type,
              types: ["Anniversary", "Hire Date", "Other"].map((e) => e.toUpperCase()).toList(),
              onDateChanged: (s, d) => setFormState(() => item.date = d),
              onTypeChanged: (value) => setFormState(() => item.type = value),
              onDelete: () => handleDeletePressed(context, item, itemList),
              showDelete: !item.isEmpty);
        }).toList();

        /// Add a "Add New" btn to the column if certain conditions are met
        injectAddNewBtnIfNecessary<EventData>("Event", kids, itemList, (e) => e.isEmpty, newItemBuilder);

        /// Return the actual Column of content
        return SeparatedColumn(
          separatorBuilder: ()=>VSpace(Insets.sm * 1.5),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: kids,
        );
      },
    );
  }

  Widget buildTextWithDatePickerAndDropdown(BuildContext context, dynamic item,
      {String hint = "",
      String typeHint = "",
      String? initialText,
      String? initialType,
      List<String> types = const <String>[],
      void Function(String, DateTime)? onDateChanged,
      void Function(String)? onTypeChanged,
      VoidCallback? onDelete,
      bool showDelete = true,
      bool autoFocus = false,
      double typeWidth = 100}) {
    return Row(
      key: item != null ? ObjectKey(item) : null,
      children: <Widget>[
        /// Text Input
        TextfieldWithDatePickerRow(
          this,
          hint: hint,
          initialValue: initialText,
          onDateChanged: onDateChanged,
          isSelected: autoFocus,
        ).flexible(),
        HSpace(Insets.m),

        /// Type dropdown
        StyledAutoCompleteDropdown(
            items: types,
            hint: typeHint,
            initialValue: initialType,
            onChanged: onTypeChanged,
            onFocusChanged: (v) => handleFocusChanged(v, context)).width(typeWidth).translate(offset: Offset(0, 3)),
        HSpace(2),

        /// Delete Btn
        ColorShiftIconBtn(
          StyledIcons.formDelete,
          size: 20,
          onPressed: showDelete ? onDelete : null,
          padding: EdgeInsets.all(Insets.sm),
        ).opacity(showDelete ? 1 : 0, animate: true).animate(Durations.fast, Curves.linear),
      ],
    );
  }
}
