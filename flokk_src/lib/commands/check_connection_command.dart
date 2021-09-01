import 'package:flokk/_internal/http_client.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:universal_platform/universal_platform.dart';

class CheckConnectionCommand extends AbstractCommand
    with CancelableCommandMixin {
  CheckConnectionCommand(BuildContext context) : super(context);

  /// Checks if we can connect to the internet.
  /// If repeat == true, recursively calls itself forever.
  Future<bool> execute([bool repeat = false, double wait = 10]) async {
    if (UniversalPlatform.isWeb) {
      appModel.isOnline = true;
    } else {
      String url = UniversalPlatform.isWeb ? "flokk.app" : "google.com";
      appModel.isOnline = (await HttpClient.head("https://$url")).success;
      if (repeat) {
        Future.delayed(wait.seconds).then((value) {
          if (isCancelled) return;
          execute(true);
        });
      }
    }
    return appModel.isOnline;
  }
}
