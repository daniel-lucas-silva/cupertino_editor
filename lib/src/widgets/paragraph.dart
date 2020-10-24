import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'theme.dart';

/// Represents regular paragraph line in a Editor editor.
class EditorParagraph extends StatelessWidget {
  EditorParagraph({Key key, @required this.node, this.blockStyle})
      : super(key: key);

  final LineNode node;
  final TextStyle blockStyle;

  @override
  Widget build(BuildContext context) {
    final theme = EditorTheme.of(context);
    var style = theme.defaultLineTheme.textStyle;
    if (blockStyle != null) {
      style = style.merge(blockStyle);
    }
    return EditorLine(
      node: node,
      style: style,
      padding: theme.defaultLineTheme.padding,
    );
  }
}

/// Represents heading-styled line in [EditorEditor].
class EditorHeading extends StatelessWidget {
  EditorHeading({Key key, @required this.node, this.blockStyle})
      : assert(node.style.contains(NotusAttribute.heading)),
        super(key: key);

  final LineNode node;
  final TextStyle blockStyle;

  @override
  Widget build(BuildContext context) {
    final theme = themeOf(node, context);
    var style = theme.textStyle;
    if (blockStyle != null) {
      style = style.merge(blockStyle);
    }
    return EditorLine(
      node: node,
      style: style,
      padding: theme.padding,
    );
  }

  static LineTheme themeOf(LineNode node, BuildContext context) {
    final theme = EditorTheme.of(context);
    final style = node.style.get(NotusAttribute.heading);
    if (style == NotusAttribute.heading.level1) {
      return theme.attributeTheme.heading1;
    } else if (style == NotusAttribute.heading.level2) {
      return theme.attributeTheme.heading2;
    } else if (style == NotusAttribute.heading.level3) {
      return theme.attributeTheme.heading3;
    }
    throw UnimplementedError('Unsupported heading style $style');
  }
}
