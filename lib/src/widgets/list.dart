import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'paragraph.dart';
import 'theme.dart';

/// Represents number lists and bullet lists in a Editor editor.
class EditorList extends StatelessWidget {
  const EditorList({Key key, @required this.node}) : super(key: key);

  final BlockNode node;

  @override
  Widget build(BuildContext context) {
    final theme = EditorTheme.of(context);
    final items = <Widget>[];
    var index = 1;
    for (var line in node.children) {
      items.add(_buildItem(line, index));
      index++;
    }

    final isNumberList =
        node.style.get(NotusAttribute.block) == NotusAttribute.block.numberList;
    var padding = isNumberList
        ? theme.attributeTheme.numberList.padding
        : theme.attributeTheme.bulletList.padding;
    padding = padding.copyWith(left: theme.indentWidth);

    return Padding(
      padding: padding,
      child: Column(children: items),
    );
  }

  Widget _buildItem(Node node, int index) {
    LineNode line = node;
    return EditorListItem(index: index, node: line);
  }
}

/// An item in a [EditorList].
class EditorListItem extends StatelessWidget {
  EditorListItem({Key key, this.index, this.node}) : super(key: key);

  final int index;
  final LineNode node;

  @override
  Widget build(BuildContext context) {
    final BlockNode block = node.parent;
    final style = block.style.get(NotusAttribute.block);
    final theme = EditorTheme.of(context);
    final blockTheme = (style == NotusAttribute.block.bulletList)
        ? theme.attributeTheme.bulletList
        : theme.attributeTheme.numberList;
    final bulletText =
        (style == NotusAttribute.block.bulletList) ? '•' : '$index.';

    TextStyle textStyle;
    Widget content;
    EdgeInsets padding;

    if (node.style.contains(NotusAttribute.heading)) {
      final headingTheme = EditorHeading.themeOf(node, context);
      textStyle = headingTheme.textStyle;
      padding = headingTheme.padding;
      content = EditorHeading(node: node);
    } else {
      textStyle = theme.defaultLineTheme.textStyle;
      content = EditorLine(
        node: node,
        style: textStyle,
        padding: blockTheme.linePadding,
      );
      padding = blockTheme.linePadding;
    }

    Widget bullet =
        SizedBox(width: 24.0, child: Text(bulletText, style: textStyle));
    if (padding != null) {
      bullet = Padding(padding: padding, child: bullet);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[bullet, Expanded(child: content)],
    );
  }
}
