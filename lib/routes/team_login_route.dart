import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TeamLoginRoute extends StatelessWidget {
  static const routeName = '/team-login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TeamLoginForm(),
      ),
    );
  }
}

class TeamLoginForm extends StatefulWidget {
  @override
  _TeamLoginFormState createState() => _TeamLoginFormState();
}

class _TeamLoginFormState extends State<TeamLoginForm> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Team>>(
      future: Provider.of<LoginProvider>(context, listen: false).fetchTeams(),
      builder: (context, snapshot) => snapshot.hasData
          ? _CustomForm(snapshot.data)
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class TeamDropdown extends StatefulWidget {
  final Function onSelect;
  final Team selectedTeam;
  final List<Team> teams;

  TeamDropdown(this.onSelect, this.teams, this.selectedTeam);

  @override
  _TeamDropdownState createState() => _TeamDropdownState();
}

class _TeamDropdownState extends State<TeamDropdown> {
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<Team>> buttonItems = widget.teams.isNotEmpty
        ? widget.teams
            .map((e) => DropdownMenuItem<Team>(
                  child: Text(e.name),
                  value: e,
                ))
            .toList()
        : [];
    return Container(
      child: DropdownButton<Team>(
        items: buttonItems,
        onChanged: (value) {
          widget.onSelect(value.id);
        },
        value: widget.selectedTeam,
        hint: Text('Scegli il tuo team'),
        isExpanded: true,
      ),
    );
  }
}

class _CustomForm extends StatefulWidget {
  final List<Team> teams;

  const _CustomForm(this.teams);

  @override
  __CustomFormState createState() => __CustomFormState();
}

class __CustomFormState extends State<_CustomForm> {
  final _formKey = GlobalKey<FormState>();

  bool isSigningUp = false;
  bool _isLoading = false;

  String id;
  Team team;
  String name;
  String password1;
  String password2;

  void updateId(String newValue) {
    setState(() {
      id = newValue.trim();
      team =
          widget.teams.firstWhere((element) => element.id.compareTo(id) == 0);
    });
  }

  void updatePwd1(String newValue) {
    setState(() {
      password1 = newValue.trim();
    });
  }

  void updatePwd2(String newValue) {
    password2 = newValue.trim();
  }

  void updateName(String newValue) {
    name = newValue.trim();
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
      inAsyncCall: _isLoading,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 60, bottom: 8),
                  child: Text(
                    'Per completare,',
                    style: kPageTitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 100),
                  child: Text(
                    !isSigningUp
                        ? 'Trova il tuo team!'
                        : 'Crea il tuo nuovo team!',
                    style: kPageSubtitle,
                  ),
                ),
                if (isSigningUp)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NameFormField(updateName),
                  ),
                if (!isSigningUp)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TeamDropdown(updateId, widget.teams, team),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PasswordFormField(updatePwd1, team?.password),
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
                            ? 'Il tuo team è già stato creato?'
                            : 'Vuoi creare un nuovo team?'),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 20.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          isSigningUp
                              ? await Provider.of<LoginProvider>(context,
                                      listen: false)
                                  .createNewTeam(name: name, pwd: password1)
                              : await Provider.of<LoginProvider>(context,
                                      listen: false)
                                  .tryTeamLogin(teamId: id);
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          _showDialog(e.toString());
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(
                        isSigningUp ? 'Crea' : 'Login',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
