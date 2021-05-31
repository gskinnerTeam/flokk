import 'package:shared_preferences/shared_preferences.dart';

import 'universal_file.dart';

class WebFileWriter implements UniversalFile {
  late SharedPreferences prefs;
  bool _hasPrefs = false;

  @override
  String fileName;

  String? _lastWrite;

  WebFileWriter(this.fileName);

  Future<void> initPrefs() async {
    if (_hasPrefs)
      return;
    _hasPrefs = true;
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<String> read() async {
    await initPrefs();
    String? value = prefs.getString(fileName);
    if (value == null)
      throw Exception("$fileName not found");
    //print("Reading pref: $fileName = $value");
    return value;
  }

  @override
  Future write(String value, [bool append = false]) async {
    await initPrefs();
    if (append && _lastWrite == null) {
      String lastWrite = await read();
      _lastWrite = lastWrite;
      value = lastWrite + value;
    }
    //print("Write: $fileName = $value");
    _lastWrite = value;
    await prefs.setString(fileName, value);
  }
}

UniversalFile getPlatformFileWriter(String fileName) => WebFileWriter(fileName);
