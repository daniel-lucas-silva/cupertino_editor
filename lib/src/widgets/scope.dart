import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';

import 'controller.dart';
import 'cursor_timer.dart';
import 'editor.dart';
import 'image.dart';
import 'mode.dart';
import 'render_context.dart';
import 'view.dart';

/// Provides access to shared state of [EditorEditor] or [EditorView].
///
/// A scope object can be created by an editable widget like [EditorEditor] in
/// which case it provides access to editing state, including focus nodes,
/// selection and such. Editable scope can be created using
/// [EditorScope.editable] constructor.
///
/// If a scope object is created by a view-only widget like [EditorView] then
/// it only provides access to [imageDelegate].
///
/// Can be retrieved using [EditorScope.of].
class EditorScope extends ChangeNotifier {
  /// Creates a view-only scope.
  ///
  /// Normally used in [EditorView].
  EditorScope.view({EditorImageDelegate imageDelegate})
      : isEditable = false,
        _mode = EditorMode.view,
        _imageDelegate = imageDelegate;

  /// Creates editable scope.
  ///
  /// Normally used in [EditorEditor].
  EditorScope.editable({
    @required EditorMode mode,
    @required EditorController controller,
    @required FocusNode focusNode,
    @required FocusScopeNode focusScope,
    EditorImageDelegate imageDelegate,
  })  : assert(mode != null),
        assert(controller != null),
        assert(focusNode != null),
        assert(focusScope != null),
        isEditable = true,
        _mode = mode,
        _controller = controller,
        _imageDelegate = imageDelegate,
        _focusNode = focusNode,
        _focusScope = focusScope,
        _cursorTimer = CursorTimer(),
        _renderContext = EditorRenderContext() {
    _selectionStyle = _controller.getSelectionStyle();
    _selection = _controller.selection;
    _controller.addListener(_handleControllerChange);
    _focusNode.addListener(_handleFocusChange);
  }

  static EditorScope of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<EditorScopeAccess>();
    return widget.scope;
  }

  EditorImageDelegate _imageDelegate;
  EditorImageDelegate get imageDelegate => _imageDelegate;
  set imageDelegate(EditorImageDelegate value) {
    if (_imageDelegate != value) {
      _imageDelegate = value;
      notifyListeners();
    }
  }

  EditorMode _mode;
  EditorMode get mode => _mode;
  set mode(EditorMode value) {
    assert(value != null);
    if (_mode != value) {
      _mode = value;
      notifyListeners();
    }
  }

  EditorController _controller;
  EditorController get controller => _controller;
  set controller(EditorController value) {
    assert(isEditable && value != null);
    if (_controller != value) {
      _controller.removeListener(_handleControllerChange);
      _controller = value;
      _selectionStyle = _controller.getSelectionStyle();
      _selection = _controller.selection;
      _controller.addListener(_handleControllerChange);
      notifyListeners();
    }
  }

  FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;
  set focusNode(FocusNode value) {
    assert(isEditable && value != null);
    if (_focusNode != value) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = value;
      _focusNode.addListener(_handleFocusChange);
      notifyListeners();
    }
  }

  FocusScopeNode _focusScope;
  FocusScopeNode get focusScope => _focusScope;
  set focusScope(FocusScopeNode value) {
    assert(isEditable && value != null);
    if (_focusScope != value) {
      _focusScope = value;
    }
  }

  CursorTimer _cursorTimer;
  CursorTimer get cursorTimer => _cursorTimer;
  ValueNotifier<bool> get showCursor => cursorTimer.value;

  EditorRenderContext _renderContext;
  EditorRenderContext get renderContext => _renderContext;

  NotusStyle get selectionStyle => _selectionStyle;
  NotusStyle _selectionStyle;
  TextSelection get selection => _selection;
  TextSelection _selection;

  bool _disposed = false;
  FocusNode _toolbarFocusNode;

  /// Whether this scope is backed by editable Editor widgets or read-only view.
  ///
  /// Returns `true` if this scope provides Editor interface that allows editing
  /// (e.g. created by [EditorEditor]). Returns `false` if this scope provides
  /// read-only view (e.g. created by [EditorView]).
  ///
  /// Editable scope provides access to corresponding [controller], [focusNode],
  /// [focusScope], [showCursor], [renderContext] and other shared objects. For
  /// non-editable scopes these are set to `null`. You can still access
  /// objects which are not dependent on editing flow, e.g. [imageDelegate].
  final bool isEditable;

  set toolbarFocusNode(FocusNode node) {
    assert(isEditable);
    assert(!_disposed || node == null);
    if (_toolbarFocusNode != node) {
      _toolbarFocusNode?.removeListener(_handleFocusChange);
      _toolbarFocusNode = node;
      _toolbarFocusNode?.addListener(_handleFocusChange);
      // We do not notify listeners here because it will happen when
      // focus state changes, see [_handleFocusChange].
    }
  }

  FocusOwner get focusOwner {
    assert(isEditable);
    assert(!_disposed);
    if (_focusNode.hasFocus) {
      return FocusOwner.editor;
    } else if (_toolbarFocusNode?.hasFocus == true) {
      return FocusOwner.toolbar;
    } else {
      return FocusOwner.none;
    }
  }

  void updateSelection(TextSelection value,
      {ChangeSource source = ChangeSource.remote}) {
    assert(isEditable);
    assert(!_disposed);
    _controller.updateSelection(value, source: source);
  }

  void formatSelection(NotusAttribute value) {
    assert(isEditable);
    assert(!_disposed);
    _controller.formatSelection(value);
  }

  void focus() {
    assert(isEditable);
    assert(!_disposed);
    _focusScope.requestFocus(_focusNode);
  }

  void hideKeyboard() {
    assert(isEditable);
    assert(!_disposed);
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    assert(!_disposed);
    _controller?.removeListener(_handleControllerChange);
    _focusNode?.removeListener(_handleFocusChange);
    _disposed = true;
    super.dispose();
  }

  void _handleControllerChange() {
    assert(!_disposed);
    final attrs = _controller.getSelectionStyle();
    final selection = _controller.selection;
    if (_selectionStyle != attrs || _selection != selection) {
      _selectionStyle = attrs;
      _selection = selection;
      notifyListeners();
    }
  }

  void _handleFocusChange() {
    assert(!_disposed);
    if (focusOwner == FocusOwner.none && !_selection.isCollapsed) {
      // Collapse selection if there is nothing focused.
      _controller.updateSelection(_selection.copyWith(
        baseOffset: _selection.extentOffset,
        extentOffset: _selection.extentOffset,
      ));
    }
    notifyListeners();
  }

  @override
  String toString() {
    return '$EditorScope#${shortHash(this)}';
  }
}

class EditorScopeAccess extends InheritedWidget {
  final EditorScope scope;

  EditorScopeAccess({Key key, @required this.scope, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(EditorScopeAccess oldWidget) {
    return scope != oldWidget.scope;
  }
}
