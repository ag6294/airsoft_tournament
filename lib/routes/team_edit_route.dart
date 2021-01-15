import 'dart:io';

import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:airsoft_tournament/routes/game_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/constants/exceptions.dart' as exc;
import 'package:airsoft_tournament/helpers/firebase_helper.dart' as fb;
import 'package:url_launcher/url_launcher.dart';
import 'package:airsoft_tournament/constants/style.dart';

// ignore: must_be_immutable
class TeamEditRoute extends StatefulWidget {
  static const routeName = '/team/edit';

  @override
  _TeamEditRouteState createState() => _TeamEditRouteState();
}

class _TeamEditRouteState extends State<TeamEditRoute> {
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _imageController = TextEditingController();

  var team = Team(
    password: '',
    players: [],
    id: '',
    name: '',
    imageUrl: '',
    description: '',
    contacts: '',
  );
  String oldImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    team = ModalRoute.of(context).settings.arguments;
    oldImageUrl = team.imageUrl;
  }

  @override
  void dispose() {
    super.dispose();
    _imageController.dispose();
  }

  void _saveForm(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<TeamsProvider>(context, listen: false)
            .editTeam(team, oldImageUrl);
        await Provider.of<LoginProvider>(context, listen: false)
            .getAndSetLoggedPlayerTeam();
      } catch (e) {
        setState(() {
          _isLoading = false;
          exc.showCustomErrorDialog(context, e.toString());
        });
        throw (e);
      }

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(team);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.save), onPressed: () => _saveForm(context))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                // itemExtent: 100,
                // reverse: true,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      hintText: 'Inserisci il nome del team',
                      hintStyle: kFormHint,
                    ),
                    initialValue: team.name,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      team = Team(
                        name: value,
                        password: team.password,
                        players: team.players,
                        id: team.id,
                        contacts: team.contacts,
                        description: team.description,
                        imageUrl: team.imageUrl,
                      );
                    },
                    validator: (value) => _validateText(value),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Inserisci la password del team',
                      hintStyle: kFormHint,
                    ),
                    initialValue: team.password,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      team = Team(
                        name: team.name,
                        password: value,
                        players: team.players,
                        id: team.id,
                        contacts: team.contacts,
                        description: team.description,
                        imageUrl: team.imageUrl,
                      );
                    },
                    validator: (value) => _validatePassword(value),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contatti',
                      hintText: 'Inserisci i contatti per il team (opzionale)',
                      hintStyle: kFormHint,
                    ),
                    initialValue: team.contacts,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      team = Team(
                        name: team.name,
                        password: team.password,
                        players: team.players,
                        id: team.id,
                        contacts: value,
                        description: team.description,
                        imageUrl: team.imageUrl,
                      );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descrizione',
                      hintText:
                          'Inserisci una descrizione per il team (opzionale)',
                      hintStyle: kFormHint,
                    ),
                    initialValue: team.description,
                    maxLines: 3,
                    onSaved: (value) {
                      team = Team(
                        name: team.name,
                        password: team.password,
                        players: team.players,
                        id: team.id,
                        contacts: team.contacts,
                        description: value,
                        imageUrl: team.imageUrl,
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();

                      final picker = ImagePicker();
                      final pickedImage =
                          await picker.getImage(source: ImageSource.gallery);

                      _imageController.text = pickedImage.path;

                      team = Team(
                        name: team.name,
                        password: team.password,
                        players: team.players,
                        id: team.id,
                        contacts: team.contacts,
                        description: team.description,
                        imageUrl: pickedImage.path,
                      );

                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 100,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: Theme.of(context).cardColor),
                          child: team.imageUrl != '' && team.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: fb.FirebaseHelper.isNetworkImage(
                                          team.imageUrl)
                                      ? Image.network(team.imageUrl,
                                          fit: BoxFit.cover)
                                      : Image.file(
                                          File(team.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Center(
                                  child: Text(
                                  '+ Scegli un\'immagine (opzionale)',
                                  textAlign: TextAlign.center,
                                )),
                        ),
                      ),
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

  String _validateText(String value) {
    if (value == null || value == '')
      return 'Compila questo campo!';
    else
      return null;
  }

  String _validatePassword(String value) {
    if (value == null || value == '') return 'Compila questo campo!';
    if (value.length < 6)
      return 'Inserisci una password da almeno 6 caratteri';
    else
      return null;
  }
}
