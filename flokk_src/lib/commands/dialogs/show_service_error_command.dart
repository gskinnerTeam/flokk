import 'dart:convert';

import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/check_connection_command.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:universal_platform/universal_platform.dart';

class ShowServiceErrorCommand extends AbstractCommand {
  ShowServiceErrorCommand(BuildContext context) : super(context);

  static bool isShowingError = false;

  Future<bool> execute(HttpResponse response,
      {String customMessage = ""}) async {
    //If response has no errors, return false to indicate no error was shown
    if (response.success) return false;
    Log.p("[ShowServiceErrorCommand]");

    String msg;
    if (customMessage.isNotEmpty) {
      msg = customMessage;
    } else {
      msg =
          "An unknown error occured (${response.statusCode}). Try checking your internet connection or re-starting the application.";
      // 400 Errors (denied request)
      if (response.errorType == NetErrorType.denied) {
        //Default message
        if (response.statusCode == 401) {
          msg =
              "Something went wrong with authorization, you should probably ${UniversalPlatform.isWeb ? "refresh" : "restart"} the app";
        } else {
          //Use message from server if available
          Map<String, dynamic>? json = jsonDecode(response.body)["error"];
          if (json?.containsKey("message") ?? false) {
            msg = json!["message"];
          } else {
            msg =
                "Unable to connect to online services: Internal Server Error (${response.statusCode})";
          }
        }
      }
      // 500 Errors (server)
      else if (response.errorType == NetErrorType.timedOut) {
        //Default message
        msg = "Server is down, please try again later";

        //Show message from server if available
        Map<String, dynamic>? json = jsonDecode(response.body)["error"];
        if (json?.containsKey("message") ?? false) {
          msg = json!["message"];
        }
      }
      // No Connection
      else if (response.errorType == NetErrorType.disconnected) {
        msg =
            "Unable to connect to the internet, please check your connection.";
        //Run an immediate connection check, it's likely that we've lost connection but we're not sure.
        await CheckConnectionCommand(context).execute(false);
      }
    }

    //Suppress popups, only log for release
    if (kReleaseMode) {
      Log.p(msg);
    }

    //Show error popup, if we're not already. Last thing we want to do is spam error messages.
    if (!isShowingError && kDebugMode) {
      isShowingError = true;
      await Dialogs.show(
        OkCancelDialog(
          title: "Connection Error",
          message: msg,
          onOkPressed: () => rootNav?.pop(),
        ),
      );
      isShowingError = false;
    }
    return true;
  }
}
