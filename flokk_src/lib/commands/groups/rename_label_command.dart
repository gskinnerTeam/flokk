import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/src/widgets/framework.dart';

class RenameLabelCommand extends AbstractCommand
    with AuthorizedServiceCommandMixin {
  RenameLabelCommand(BuildContext c) : super(c);

  Future<GroupData?> execute(GroupData group) async {
    if (group == GroupData()) return group;
    Log.p("[RenameLabelCommand]");
    ServiceResult<GroupData> result = await executeAuthServiceCmd(() async {
      ServiceResult<GroupData> result = await googleRestService.groups
          .set(authModel.googleAccessToken, group);
      if (result.success) {
        contactsModel.swapGroupById(result.content!);
      }
      return result;
    });
    return result.success ? result.content : null;
  }
}
