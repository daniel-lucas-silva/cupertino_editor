import 'package:cupertino/cupertino.dart';
import 'package:flutter/widgets.dart';

class EditorTheme extends InheritedWidget {
  final EditorThemeData data;

  EditorTheme({
    Key key,
    @required this.data,
    @required Widget child,
  })  : assert(data != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(EditorTheme oldWidget) {
    return data != oldWidget.data;
  }

  static EditorThemeData of(BuildContext context, {bool nullOk = false}) {
    final widget = context.dependOnInheritedWidgetOfExactType<EditorTheme>();
    if (widget == null && nullOk) return null;
    assert(widget != null,
        '$EditorTheme.of() called with a context that does not contain a EditorEditor.');
    return widget.data;
  }
}

@immutable
class EditorThemeData {
  final LineTheme defaultLineTheme;

  final AttributeTheme attributeTheme;

  final double indentWidth;

  const EditorThemeData({
    this.defaultLineTheme,
    this.attributeTheme,
    this.indentWidth,
  });

  factory EditorThemeData.fallback(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final defaultLineTheme = LineTheme(
      textStyle: defaultStyle.style.copyWith(
        fontSize: 14.0,
        height: 1.2,
        fontFamily: '.SF Pro Text',
        color: CupertinoColors.label.resolveFrom(context).withOpacity(0.9),
        letterSpacing: -0.41,
        inherit: true,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
    );
    return EditorThemeData(
      defaultLineTheme: defaultLineTheme,
      attributeTheme: AttributeTheme.fallback(context, defaultLineTheme),
      indentWidth: 16.0,
    );
  }

  EditorThemeData copyWith({
    LineTheme defaultLineTheme,
    AttributeTheme attributeTheme,
    double indentWidth,
  }) {
    return EditorThemeData(
      defaultLineTheme: defaultLineTheme ?? this.defaultLineTheme,
      attributeTheme: attributeTheme ?? this.attributeTheme,
      indentWidth: indentWidth ?? this.indentWidth,
    );
  }

  EditorThemeData merge(EditorThemeData other) {
    if (other == null) return this;
    return copyWith(
      defaultLineTheme: defaultLineTheme?.merge(other.defaultLineTheme) ??
          other.defaultLineTheme,
      attributeTheme:
          attributeTheme?.merge(other.attributeTheme) ?? other.attributeTheme,
      indentWidth: other.indentWidth ?? indentWidth,
    );
  }

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) return false;
    final EditorThemeData otherData = other;
    return (otherData.defaultLineTheme == defaultLineTheme) &&
        (otherData.attributeTheme == attributeTheme) &&
        (otherData.indentWidth == indentWidth);
  }

  @override
  int get hashCode {
    return hashList([
      defaultLineTheme,
      attributeTheme,
      indentWidth,
    ]);
  }
}

@immutable
class LineTheme {
  final TextStyle textStyle;

  final EdgeInsets padding;

  LineTheme({@required this.textStyle, @required this.padding})
      : assert(textStyle != null),
        assert(padding != null);

  LineTheme copyWith({TextStyle textStyle, EdgeInsets padding}) {
    return LineTheme(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
    );
  }

  LineTheme merge(LineTheme other) {
    if (other == null) return this;
    return copyWith(
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      padding: other.padding ?? padding,
    );
  }

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) return false;
    final LineTheme otherTheme = other;
    return (otherTheme.textStyle == textStyle) &&
        (otherTheme.padding == padding);
  }

  @override
  int get hashCode => hashValues(textStyle, padding);
}

@immutable
class BlockTheme {
  final TextStyle textStyle;
  final bool inheritLineTextStyle;
  final EdgeInsets padding;
  final EdgeInsets linePadding;

  const BlockTheme({
    this.textStyle,
    this.inheritLineTextStyle = true,
    this.padding,
    this.linePadding,
  });

  BlockTheme copyWith({
    TextStyle textStyle,
    EdgeInsets padding,
    bool inheritLineTextStyle,
    EdgeInsets linePadding,
  }) {
    return BlockTheme(
      textStyle: textStyle ?? this.textStyle,
      inheritLineTextStyle: inheritLineTextStyle ?? this.inheritLineTextStyle,
      padding: padding ?? this.padding,
      linePadding: linePadding ?? this.linePadding,
    );
  }

  BlockTheme merge(BlockTheme other) {
    if (other == null) return this;
    return copyWith(
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      inheritLineTextStyle: other.inheritLineTextStyle ?? inheritLineTextStyle,
      padding: other.padding ?? padding,
      linePadding: other.linePadding ?? linePadding,
    );
  }

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) return false;
    final BlockTheme otherTheme = other;
    return (otherTheme.textStyle == textStyle) &&
        (otherTheme.inheritLineTextStyle == inheritLineTextStyle) &&
        (otherTheme.padding == padding) &&
        (otherTheme.linePadding == linePadding);
  }

  @override
  int get hashCode =>
      hashValues(textStyle, inheritLineTextStyle, padding, linePadding);
}

