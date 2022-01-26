import 'dart:async';

import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/groups/create_label_command.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/styled_components/styled_form_label_input.dart';
import 'package:flokk/styled_components/styled_group_label.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/base_miniform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactLabelMiniForm extends BaseMiniForm {
  ContactLabelMiniForm(ContactEditFormState form, {Key? key}) : super(form, ContactSectionType.label, key: key);

  void _handleAddLabel(String label, BuildContext context) {
    // If the label is empty or we already have that label on our contact then dont add it
    if (label.isEmpty || c.groupList.any((g) => g.name == label)) return;
    //TODO SB@CE - This (form.widget.contactsModel) is probably ok, since these miniforms are tightly coupled to form. But no need to reach out for contactsModel. Instead just look it up with provider: ContactsModel contactsModel = context.watch();
    GroupData? groupToAdd = form.widget.contactsModel.getGroupByName(label);
    if (groupToAdd != null) {
      setFormState(() => c.groupList.add(groupToAdd));
    } else {
      // We must make a new group, add that group to this contact when the creation has finished
      CreateLabelCommand(context).execute(label).then((g) {
        if (g != null)
          setFormState(() => c.groupList.add(g));
      });
    }
  }

  void _handleRemoveLabel(String label) {
    setFormState(() => c.groupList.removeWhere((g) => g.name == label));
  }

  @override
  Widget build(BuildContext context) {
    return buildExpandingContainer(
      StyledIcons.label,
      hasContent: () => c.hasLabel,
      formBuilder: () {
        // Wrap content in a builder so the FocusNotification will get caught by the ExpandingFormContainer
        return Builder(
          builder: (context) {
            return _LabelMiniformWithSearch(
              autoFocus: isSelected,
              onAddLabel: (label) => _handleAddLabel(label, context),
              onRemoveLabel: _handleRemoveLabel,
              contactLabels: c.groupList.map((g) => g.name).toList(),
              allLabels: form.widget.contactsModel.allGroups.map((g) => g.name).toList(),
              onFocusChanged: (v) => handleFocusChanged(v, context),
            ).padding(right: rightPadding);
          },
        );
      },
    );
  }
}

class _LabelMiniformWithSearch extends StatefulWidget {
  final bool autoFocus;
  final void Function(String) onAddLabel;
  final void Function(String) onRemoveLabel;
  final void Function(bool)? onFocusChanged;
  final List<String> contactLabels;
  final List<String> allLabels;

  _LabelMiniformWithSearch({
    this.autoFocus = false,
    required this.onAddLabel,
    required this.onRemoveLabel,
    this.onFocusChanged,
    this.contactLabels = const <String>[],
    this.allLabels = const <String>[],
  });

  @override
  _LabelMiniformWithSearchState createState() => _LabelMiniformWithSearchState();
}

class _LabelMiniformWithSearchState extends State<_LabelMiniformWithSearch> {
  bool? _isOpen;
  String _labelFilter = "";
  Timer? _timer;

  _LabelMiniformWithSearchState();

  @override
  void didUpdateWidget(_LabelMiniformWithSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _handleOnChanged(String filter) {
    setState(() {
      _labelFilter = filter;
    });
  }

  bool _handleFocusChanged(bool value) {
    if (value == false) {
      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: 750), () {
        setState(() => _isOpen = false);
      });
    } else {
      _timer?.cancel();
    }
    widget.onFocusChanged?.call(value);
    return true;
  }

  bool _handleTextFocusChanged(bool value) {
    final result = _handleFocusChanged(value);
    if (value && !_isOpen!) setState(() => _isOpen = true);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _isOpen ??= widget.autoFocus;
    AppTheme theme = context.watch();
    final searchResults = widget.allLabels
        .where((l) => l.toLowerCase().contains(_labelFilter.toLowerCase()))
        .where((l) => !widget.contactLabels.contains(l))
        .take(6)
        .map(
          (l) => StyledGroupLabel(
            text: l,
            onPressed: () => widget.onAddLabel(l),
            onFocusChanged: _handleFocusChanged,
          ),
        )
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StyledFormLabelInput(
        hintText: "Labels",
        autoFocus: widget.autoFocus,
        onAddLabel: widget.onAddLabel,
        onRemoveLabel: widget.onRemoveLabel,
        onChanged: _handleOnChanged,
        labels: widget.contactLabels,
        onFocusChanged: _handleTextFocusChanged,
      ),
      if (_isOpen!) ...{
        Text("Suggestions".toUpperCase(), style: TextStyles.Caption.textColor(theme.grey)).padding(bottom: Insets.m),
        Wrap(
          runSpacing: Insets.sm * 1.5,
          spacing: Insets.sm,
          children: searchResults,
        ),
      },
    ]);
  }
}
