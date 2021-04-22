import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/dialogs/show_service_error_command.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flokk/services/twitter_rest_service.dart';
import 'package:flutter/src/widgets/framework.dart';

class AuthenticateTwitterCommand extends AbstractCommand {
  AuthenticateTwitterCommand(BuildContext c) : super(c);

  Future<String> execute() async {
    Log.p("[AuthenticateTwitterCommand]");

    ServiceResult<TwitterAuthResult> result = await twitterService.getAuth();
    if (result.success) {
      twitterModel.twitterAccessToken = result.content?.accessToken ?? "";
      twitterModel.scheduleSave();
      return twitterModel.twitterAccessToken;
    } else {
      ShowServiceErrorCommand(context).execute(result.response);
      return "";
    }
  }
}
