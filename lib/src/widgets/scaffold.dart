import 'package:flutter/widgets.dart';

import 'editor.dart';

/// Provides necessary layout for [EditorEditor].
class EditorScaffold extends StatefulWidget {
  final Widget child;

  const EditorScaffold({Key key, this.child}) : super(key: key);

  static EditorScaffoldState of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_EditorScaffoldAccess>();
    return widget.scaffold;
  }

  @override
  EditorScaffoldState createState() => EditorScaffoldState();
}

class EditorScaffoldState extends State<EditorScaffold> {
  WidgetBuilder _toolbarBuilder;

  void showToolbar(WidgetBuilder builder) {
    setState(() {
      _toolbarBuilder = builder;
    });
  }

  void hideToolbar(WidgetBuilder builder) {
    if (_toolbarBuilder == builder) {
      setState(() {
        _toolbarBuilder = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolbar =
        (_toolbarBuilder == null) ? Container() : _toolbarBuilder(context);
    return _EditorScaffoldAccess(
      scaffold: this,
      child: Column(
        children: <Widget>[
          Expanded(child: widget.child),
          toolbar,
        ],
      ),
    );
  }
}

class _EditorScaffoldAccess extends InheritedWidget {
  final EditorScaffoldState scaffold;

  _EditorScaffoldAccess({Widget child, this.scaffold}) : super(child: child);

  @override
  bool updateShouldNotify(_EditorScaffoldAccess oldWidget) {
    return oldWidget.scaffold != scaffold;
  }
}
