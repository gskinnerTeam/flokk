import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/social/refresh_github_command.dart';
import 'package:flokk/commands/social/refresh_twitter_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flutter/material.dart';

class RefreshSocialCommand extends AbstractCommand {
  RefreshSocialCommand(BuildContext c) : super(c);

  /// Pass in list of contacts to update; can be used to pass in single contact (manual refresh) or else multiple (ie. all contacts on background poll)
  Future<void> execute(List<ContactData> contacts) async {
    //Ignore if contacts are empty or null
    if (contacts.isEmpty) {
      return;
    }

    List<String> githubHandles = contacts
        .where((x) => !StringUtils.isEmpty(x.gitUsername))
        .map((x) => x.gitUsername)
        .toList();
    List<String> twitterHandles = contacts
        .where((x) => !StringUtils.isEmpty(x.twitterHandle))
        .map((x) => x.twitterHandle)
        .toList();

    List<Future<void>> gitFutures = githubHandles
        .map((x) => RefreshGithubCommand(context).execute(x))
        .toList();
    await Future.wait(gitFutures);

    List<Future<void>> twitterFutures = twitterHandles
        .map((x) => RefreshTwitterCommand(context).execute(x))
        .toList();
    await Future.wait(twitterFutures);
  }
}
