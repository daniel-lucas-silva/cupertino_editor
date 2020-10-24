// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:cupertino/cupertino.dart';
import 'package:flutter/services.dart';

import 'src/form.dart';
import 'src/full_page.dart';
import 'src/view.dart';

void main() {
  runApp(ZefyrApp());
}

// Create a Focus Intent that does nothing
class FakeFocusIntent extends Intent {
  const FakeFocusIntent();
}

class ZefyrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      shortcuts: Map<LogicalKeySet, Intent>.from(WidgetsApp.defaultShortcuts)
        ..addAll(<LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const FakeFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const FakeFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const FakeFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const FakeFocusIntent(),
        }),
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      title: 'Zefyr Editor',
      home: HomePage(),
      routes: {
        '/fullPage': buildFullPage,
        '/form': buildFormPage,
        '/view': buildViewPage,
      },
    );
  }

  Widget buildFullPage(BuildContext context) {
    return FullPageEditorScreen();
  }

  Widget buildFormPage(BuildContext context) {
    return FormEmbeddedScreen();
  }

  Widget buildViewPage(BuildContext context) {
    return ViewScreen();
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: ZefyrLogo()),
      child: Column(
        children: <Widget>[
          Expanded(child: Container()),
          CupertinoButton(
            onPressed: () => nav.pushNamed('/fullPage'),
            child: Text('Full page editor'),
          ),
          CupertinoButton(
            onPressed: () => nav.pushNamed('/form'),
            child: Text('Embedded in a form'),
          ),
          CupertinoButton(
            onPressed: () => nav.pushNamed('/view'),
            child: Text('Read-only embeddable view'),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
