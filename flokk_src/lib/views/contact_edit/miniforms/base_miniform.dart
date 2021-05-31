import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/colored_icon_btn.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/styled_autocomplete_dropdown.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/expanding_miniform_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// /////////////////////////////////////////////////////
/// [BaseMiniForm] Provides common methods and component builders for all mini-forms
/// [SB] Currently this class basically just provides convenience methods, and buildFxns,
/// so you don't need to dispatch FocusNotifications in your concrete MiniForms.
/// It's composed mainly of sub-builds methods, which should probably be refactored into
/// individual FormWidgets, but it works for now.
abstract class BaseMiniForm extends StatelessWidget {
  BaseMiniForm(this.form, this.sectionType, {Key? key}) : super(key: key);

  double get rightPadding => Insets.l * 1.5 - 2;

  final String sectionType;

  final ContactEditFormState form;

  bool get isSelected => form.currentSection == sectionType;

  ContactData get c => form.tmpContact;

  bool getIsFocused<T>(List<T> list, T item) => isSelected && list.indexOf(item) == 0;

  /// /////////////////////////////////////////////////////
  /// SHARED HANDLERS AND BUSINESS LOGIC
  void setFormState(Function() action) {
    action();
    form.rebuild();
  }

  void handleFocusChanged(bool value, BuildContext context) => FocusChangedNotification(value).dispatch(context);

  void handleDeletePressed<T>(BuildContext context, T item, List<T> list) {
    // Remove item
    list.remove(item);
    // Rebuild form

    //Manually request a close if we're empty
    (list.isEmpty) ? CloseFormNotification().dispatch(context) : form.rebuild();
  }

  void handleAddPressed<T>(T item, List<T> list) {
    list.add(item);
    form.rebuild();
  }

  /// /////////////////////////////////////////////////////
  /// SHARED UI FACTORY BUILD METHODS

  /// Adds a build button if the final row in the list has some content, and we don't exceed some max # of items
  void injectAddNewBtnIfNecessary<T>(
      String hint, List<Widget> column, List<T> list, Function(T) isEmpty, Function() itemBuilder) {
    int maxItems = 8;
    if (list.isNotEmpty && !isEmpty(list.last) && list.length < maxItems) {
      Widget btn = TransparentIconAndTextBtn(
        "Add $sectionType",
        StyledIcons.formAdd,
        bigMode: true,
        textColor: form.theme.greyWeak,
        onPressed: () => handleAddPressed(itemBuilder(), list),
      ).translate(offset: Offset(-4, 0));
      // Wrap the button in a row with a spacer, so it will not stretch all the way across the form
      column.add(Row(children: [btn, Spacer()]));
    }
  }

  /// //////////////////////////////////////////////////////////////
  /// Creates an ExpandingMiniformContainer with some shared boilerplate (auto-focus check, and onOpened handler).
  /// Every miniform calls this fxn.
  Widget buildExpandingContainer(dynamic icon, {required BoolCallback hasContent, required FormBuilder formBuilder}) {
    return ExpandingMiniformContainer(
      sectionType,
      icon,
      hasContent: hasContent,
      formBuilder: formBuilder,
      // Auto-focus if we're the current form section
      autoFocus: form.currentSection == sectionType,
      // When we open, let the form know that we're the current section
      onOpened: form.handleSectionChanged,
    );
  }

  /// //////////////////////////////////////////////////
  /// Builds a basic TextInput that dispatches focusChanged
  /// //TODO SB: Move this and the other components into their own widgets. They just need to be passed the miniform as a component.
  Widget buildTextInput(BuildContext context, String hint, String? initial, void Function(String)? onChanged,
      {bool autoFocus = false,
      EdgeInsets padding = StyledFormTextInput.kDefaultTextInputPadding,
      int? maxLines = 1,
      TextEditingController? controller}) {
    return StyledFormTextInput(
        controller: controller,
        hintText: hint,
        contentPadding: padding,
        autoFocus: autoFocus,
        initialValue: initial,
        maxLines: maxLines,
        onChanged: onChanged,
        // Let  parent widget know when textfield focus has changed
        onFocusChanged: (v) => handleFocusChanged(v, context));
  }

