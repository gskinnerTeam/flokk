import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/contacts/delete_contact_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/styled_checkbox.dart';
import 'package:flokk/styled_components/styled_container.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BulkContactEditBar extends StatefulWidget {
  final List<ContactData> checked;
  final List<ContactData> all;
  final VoidCallback? onCheckChanged;

  const BulkContactEditBar(
      {Key? key,
      this.checked = const <ContactData>[],
      this.onCheckChanged,
      this.all = const <ContactData>[]})
      : super(key: key);

  @override
  _BulkContactEditBarState createState() => _BulkContactEditBarState();
}

class _BulkContactEditBarState extends State<BulkContactEditBar> {
  void _handleCheckChanged(StyledCheckboxValue value) {
    if (value == StyledCheckboxValue.All) {
      widget.checked.clear();
      widget.checked.addAll(widget.all);
    } else if (value == StyledCheckboxValue.None) {
      widget.checked.clear();
    }
    widget.onCheckChanged?.call();
  }

  void _handleDeletePressed() async {
    //Make a copy of the list, so it doesn't get cleared while the Command is still working
    List<ContactData> usersToDelete = widget.checked.toList();
    await DeleteContactCommand(context).execute(usersToDelete,
        onDeleteConfirmed: () {
      // For a nicer UI interaction, we want to clear the list immediately when the User has confirmed their delete intent.
      widget.checked.clear();
      widget.onCheckChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    TextStyle linkStyle =
        TextStyles.Body2.textHeight(1.1).textColor(theme.accent1);
    return StyledContainer(
      theme.bg1,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          HSpace(Insets.l),
          StyledCheckbox(value: _getValue(), onChanged: _handleCheckChanged),
          HSpace(Insets.m),
          Text("Select", style: TextStyles.H2.textHeight(1)),
          HSpace(Insets.sm * 1.5),
          TransparentTextBtn("All",
              style: linkStyle,
              onPressed: () => _handleCheckChanged(StyledCheckboxValue.All)),
          Text("  /  ", style: linkStyle)
              .translate(offset: Offset(-Insets.sm, 0)),
          TransparentTextBtn("None",
                  style: linkStyle,
                  onPressed: () =>
                      _handleCheckChanged(StyledCheckboxValue.None))
              .translate(offset: Offset(-Insets.sm * 2, 0)),
          HSpace(Insets.m),
//TODO: Implement ManageLabels btn
//          TransparentIconAndTextBtn("Manage Labels", StyledIcons.label, style: linkStyle),
//          HSpace(Insets.m),
          TransparentIconAndTextBtn("Delete", StyledIcons.trash,
              style: linkStyle.textColor(theme.grey),
              onPressed: _handleDeletePressed,
              color: theme.grey),
          Spacer(),
          Text("${widget.checked.length} Selected",
              style: TextStyles.H2.textColor(theme.grey)),
          HSpace(Insets.l),
        ],
      ),
    );
  }

  StyledCheckboxValue _getValue() {
    if (widget.checked.isEmpty) return StyledCheckboxValue.None;
    if (widget.checked.length == widget.all.length)
      return StyledCheckboxValue.All;
    return StyledCheckboxValue.Partial;
  }
}
