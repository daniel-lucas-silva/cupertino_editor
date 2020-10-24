// Copyright (c) 2018, the Editor project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:cupertino_editor/cupertino_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../testing.dart';

void main() {
  group('$EditorImage', () {
    testWidgets('embed image', (tester) async {
      final editor = EditorSandBox(
        tester: tester,
        imageDelegate: _TestImageDelegate(),
      );
      await editor.pumpAndTap();
      await editor.tapButtonWithIcon(Icons.photo);
      await editor.tapButtonWithIcon(Icons.photo_camera);
      LineNode line = editor.document.root.children.last;
      expect(line.hasEmbed, isTrue);
      EmbedNode embed = line.children.single;
      expect(embed.style.value(NotusAttribute.embed), <String, dynamic>{
        'type': 'image',
        'source': 'file:///tmp/test.jpg',
      });
      expect(find.byType(EditorImage), findsOneWidget);
    });

    testWidgets('tap on left side of image puts caret before it',
        (tester) async {
      final editor = EditorSandBox(
        tester: tester,
        imageDelegate: _TestImageDelegate(),
      );
      await editor.pumpAndTap();
      await editor.tapButtonWithIcon(Icons.photo);
      await editor.tapButtonWithIcon(Icons.photo_camera);
      await editor.updateSelection(base: 0, extent: 0);

      await tester.tapAt(tester.getTopLeft(find.byType(EditorImage)));
      LineNode line = editor.document.root.children.last;
      EmbedNode embed = line.children.single;
      expect(editor.selection.isCollapsed, isTrue);
      expect(editor.selection.extentOffset, embed.documentOffset);
    });

    testWidgets('tap right side of image puts caret after it', (tester) async {
      final editor = EditorSandBox(
        tester: tester,
        imageDelegate: _TestImageDelegate(),
      );
      await editor.pumpAndTap();
      await editor.tapButtonWithIcon(Icons.photo);
      await editor.tapButtonWithIcon(Icons.photo_camera);
      await editor.updateSelection(base: 0, extent: 0);

      final img = find.byType(EditorImage);
      final offset = tester.getBottomRight(img) - Offset(1.0, 1.0);
      await tester.tapAt(offset);
      LineNode line = editor.document.root.children.last;
      EmbedNode embed = line.children.single;
      expect(editor.selection.isCollapsed, isTrue);
      expect(editor.selection.extentOffset, embed.documentOffset + 1);
    });

    testWidgets('selects on long press', (tester) async {
      final editor = EditorSandBox(
        tester: tester,
        imageDelegate: _TestImageDelegate(),
      );
      await editor.pumpAndTap();
      await editor.tapButtonWithIcon(Icons.photo);
      await editor.tapButtonWithIcon(Icons.photo_camera);
      await editor.updateSelection(base: 0, extent: 0);

      final img = find.byType(EditorImage);
      await tester.longPress(img);
      LineNode line = editor.document.root.children.last;
      EmbedNode embed = line.children.single;
      expect(editor.selection.baseOffset, embed.documentOffset);
      expect(editor.selection.extentOffset, embed.documentOffset + 1);
      final state = tester.state(find.byType(EditorSelectionOverlay))
          as EditorSelectionOverlayState;
      expect(state.isToolbarVisible, isTrue);
    });
  });
}

class _TestImageDelegate implements EditorImageDelegate<String> {
  @override
  Widget buildImage(BuildContext context, String key) {
    return Image.file(File(key));
  }

  @override
  String get cameraSource => 'camera';

  @override
  String get gallerySource => 'gallery';

  @override
  Future<String> pickImage(String source) {
    return Future.value('file:///tmp/test.jpg');
  }
}
