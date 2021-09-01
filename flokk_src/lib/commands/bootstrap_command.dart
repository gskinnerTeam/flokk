import 'package:desktop_window/desktop_window.dart';
import 'package:flokk/_internal/log.dart';
import 'package:flokk/_internal/utils/path.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/api_keys.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/commands/refresh_auth_tokens_command.dart';
import 'package:flokk/commands/social/refresh_social_command.dart';
import 'package:flokk/commands/web_sign_in_command.dart';
import 'package:flokk/main.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_platform/universal_platform.dart';

class BootstrapCommand extends AbstractCommand {
  BootstrapCommand(BuildContext context) : super(context);

  Future<bool> execute() async {
    /// Let the splash view sit for a bit. Mainly for aesthetics and to ensure a smooth intro animation.
    await Future.delayed(.5.seconds);

    /// Display startup logs
    Log.writeToDisk = false;
    Log.p("/##################################################", false);
    Log.p("[BootstrapCommand]");
    if (!UniversalPlatform.isWeb) {
      Log.p("DataDir is: ${await PathUtil.dataPath}");
    }
    Log.p("##################################################", false);

    /// Define default locale
    Intl.defaultLocale = 'en_US';

    /// Set minimal Window size
    DesktopWindow.setMinWindowSize(Size(750, 600));

    /// Handle version upgrades
    if (appModel.version != AppModel.kCurrentVersion) {
      appModel.upgradeToVersion(AppModel.kCurrentVersion);
    }

    /// Load saved data into necessary models
    bool errorLoadingData = false;
    await authModel.load().catchError((e, s) {
      print("[BootstrapCommand] Error loading AuthModel: $s");
      errorLoadingData = true;
    });
    await twitterModel.load().catchError((e, s) {
      print("[BootstrapCommand] Error loading TwitterModel: $s");
      errorLoadingData = true;
    });
    await githubModel.load().catchError((e, s) {
      print("[BootstrapCommand] Error loading GithubModel: $s");
      errorLoadingData = true;
    });
    await contactsModel.load().catchError((e, s) {
      print("[BootstrapCommand] Error loading ContactsModel: $s");
      errorLoadingData = true;
    });

    /// Reset models if there are any errors, or if the app version has been updated
    if (errorLoadingData) {
      authModel.reset();
      twitterModel.reset();
      githubModel.reset();
      contactsModel.reset();
    }

    /// ////////////////////////////////////////////////////////////////
    /// Debug: Inject authModel in web dev builds for quicker local testing
    /// TODO: Remove before release
    bool sideStepLoginFlow = (kDebugMode || kForceWebLogin) &&
        (UniversalPlatform.isWeb || UniversalPlatform.isAndroid);
    if (sideStepLoginFlow) {
      // Force login on the web by injecting a known refresh token, which we can use to fetch a valid authKey
      authModel.googleRefreshToken =
          "1//06TVHZgXSuhqfCgYIARAAGAYSNwF-L9IrPuIVzs3JSYt1xzWSXnK8Vx5cUPgYrEN4FouCtOy1j01hosURDlWogymULquE-e1lXm0";
      await RefreshAuthTokensCommand(context).execute();
      await (RefreshContactsCommand(context)..ignoreErrors = true).execute();
    }

    /// ////////////////////////////////////////////////////////////////////////

    /// After we've loaded the models, kickoff an auth-token refresh, our old one is likely expired.
    bool signInError = false;
    if (authModel.hasAuthKey && !sideStepLoginFlow) {
      /// Try and refresh authKey and Contacts.
      bool authSuccess;
      if (UniversalPlatform.isWeb) {
        // On web, perform a silentSignIn to refresh the OAuth token
        authSuccess =
            await WebSignInCommand(context).execute(silentSignIn: true);
      } else {
        // On desktop, refresh the authToken manually
        authSuccess = await RefreshAuthTokensCommand(context).execute();
        // Make a special exemption for a failed auth-refresh, if we have no key at all. Assume this is running in a test mode.
        if (!authSuccess && StringUtils.isEmpty(ApiKeys().googleClientId)) {
          authSuccess = true;
          AppModel.forceIgnoreGoogleApiCalls = true;
        }
      }
      // Load contacts
      ServiceResult contactsResult = await (RefreshContactsCommand(context)
            ..ignoreErrors = true)
          .execute();
      if (contactsResult.success) {
        await RefreshSocialCommand(context).execute(contactsModel.allContacts);
      }
      // Check that both the authCall and contactsLoad was successful
      signInError = !authSuccess || !contactsResult.success;
    }

    Log.p("#########################", false);
    Log.p("BootstrapCommand Complete");
    Log.p("#########################", false);

    return !signInError && authModel.hasAuthKey;
  }
}
