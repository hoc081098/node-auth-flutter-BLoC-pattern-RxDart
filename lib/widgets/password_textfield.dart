import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String errorText;
  final String labelText;
  final TextInputAction textInputAction;
  final VoidCallback onSubmitted;
  final FocusNode focusNode;

  const PasswordTextField({
    Key key,
    @required this.onChanged,
    @required this.errorText,
    @required this.labelText,
    @required this.onSubmitted,
    @required this.textInputAction,
    @required this.focusNode,
  }) : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: true,
      obscureText: _obscureText,
      decoration: InputDecoration(
        errorText: widget.errorText,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          iconSize: 18.0,
        ),
        labelText: widget.labelText,
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(Icons.lock),
        ),
      ),
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: TextStyle(fontSize: 16.0),
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted(),
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
    );
  }
}
