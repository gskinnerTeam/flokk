import "dart:io" as io;
import 'dart:io';

import 'package:flokk/_internal/log.dart';
import 'package:universal_platform/universal_platform.dart';

Future<bool> urlLauncherOpen(String url) async {
  ProcessResult? result;
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
    }
  } on ProcessException catch (e) {
    Log.e(e.message);
  }

  return result?.exitCode == 0;
}
