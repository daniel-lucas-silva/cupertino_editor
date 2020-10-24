import 'dart:ui' as ui;

import 'package:cupertino/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:notus/notus.dart';

import 'editable_box.dart';

class EditorHorizontalRule extends LeafRenderObjectWidget {
  EditorHorizontalRule({@required this.node}) : assert(node != null);

  final EmbedNode node;

  @override
  RenderHorizontalRule createRenderObject(BuildContext context) {
    return RenderHorizontalRule(
      node: node,
      color: CupertinoColors.separator.resolveFrom(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderHorizontalRule renderObject) {
    renderObject..node = node;
  }
}

class RenderHorizontalRule extends RenderEditableBox {
  static const _kPaddingBottom = 17.0;
  static const _kThickness = 1.5;
  static const _kHeight = _kThickness + _kPaddingBottom;

  final Color color;

  RenderHorizontalRule({
    @required EmbedNode node,
    @required this.color,
  }) : _node = node;

  @override
  EmbedNode get node => _node;
  EmbedNode _node;
  set node(EmbedNode value) {
    if (_node == value) return;
    _node = value;
    markNeedsPaint();
  }

  @override
  double get preferredLineHeight => size.height;

  @override
  SelectionOrder get selectionOrder => SelectionOrder.background;

  @override
  List<ui.TextBox> getEndpointsForSelection(TextSelection selection) {
    final local = getLocalSelection(selection);
    if (local.isCollapsed) {
      final dx = local.extentOffset == 0 ? 0.0 : size.width;
      return [
        ui.TextBox.fromLTRBD(dx, 0.0, dx, size.height, TextDirection.ltr),
      ];
    }

    return [
      ui.TextBox.fromLTRBD(0.0, 0.0, 0.0, size.height, TextDirection.ltr),
      ui.TextBox.fromLTRBD(
          size.width, 0.0, size.width, size.height, TextDirection.ltr),
    ];
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    size = Size(constraints.maxWidth, _kHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, _kThickness);
    final paint = ui.Paint()..color = color;
    context.canvas.drawRect(rect.shift(offset), paint);
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    var position = _node.documentOffset;

    if (offset.dx > size.width / 2) {
      position++;
    }
    return TextPosition(offset: position);
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    final start = _node.documentOffset;
    return TextRange(start: start, end: start + 1);
  }

  @override
  void paintSelection(PaintingContext context, Offset offset,
      TextSelection selection, Color selectionColor) {
    final localSelection = getLocalSelection(selection);
    assert(localSelection != null);
    if (!localSelection.isCollapsed) {
      final paint = Paint()..color = selectionColor;
      final rect = Rect.fromLTWH(0.0, 0.0, size.width, _kHeight);
      context.canvas.drawRect(rect.shift(offset), paint);
    }
  }

  @override
  Offset getOffsetForCaret(ui.TextPosition position, ui.Rect caretPrototype) {
    final pos = position.offset - node.documentOffset;
    var caretOffset = Offset.zero;
    if (pos == 1) {
      caretOffset = caretOffset + Offset(size.width - 1.0, 0.0);
    }
    return caretOffset;
  }
}
