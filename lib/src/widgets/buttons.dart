import 'package:cupertino/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:notus/notus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'scope.dart';
import 'toolbar.dart';

class EditorButton extends StatelessWidget {
  EditorButton.icon({
    @required this.action,
    @required IconData icon,
    double iconSize,
    this.onPressed,
  })  : assert(action != null),
        assert(icon != null),
        _icon = icon,
        _iconSize = iconSize,
        _text = null,
        _textStyle = null,
        super();

  EditorButton.text({
    @required this.action,
    @required String text,
    TextStyle style,
    this.onPressed,
  })  : assert(action != null),
        assert(text != null),
        _icon = null,
        _iconSize = null,
        _text = text,
        _textStyle = style,
        super();

  final EditorToolbarAction action;
  final IconData _icon;
  final double _iconSize;
  final String _text;
  final TextStyle _textStyle;

  final VoidCallback onPressed;

  bool get isAttributeAction {
    return kEditorToolbarAttributeActions.keys.contains(action);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final toolbar = EditorToolbar.of(context);
    final editor = toolbar.editor;
    final pressedHandler = _getPressedHandler(editor, toolbar);
    final iconColor = (pressedHandler == null)
        ? CupertinoColors.inactiveGray.resolveFrom(context)
        : theme.textTheme.textStyle.color;
    if (_icon != null) {
      return RawEditorButton.icon(
        action: action,
        icon: _icon,
        size: _iconSize,
        iconColor: iconColor,
        color: _getColor(editor, theme),
        onPressed: _getPressedHandler(editor, toolbar),
      );
    } else {
      assert(_text != null);
      var style = _textStyle ?? TextStyle();
      style = style.copyWith(color: iconColor);

      return RawEditorButton(
        action: action,
        child: Text(_text, style: style),
        color: _getColor(editor, theme),
        onPressed: _getPressedHandler(editor, toolbar),
      );
    }
  }

  Color _getColor(EditorScope editor, CupertinoThemeData theme) {
    if (isAttributeAction) {
      final attribute = kEditorToolbarAttributeActions[action];
      final isToggled = (attribute is NotusAttribute)
          ? editor.selectionStyle.containsSame(attribute)
          : editor.selectionStyle.contains(attribute);
      return isToggled ? theme.barBackgroundColor.lighten(12) : null;
    }
    return null;
  }

  VoidCallback _getPressedHandler(
      EditorScope editor, EditorToolbarState toolbar) {
    if (onPressed != null) {
      return onPressed;
    } else if (isAttributeAction) {
      final attribute = kEditorToolbarAttributeActions[action];
      if (attribute is NotusAttribute) {
        return () => _toggleAttribute(attribute, editor);
      }
    } else if (action == EditorToolbarAction.close) {
      return () => toolbar.closeOverlay();
    } else if (action == EditorToolbarAction.hideKeyboard) {
      return () => editor.hideKeyboard();
    }

    return null;
  }

  void _toggleAttribute(NotusAttribute attribute, EditorScope editor) {
    final isToggled = editor.selectionStyle.containsSame(attribute);
    if (isToggled) {
      editor.formatSelection(attribute.unset);
    } else {
      editor.formatSelection(attribute);
    }
  }
}

class RawEditorButton extends StatelessWidget {
  const RawEditorButton({
    Key key,
    @required this.action,
    @required this.child,
    @required this.color,
    @required this.onPressed,
  }) : super(key: key);

  RawEditorButton.icon({
    @required this.action,
    @required IconData icon,
    double size,
    Color iconColor,
    @required this.color,
    @required this.onPressed,
  })  : child = Icon(icon, size: size, color: iconColor),
        super();

  final EditorToolbarAction action;
  final Widget child;
  final Color color;
  final VoidCallback onPressed;

  bool get isToggled => color != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 6.0),
      child: CupertinoButton(
        color: color,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class HeadingButton extends StatefulWidget {
  const HeadingButton({Key key}) : super(key: key);

  @override
  _HeadingButtonState createState() => _HeadingButtonState();
}

class _HeadingButtonState extends State<HeadingButton> {
  @override
  Widget build(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    return toolbar.buildButton(
      context,
      EditorToolbarAction.heading,
      onPressed: showOverlay,
    );
  }

  void showOverlay() {
    final toolbar = EditorToolbar.of(context);
    toolbar.showOverlay(buildOverlay);
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        SizedBox(width: 8.0),
        toolbar.buildButton(context, EditorToolbarAction.headingLevel1),
        toolbar.buildButton(context, EditorToolbarAction.headingLevel2),
        toolbar.buildButton(context, EditorToolbarAction.headingLevel3),
      ],
    );
    return EditorToolbarScaffold(body: buttons);
  }
}

