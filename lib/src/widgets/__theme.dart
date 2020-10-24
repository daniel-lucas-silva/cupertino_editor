import 'package:cupertino/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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

class EditorThemeData {
  final TextStyle boldStyle;
  final TextStyle italicStyle;
  final TextStyle linkStyle;
  final StyleTheme paragraphTheme;
  final HeadingTheme headingTheme;
  final BlockTheme blockTheme;
  final Color selectionColor;
  final Color cursorColor;
  final double indentSize;

  factory EditorThemeData.fallback(BuildContext context) {
    final themeData = CupertinoTheme.of(context);
    final defaultStyle = DefaultTextStyle.of(context);
    final paragraphStyle = defaultStyle.style.copyWith(
      fontSize: 16.0,
      height: 1.3,
    );
    const padding = EdgeInsets.symmetric(vertical: 8.0);
    final boldStyle = TextStyle(fontWeight: FontWeight.bold);
    final italicStyle = TextStyle(fontStyle: FontStyle.italic);
    final linkStyle = TextStyle(
      color: themeData.primaryColor,
      decoration: TextDecoration.underline,
    );

    return EditorThemeData(
      boldStyle: boldStyle,
      italicStyle: italicStyle,
      linkStyle: linkStyle,
      paragraphTheme: StyleTheme(textStyle: paragraphStyle, padding: padding),
      headingTheme: HeadingTheme.fallback(context),
      blockTheme: BlockTheme.fallback(context),
      selectionColor: themeData.primaryColor.withOpacity(0.4),
      cursorColor: themeData.primaryColor,
      indentSize: 16.0,
    );
  }

  const EditorThemeData({
    this.boldStyle,
    this.italicStyle,
    this.linkStyle,
    this.paragraphTheme,
    this.headingTheme,
    this.blockTheme,
    this.selectionColor,
    this.cursorColor,
    this.indentSize,
  });

  EditorThemeData copyWith({
    TextStyle textStyle,
    TextStyle boldStyle,
    TextStyle italicStyle,
    TextStyle linkStyle,
    StyleTheme paragraphTheme,
    HeadingTheme headingTheme,
    BlockTheme blockTheme,
    Color selectionColor,
    Color cursorColor,
    double indentSize,
  }) {
    return EditorThemeData(
      boldStyle: boldStyle ?? this.boldStyle,
      italicStyle: italicStyle ?? this.italicStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      paragraphTheme: paragraphTheme ?? this.paragraphTheme,
      headingTheme: headingTheme ?? this.headingTheme,
      blockTheme: blockTheme ?? this.blockTheme,
      selectionColor: selectionColor ?? this.selectionColor,
      cursorColor: cursorColor ?? this.cursorColor,
      indentSize: indentSize ?? this.indentSize,
    );
  }

  EditorThemeData merge(EditorThemeData other) {
    return copyWith(
      boldStyle: other.boldStyle,
      italicStyle: other.italicStyle,
      linkStyle: other.linkStyle,
      paragraphTheme: other.paragraphTheme,
      headingTheme: other.headingTheme,
      blockTheme: other.blockTheme,
      selectionColor: other.selectionColor,
      cursorColor: other.cursorColor,
      indentSize: other.indentSize,
    );
  }
}

class HeadingTheme {
  final StyleTheme level1;
  final StyleTheme level2;
  final StyleTheme level3;

  HeadingTheme({
    @required this.level1,
    @required this.level2,
    @required this.level3,
  });

  factory HeadingTheme.fallback(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    return HeadingTheme(
      level1: StyleTheme(
        textStyle: defaultStyle.style.copyWith(
          fontSize: 34.0,
          color: defaultStyle.style.color.withOpacity(0.70),
          height: 1.15,
          fontWeight: FontWeight.w300,
        ),
        padding: EdgeInsets.only(top: 16.0, bottom: 0.0),
      ),
      level2: StyleTheme(
        textStyle: TextStyle(
          fontSize: 24.0,
          color: defaultStyle.style.color.withOpacity(0.70),
          height: 1.15,
          fontWeight: FontWeight.normal,
        ),
        padding: EdgeInsets.only(bottom: 0.0, top: 8.0),
      ),
      level3: StyleTheme(
        textStyle: TextStyle(
          fontSize: 20.0,
          color: defaultStyle.style.color.withOpacity(0.70),
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.only(bottom: 0.0, top: 8.0),
      ),
    );
  }
}

class BlockTheme {
  final StyleTheme bulletList;

  final StyleTheme numberList;

  final StyleTheme code;

  final StyleTheme quote;

  BlockTheme({
    @required this.bulletList,
    @required this.numberList,
    @required this.quote,
    @required this.code,
  });

  factory BlockTheme.fallback(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final padding = const EdgeInsets.symmetric(vertical: 8.0);

    return BlockTheme(
      bulletList: StyleTheme(padding: padding),
      numberList: StyleTheme(padding: padding),
      quote: StyleTheme(
        textStyle: TextStyle(
          color: defaultTextStyle.style.color.withOpacity(0.6),
        ),
        padding: padding,
      ),
      code: StyleTheme(
        textStyle: TextStyle(
          color: defaultTextStyle.style.color.withOpacity(0.8),
          fontFamily: 'Menlo',
          fontSize: 14.0,
          height: 1.25,
        ),
        padding: padding,
      ),
    );
  }
}

class StyleTheme {
  final TextStyle textStyle;

  final EdgeInsets padding;

  StyleTheme({
    this.textStyle,
    this.padding,
  });
}
