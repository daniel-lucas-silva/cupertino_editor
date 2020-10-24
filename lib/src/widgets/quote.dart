import 'package:cupertino/cupertino.dart';
import 'package:notus/notus.dart';

import 'paragraph.dart';
import 'theme.dart';

/// Represents a quote block in a Editor editor.
class EditorQuote extends StatelessWidget {
  const EditorQuote({Key key, @required this.node}) : super(key: key);

  final BlockNode node;

  @override
  Widget build(BuildContext context) {
    final theme = EditorTheme.of(context);
    final color = CupertinoTheme.of(context).primaryColor;
    final background = CupertinoTheme.of(context).barBackgroundColor;
    final style = theme.attributeTheme.quote.textStyle;
    final items = <Widget>[];
    for (var line in node.children) {
      items.add(_buildLine(line, style, theme.indentWidth, color, background));
    }

    return Padding(
      padding: theme.attributeTheme.quote.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }

  Widget _buildLine(
    Node node,
    TextStyle blockStyle,
    double indentSize,
    Color color,
    Color background,
  ) {
    LineNode line = node;

    Widget content;
    if (line.style.contains(NotusAttribute.heading)) {
      content = EditorHeading(node: line, blockStyle: blockStyle);
    } else {
      content = EditorParagraph(node: line, blockStyle: blockStyle);
    }

    final row = Row(children: <Widget>[Expanded(child: content)]);
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          left: BorderSide(width: 3.0, color: color),
        ),
      ),
      padding: EdgeInsets.only(left: indentSize),
      child: row,
    );
  }
}
