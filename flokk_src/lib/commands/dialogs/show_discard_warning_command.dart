import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flokk/data/contact_data.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';

class ShowDiscardWarningCommand extends AbstractCommand {
  ShowDiscardWarningCommand(BuildContext c) : super(c);

  Future<bool> execute() async {
    if (appModel.selectedContact == ContactData()) return true;
    bool isNew = appModel.selectedContact.isNew;
    return await Dialogs.show(OkCancelDialog(
      okLabel: "DISCARD",
      title: "UNSAVED CHANGES FOR ${isNew ? "NEW " : ""}CONTACT",
      message: "You have unsaved changes which will be lost if you navigate away.\n"
          "Are you sure you wish to discard these changes?",
      onOkPressed: () => rootNav?.pop(true),
      onCancelPressed: () => rootNav?.pop(false),
    ));
  }
}
