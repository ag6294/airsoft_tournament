import 'dart:io';
import 'package:intl/intl.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';

import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/constants/exceptions.dart' as exc;
import 'package:airsoft_tournament/helpers/firebase_helper.dart' as fb;
import 'dart:core';

import 'package:airsoft_tournament/constants/style.dart';

// ignore: must_be_immutable
class PlayerEditRoute extends StatefulWidget {
  static const routeName = '/player/edit';

  @override
  _PlayerEditRouteState createState() => _PlayerEditRouteState();
}

class _PlayerEditRouteState extends State<PlayerEditRoute> {
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();

  Player player;

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    player = ModalRoute.of(context).settings.arguments;
    if (player.dateOfBirth != null) {
      _dateController.text =
          DateFormat('dd/MM/yyyy').format(player.dateOfBirth);
    }
  }

  void _saveForm(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<LoginProvider>(context, listen: false)
            .updatePlayer(player);
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
      Navigator.of(context).pop();
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
                      labelText: 'Nickname',
                      hintText: 'Inserisci il tuo nickname',
                      hintStyle: kFormHint,
                    ),
                    initialValue: player.nickname,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      player.nickname = value;
                    },
                    validator: (value) => _validateText(value),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      hintText: 'Inserisci il tuo nome',
                      hintStyle: kFormHint,
                    ),
                    initialValue: player.name,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      player.name = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Cognome',
                      hintText: 'Inserisci il tuo cognome',
                      hintStyle: kFormHint,
                    ),
                    initialValue: player.lastName,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      player.lastName = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Luogo di nascita',
                      hintText: 'Inserisci il tuo luogo di nascita',
                      hintStyle: kFormHint,
                    ),
                    initialValue: player.placeOfBirth,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      player.placeOfBirth = value;
                    },
                  ),
                  TextFormField(
                    // textInputAction: TextInputAction.done
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Data di nascita',
                      hintText: 'Inserisci il la tua data di nascita',
                    ),
                    controller: _dateController,
                    validator: (value) => _validateText(value),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      DateTime date = player.dateOfBirth ?? DateTime(1970);

                      date = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        _dateController.text =
                            DateFormat('dd/MM/yyyy').format(date);

                        player.dateOfBirth = date;
                      }
                    },
                  ),
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
}
