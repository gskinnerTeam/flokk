import 'package:flokk/_internal/universal_file/universal_file.dart';
import 'package:intl/intl.dart';

class Log {
  static bool writeToDisk = true;
  static late UniversalFile _printFile;
  static late UniversalFile _errorFile;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _printFile = UniversalFile("editor-log.txt");
    _errorFile = UniversalFile("error-log.txt");
  }

  static void p(String value, [bool writeTimestamp = true]) {
    init().then((_) {
      print(value);
      if (writeToDisk) {
        _printFile.write(_formatLine(value, writeTimestamp), true);
      }
    });
  }

  static String _formatLine(String value, bool writeTimestamp) {
    String date = writeTimestamp
        ? "${DateFormat("EEE MMM d @ H:m:s").format(DateTime.now())}"
        : "";
    return "$date: $value \n";
  }

  static void e(String error, {StackTrace? stack, bool writeTimestamp = true}) {
    init().then((dynamic value) {
      print("[ERROR] $error");
      if (writeToDisk) {
        _errorFile.write(
            _formatLine("[ERROR] $value\n${stack?.toString()}", writeTimestamp),
            true);
      }
    });
  }
}
