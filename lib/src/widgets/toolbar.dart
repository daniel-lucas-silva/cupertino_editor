import 'dart:async';
import 'dart:ui' as ui;

import 'package:cupertino/cupertino.dart';
import 'package:notus/notus.dart';

import 'buttons.dart';
import 'scope.dart';

/// List of all button actions supported by [EditorToolbar] buttons.
enum EditorToolbarAction {
  bold,
  italic,
  link,
  unlink,
  clipboardCopy,
  openInBrowser,
  heading,
  headingLevel1,
  headingLevel2,
  headingLevel3,
  bulletList,
  numberList,
  code,
  quote,
  horizontalRule,
  image,
  cameraImage,
  galleryImage,
  hideKeyboard,
  close,
  confirm,
}

final kEditorToolbarAttributeActions = <EditorToolbarAction, NotusAttributeKey>{
  EditorToolbarAction.bold: NotusAttribute.bold,
  EditorToolbarAction.italic: NotusAttribute.italic,
  EditorToolbarAction.link: NotusAttribute.link,
  EditorToolbarAction.heading: NotusAttribute.heading,
  EditorToolbarAction.headingLevel1: NotusAttribute.heading.level1,
  EditorToolbarAction.headingLevel2: NotusAttribute.heading.level2,
  EditorToolbarAction.headingLevel3: NotusAttribute.heading.level3,
  EditorToolbarAction.bulletList: NotusAttribute.block.bulletList,
  EditorToolbarAction.numberList: NotusAttribute.block.numberList,
  EditorToolbarAction.code: NotusAttribute.block.code,
  EditorToolbarAction.quote: NotusAttribute.block.quote,
  EditorToolbarAction.horizontalRule: NotusAttribute.embed.horizontalRule,
};

/// Allows customizing appearance of [EditorToolbar].
abstract class EditorToolbarDelegate {
  /// Builds toolbar button for specified [action].
  ///
  /// Returned widget is usually an instance of [EditorButton].
  Widget buildButton(BuildContext context, EditorToolbarAction action,
      {VoidCallback onPressed});
}

/// Scaffold for [EditorToolbar].
class EditorToolbarScaffold extends StatelessWidget {
  const EditorToolbarScaffold({
    Key key,
    @required this.body,
    this.trailing,
    this.autoImplyTrailing = true,
  }) : super(key: key);

  final Widget body;
  final Widget trailing;
  final bool autoImplyTrailing;

  @override
  Widget build(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    final constraints =
        BoxConstraints.tightFor(height: EditorToolbar.kToolbarHeight);
    final children = <Widget>[
      Expanded(child: body),
    ];

    if (trailing != null) {
      children.add(trailing);
    } else if (autoImplyTrailing) {
      children.add(toolbar.buildButton(context, EditorToolbarAction.close));
    }
    return Container(
      constraints: constraints,
      child: Container(
        color: CupertinoTheme.of(context).barBackgroundColor,
        child: Row(children: children),
      ),
    );
  }
}

/// Toolbar for [EditorEditor].
class EditorToolbar extends StatefulWidget implements PreferredSizeWidget {
  static const kToolbarHeight = 50.0;

  const EditorToolbar({
    Key key,
    @required this.editor,
    this.autoHide = true,
    this.delegate,
  }) : super(key: key);

  final EditorToolbarDelegate delegate;
  final EditorScope editor;

  /// Whether to automatically hide this toolbar when editor loses focus.
  final bool autoHide;

  static EditorToolbarState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_EditorToolbarScope>();
    return scope?.toolbar;
  }

  @override
  EditorToolbarState createState() => EditorToolbarState();

  @override
  ui.Size get preferredSize => Size.fromHeight(EditorToolbar.kToolbarHeight);
}

class _EditorToolbarScope extends InheritedWidget {
  _EditorToolbarScope({Key key, @required Widget child, @required this.toolbar})
      : super(key: key, child: child);