class ImageButton extends StatefulWidget {
  const ImageButton({Key key}) : super(key: key);

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  @override
  Widget build(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    return toolbar.buildButton(
      context,
      EditorToolbarAction.image,
      onPressed: showOverlay,
    );
  }

  void showOverlay() {
    final toolbar = EditorToolbar.of(context);
    toolbar.showOverlay(buildOverlay);
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    final buttons = Row(
      children: <Widget>[
        SizedBox(width: 8.0),
        toolbar.buildButton(context, EditorToolbarAction.cameraImage,
            onPressed: _pickFromCamera),
        toolbar.buildButton(context, EditorToolbarAction.galleryImage,
            onPressed: _pickFromGallery),
      ],
    );
    return EditorToolbarScaffold(body: buttons);
  }

  void _pickFromCamera() async {
    final editor = EditorToolbar.of(context).editor;
    final image =
        await editor.imageDelegate.pickImage(editor.imageDelegate.cameraSource);
    if (image != null) {
      editor.formatSelection(NotusAttribute.embed.image(image));
    }
  }

  void _pickFromGallery() async {
    final editor = EditorToolbar.of(context).editor;
    final image = await editor.imageDelegate
        .pickImage(editor.imageDelegate.gallerySource);
    if (image != null) {
      editor.formatSelection(NotusAttribute.embed.image(image));
    }
  }
}

class LinkButton extends StatefulWidget {
  const LinkButton({Key key}) : super(key: key);

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  final TextEditingController _inputController = TextEditingController();
  Key _inputKey;
  bool _formatError = false;

  bool get isEditing => _inputKey != null;

  @override
  Widget build(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    final editor = toolbar.editor;
    final enabled =
        hasLink(editor.selectionStyle) || !editor.selection.isCollapsed;

    return toolbar.buildButton(
      context,
      EditorToolbarAction.link,
      onPressed: enabled ? showOverlay : null,
    );
  }

  bool hasLink(NotusStyle style) => style.contains(NotusAttribute.link);

  String getLink([String defaultValue]) {
    final editor = EditorToolbar.of(context).editor;
    final attrs = editor.selectionStyle;
    if (hasLink(attrs)) {
      return attrs.value(NotusAttribute.link);
    }
    return defaultValue;
  }

  void showOverlay() {
    final toolbar = EditorToolbar.of(context);
    toolbar.showOverlay(buildOverlay).whenComplete(cancelEdit);
  }

  void closeOverlay() {
    final toolbar = EditorToolbar.of(context);
    toolbar.closeOverlay();
  }

  void edit() {
    final toolbar = EditorToolbar.of(context);
    setState(() {
      _inputKey = UniqueKey();
      _inputController.text = getLink('https://');
      _inputController.addListener(_handleInputChange);
      toolbar.markNeedsRebuild();
    });
  }

  void doneEdit() {
    final toolbar = EditorToolbar.of(context);
    setState(() {
      var error = false;
      if (_inputController.text.isNotEmpty) {
        try {
          var uri = Uri.parse(_inputController.text);
          if ((uri.isScheme('https') || uri.isScheme('http')) &&
              uri.host.isNotEmpty) {
            toolbar.editor.formatSelection(
                NotusAttribute.link.fromString(_inputController.text));
          } else {
            error = true;
          }
        } on FormatException {
          error = true;
        }
      }
      if (error) {
        _formatError = error;
        toolbar.markNeedsRebuild();
      } else {
        _inputKey = null;
        _inputController.text = '';
        _inputController.removeListener(_handleInputChange);
        toolbar.markNeedsRebuild();
        toolbar.editor.focus();
      }
    });
  }

  void cancelEdit() {
    if (mounted) {
      final editor = EditorToolbar.of(context).editor;
      setState(() {
        _inputKey = null;
        _inputController.text = '';
        _inputController.removeListener(_handleInputChange);
        editor.focus();
      });
    }
  }

  void unlink() {
    final editor = EditorToolbar.of(context).editor;
    editor.formatSelection(NotusAttribute.link.unset);
    closeOverlay();
  }

  void copyToClipboard() {
    var link = getLink();
    assert(link != null);
    Clipboard.setData(ClipboardData(text: link));
  }

