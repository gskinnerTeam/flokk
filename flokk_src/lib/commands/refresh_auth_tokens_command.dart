import 'package:flokk/_internal/log.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/services/google_rest/google_rest_auth_service.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';

class RefreshAuthTokensCommand extends AbstractCommand {
  RefreshAuthTokensCommand(BuildContext context) : super(context);

  Future<bool> execute({bool onlyIfExpired = false}) async {
    Log.p(
        "[RefreshAuthTokensCommand] Refreshing with token: ${authModel.googleRefreshToken}");
    if (StringUtils.isEmpty(authModel.googleRefreshToken)) return true;

    //Don't bother calling refresh if it's already authenticated
    if (onlyIfExpired && !authModel.isExpired) return true;

    //Query server, see if we can get a new auth token
    ServiceResult<GoogleAuthResults> result = await googleRestService.auth
        .refresh(authModel.googleRefreshToken ?? "");
    //If the request succeeded, inject the model with the latest authToken and write to disk
    if (result.success) {
      authModel.googleAccessToken = result.content?.accessToken ?? "";
      authModel.setExpiry(result.content?.expiresIn ?? 0);
      authModel.scheduleSave();
      Log.p(
        "Refresh token success. authKey = ${authModel.googleAccessToken}, refreshToken = ${authModel.googleRefreshToken}",
      );
    }
    return result.success;
  }
}
