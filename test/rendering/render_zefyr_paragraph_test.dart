// Copyright (c) 2018, the Editor project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:ui';

import 'package:cupertino_editor/cupertino_editor.dart';
import 'package:cupertino_editor/src/widgets/render_context.dart';
import 'package:cupertino_editor/src/widgets/rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$RenderEditorParagraph', () {
    final doc = NotusDocument();
    doc.insert(0, 'This House Is A Circus');
    final text = TextSpan(text: 'This House Is A Circus');

    EditorRenderContext renderContext;
    RenderEditorParagraph p;

    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      renderContext = EditorRenderContext();
      p = RenderEditorParagraph(
        text,
        node: doc.root.children.first as LineNode,
        textDirection: TextDirection.ltr,
      );
    });

    test('it registers with viewport', () {
      var owner = PipelineOwner();
      expect(renderContext.active, isNot(contains(p)));
      p.attach(owner);
      expect(renderContext.dirty, contains(p));
      p.layout(BoxConstraints());
      expect(renderContext.active, contains(p));
    }, skip: 'TODO: move to RenderEditableProxyBox');
  });
}
