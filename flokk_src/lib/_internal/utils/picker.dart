import 'package:file_chooser/file_chooser.dart';

import 'path.dart';

Future<String> pickImage({String confirmText, String initialPath}) async {
  confirmText ??= "Pick Image";
  initialPath ??= await PathUtil.dataPath;

  final result = await showOpenPanel(
    initialDirectory: initialPath,
    allowedFileTypes: [
      FileTypeFilterGroup(
        label: "images",
        fileExtensions: ["png", "jpg", "jpeg", "gif", "webm"],
      ),
    ],
    allowsMultipleSelection: false,
    canSelectDirectories: false,
    confirmButtonText: confirmText,
  );

  if (result.canceled || result.paths.isEmpty) {
    return null;
  }

  return result.paths[0];
}
