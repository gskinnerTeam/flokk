import "dart:io" as io;
import 'dart:io';

import 'package:flokk/_internal/log.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

Future<bool> urlLauncherOpen(String url) async {
  ProcessResult result;
  try {
    if (UniversalPlatform.isLinux) {
      result = await io.Process.run("xdg-open", [
        url,
      ]);
    } else if (UniversalPlatform.isWindows) {
      url = url.replaceAll("&", "^&");
      result = await io.Process.run("start", [url], runInShell: true);
    } else if (UniversalPlatform.isMacOS) {
      result = await io.Process.run("open", [url]);
    } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      if (await urlLauncher.canLaunch(url)) {
        return await urlLauncher.launch(url);
      }
      ;
    }
  } on ProcessException catch (e) {
    Log.e(e?.message);
  }

  return result?.exitCode == 0;
}
