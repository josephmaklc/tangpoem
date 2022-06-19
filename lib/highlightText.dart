// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {

  // constructor
  HighlightText(this.text, this.highlight, this.ignoreCase, this.normalTextStyle, this.highlightTextStyle,this.selectable);

  String text;
  String highlight;
  bool ignoreCase;
  TextStyle normalTextStyle;
  TextStyle highlightTextStyle;
  bool selectable;

  TextSpan _highlightSpan(String content) {
    return TextSpan(text: content, style: highlightTextStyle);
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content, style: normalTextStyle);
  }

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty || text.isEmpty) {
      if (selectable) {
        return SelectableText(text, style: normalTextStyle);
      }
      else {
        return Text(text, style: normalTextStyle);
      }
    }

    var sourceText = ignoreCase ? text.toLowerCase() : text;
    var targetHighlight = ignoreCase ? highlight.toLowerCase() : highlight;

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = sourceText.indexOf(targetHighlight, start);
      if (indexOfHighlight < 0) {
        // no highlight
        spans.add(_normalSpan(text.substring(start)));
        break;
      }
      if (indexOfHighlight > start) {
        // normal text before highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
      }
      start = indexOfHighlight + highlight.length;
      spans.add(_highlightSpan(text.substring(indexOfHighlight, start)));
    } while (true);

    //print("selectable: "+selectable.toString());
    if (selectable) {
      return SelectableText.rich(TextSpan(children: spans));
    }
    else {
      return Text.rich(TextSpan(children: spans));
    }
  }
}