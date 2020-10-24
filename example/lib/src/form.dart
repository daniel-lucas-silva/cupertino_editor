// Copyright (c) 2018, the Editor project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cupertino/cupertino.dart';
import 'package:cupertino_editor/cupertino_editor.dart';

import 'full_page.dart';
import 'images.dart';

enum _Options { darkTheme }

class FormEmbeddedScreen extends StatefulWidget {
  @override
  _FormEmbeddedScreenState createState() => _FormEmbeddedScreenState();
}

class _FormEmbeddedScreenState extends State<FormEmbeddedScreen> {
  final EditorController _controller = EditorController(NotusDocument());
  final FocusNode _focusNode = FocusNode();

  bool _darkTheme = false;

  @override
  Widget build(BuildContext context) {
    final form = Section(
      children: <Widget>[
        TextFormField(
          decoration: TextFieldDecoration(placeholder: 'Name'),
        ),
        buildEditor(),
        TextFormField(
          decoration: TextFieldDecoration(placeholder: 'Details'),
          settings: TextFieldSettings(
            maxLines: 3,
          ),
        ),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: ZefyrLogo(),
      ),
      child: SafeArea(
        top: true,
        child: EditorScaffold(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: form,
          ),
        ),
      ),
    );
  }

  Widget buildEditor() {
    return EditorField(
      height: 200.0,
      // decoration: InputDecoration(labelText: 'Description'),
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      imageDelegate: CustomImageDelegate(),
      physics: ClampingScrollPhysics(),
    );
  }
}
