import 'dart:io';

import 'package:flokk/_internal/utils/path.dart';
import 'package:path/path.dart' as p;

import 'universal_file.dart';

class IoFileWriter implements UniversalFile {
  Directory dataPath;

  @override
  String fileName;

  IoFileWriter(this.fileName);

  String get fullPath => p.join(dataPath.path, fileName);

  Future getDataPath() async {
    if (dataPath != null) return;
    dataPath = Directory(await PathUtil.dataPath);
    if (Platform.isWindows || Platform.isLinux) {
      createDirIfNotExists(dataPath);
    }
  }

  @override
  Future<String> read() async {
    await getDataPath();
    return await File("$fullPath").readAsString().catchError(print);
  }

  @override
  Future write(String value, [bool append = false]) async {
    await getDataPath();
    await File("$fullPath")
        .writeAsString(
          value,
          mode: append ? FileMode.append : FileMode.write,
        )
        .catchError(print);
  }

  static void createDirIfNotExists(Directory dir) async {
    //Create directory if it doesn't exist
    if (dir != null && !await dir.exists()) {
      //Catch error since disk io can always fail.
      await dir.create(recursive: true).catchError((e, stack) => print(e));
    }
  }
}

UniversalFile getPlatformFileWriter(String string) => IoFileWriter(string);
