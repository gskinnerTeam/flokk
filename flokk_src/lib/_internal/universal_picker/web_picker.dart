import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'universal_picker.dart';

class WebPicker implements UniversalPicker {
  @override
  ValueChanged<String> onChange;

  @override
  Uint8List byteData;

  @override
  String base64Data;

  InputElement uploadInput;
  FileReader reader;

  WebPicker({String accept}) {
    print("Web Picker Constructor: accept: $accept");
    reader = FileReader();
    reader.onLoad.listen(handleFileLoad);

    uploadInput = FileUploadInputElement();
    uploadInput.accept = accept ?? "";
    uploadInput.draggable = true;

    uploadInput.onChange.listen(handleInputChange);
  }

  @override
  void open() {
    print("Web Picker open");
    uploadInput.click();
  }

  void handleInputChange(Event e) {
    if (uploadInput.files?.isNotEmpty ?? false) {
      File f = uploadInput.files.first;
      reader.readAsDataUrl(f);
    }
  }

  void handleFileLoad(ProgressEvent e) {
    base64Data = reader.result.toString().split(",").last;
    byteData = Base64Decoder().convert(base64Data);
    onChange(base64Data);
  }
}

UniversalPicker getPlatformPicker({String accept}) => WebPicker(accept: accept);
