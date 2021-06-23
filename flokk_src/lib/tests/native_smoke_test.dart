import 'package:desktop_window/desktop_window.dart';
import 'package:flokk/_internal/url_launcher/url_launcher.dart';
import 'package:flokk/_internal/utils/path.dart';
import 'package:flokk/_internal/utils/picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeSmokeTest extends StatefulWidget {
  const NativeSmokeTest({Key? key}) : super(key: key);

  @override
  _NativeSmokeTestState createState() => _NativeSmokeTestState();
}

class _NativeSmokeTestState extends State<NativeSmokeTest> {
  late String _dataPath;
  late String _imagePath;

  @override
  void initState() {
    _fetchAsyncContent();
    super.initState();
  }

  void _fetchAsyncContent() async {
    final dataPath = await PathUtil.dataPath;

    setState(() => _dataPath = dataPath);
  }

  void _handlePickImage() async {
    final imagePath = await pickImage(confirmText: "Choose Image") ?? "";

    setState(() => _imagePath = imagePath);
  }

  void _handleSetWindowRect() async {
    DesktopWindow.setWindowSize(const Size(256, 256));
  }

  void _handleSetWindowMinSize() async {
    DesktopWindow.setMinWindowSize(const Size(512, 512));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Data path: $_dataPath"),
            MaterialButton(
              onPressed: () => UrlLauncher.open("https://google.com"),
              child: const Text("Open url"),
            ),
            MaterialButton(
              onPressed: () => Clipboard.setData(const ClipboardData()),
              child: const Text("Copy \"clipboard test\" to clipboard"),
            ),
            MaterialButton(
              onPressed: _handlePickImage,
              child: const Text("Open file picker"),
            ),
            Text("Image path: $_imagePath"),
            MaterialButton(
              onPressed: _handleSetWindowRect,
              child: const Text("Set window dimensions"),
            ),
            MaterialButton(
              onPressed: _handleSetWindowMinSize,
              child: const Text("Set window min size"),
            ),
          ],
        ),
      ),
    );
  }
}
