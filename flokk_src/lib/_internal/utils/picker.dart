import 'package:file_selector/file_selector.dart';

import 'path.dart';

Future<String?> pickImage(
    {String confirmText = "", String initialPath = ""}) async {
  if (confirmText.isEmpty) confirmText = "Pick Image";
  if (initialPath.isEmpty) initialPath = await PathUtil.homePath;

  final typeGroup =
      XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png']);
  XFile? file = (await openFile(
    initialDirectory: initialPath,
    confirmButtonText: confirmText,
    acceptedTypeGroups: [typeGroup],
  ));
  if (file != null) {
    return file.path;
  }
  return null;
}
