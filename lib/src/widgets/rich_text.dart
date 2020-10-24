import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';

import 'caret.dart';
import 'editable_box.dart';
import 'selection_utils.dart';

class EditorRichText extends LeafRenderObjectWidget {
  EditorRichText({
    @required this.node,
    @required this.text,
  }) : assert(node != null && text != null);

  final LineNode node;
  final TextSpan text;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderEditorParagraph(
      text,
      node: node,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderEditorParagraph renderObject) {
    renderObject
      ..text = text
      ..node = node;
  }
}

class RenderEditorParagraph extends RenderParagraph
    implements RenderEditableBox {
  RenderEditorParagraph(
    TextSpan text, {
    @required LineNode node,
    TextAlign textAlign = TextAlign.start,
    @required TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLines,
  })  : node = node,
        _prototypePainter = TextPainter(
          text: TextSpan(text: '.', style: text.style),
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
        ),
        super(
          text,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
        );

  @override
  LineNode node;

  @override
  double get preferredLineHeight => _prototypePainter.height;

  @override
  SelectionOrder get selectionOrder => SelectionOrder.background;

  @override
  TextSelection getLocalSelection(TextSelection documentSelection) {
    if (!intersectsWithSelection(documentSelection)) {
      return null;
    }
    final nodeBase = node.documentOffset;
    final nodeExtent = nodeBase + node.length;
    return selectionRestrict(nodeBase, nodeExtent, documentSelection);
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    final position = super.getPositionForOffset(offset);
    return TextPosition(
      offset: node.documentOffset + position.offset,
      affinity: position.affinity,
    );
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    final localPosition = TextPosition(
      offset: position.offset - node.documentOffset,
      affinity: position.affinity,
    );
    final localRange = super.getWordBoundary(localPosition);
    return TextRange(
      start: node.documentOffset + localRange.start,
      end: node.documentOffset + localRange.end,
    );
  }

  @override
  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) {
    final localPosition = TextPosition(
      offset: position.offset - node.documentOffset,
      affinity: position.affinity,
    );
    return super.getOffsetForCaret(localPosition, caretPrototype);
  }

  TextSelection _trimSelection(TextSelection selection) {
    if (selection.baseOffset > node.length - 1) {
      selection = selection.copyWith(baseOffset: node.length - 1);
    }
    if (selection.extentOffset > node.length - 1) {
      selection = selection.copyWith(extentOffset: node.length - 1);
    }
    return selection;
  }

  @override
  List<ui.TextBox> getEndpointsForSelection(TextSelection selection) {
    final local = getLocalSelection(selection);
    if (local.isCollapsed) {
      final caret = CursorPainter.buildPrototype(preferredLineHeight);
      final offset = getOffsetForCaret(local.extent, caret);
      return [
        ui.TextBox.fromLTRBD(
          offset.dx,
          offset.dy,
          offset.dx,
          offset.dy + caret.height,
          TextDirection.ltr,
        )
      ];
    }

    final result = getBoxesForSelection(_trimSelection(local)).toList();

    return result;
  }

  @override
  set text(InlineSpan value) {
    _prototypePainter.text = TextSpan(text: '.', style: value.style);
    _selectionRects = null;
    super.text = value;
  }

  @override
  void performLayout() {
    super.performLayout();
    _prototypePainter.layout(
        minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }

  final TextPainter _prototypePainter;
  List<ui.TextBox> _selectionRects;

  @override
  bool intersectsWithSelection(TextSelection selection) {
    final base = node.documentOffset;
    final extent = base + node.length;
    return selectionIntersectsWith(base, extent, selection);
  }

  TextSelection _lastPaintedSelection;
  @override
  void paintSelection(PaintingContext context, Offset offset,
      TextSelection selection, Color selectionColor) {
    if (_lastPaintedSelection != selection) {
      _selectionRects = null;
    }
    var localSel = getLocalSelection(selection);

    _selectionRects ??= getBoxesForSelection(_trimSelection(localSel));
    final paint = Paint()..color = selectionColor;
    for (var box in _selectionRects) {
      context.canvas.drawRect(box.toRect().shift(offset), paint);
    }
    _lastPaintedSelection = selection;
  }
}
