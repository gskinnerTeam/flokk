//If in web, use the FileUploadInputElement found in dart:html
//If on desktop or mobile, use ...

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'universal_picker_locator.dart'
    if (dart.library.html) 'web_picker.dart'
    if (dart.library.io) 'desktop_picker.dart';

abstract class UniversalPicker {
  Uint8List? byteData;
  String? base64Data;

  ValueChanged<String>? onChange;

  void open();

  factory UniversalPicker({String accept = ""}) =>
      getPlatformPicker(accept: accept);
}
