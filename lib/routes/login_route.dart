import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:airsoft_tournament/routes/privacy_route.dart';

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
        child: AutofillGroup(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 60, bottom: 8),
                    child: Text(
                      isSigningUp ? 'Benvenuto,' : 'Bentornato,',
                      style: kPageTitle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 100),
                    child: Text(
                      isSigningUp
                          ? 'Iscriviti per continuare!'
                          : 'Fai login per continuare!',
                      style: kPageSubtitle,
                    ),
                  ),
                  if (isSigningUp)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NameFormField(updateNickname, true),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EmailFormField(
                        updateEmail, <String>[AutofillHints.email]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PasswordFormField(
                      updatePwd1,
                      <String>[AutofillHints.password],
                    ),
                  ),
                  if (isSigningUp)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConfirmPasswordFormField(updatePwd2, password1),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          isSigningUp = !isSigningUp;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(isSigningUp
                              ? 'Sei già registrato?'
                              : 'Non sei ancora registrato?'),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 20.0,
                    ),
                    child: ElevatedButton(
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
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          isSigningUp ? 'Registrati' : 'Login',
                        ),
                      ),
                    ),
                  ),
                  if (isSigningUp)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(
                            'Registrandomi dichiaro di aver letto e aderisco alla Privacy Policy'),
                        onTap: () => Navigator.of(context)
                            .pushNamed(PrivacyRoute.routeName),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
