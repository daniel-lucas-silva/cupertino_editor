// Copyright (c) 2018, the Editor project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:ui';

import 'package:cupertino_editor/cupertino_editor.dart';
import 'package:cupertino_editor/src/widgets/rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$EditorRichText', () {
    final doc = NotusDocument();
    doc.insert(0, 'This House Is A Circus');
    final text = TextSpan(text: 'This House Is A Circus');

    Widget widget;
    setUp(() {
      widget = Directionality(
        textDirection: TextDirection.ltr,
        child: EditorRichText(
          node: doc.root.children.first as LineNode,
          text: text,
        ),
      );
    });

    testWidgets('initialize', (tester) async {
      await tester.pumpWidget(widget);
      final result =
          tester.firstWidget(find.byType(EditorRichText)) as EditorRichText;
      expect(result, isNotNull);
      expect(result.text.text, 'This House Is A Circus');
    });
  });
}