  final EditorToolbarState toolbar;

  @override
  bool updateShouldNotify(_EditorToolbarScope oldWidget) {
    return toolbar != oldWidget.toolbar;
  }
}

class EditorToolbarState extends State<EditorToolbar>
    with SingleTickerProviderStateMixin {
  final Key _toolbarKey = UniqueKey();
  final Key _overlayKey = UniqueKey();

  EditorToolbarDelegate _delegate;
  AnimationController _overlayAnimation;
  WidgetBuilder _overlayBuilder;
  Completer<void> _overlayCompleter;

  TextSelection _selection;

  void markNeedsRebuild() {
    setState(() {
      if (_selection != editor.selection) {
        _selection = editor.selection;
        closeOverlay();
      }
    });
  }

  Widget buildButton(BuildContext context, EditorToolbarAction action,
      {VoidCallback onPressed}) {
    return _delegate.buildButton(context, action, onPressed: onPressed);
  }

  Future<void> showOverlay(WidgetBuilder builder) async {
    assert(_overlayBuilder == null);
    final completer = Completer<void>();
    setState(() {
      _overlayBuilder = builder;
      _overlayCompleter = completer;
      _overlayAnimation.forward();
    });
    return completer.future;
  }

  void closeOverlay() {
    if (!hasOverlay) return;
    _overlayAnimation.reverse().whenComplete(() {
      setState(() {
        _overlayBuilder = null;
        _overlayCompleter?.complete();
        _overlayCompleter = null;
      });
    });
  }

  bool get hasOverlay => _overlayBuilder != null;

  EditorScope get editor => widget.editor;

  @override
  void initState() {
    super.initState();
    _delegate = widget.delegate ?? _DefaultEditorToolbarDelegate();
    _overlayAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _selection = editor.selection;
  }

  @override
  void didUpdateWidget(EditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      _delegate = widget.delegate ?? _DefaultEditorToolbarDelegate();
    }
  }

  @override
  void dispose() {
    _overlayAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[];

    // Must set unique key for the toolbar to prevent it from reconstructing
    // new state each time we toggle overlay.
    final toolbar = EditorToolbarScaffold(
      key: _toolbarKey,
      body: EditorButtonList(buttons: _buildButtons(context)),
      trailing: buildButton(context, EditorToolbarAction.hideKeyboard),
    );

    layers.add(toolbar);

    if (hasOverlay) {
      Widget widget = Builder(builder: _overlayBuilder);
      assert(widget != null);
      final overlay = FadeTransition(
        key: _overlayKey,
        opacity: _overlayAnimation,
        child: widget,
      );
      layers.add(overlay);
    }

    final constraints =
        BoxConstraints.tightFor(height: EditorToolbar.kToolbarHeight);
    return _EditorToolbarScope(
      toolbar: this,
      child: Container(
        constraints: constraints,
        child: Stack(children: layers),
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final buttons = <Widget>[
      buildButton(context, EditorToolbarAction.bold),
      buildButton(context, EditorToolbarAction.italic),
      LinkButton(),
      HeadingButton(),
      buildButton(context, EditorToolbarAction.bulletList),
      buildButton(context, EditorToolbarAction.numberList),
      buildButton(context, EditorToolbarAction.quote),
      buildButton(context, EditorToolbarAction.code),
      buildButton(context, EditorToolbarAction.horizontalRule),
      if (editor.imageDelegate != null) ImageButton(),
    ];
    return buttons;
  }
}

/// Scrollable list of toolbar buttons.
class EditorButtonList extends StatefulWidget {
  const EditorButtonList({Key key, @required this.buttons}) : super(key: key);
  final List<Widget> buttons;

  @override
  _EditorButtonListState createState() => _EditorButtonListState();
}

class _EditorButtonListState extends State<EditorButtonList> {
  final ScrollController _controller = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
    // Workaround to allow scroll controller attach to our ListView so that
    // we can detect if overflow arrows need to be shown on init.
    // TODO: find a better way to detect overflow
    Timer.run(_handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final color = theme.textTheme.textStyle.color;
    final list = ListView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      children: widget.buttons,
      physics: ClampingScrollPhysics(),
    );

    final leftArrow = _showLeftArrow
        ? Icon(CupertinoIcons.left_arrow, size: 18.0, color: color)
        : null;
    final rightArrow = _showRightArrow
        ? Icon(CupertinoIcons.right_arrow, size: 18.0, color: color)
        : null;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 12.0,
          height: EditorToolbar.kToolbarHeight,
          child: Container(child: leftArrow, color: theme.barBackgroundColor),
        ),
        Expanded(child: ClipRect(child: list)),
        SizedBox(
          width: 12.0,
          height: EditorToolbar.kToolbarHeight,
          child: Container(child: rightArrow, color: theme.barBackgroundColor),
        ),
      ],
    );
  }

  void _handleScroll() {
    setState(() {
      _showLeftArrow =
          _controller.position.minScrollExtent != _controller.position.pixels;
      _showRightArrow =
          _controller.position.maxScrollExtent != _controller.position.pixels;
    });
  }
}

