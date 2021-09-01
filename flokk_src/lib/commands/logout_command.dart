import 'package:flokk/_internal/log.dart';
import 'package:flokk/_internal/page_routes.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/welcome/welcome_page.dart';
import 'package:flutter/cupertino.dart';

class LogoutCommand extends AbstractCommand {
  LogoutCommand(BuildContext context) : super(context);

  Future<void> execute({bool doConfirm = false}) async {
    Log.p("[LogoutCommand]");

    if (doConfirm) {
      bool doLogout = await Dialogs.show(OkCancelDialog(
        title: "Sign Out?",
        message: "Are you sure you want to sign-out?",
        onOkPressed: () => rootNav?.pop<bool>(true),
        onCancelPressed: () => rootNav?.pop<bool>(false),
      ));
      if (!doLogout) return;
    }

    //Quietly clear out various models.
    // Don't notify listeners, as we don't want the views to clear until we've fully transitioned out
    authModel.reset(false);
    contactsModel.reset(false);
    githubModel.reset(false);
    twitterModel.reset(false);

    //Reset the theme and app settings
    appModel.theme = ThemeType.FlockGreen;
    appModel.reset(false);

    //Show login page
    rootNav?.pushReplacement(
        PageRoutes.fade(() => WelcomePage(initialPanelOpen: true)));
  }
}
