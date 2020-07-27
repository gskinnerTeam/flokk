import 'package:universal_platform/universal_platform.dart';

class UniversalPlatformExt {
  static bool get isMobile => UniversalPlatform.isAndroid || UniversalPlatform.isIOS;
}
