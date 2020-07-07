import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/social/refresh_social_command.dart';
import 'package:flutter/src/widgets/framework.dart';

class PollSocialCommand extends AbstractCommand with CancelableCommandMixin {
  PollSocialCommand(BuildContext c) : super(c);

  Future<void> execute([bool repeat = false, double wait = 15]) async {
    await RefreshSocialCommand(context).execute(contactsModel.allContacts);

    if (repeat) {
      Future.delayed(wait.minutes).then((value) {
        if (isCancelled) return;
        execute(true);
      });
    }
  }
}
