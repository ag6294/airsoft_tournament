import 'package:airsoft_tournament/helpers/form_helper.dart';
import 'package:flutter/material.dart';

class EmailFormField extends StatefulWidget {
  final Function onChanged;

  const EmailFormField(this.onChanged);

  @override
  _EmailFormFieldState createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('email'),
      decoration: InputDecoration(
        labelText: 'Email',
      ),
      validator: (value) => FormHelper.validateEmail(value),
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged,
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final Function onChanged;
  final String teamPwd;

  const PasswordFormField(this.onChanged, [this.teamPwd]);
  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('password'),
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
      ),
      validator: (value) => FormHelper.validatePassword(value, widget.teamPwd),
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged,
    );
  }
}

class ConfirmPasswordFormField extends StatefulWidget {
  final Function onChanged;
  final String pwd1;

  const ConfirmPasswordFormField(this.onChanged, this.pwd1);
  @override
  _ConfirmPasswordFormFieldState createState() =>
      _ConfirmPasswordFormFieldState();
}

class _ConfirmPasswordFormFieldState extends State<ConfirmPasswordFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('password2'),
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Conferma la password',
      ),
      validator: (value) => FormHelper.validatePassword2(widget.pwd1, value),
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged,
    );
  }
}

class NameFormField extends StatefulWidget {
  final Function onChanged;

  const NameFormField(this.onChanged);

  @override
  _NameFormFieldState createState() => _NameFormFieldState();
}

class _NameFormFieldState extends State<NameFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('name'),
      decoration: InputDecoration(
        labelText: 'Nome',
      ),
      validator: (value) => FormHelper.validateNickname(value),
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged,
    );
  }
}
