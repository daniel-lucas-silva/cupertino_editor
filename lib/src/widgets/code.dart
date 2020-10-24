import 'package:cupertino/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'theme.dart';

/// Represents a code snippet in Editor editor.
class EditorCode extends StatelessWidget {
  const EditorCode({Key key, @required this.node}) : super(key: key);

  /// Document node represented by this widget.
  final BlockNode node;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final zefyrTheme = EditorTheme.of(context);

    final items = <Widget>[];
    for (var line in node.children) {
      items.add(_buildLine(line, zefyrTheme.attributeTheme.code.textStyle));
    }

    return Padding(
      padding: zefyrTheme.attributeTheme.code.padding,
      child: Container(
        decoration: BoxDecoration(
          color: theme.barBackgroundColor,
          borderRadius: BorderRadius.circular(3.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }

  Widget _buildLine(Node node, TextStyle style) {
    LineNode line = node;
    return EditorLine(node: line, style: style);
  }
}
