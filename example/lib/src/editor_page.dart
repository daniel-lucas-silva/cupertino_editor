import 'dart:convert';
import 'dart:io';

import 'package:cupertino/cupertino.dart';
import 'package:cupertino_editor/cupertino_editor.dart';
import 'package:quill_delta/quill_delta.dart';

class EditorPage extends StatefulWidget {
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  /// Allows to control the editor and the document.
  EditorController _controller;

  /// Editor editor like any other input field requires a focus node.
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = EditorController(document);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = (_controller == null)
        ? Center(child: CupertinoActivityIndicator())
        : EditorScaffold(
            child: EditorEditor(
              padding: EdgeInsets.all(16),
              controller: _controller,
              focusNode: _focusNode,
            ),
          );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Editor page'),
        trailing: CupertinoButton(
          child: Text("Save"),
          onPressed: () => _saveDocument(context),
        ),
      ),
      child: body,
    );
  }

  /// Loads the document asynchronously from a file if it exists, otherwise
  /// returns default document.
  Future<NotusDocument> _loadDocument() async {
    final file = File(Directory.systemTemp.path + '/quick_start.json');
    if (await file.exists()) {
      final contents = await file
          .readAsString()
          .then((data) => Future.delayed(Duration(seconds: 1), () => data));
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    final delta = Delta()..insert('Editor Quick Start\n');
    return NotusDocument.fromDelta(delta);
  }

  void _saveDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly:
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + '/quick_start.json');
    // And show a snack bar on success.
    file.writeAsString(contents).then(
      (_) {
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Saved.')));
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Saved.'),
            actions: [
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
