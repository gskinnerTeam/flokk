import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'universal_picker.dart';

class WebPicker implements UniversalPicker {
  @override
  ValueChanged<String>? onChange;

  @override
  Uint8List? byteData;

  @override
  String? base64Data;

  late FileUploadInputElement uploadInput;
  late FileReader reader;

  WebPicker({required String accept}) {
    print("Web Picker Constructor: accept: $accept");
    reader = FileReader();
    reader.onLoad.listen(handleFileLoad);

    uploadInput = FileUploadInputElement();
    uploadInput.accept = accept;
    uploadInput.draggable = true;

    uploadInput.onChange.listen(handleInputChange);
  }

  @override
  void open() {
    print("Web Picker open");
    uploadInput.click();
  }

  void handleInputChange(Event e) {
    List<File> files = uploadInput.files ?? <File>[];
    if (files.isNotEmpty) {
      File f = files.first;
      reader.readAsDataUrl(f);
    }
  }

  void handleFileLoad(ProgressEvent e) {
    base64Data = reader.result.toString().split(",").last;
    if (base64Data != null) byteData = Base64Decoder().convert(base64Data!);
    onChange?.call(base64Data ?? "");
  }
}

UniversalPicker getPlatformPicker({required String accept}) =>
    WebPicker(accept: accept);
