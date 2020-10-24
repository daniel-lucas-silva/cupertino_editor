import 'package:cupertino/cupertino.dart';

import 'controller.dart';
import 'editor.dart';
import 'image.dart';
import 'mode.dart';
import 'toolbar.dart';

class EditorField extends StatefulWidget {
  final double height;
  final EditorController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final EditorMode mode;
  final EditorToolbarDelegate toolbarDelegate;
  final EditorImageDelegate imageDelegate;
  final ScrollPhysics physics;

  final Brightness keyboardAppearance;

  const EditorField({
    Key key,
    this.height,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.mode,
    this.toolbarDelegate,
    this.imageDelegate,
    this.physics,
    this.keyboardAppearance,
  }) : super(key: key);

  @override
  _EditorFieldState createState() => _EditorFieldState();
}

class _EditorFieldState extends State<EditorField> {
  EditorMode get _effectiveMode => widget.mode ?? EditorMode.edit;
  @override
  Widget build(BuildContext context) {
    Widget child = EditorEditor(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mode: _effectiveMode,
      toolbarDelegate: widget.toolbarDelegate,
      imageDelegate: widget.imageDelegate,
      physics: widget.physics,
      keyboardAppearance: widget.keyboardAppearance,
    );

    if (widget.height != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: widget.height),
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge(
        <Listenable>[widget.focusNode, widget.controller],
      ),
      builder: (BuildContext context, Widget child) {
        return child;
      },
      child: child,
    );
  }
}
