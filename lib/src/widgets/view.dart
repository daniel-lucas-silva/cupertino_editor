import 'package:cupertino/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:notus/notus.dart';

import 'code.dart';
import 'common.dart';
import 'image.dart';
import 'list.dart';
import 'paragraph.dart';
import 'quote.dart';
import 'scope.dart';
import 'theme.dart';

@experimental
class EditorView extends StatefulWidget {
  final NotusDocument document;
  final EditorImageDelegate imageDelegate;

  const EditorView({Key key, @required this.document, this.imageDelegate})
      : super(key: key);

  @override
  EditorViewState createState() => EditorViewState();
}

class EditorViewState extends State<EditorView> {
  EditorScope _scope;
  EditorThemeData _themeData;

  EditorImageDelegate get imageDelegate => widget.imageDelegate;

  @override
  void initState() {
    super.initState();
    _scope = EditorScope.view(imageDelegate: widget.imageDelegate);
  }

  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scope.imageDelegate = widget.imageDelegate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentTheme = EditorTheme.of(context, nullOk: true);
    final fallbackTheme = EditorThemeData.fallback(context);
    _themeData = (parentTheme != null)
        ? fallbackTheme.merge(parentTheme)
        : fallbackTheme;
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditorTheme(
      data: _themeData,
      child: EditorScopeAccess(
        scope: _scope,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final result = <Widget>[];
    for (var node in widget.document.root.children) {
      result.add(_defaultChildBuilder(context, node));
    }
    return result;
  }

  Widget _defaultChildBuilder(BuildContext context, Node node) {
    if (node is LineNode) {
      if (node.hasEmbed) {
        return EditorLine(node: node);
      } else if (node.style.contains(NotusAttribute.heading)) {
        return EditorHeading(node: node);
      }
      return EditorParagraph(node: node);
    }

    final BlockNode block = node;
    final blockStyle = block.style.get(NotusAttribute.block);
    if (blockStyle == NotusAttribute.block.code) {
      return EditorCode(node: block);
    } else if (blockStyle == NotusAttribute.block.bulletList) {
      return EditorList(node: block);
    } else if (blockStyle == NotusAttribute.block.numberList) {
      return EditorList(node: block);
    } else if (blockStyle == NotusAttribute.block.quote) {
      return EditorQuote(node: block);
    }

    throw UnimplementedError('Block format $blockStyle.');
  }
}
