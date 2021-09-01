import 'package:flokk/_internal/log.dart';
import 'package:flokk/api_keys.dart';
import 'package:flokk/commands/abstract_command.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WebSignInCommand extends AbstractCommand {
  WebSignInCommand(BuildContext c) : super(c);

  Future<bool> execute({bool silentSignIn = false}) async {
    Log.p("[WebSignInCommand] isSilentSignIn: $silentSignIn");
    try {
      final gs = GoogleSignIn(
        clientId: ApiKeys().googleWebClientId,
        scopes: ['https://www.googleapis.com/auth/contacts'],
      );

      GoogleSignInAccount? account =
          silentSignIn ? await gs.signInSilently() : await gs.signIn();
      GoogleSignInAuthentication? auth;
      if (account != null) auth = await account.authentication;

      if (auth != null) {
        Log.p("[WebSignInCommand] Success");
        authModel.googleSignIn =
            gs; //save off instance of GoogleSignIn, so it can be used to call googleSignIn.disconnect() if needed
        authModel.googleAccessToken = auth.accessToken ?? "";
        authModel.scheduleSave();
        return true;
      } else {
        Log.p("[WebSignInCommand] Fail");
        return false;
      }
    } catch (e) {
      print("Error!");
      print(e);
      return false;
    }
  }
}