class _DefaultEditorToolbarDelegate implements EditorToolbarDelegate {
  static const kDefaultButtonIcons = {
    EditorToolbarAction.bold: Icons.bold,
    EditorToolbarAction.italic: Icons.italic,
    EditorToolbarAction.link: Icons.link,
    EditorToolbarAction.unlink: Icons.multiply,
    EditorToolbarAction.clipboardCopy: Icons.square_on_square,
    EditorToolbarAction.openInBrowser: Icons.square_arrow_up,
    EditorToolbarAction.heading: Icons.textformat_size,
    EditorToolbarAction.bulletList: Icons.list_bullet,
    EditorToolbarAction.numberList: Icons.list_number,
    EditorToolbarAction.code: Icons.chevron_left_slash_chevron_right,
    EditorToolbarAction.quote: Icons.text_quote,
    EditorToolbarAction.horizontalRule: Icons.minus,
    EditorToolbarAction.image: Icons.camera_on_rectangle,
    EditorToolbarAction.cameraImage: Icons.photo_camera,
    EditorToolbarAction.galleryImage: Icons.photo,
    EditorToolbarAction.hideKeyboard: Icons.keyboard_chevron_compact_down,
    EditorToolbarAction.close: Icons.chevron_forward,
    EditorToolbarAction.confirm: Icons.checkmark,
  };

  static const kSpecialIconSizes = {
    EditorToolbarAction.unlink: 20.0,
    EditorToolbarAction.clipboardCopy: 20.0,
    EditorToolbarAction.openInBrowser: 20.0,
    EditorToolbarAction.close: 20.0,
    EditorToolbarAction.confirm: 20.0,
  };

  static const kDefaultButtonTexts = {
    EditorToolbarAction.headingLevel1: 'H1',
    EditorToolbarAction.headingLevel2: 'H2',
    EditorToolbarAction.headingLevel3: 'H3',
  };

  @override
  Widget buildButton(BuildContext context, EditorToolbarAction action,
      {VoidCallback onPressed}) {
    final theme = CupertinoTheme.of(context);
    if (kDefaultButtonIcons.containsKey(action)) {
      final icon = kDefaultButtonIcons[action];
      final size = kSpecialIconSizes[action];
      return EditorButton.icon(
        action: action,
        icon: icon,
        iconSize: size,
        onPressed: onPressed,
      );
    } else {
      final text = kDefaultButtonTexts[action];
      assert(text != null);
      final style = theme.textTheme.textStyle
          .copyWith(fontWeight: FontWeight.bold, fontSize: 14.0);
      return EditorButton.text(
        action: action,
        text: text,
        style: style,
        onPressed: onPressed,
      );
    }
  }
}
