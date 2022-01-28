import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/url_launcher/url_launcher.dart';
import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/git_event_data.dart';
import 'package:flokk/data/git_repo_data.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../styled_icons.dart';

class GitUtils {
  static DateFormat get monthDayFmt => DateFormat("MMM d");

  //EC: https://developer.github.com/v3/activity/events/types/, made human readable and added past tense where applicable
  static String getStringForType(String type) {
    if (type == "CheckRunEvent") return "Checked Run";
    if (type == "CheckSuiteEvent") return "Checked Suite";
    if (type == "CommitCommentEvent") return "Commit Commented";
    if (type == "ContentReferenceEvent") return "Content Referenced";
    if (type == "CreateEvent") return "Created";
    if (type == "DeleteEvent") return "Deleted";
    if (type == "DeployKeyEvent") return "Deployed Key";
    if (type == "DeploymentEvent") return "Deployed";
    if (type == "DeploymentStatusEvent") return "Deployment Status";
    if (type == "DownloadEvent") return "Downloaded";
    if (type == "FollowEvent") return "Followed";
    if (type == "ForkEvent") return "Forked";
    if (type == "ForkApplyEvent") return "Applied Fork";
    if (type == "GitHubAppAuthorizationEvent") return "GitHub AppAuthorization";
    if (type == "GistEvent") return "Gist";
    if (type == "GollumEvent") return "Gollum";
    if (type == "InstallationEvent") return "Installation";
    if (type == "InstallationRepositoriesEvent") return "Installation Repositories";
    if (type == "IssueCommentEvent") return "Commented on Issue";
    if (type == "IssuesEvent") return "Issues";
    if (type == "LabelEvent") return "Labelled";
    if (type == "MarketplacePurchaseEvent") return "Marketplace Purchase";
    if (type == "MemberEvent") return "Member";
    if (type == "MembershipEvent") return "Membership";
    if (type == "MetaEvent") return "Meta";
    if (type == "MilestoneEvent") return "Milestone";
    if (type == "OrganizationEvent") return "Organization";
    if (type == "OrgBlockEvent") return "Org Blocked";
    if (type == "PackageEvent") return "Packaged";
    if (type == "PageBuildEvent") return "PageBuild";
    if (type == "ProjectCardEvent") return "Project Card";
    if (type == "ProjectColumnEvent") return "Project Column";
    if (type == "ProjectEvent") return "Project";
    if (type == "PublicEvent") return "Public";
    if (type == "PullRequestEvent") return "Pull Requested";
    if (type == "PullRequestReviewEvent") return "Reviewed Pull Request";
    if (type == "PullRequestReviewCommentEvent") return "Commented Pull Request Review";
    if (type == "PushEvent") return "Pushed";
    if (type == "ReleaseEvent") return "Released";
    if (type == "RepositoryDispatchEvent") return "Repository Dispatch";
    if (type == "RepositoryEvent") return "Repository";
    if (type == "RepositoryImportEvent") return "Repository Import";
    if (type == "RepositoryVulnerabilityAlertEvent") return "Repository Vulnerability Alert";
    if (type == "SecurityAdvisoryEvent") return "Security Advisory";
    if (type == "SponsorshipEvent") return "Sponsorship";
    if (type == "StarEvent") return "Starred";
    if (type == "StatusEvent") return "Status";
    if (type == "TeamEvent") return "Team";
    if (type == "TeamAddEvent") return "Team Added";
    if (type == "WatchEvent") return "Watched";
    return type;
  }
}

/// Item Renderer for Git Events
class GitEventListItem extends StatelessWidget {
  final GitEvent gitEvent;

  const GitEventListItem(this.gitEvent, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyles.Body2;
    return Column(
      children: [
        Row(children: [
          Text("${gitEvent.event.actor?.login ?? ""}", style: titleStyle.bold),
          Text(
              "  ·  ${GitUtils.getStringForType(gitEvent.event.type ?? "")}  ·  ${GitUtils.monthDayFmt.format(gitEvent.createdAt)}",
              style: titleStyle),
        ]),
        VSpace(Insets.xs * 1.5),
        GitRepoInfo(gitEvent.repository),
        VSpace(Insets.l),
      ],
    );
  }
}

/// Item Renderer for Git Repos
class GitRepoListItem extends StatelessWidget {
  final GitRepo repo;

  const GitRepoListItem(this.repo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyles.Body2;
    return Column(
      children: [
        Row(children: [
          Text("${repo.contacts.first.nameGiven}", style: titleStyle.bold),
          Text("  ·  ${GitUtils.monthDayFmt.format(repo.repository.updatedAt ?? Dates.epoch)}", style: titleStyle),
        ]),
        VSpace(Insets.xs * 1.5),
        GitRepoInfo(repo.repository),
        VSpace(Insets.l),
      ],
    );
  }
}

/// Small pill used for Language Type
class _GitPill extends StatelessWidget {
  final String label;

  const _GitPill(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return Text(label, style: TextStyles.Footnote.letterSpace(0))
        .padding(all: Insets.xs, horizontal: Insets.sm)
        .decorated(color: theme.bg2, borderRadius: Corners.s3Border);
  }
}

/// This is used in both renderers to show the core Repo info
class GitRepoInfo extends StatelessWidget {
  final Repository? repo;

  const GitRepoInfo(this.repo, {Key? key}) : super(key: key);

  void _handleRepoPressed() {
    if (repo != null)
      UrlLauncher.openHttp(repo!.htmlUrl);
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    TextStyle smallTextStyle = TextStyles.Body3.textHeight(1.4);
    TextStyle contentTextStyle = TextStyles.Body1.textHeight(1.4);
    return Column(
      children: [
        Row(children: [
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "${repo?.name}", style: contentTextStyle.textColor(theme.accent1Dark)),
                TextSpan(text: " | ${repo?.description}", style: contentTextStyle.textColor(theme.txt)),
              ],
            ),
          ).flexible(),
          //ClickableText(repo.name, onPressed: _handleRepoPressed,),
        ]),
        VSpace(Insets.sm * 1.5),
        Row(children: [
          if (repo?.language != null) ...{
            _GitPill(repo!.language),
            HSpace(Insets.sm),
          },
          StyledImageIcon(StyledIcons.starFilled, size: 12, color: theme.grey),
          Text("${repo?.stargazersCount ?? 0}", style: smallTextStyle).padding(left: Insets.xs),
          HSpace(Insets.sm),
          StyledImageIcon(StyledIcons.socialFork, size: 12, color: theme.grey).translate(
            offset: Offset(0, 1), // Add a bit of offset to the fork icon cause it's a bit tall and doesn't look right
          ),
          Text("${repo?.forksCount ?? 0}", style: smallTextStyle).padding(left: Insets.xs),
        ]),
        VSpace(Insets.m * 1.5),
        Container(color: theme.greyWeak.withOpacity(.35), width: double.infinity, height: 1),
        //VSpace(Insets.l),
      ],
    ).gestures(onTap: _handleRepoPressed);
  }
}
