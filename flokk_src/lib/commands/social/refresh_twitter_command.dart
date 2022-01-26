import 'package:flokk/_internal/log.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flokk/commands/dialogs/show_service_error_command.dart';
import 'package:flokk/commands/social/authenticate_twitter_command.dart';
import 'package:flokk/data/tweet_data.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/services/service_result.dart';
import 'package:flutter/cupertino.dart';

class RefreshTwitterCommand extends AbstractCommand {
  RefreshTwitterCommand(BuildContext c) : super(c);

  Future<void> execute(String twitterHandle) async {
    Log.p("[RefreshTwitterCommand]");

    if (contactsModel.canRefreshTweetsFor(twitterHandle) || AppModel.ignoreCooldowns) {
      if (!twitterModel.isAuthenticated) {
        await AuthenticateTwitterCommand(context).execute();
      }
      twitterModel.isLoading = true;
      ServiceResult result = await twitterService.getTweets(twitterModel.twitterAccessToken, twitterHandle);

      contactsModel.updateSocialTimestamps(twitterHandle: twitterHandle);

      //set "hasValidTwitter" flag on contact, depending on success of call
      contactsModel.updateContactDataTwitterValidity(twitterHandle, result.success);

      //Suppress error dialogs if the twitter handle is not found. Already updated the ContactData.hasValidTwitter flag above
      final int statusCode = result.response.statusCode;
      switch (statusCode) {
        case 429: //rate limit (https://developer.twitter.com/en/docs/basics/rate-limiting)
          ShowServiceErrorCommand(context)
              .execute(result.response, customMessage: "Twitter rate limit exceeded. Please try again later.");
          break;
        case 404: //likely invalid twitter username, don't bother showing error dialog.
          break;
        default:
          ShowServiceErrorCommand(context).execute(result.response);
          break;
      }

      List<Tweet> tweets = result.content ?? [];
      twitterModel.addTweets(twitterHandle, tweets);
      twitterModel.isLoading = false;
      twitterModel.scheduleSave();
      int newTweets = contactsModel.getSocialContactByTwitter(twitterHandle)?.newTweets.length ?? 0;
      print("New Tweets = $newTweets");
    }
  }
}
