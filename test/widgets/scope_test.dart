// Copyright (c) 2018, the Editor project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cupertino_editor/cupertino_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$EditorScope', () {
    EditorScope scope;

    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      final doc = NotusDocument();
      scope = EditorScope.editable(
        mode: EditorMode.edit,
        controller: EditorController(doc),
        focusNode: FocusNode(),
        focusScope: FocusScopeNode(),
      );
    });

    test('it notifies on image delegate update', () {
      var notified = false;
      scope.addListener(() {
        notified = true;
      });
      final delegate = _TestImageDelegate();
      scope.imageDelegate = delegate;
      expect(notified, isTrue);
      notified = false;
      scope.imageDelegate = delegate;
      expect(notified, isFalse);
    });

    test('it notifies on controller update', () {
      var notified = false;
      scope.addListener(() {
        notified = true;
      });
      final controller = EditorController(NotusDocument());
      scope.controller = controller;
      expect(notified, isTrue);
      notified = false;
      scope.controller = controller;
      expect(notified, isFalse);
    });

    test('it notifies on focus node update', () {
      var notified = false;
      scope.addListener(() {
        notified = true;
      });
      final focusNode = FocusNode();
      scope.focusNode = focusNode;
      expect(notified, isTrue);
      notified = false;
      scope.focusNode = focusNode;
      expect(notified, isFalse);
    });

    test('it notifies on selection changes but not text changes', () {
      var notified = false;
      scope.addListener(() {
        notified = true;
      });

      scope.controller.replaceText(0, 0, 'Hello');
      expect(notified, isFalse);
      scope.controller.updateSelection(TextSelection.collapsed(offset: 4));
      expect(notified, isTrue);
    });
  });
}

class _TestImageDelegate implements EditorImageDelegate<String> {
  @override
  Widget buildImage(BuildContext context, String key) {
    return null;
  }

  @override
  String get cameraSource => null;

  @override
  String get gallerySource => null;

  @override
  Future<String> pickImage(String source) {
    return null;
  }
}
