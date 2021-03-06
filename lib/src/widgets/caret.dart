import 'dart:ui';

import 'package:flutter/widgets.dart';

class CursorPainter {
  static const double _kCaretHeightOffset = 2.0;
  static const double _kCaretWidth = 2.0;

  static Rect buildPrototype(double lineHeight) {
    return Rect.fromLTWH(
        0.0, 0.0, _kCaretWidth, lineHeight - _kCaretHeightOffset);
  }

  CursorPainter(Color color)
      : assert(color != null),
        _color = color;

  Rect _prototype;

  Rect get prototype => _prototype;

  Color _color;
  Color get color => _color;
  set color(Color value) {
    assert(value != null);
    _color = value;
  }

  void layout(double lineHeight) {
    _prototype = buildPrototype(lineHeight);
  }

  void paint(Canvas canvas, Offset offset) {
    final paint = Paint()..color = _color;
    final caretRect = _prototype.shift(offset);
    canvas.drawRect(caretRect, paint);
  }
}