  /// //////////////////////////////////////////////////
  /// Builds a dual-column TextInput like those used in Address
  Widget buildDualTextInput(BuildContext context, String hint1, String initial1, Function(String) onChanged1,
      String hint2, String initial2, Function(String) onChanged2,
      {bool autoFocus = false, EdgeInsets padding = StyledFormTextInput.kDefaultTextInputPadding, int maxLines = 1}) {
    return Row(
      children: <Widget>[
        buildTextInput(context, hint1, initial1, onChanged1, autoFocus: autoFocus, padding: padding, maxLines: maxLines)
            .flexible(),
        HSpace(Insets.m),
        buildTextInput(context, hint2, initial2, onChanged2, padding: padding, maxLines: maxLines).flexible(),
      ],
    );
  }

  /// ///////////////////////////////////////////////////
  /// Builds a single-row widget that is a combination of Text and AutoCompleteDropdown
  /// This is your classic EMAIL / TYPE DROPDOWN field
  Widget buildTextWithDropdown(BuildContext context, dynamic item,
      {String hint = "",
      String typeHint = "",
      String? initialText,
      String? initialType,
      List<String> types = const<String>[],
      void Function(String)? onTextChanged,
      void Function(String)? onTypeChanged,
      VoidCallback? onDelete,
      bool showDelete = true,
      bool autoFocus = false,
      double maxDropdownHeight = 300,
      double typeWidth = 100}) {
    return Row(
      key: item != null ? ObjectKey(item) : null,
      children: <Widget>[
        /// Text Input
        buildTextInput(
          context,
          hint,
          initialText,
          onTextChanged,
          autoFocus: autoFocus,
        ).flexible(),
        HSpace(Insets.m),

        /// Type dropdown
        StyledAutoCompleteDropdown(
            items: types,
            hint: typeHint,
            initialValue: initialType,
            onChanged: onTypeChanged,
            maxHeight: maxDropdownHeight,
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

  /// ////////////////////////////////////////////////////////////
  /// Build a column of Text/Type dropdowns, from a list of items
  buildColumnOfTextWithDropdown<T>(
    BuildContext context,
    String hint,
    String typeHint, {
    List<T> itemList = const [], // NOTE CE: Dart really fails here, default argument values must be const but generic type arguments cannot be used in a const context
    List<String> types = const <String>[],
    required T Function() newItemBuilder,
    required bool Function(T) isEmpty,
    required String? Function(T) getValue,
    required Function(T, String) setValue,
    required String? Function(T) getType,
    required void Function(T, String) setType,
    double maxDropdownHeight = 300,
  }) {
    //If we've been given an empty list, populate it with at least one item.
    if (itemList.isEmpty) itemList.add(newItemBuilder());

    /// Build a list of rows for each item in the list
    List<Widget> kids = itemList.map((item) {
      // Create a TextAndTypeRow widget
      return buildTextWithDropdown(context, item,
          autoFocus: getIsFocused<T>(itemList, item),
          hint: hint,
          typeHint: typeHint,
          initialText: getValue(item),
          initialType: getType(item),
          types: types.map((e) => e.toUpperCase()).toList(),
          onTextChanged: (value) => setFormState(() => setValue(item, value)),
          onTypeChanged: (value) => setFormState(() => setType(item, value)),
          onDelete: () => handleDeletePressed<T>(context, item, itemList),
          showDelete: !isEmpty(item),
          maxDropdownHeight: maxDropdownHeight);
    }).toList();

    /// Add a "Add New" btn to the column if certain conditions are met
    injectAddNewBtnIfNecessary<T>(hint, kids, itemList, isEmpty, newItemBuilder);

    /// Return the actual Column of content
    return SeparatedColumn(
      separatorBuilder: () => VSpace(Insets.sm),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: kids,
    );
  }
}
