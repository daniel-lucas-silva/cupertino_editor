// Copyright (c) 2018, the Editor project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:cupertino/cupertino.dart';
import 'package:cupertino_editor/cupertino_editor.dart';
import 'package:flutter/material.dart' show FlutterLogo;
import 'package:quill_delta/quill_delta.dart';

import 'images.dart';

class ZefyrLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Ze'),
        FlutterLogo(size: 24.0),
        Text('yr'),
      ],
    );
  }
}

class FullPageEditorScreen extends StatefulWidget {
  @override
  _FullPageEditorScreenState createState() => _FullPageEditorScreenState();
}

final doc =
    r'[{"insert":"Editor"},{"insert":"\n","attributes":{"heading":1}},{"insert":"Soft and gentle rich text editing for Flutter applications.","attributes":{"i":true}},{"insert":"\n"},{"insert":"​","attributes":{"embed":{"type":"image","source":"asset://images/breeze.jpg"}}},{"insert":"\n"},{"insert":"Photo by Hiroyuki Takeda.","attributes":{"i":true}},{"insert":"\nEditor is currently in "},{"insert":"early preview","attributes":{"b":true}},{"insert":". If you have a feature request or found a bug, please file it at the "},{"insert":"issue tracker","attributes":{"a":"https://github.com/memspace/zefyr/issues"}},{"insert":'
    r'".\nDocumentation"},{"insert":"\n","attributes":{"heading":3}},{"insert":"Quick Start","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/quick_start.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Data Format and Document Model","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/data_and_document.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Style Attributes","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/attr'
    r'ibutes.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Heuristic Rules","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/heuristics.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"FAQ","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/faq.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Clean and modern look"},{"insert":"\n","attributes":{"heading":2}},{"insert":"Editor’s rich text editor is built with simplicity and fle'
    r'xibility in mind. It provides clean interface for distraction-free editing. Think Medium.com-like experience.\nMarkdown inspired semantics"},{"insert":"\n","attributes":{"heading":2}},{"insert":"Ever needed to have a heading line inside of a quote block, like this:\nI’m a Markdown heading"},{"insert":"\n","attributes":{"block":"quote","heading":3}},{"insert":"And I’m a regular paragraph"},{"insert":"\n","attributes":{"block":"quote"}},{"insert":"Code blocks"},{"insert":"\n","attributes":{"headin'
    r'g":2}},{"insert":"Of course:\nimport ‘package:flutter/material.dart’;"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"import ‘package:zefyr/zefyr.dart’;"},{"insert":"\n\n","attributes":{"block":"code"}},{"insert":"void main() {"},{"insert":"\n","attributes":{"block":"code"}},{"insert":" runApp(MyEditorApp());"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"}"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"\n\n\n"}]';

Delta getDelta() {
  return Delta.fromJson(json.decode(doc) as List);
}

enum _Options { darkTheme }

class _FullPageEditorScreenState extends State<FullPageEditorScreen> {
  final EditorController _controller =
      EditorController(NotusDocument.fromDelta(getDelta()));
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;
  StreamSubscription<NotusChange> _sub;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _sub = _controller.document.changes.listen((change) {
      print('${change.source}: ${change.change}');
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _editing
        ? CupertinoButton(
            onPressed: _stopEditing,
            child: Text("Save"),
            padding: EdgeInsets.zero,
          )
        : CupertinoButton(
            onPressed: _startEditing,
            child: Text("Edit"),
            padding: EdgeInsets.zero,
          );
    final result = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: ZefyrLogo(),
        trailing: done,
      ),
      child: SafeArea(
        top: true,
        child: EditorScaffold(
          child: EditorEditor(
            controller: _controller,
            focusNode: _focusNode,
            mode: _editing ? EditorMode.edit : EditorMode.select,
            imageDelegate: CustomImageDelegate(),
            keyboardAppearance: _darkTheme ? Brightness.dark : Brightness.light,
          ),
        ),
      ),
    );
    return result;
  }

  void handlePopupItemSelected(value) {
    if (!mounted) return;
    setState(() {
      if (value == _Options.darkTheme) {
        _darkTheme = !_darkTheme;
      }
    });
  }

  void _startEditing() {
    setState(() {
      _editing = true;
    });
  }

  void _stopEditing() {
    setState(() {
      _editing = false;
    });
  }
}