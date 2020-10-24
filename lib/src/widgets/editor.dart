import 'package:cupertino/cupertino.dart';

import 'controller.dart';
import 'editable_text.dart';
import 'image.dart';
import 'mode.dart';
import 'scaffold.dart';
import 'scope.dart';
import 'theme.dart';
import 'toolbar.dart';

class EditorEditor extends StatefulWidget {
  const EditorEditor({
    Key key,
    @required this.controller,
    @required this.focusNode,
    this.autofocus = true,
    this.mode = EditorMode.edit,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.toolbarDelegate,
    this.imageDelegate,
    this.selectionControls,
    this.physics,
    this.keyboardAppearance,
  })  : assert(mode != null),
        assert(controller != null),
        assert(focusNode != null),
        super(key: key);

  final EditorController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final EditorMode mode;
  final EditorToolbarDelegate toolbarDelegate;
  final EditorImageDelegate imageDelegate;
  final TextSelectionControls selectionControls;
  final ScrollPhysics physics;
  final EdgeInsets padding;
  final Brightness keyboardAppearance;

  @override
  _EditorEditorState createState() => _EditorEditorState();
}

class _EditorEditorState extends State<EditorEditor> {
  EditorImageDelegate _imageDelegate;
  EditorScope _scope;
  EditorThemeData _themeData;
  GlobalKey<EditorToolbarState> _toolbarKey;
  EditorScaffoldState _scaffold;

  bool get hasToolbar => _toolbarKey != null;

  void showToolbar() {
    assert(_toolbarKey == null);
    _toolbarKey = GlobalKey();
    _scaffold.showToolbar(buildToolbar);
  }

  void hideToolbar() {
    if (_toolbarKey == null) return;
    _scaffold.hideToolbar(buildToolbar);
    _toolbarKey = null;
  }

  Widget buildToolbar(BuildContext context) {
    return EditorTheme(
      data: _themeData,
      child: EditorToolbar(
        key: _toolbarKey,
        editor: _scope,
        delegate: widget.toolbarDelegate,
      ),
    );
  }

  void _handleChange() {
    if (_scope.focusOwner == FocusOwner.none) {
      hideToolbar();
    } else if (!hasToolbar) {
      showToolbar();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toolbarKey?.currentState?.markNeedsRebuild();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _imageDelegate = widget.imageDelegate;
  }

  @override
  void didUpdateWidget(EditorEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scope.mode = widget.mode;
    _scope.controller = widget.controller;
    _scope.focusNode = widget.focusNode;
    if (widget.imageDelegate != oldWidget.imageDelegate) {
      _imageDelegate = widget.imageDelegate;
      _scope.imageDelegate = _imageDelegate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentTheme = EditorTheme.of(context, nullOk: true);
    final fallbackTheme = EditorThemeData.fallback(context);
    _themeData = (parentTheme != null)
        ? fallbackTheme.merge(parentTheme)
        : fallbackTheme;

    if (_scope == null) {
      _scope = EditorScope.editable(
        mode: widget.mode,
        imageDelegate: _imageDelegate,
        controller: widget.controller,
        focusNode: widget.focusNode,
        focusScope: FocusScope.of(context),
      );
      _scope.addListener(_handleChange);
    } else {
      final focusScope = FocusScope.of(context);
      _scope.focusScope = focusScope;
    }

    final scaffold = EditorScaffold.of(context);
    if (_scaffold != scaffold) {
      final didHaveToolbar = hasToolbar;
      hideToolbar();
      _scaffold = scaffold;
      if (didHaveToolbar) showToolbar();
    }
  }

  @override
  void dispose() {
    hideToolbar();
    _scope.removeListener(_handleChange);
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = CupertinoTheme.of(context);
    final keyboardAppearance =
        widget.keyboardAppearance ?? themeData.brightness;

    Widget editable = EditorEditableText(
      controller: _scope.controller,
      focusNode: _scope.focusNode,
      imageDelegate: _scope.imageDelegate,
      selectionControls: widget.selectionControls,
      autofocus: widget.autofocus,
      mode: widget.mode,
      padding: widget.padding,
      physics: widget.physics,
      keyboardAppearance: keyboardAppearance,
    );

    return EditorTheme(
      data: _themeData,
      child: EditorScopeAccess(
        scope: _scope,
        child: editable,
      ),
    );
  }
}
