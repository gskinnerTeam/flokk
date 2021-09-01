import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flokk/_internal/utils/picker.dart';
import 'package:flutter/foundation.dart';

import 'universal_picker.dart';

class DesktopPicker implements UniversalPicker {
  @override
  ValueChanged<String>? onChange;

  @override
  Uint8List? byteData;

  @override
  String? base64Data;

  //accept: filters for files (ie. images, etc), expecting the same format as that found for html input accept https://www.w3schools.com/TAGS/att_input_accept.asp
  DesktopPicker({required String accept}) {
    // The desktop file picker plugin doesn't accept these input accept strings,
    // the pickImage function has a hardcoded image filter in it
  }

  void _openPicker() async {
    final imagePath = await pickImage(confirmText: "Upload image");
    if (imagePath == null)
      // The user most likely pressed cancel or we don't have an image for some other reason, return
      return;
    final bytes = await File(imagePath).readAsBytes();
    byteData = bytes;
    base64Data = Base64Encoder().convert(bytes.toList());

    onChange?.call(base64Data ?? "");
  }

  @override
  void open() {
    _openPicker();
  }
}

UniversalPicker getPlatformPicker({required String accept}) =>
    DesktopPicker(accept: accept);
