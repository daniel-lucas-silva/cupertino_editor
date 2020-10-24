import 'package:cupertino/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:notus/notus.dart';

import 'code.dart';
import 'common.dart';
import 'controller.dart';
import 'cursor_timer.dart';
import 'image.dart';
import 'input.dart';
import 'list.dart';
import 'mode.dart';
import 'paragraph.dart';
import 'quote.dart';
import 'render_context.dart';
import 'scope.dart';
import 'selection.dart';

class EditorEditableText extends StatefulWidget {
  const EditorEditableText({
    Key key,
    @required this.controller,
    @required this.focusNode,
    @required this.imageDelegate,
    this.selectionControls,
    this.autofocus = true,
    this.mode = EditorMode.edit,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.physics,
    this.keyboardAppearance = Brightness.light,
  })  : assert(mode != null),
        assert(controller != null),
        assert(focusNode != null),
        assert(keyboardAppearance != null),
        super(key: key);

  final EditorController controller;
  final FocusNode focusNode;
  final EditorImageDelegate imageDelegate;
  final bool autofocus;
  final EditorMode mode;
  final ScrollPhysics physics;
  final TextSelectionControls selectionControls;
  final EdgeInsets padding;
  final Brightness keyboardAppearance;

  @override
  _EditorEditableTextState createState() => _EditorEditableTextState();
}

class _EditorEditableTextState extends State<EditorEditableText>
    with AutomaticKeepAliveClientMixin {
  NotusDocument get document => widget.controller.document;

  TextSelection get selection => widget.controller.selection;

  FocusNode _focusNode;
  FocusAttachment _focusAttachment;

  void requestKeyboard() {
    if (_focusNode.hasFocus) {
      _input.openConnection(
          widget.controller.plainTextEditingValue, widget.keyboardAppearance);
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void focusOrUnfocusIfNeeded() {
    if (!_didAutoFocus && widget.autofocus && widget.mode.canEdit) {
      FocusScope.of(context).autofocus(_focusNode);
      _didAutoFocus = true;
    }
    if (!widget.mode.canEdit && _focusNode.hasFocus) {
      _didAutoFocus = false;
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    super.build(context);

    Widget body = ListBody(children: _buildChildren(context));
    if (widget.padding != null) {
      body = Padding(padding: widget.padding, child: body);
    }

    body = SingleChildScrollView(
      physics: widget.physics,
      controller: _scrollController,
      child: body,
    );

    final layers = <Widget>[body];
    layers.add(EditorSelectionOverlay(
      controls: widget.selectionControls ?? textSelectionControls,
    ));

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Stack(fit: StackFit.expand, children: layers),
    );
  }

  @override
  void initState() {
    _focusNode = widget.focusNode;
    super.initState();
    _focusAttachment = _focusNode.attach(context);
    _input = InputConnectionController(_handleRemoteValueChange);
    _updateSubscriptions();
  }

  @override
  void didUpdateWidget(EditorEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode != widget.focusNode) {
      _focusAttachment.detach();
      _focusNode = widget.focusNode;
      _focusAttachment = _focusNode.attach(context);
    }
    _updateSubscriptions(oldWidget);
    focusOrUnfocusIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = EditorScope.of(context);
    if (_renderContext != scope.renderContext) {
      _renderContext?.removeListener(_handleRenderContextChange);
      _renderContext = scope.renderContext;
      _renderContext.addListener(_handleRenderContextChange);
    }
    if (_cursorTimer != scope.cursorTimer) {
      _cursorTimer?.stop();
      _cursorTimer = scope.cursorTimer;
      _cursorTimer.startOrStop(_focusNode, selection);
    }
    focusOrUnfocusIfNeeded();
  }

  @override
  void dispose() {
    _focusAttachment.detach();
    _cancelSubscriptions();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => _focusNode.hasFocus;

  final ScrollController _scrollController = ScrollController();
  EditorRenderContext _renderContext;
  CursorTimer _cursorTimer;
  InputConnectionController _input;
  bool _didAutoFocus = false;

  List<Widget> _buildChildren(BuildContext context) {
    final result = <Widget>[];
    for (var node in document.root.children) {
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

  void _updateSubscriptions([EditorEditableText oldWidget]) {
    if (oldWidget == null) {
      widget.controller.addListener(_handleLocalValueChange);
      _focusNode.addListener(_handleFocusChange);
      return;
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleLocalValueChange);
      widget.controller.addListener(_handleLocalValueChange);
      _input.updateRemoteValue(widget.controller.plainTextEditingValue);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
      updateKeepAlive();
    }
  }

  void _cancelSubscriptions() {
    _renderContext.removeListener(_handleRenderContextChange);
    widget.controller.removeListener(_handleLocalValueChange);
    _focusNode.removeListener(_handleFocusChange);
    _input.closeConnection();
    _cursorTimer.stop();
  }

  void _handleLocalValueChange() {
    if (widget.mode.canEdit &&
        widget.controller.lastChangeSource == ChangeSource.local) {
      requestKeyboard();
    }
    _input.updateRemoteValue(widget.controller.plainTextEditingValue);
    _cursorTimer.startOrStop(_focusNode, selection);
    setState(() {});
  }

  void _handleFocusChange() {
    _input.openOrCloseConnection(_focusNode,
        widget.controller.plainTextEditingValue, widget.keyboardAppearance);
    _cursorTimer.startOrStop(_focusNode, selection);
    updateKeepAlive();
  }

  void _handleRemoteValueChange(
      int start, String deleted, String inserted, TextSelection selection) {
    widget.controller
        .replaceText(start, deleted.length, inserted, selection: selection);
  }

  void _handleRenderContextChange() {
    setState(() {});
  }
}