  void openInBrowser() async {
    final editor = EditorToolbar.of(context).editor;
    var link = getLink();
    assert(link != null);
    if (await canLaunch(link)) {
      editor.hideKeyboard();
      await launch(link, forceWebView: true);
    }
  }

  void _handleInputChange() {
    final toolbar = EditorToolbar.of(context);
    setState(() {
      _formatError = false;
      toolbar.markNeedsRebuild();
    });
  }

  Widget buildOverlay(BuildContext context) {
    final toolbar = EditorToolbar.of(context);
    final style = toolbar.editor.selectionStyle;

    var value = 'Tap to edit link';
    if (style.contains(NotusAttribute.link)) {
      value = style.value(NotusAttribute.link);
    }
    final clipboardEnabled = value != 'Tap to edit link';
    final body = !isEditing
        ? _LinkView(value: value, onTap: edit)
        : _LinkInput(
            key: _inputKey,
            controller: _inputController,
            formatError: _formatError,
          );
    final items = <Widget>[Expanded(child: body)];
    if (!isEditing) {
      final unlinkHandler = hasLink(style) ? unlink : null;
      final copyHandler = clipboardEnabled ? copyToClipboard : null;
      final openHandler = hasLink(style) ? openInBrowser : null;
      final buttons = <Widget>[
        toolbar.buildButton(context, EditorToolbarAction.unlink,
            onPressed: unlinkHandler),
        toolbar.buildButton(context, EditorToolbarAction.clipboardCopy,
            onPressed: copyHandler),
        toolbar.buildButton(
          context,
          EditorToolbarAction.openInBrowser,
          onPressed: openHandler,
        ),
      ];
      items.addAll(buttons);
    }
    final trailingPressed = isEditing ? doneEdit : closeOverlay;
    final trailingAction =
        isEditing ? EditorToolbarAction.confirm : EditorToolbarAction.close;

    return EditorToolbarScaffold(
      body: Row(children: items),
      trailing: toolbar.buildButton(
        context,
        trailingAction,
        onPressed: trailingPressed,
      ),
    );
  }
}

class _LinkInput extends StatefulWidget {
  final TextEditingController controller;
  final bool formatError;

  const _LinkInput(
      {Key key, @required this.controller, this.formatError = false})
      : super(key: key);

  @override
  _LinkInputState createState() {
    return _LinkInputState();
  }
}

class _LinkInputState extends State<_LinkInput> {
  final FocusNode _focusNode = FocusNode();

  EditorScope _editor;
  bool _didAutoFocus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAutoFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
      _didAutoFocus = true;
    }

    final toolbar = EditorToolbar.of(context);

    if (_editor != toolbar.editor) {
      _editor?.toolbarFocusNode = null;
      _editor = toolbar.editor;
      _editor.toolbarFocusNode = _focusNode;
    }
  }

  @override
  void dispose() {
    _editor?.toolbarFocusNode = null;
    _focusNode.dispose();
    _editor = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final color = widget.formatError
        ? CupertinoColors.systemRed.resolveFrom(context)
        : theme.textTheme.textStyle.color;
    final style = theme.textTheme.textStyle.copyWith(color: color);

    return CupertinoTextField(
      placeholder: 'https://',
      style: style,
      keyboardType: TextInputType.url,
      focusNode: _focusNode,
      controller: widget.controller,
      autofocus: true,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: theme.barBackgroundColor),
    );

    // return TextField(
    //   style: style,
    //   keyboardType: TextInputType.url,
    //   focusNode: _focusNode,
    //   controller: widget.controller,
    //   autofocus: true,
    //   decoration: InputDecoration(
    //     hintText: 'https://',
    //     filled: true,
    //     fillColor: toolbarTheme.color,
    //     border: InputBorder.none,
    //     contentPadding: const EdgeInsets.all(10.0),
    //   ),
    // );
  }
}

class _LinkView extends StatelessWidget {
  const _LinkView({Key key, @required this.value, this.onTap})
      : super(key: key);
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    Widget widget = ClipRect(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            alignment: AlignmentDirectional.centerStart,
            constraints:
                BoxConstraints(minHeight: EditorToolbar.kToolbarHeight),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.textStyle.copyWith(
                color: CupertinoColors.inactiveGray.resolveFrom(context),
              ),
            ),
          )
        ],
      ),
    );
    if (onTap != null) {
      widget = GestureDetector(
        child: widget,
        onTap: onTap,
      );
    }
    return widget;
  }
}
