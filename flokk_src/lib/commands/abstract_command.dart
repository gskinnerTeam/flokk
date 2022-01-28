import 'package:flokk/commands/dialogs/show_service_error_command.dart';
import 'package:flokk/commands/refresh_auth_tokens_command.dart';
import 'package:flokk/globals.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/models/auth_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/models/github_model.dart';
import 'package:flokk/models/twitter_model.dart';
import 'package:flokk/services/github_rest_service.dart';
import 'package:flokk/services/google_rest/google_rest_service.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flokk/services/twitter_rest_service.dart';
import 'package:flokk/styled_components/styled_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AbstractCommand {
  static BuildContext? _lastKnownRoot;

  /// Provide all commands access to the global context & navigator
  late BuildContext context;

  NavigatorState? get rootNav => AppGlobals.nav;

  AbstractCommand(BuildContext c) {
    /// Get root context
    /// If we're passed a context that is known to be root, skip the lookup, it will throw an error otherwise.
    context = (c == _lastKnownRoot) ? c : Provider.of(c, listen: false);
    _lastKnownRoot = context;
  }

  T getProvided<T>() => Provider.of<T>(context, listen: false);

  /// Convenience lookup methods for all commands to share
  ///
  /// Models
  AuthModel get authModel => getProvided();

  ContactsModel get contactsModel => getProvided();

  TwitterModel get twitterModel => getProvided();

  GithubModel get githubModel => getProvided();

  AppModel get appModel => getProvided();

  /// Services
  GoogleRestService get googleRestService => getProvided();

  TwitterRestService get twitterService => getProvided();

  GithubRestService get gitService => getProvided();
}

/// //////////////////////////////////////////////////////////////////
/// MIX-INS
/// //////////////////////////////////////////////////////////////////

mixin CancelableCommandMixin on AbstractCommand {
  bool isCancelled = false;

  bool cancel() => isCancelled = true;
}

mixin AuthorizedServiceCommandMixin on AbstractCommand {
  bool ignoreErrors = false;

  /// Runs a service that refreshes Auth if needed, and checks for errors on completion
  Future<ServiceResult<T>> executeAuthServiceCmd<T>(Future<ServiceResult<T>> Function() cmd) async {
    /// Bail early if we're offline
    if (!appModel.isOnline) {
      Dialogs.show(OkCancelDialog(
        title: "No Connection",
        message: "It appears your device is offline. Please check your connection and try again.",
        onOkPressed: () => rootNav?.pop(),
      ));
    }

    /// Refresh token if needed
    await RefreshAuthTokensCommand(context).execute(onlyIfExpired: true);

    /// Execute command
    ServiceResult<T> r = await cmd();

    /// Check for errors
    if (!ignoreErrors) {
      ShowServiceErrorCommand(context).execute(r.response);
    }

    return r;
  }
}
