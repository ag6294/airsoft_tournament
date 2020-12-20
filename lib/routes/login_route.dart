import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginRoute extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SignInForm(),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  bool isSigningUp = false;
  bool isLoading = true;

  String email;
  String password1;
  String password2;
  String nickname;

  @override
  void initState() {
    super.initState();
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    try {
      await Provider.of<LoginProvider>(context, listen: false).tryAutoSignIn();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showDialog(e.toString());
    }
  }

  void updateEmail(String newValue) {
    email = newValue.trim();
  }

  void updatePwd1(String newValue) {
    setState(() {
      password1 = newValue.trim();
    });
  }

  void updatePwd2(String newValue) {
    password2 = newValue.trim();
  }

  void updateNickname(String newValue) {
    nickname = newValue.trim();
  }

  void _showDialog(String text) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: SingleChildScrollView(
            child: Text(text),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isSigningUp)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NameFormField(updateNickname),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: EmailFormField(updateEmail),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PasswordFormField(updatePwd1),
              ),
              if (isSigningUp)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ConfirmPasswordFormField(updatePwd2, password1),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () => setState(() {
                      isSigningUp = !isSigningUp;
                    }),
                    child: Text(isSigningUp
                        ? 'Sei già registrato?'
                        : 'Non sei ancora registrato?'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          isSigningUp
                              ? await Provider.of<LoginProvider>(context,
                                      listen: false)
                                  .trySignUp(email, password1, nickname)
                              : await Provider.of<LoginProvider>(context,
                                      listen: false)
                                  .trySignIn(email, password1);
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          _showDialog(e.toString());
                        }
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text(
                      isSigningUp ? 'Registrati' : 'Login',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
