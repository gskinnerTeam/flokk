import 'package:url_launcher/url_launcher.dart';

Future<bool> urlLauncherOpen(String url) async {
  try {
    if (await canLaunch(url)) {
      return await launch(url);
    }
  } catch (e) {
    print(e);
  }
  return false;
}
