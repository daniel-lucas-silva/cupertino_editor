import 'package:cupertino_editor/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef RemoteValueChanged = Function(
    int start, String deleted, String inserted, TextSelection selection);

class InputConnectionController implements TextInputClient {
  InputConnectionController(this.onValueChanged)
      : assert(onValueChanged != null);

  final RemoteValueChanged onValueChanged;

  bool get hasConnection =>
      _textInputConnection != null && _textInputConnection.attached;

  void openOrCloseConnection(FocusNode focusNode, TextEditingValue value,
      Brightness keyboardAppearance) {
    if (focusNode.hasFocus && focusNode.consumeKeyboardToken()) {
      openConnection(value, keyboardAppearance);
    } else if (!focusNode.hasFocus) {
      closeConnection();
    }
  }

  void openConnection(TextEditingValue value, Brightness keyboardAppearance) {
    if (!hasConnection) {
      _lastKnownRemoteTextEditingValue = value;
      _textInputConnection = TextInput.attach(
        this,
        TextInputConfiguration(
          inputType: TextInputType.multiline,
          obscureText: false,
          autocorrect: true,
          inputAction: TextInputAction.newline,
          keyboardAppearance: keyboardAppearance,
          textCapitalization: TextCapitalization.sentences,
        ),
      )
        ..show()
        ..setEditingState(value);
      _sentRemoteValues.add(value);
    } else {
      _textInputConnection.show();
    }
  }

  void closeConnection() {
    if (hasConnection) {
      _textInputConnection.close();
      _textInputConnection = null;
      _lastKnownRemoteTextEditingValue = null;
      _sentRemoteValues.clear();
    }
  }

  void updateRemoteValue(TextEditingValue value) {
    if (!hasConnection) return;

    final actualValue = value.copyWith(
      composing: _lastKnownRemoteTextEditingValue.composing,
    );

    if (actualValue == _lastKnownRemoteTextEditingValue) return;

    final shouldRemember = value.text != _lastKnownRemoteTextEditingValue.text;
    _lastKnownRemoteTextEditingValue = actualValue;
    _textInputConnection.setEditingState(actualValue);
    if (shouldRemember) {
      _sentRemoteValues.add(actualValue);
    }
  }

  @override
  void performAction(TextInputAction action) {}

  @override
  void updateEditingValue(TextEditingValue value) {
    if (_sentRemoteValues.contains(value)) {
      _sentRemoteValues.remove(value);
      return;
    }

    if (_lastKnownRemoteTextEditingValue == value) {
      return;
    }

    if (_lastKnownRemoteTextEditingValue.text == value.text &&
        _lastKnownRemoteTextEditingValue.selection == value.selection) {
      _lastKnownRemoteTextEditingValue = value;
      return;
    }

    try {
      final effectiveLastKnownValue = _lastKnownRemoteTextEditingValue;
      _lastKnownRemoteTextEditingValue = value;
      final oldText = effectiveLastKnownValue.text;
      final text = value.text;
      final cursorPosition = value.selection.extentOffset;
      final diff = fastDiff(oldText, text, cursorPosition);
      onValueChanged(diff.start, diff.deleted, diff.inserted, value.selection);
    } catch (e, trace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: trace,
        library: 'Editor',
        context: ErrorSummary('while updating editing value'),
      ));
      rethrow;
    }
  }

  @override
  TextEditingValue get currentTextEditingValue =>
      _lastKnownRemoteTextEditingValue;

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void connectionClosed() {
    if (hasConnection) {
      _textInputConnection.connectionClosedReceived();
      _textInputConnection = null;
      _lastKnownRemoteTextEditingValue = null;
      _sentRemoteValues.clear();
    }
  }

  final List<TextEditingValue> _sentRemoteValues = [];
  TextInputConnection _textInputConnection;
  TextEditingValue _lastKnownRemoteTextEditingValue;

  @override
  AutofillScope get currentAutofillScope => null;

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}
}