@immutable
class AttributeTheme {
  final TextStyle bold;
  final TextStyle italic;
  final TextStyle link;
  final LineTheme heading1;
  final LineTheme heading2;
  final LineTheme heading3;
  final BlockTheme bulletList;
  final BlockTheme numberList;
  final BlockTheme quote;
  final BlockTheme code;

  AttributeTheme({
    this.bold,
    this.italic,
    this.link,
    this.heading1,
    this.heading2,
    this.heading3,
    this.bulletList,
    this.numberList,
    this.quote,
    this.code,
  });

  factory AttributeTheme.fallback(
    BuildContext context,
    LineTheme defaultLineTheme,
  ) {
    final theme = CupertinoTheme.of(context);
    final color = CupertinoColors.label.resolveFrom(context);

    return AttributeTheme(
      bold: TextStyle(fontWeight: FontWeight.bold),
      italic: TextStyle(fontStyle: FontStyle.italic),
      link: TextStyle(
        decoration: TextDecoration.underline,
        color: theme.primaryColor,
      ),
      heading1: LineTheme(
        textStyle: defaultLineTheme.textStyle.copyWith(
          fontSize: 34.0,
          fontFamily: '.SF Pro Display',
          color: color,
          height: 1.15,
          fontWeight: FontWeight.w300,
        ),
        padding: EdgeInsets.only(top: 16.0),
      ),
      heading2: LineTheme(
        textStyle: defaultLineTheme.textStyle.copyWith(
          fontSize: 24.0,
          fontFamily: '.SF Pro Display',
          color: color,
          height: 1.15,
          fontWeight: FontWeight.normal,
        ),
        padding: EdgeInsets.only(top: 8.0),
      ),
      heading3: LineTheme(
        textStyle: defaultLineTheme.textStyle.copyWith(
          fontSize: 20.0,
          fontFamily: '.SF Pro Display',
          color: color,
          height: 1.15,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.only(top: 8.0),
      ),
      bulletList: BlockTheme(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        linePadding: EdgeInsets.symmetric(vertical: 2.0),
      ),
      numberList: BlockTheme(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        linePadding: EdgeInsets.symmetric(vertical: 2.0),
      ),
      quote: BlockTheme(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        textStyle: TextStyle(
          color: color.withOpacity(0.8),
        ),
        inheritLineTextStyle: true,
      ),
      code: BlockTheme(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        textStyle: TextStyle(
          fontFamily: 'Menlo',
          fontSize: 14.0,
          color: color.withOpacity(0.9),
          height: 1.25,
        ),
        inheritLineTextStyle: false,
        linePadding: EdgeInsets.zero,
      ),
    );
  }

  AttributeTheme copyWith({
    TextStyle bold,
    TextStyle italic,
    TextStyle link,
    LineTheme heading1,
    LineTheme heading2,
    LineTheme heading3,
    BlockTheme bulletList,
    BlockTheme numberList,
    BlockTheme quote,
    BlockTheme code,
  }) {
    return AttributeTheme(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      link: link ?? this.link,
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      bulletList: bulletList ?? this.bulletList,
      numberList: numberList ?? this.numberList,
      quote: quote ?? this.quote,
      code: code ?? this.code,
    );
  }

  AttributeTheme merge(AttributeTheme other) {
    if (other == null) return this;
    return copyWith(
      bold: bold?.merge(other.bold) ?? other.bold,
      italic: italic?.merge(other.italic) ?? other.italic,
      link: link?.merge(other.link) ?? other.link,
      heading1: heading1?.merge(other.heading1) ?? other.heading1,
      heading2: heading2?.merge(other.heading2) ?? other.heading2,
      heading3: heading3?.merge(other.heading3) ?? other.heading3,
      bulletList: bulletList?.merge(other.bulletList) ?? other.bulletList,
      numberList: numberList?.merge(other.numberList) ?? other.numberList,
      quote: quote?.merge(other.quote) ?? other.quote,
      code: code?.merge(other.code) ?? other.code,
    );
  }

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) return false;
    final AttributeTheme otherTheme = other;
    return (otherTheme.bold == bold) &&
        (otherTheme.italic == italic) &&
        (otherTheme.link == link) &&
        (otherTheme.heading1 == heading1) &&
        (otherTheme.heading2 == heading2) &&
        (otherTheme.heading3 == heading3) &&
        (otherTheme.bulletList == bulletList) &&
        (otherTheme.numberList == numberList) &&
        (otherTheme.quote == quote) &&
        (otherTheme.code == code);
  }

  @override
  int get hashCode {
    return hashList([
      bold,
      italic,
      link,
      heading1,
      heading2,
      heading3,
      bulletList,
      numberList,
      quote,
      code,
    ]);
  }
}
