// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:que/resources/style_manager.dart';

class EmailPasswordWidget extends StatefulWidget {
  final Function setEmail;
  final Function setPassword;
  bool isSignUp;

  EmailPasswordWidget({
    Key? key,
    required this.setEmail,
    required this.setPassword,
    this.isSignUp = false,
  }) : super(key: key);

  @override
  State<EmailPasswordWidget> createState() => _EmailPasswordWidgetState();
}

class _EmailPasswordWidgetState extends State<EmailPasswordWidget> {
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: getMediumFont(color: Theme.of(context).indicatorColor),
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Email is empty';
            } else if (!value.contains('@') || !value.contains('.com')) {
              return 'Email is invalid';
            }
            return null;
          },
          onChanged: (value) {
            widget.setEmail(value);
          },
        ),
        const SizedBox(
          height: 12.0,
        ),
        TextFormField(
          initialValue: '',
          focusNode: _passwordFocusNode,
          obscureText: _passwordVisible,
          textInputAction: widget.isSignUp ? TextInputAction.next : TextInputAction.done,
          style: getMediumFont(color: Theme.of(context).indicatorColor),
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              icon: Icon(
                !_passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Password is empty';
            } else if (value.length < 7) {
              return 'Password should be 8 or more character long.';
            }
            return null;
          },
          onChanged: (value) {
            widget.setPassword(value);
            password = value;
          },
        ),
        if (widget.isSignUp)
          const SizedBox(
            height: 12.0,
          ),
        if (widget.isSignUp)
          TextFormField(
            initialValue: '',
            focusNode: _confirmPasswordFocusNode,
            obscureText: _confirmPasswordVisible,
            textInputAction: TextInputAction.done,
            style: getMediumFont(color: Theme.of(context).indicatorColor),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
                icon: Icon(
                  !_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              if (password != value!) {
                return 'Password does not match.';
              }
              return null;
            },
            onSaved: (value) {
              password = value!;
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
  }
}
