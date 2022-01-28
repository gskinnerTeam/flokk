import 'package:flokk/_internal/url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SelectableLinkText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextAlign textAlign;

  const SelectableLinkText({
    Key? key,
    required this.text,
    this.textStyle,
    this.linkStyle,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  _LinkTextState createState() => _LinkTextState();
}

class _LinkTextState extends State<SelectableLinkText> {
  List<TapGestureRecognizer> _gestureRecognizers = const <TapGestureRecognizer>[];
  final RegExp _regex = RegExp(
      r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%.,_\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\,+.~#?&//=]*)");

  @override
  void initState() {
    super.initState();
    _gestureRecognizers = <TapGestureRecognizer>[];
  }

  @override
  void dispose() {
    _gestureRecognizers.forEach((recognizer) => recognizer.dispose());
    super.dispose();
  }

  void _launchUrl(String url) async {
    UrlLauncher.openHttp(url);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textStyle = widget.textStyle ?? themeData.textTheme.bodyText1;
    final linkStyle = widget.linkStyle ??
        themeData.textTheme.bodyText1?.copyWith(color: colorScheme.secondary, decoration: TextDecoration.underline);

    final links = _regex.allMatches(widget.text);

    if (links.isEmpty) {
      return SelectableText(widget.text, style: textStyle);
    }

    final textParts = widget.text.split(_regex);
    final textSpans = <TextSpan>[];

    int i = 0;
    textParts.forEach((part) {
      textSpans.add(TextSpan(text: part, style: textStyle));
      if (i < links.length) {
        final link = links.elementAt(i).group(0) ?? "";
        final recognizer = TapGestureRecognizer()..onTap = () => _launchUrl(link);
        _gestureRecognizers.add(recognizer);
        textSpans.add(
          TextSpan(text: link, style: linkStyle, recognizer: recognizer),
        );
        i++;
      }
    });

    return RichText(text: TextSpan(children: textSpans), textAlign: widget.textAlign);
  }
}
