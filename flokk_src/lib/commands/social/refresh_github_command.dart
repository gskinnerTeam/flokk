import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/dialogs/show_service_error_command.dart';
import 'package:flokk/data/git_event_data.dart';
import 'package:flokk/data/git_repo_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/cupertino.dart';

class RefreshGithubCommand extends AbstractCommand {
  RefreshGithubCommand(BuildContext c) : super(c);

  Future<void> execute(String githubUsername) async {
    Log.p("[RefreshGithubCommand]");

    if (contactsModel.canRefreshGitEventsFor(githubUsername) ||
        AppModel.ignoreCooldowns) {
      githubModel.isLoading = true;
      ServiceResult eventResult =
          await gitService.getUserEvents(githubUsername);

      contactsModel.updateSocialTimestamps(gitUsername: githubUsername);

      //set "hasValidGit" flag on contact, depending on success of call
      contactsModel.updateContactDataGithubValidity(
          githubUsername, eventResult.success);

      //Suppress error dialogs if the git username is not found. Already updated the ContactData.hasValidGit flag above
      final int statusCode = eventResult.response.statusCode;
      switch (statusCode) {
        case 403: //rate limit (https://developer.github.com/v3/#rate-limiting)
          ShowServiceErrorCommand(context).execute(eventResult.response,
              customMessage:
                  "GitHub rate limit exceeded. Please try again later.");
          break;
        case 404: //likely invalid git username, don't bother showing error dialog.
          break;
        default:
          ShowServiceErrorCommand(context).execute(eventResult.response);
          break;
      }

      List<GitEvent> events = eventResult.content ?? [];
      githubModel.addEvents(githubUsername, events);

      //Fetch the repos for each event contact was involved in
      for (var n in events) {
        //The full name of the repo is populated in Event.repo.name, but once Repository is fetched, Repository.fullName will be populated
        String fullName = n.event.repo?.name ?? "";

        if (githubModel.repoIsStale(fullName)) {
          ServiceResult<GitRepo> repoResult =
              await gitService.getRepo(fullName);
          if (repoResult.success == true) {
            GitRepo repo = repoResult.content!;
            githubModel.addRepo(repo);
          }
        }
      }

      //Fetch contact owned repos
      // ServiceResult<List<GitRepo>> userReposResult = await gitService.getUserRepos(githubUsername);
      // if (userReposResult?.success == true) {
      //   githubModel.addRepos(userReposResult.content);
      // }
      githubModel.isLoading = false;
      githubModel.scheduleSave();
    }
  }
}
