import 'dart:io';

import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/routes/game_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/constants/exceptions.dart' as exc;
import 'package:airsoft_tournament/helpers/firebase_helper.dart' as fb;

// ignore: must_be_immutable
class EditGameRoute extends StatefulWidget {
  static const routeName = '/game/edit';

  @override
  _EditGameRouteState createState() => _EditGameRouteState();
}

class _EditGameRouteState extends State<EditGameRoute> {
  var _isLoading = false;

  final _placeFN = FocusNode();
  final _descriptionFN = FocusNode();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  var editedGame = Game(
    place: '',
    lastModifiedOn: DateTime.now(),
    lastModifiedBy: '',
    description: '',
    date: null,
    id: '',
    title: '',
    imageUrl: '',
    hostTeamName: '',
    hostTeamId: '',
  );

  var isEditing = false;
  String oldImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Game args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      editedGame = args;
      isEditing = true;
      oldImageUrl = args.imageUrl;
      _dateController.text = DateFormat('dd/MM/yyyy').format(args.date);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _placeFN.dispose();
    _descriptionFN.dispose();

    _dateController.dispose();
    _urlController.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  void _saveForm(BuildContext context) async {
    if (_formKey.currentState.validate() && editedGame.imageUrl != '') {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });
      final _loggedPlayer =
          Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
      final _loggedTeam =
          Provider.of<LoginProvider>(context, listen: false).loggedPlayerTeam;

      var newGame = Game(
        lastModifiedBy: _loggedPlayer.id,
        hostTeamId: _loggedTeam.id,
        hostTeamName: _loggedTeam.name,
        lastModifiedOn: DateTime.now(),
        place: editedGame.place,
        title: editedGame.title,
        description: editedGame.description,
        date: editedGame.date,
        imageUrl: editedGame.imageUrl,
        id: editedGame.id,
      );
      try {
        if (!isEditing)
          newGame = await Provider.of<GamesProvider>(context, listen: false)
              .addNewGame(
            newGame,
          );
        else
          newGame =
              await Provider.of<GamesProvider>(context, listen: false).editGame(
            newGame,
            oldImageUrl,
          );
      } catch (e) {
        setState(() {
          _isLoading = false;
          exc.showCustomErrorDialog(context, e.toString());
        });
      }

      setState(() {
        _isLoading = false;
      });
      if (isEditing)
        Navigator.of(context).pop(newGame);
      else
        Navigator.of(context).pushReplacementNamed(GameDetailRoute.routeName,
            arguments: newGame);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.save), onPressed: () => _saveForm(context))
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                // itemExtent: 100,
                // reverse: true,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Titolo'),
                    initialValue: editedGame.title,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_descriptionFN),
                    onSaved: (value) {
                      editedGame = Game(
                        place: editedGame.place,
                        lastModifiedOn: editedGame.lastModifiedOn,
                        lastModifiedBy: editedGame.lastModifiedBy,
                        description: editedGame.description,
                        date: editedGame.date,
                        id: editedGame.id,
                        title: value,
                        imageUrl: editedGame.imageUrl,
                        hostTeamId: editedGame.hostTeamId,
                        hostTeamName: editedGame.hostTeamName,
                      );
                    },
                    validator: (value) => _validateText(value),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Descrizione'),
                    maxLines: 3,
                    initialValue: editedGame.description,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFN,
                    onSaved: (value) {
                      editedGame = Game(
                        place: editedGame.place,
                        lastModifiedOn: editedGame.lastModifiedOn,
                        lastModifiedBy: editedGame.lastModifiedBy,
                        description: value,
                        date: editedGame.date,
                        id: editedGame.id,
                        title: editedGame.title,
                        imageUrl: editedGame.imageUrl,
                        hostTeamId: editedGame.hostTeamId,
                        hostTeamName: editedGame.hostTeamName,
                      );
                    },
                    validator: (value) => _validateText(value),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Luogo'),
                    // textInputAction: TextInputAction.next,
                    focusNode: _placeFN,
                    initialValue: editedGame.place,
                    onSaved: (value) {
                      editedGame = Game(
                        place: value,
                        lastModifiedOn: editedGame.lastModifiedOn,
                        lastModifiedBy: editedGame.lastModifiedBy,
                        description: editedGame.description,
                        date: editedGame.date,
                        id: editedGame.id,
                        title: editedGame.title,
                        imageUrl: editedGame.imageUrl,
                        hostTeamId: editedGame.hostTeamId,
                        hostTeamName: editedGame.hostTeamName,
                      );
                    },
                    validator: (value) => _validateText(value),
                  ),
                  TextFormField(
                    // textInputAction: TextInputAction.done
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(labelText: 'Data'),
                    controller: _dateController,
                    validator: (value) => _validateText(value),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      DateTime date = editedGame.date ?? DateTime.now();

                      date = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (date == null) return;

                      _dateController.text =
                          DateFormat('dd/MM/yyyy').format(date);

                      editedGame = Game(
                        place: editedGame.place,
                        lastModifiedOn: editedGame.lastModifiedOn,
                        lastModifiedBy: editedGame.lastModifiedBy,
                        description: editedGame.description,
                        date: date,
                        id: editedGame.id,
                        title: editedGame.title,
                        imageUrl: editedGame.imageUrl,
                        hostTeamId: editedGame.hostTeamId,
                        hostTeamName: editedGame.hostTeamName,
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();

                      final picker = ImagePicker();
                      final pickedImage =
                          await picker.getImage(source: ImageSource.gallery);

                      _urlController.text = pickedImage.path;

                      editedGame = Game(
                        place: editedGame.place,
                        lastModifiedOn: editedGame.lastModifiedOn,
                        lastModifiedBy: editedGame.lastModifiedBy,
                        description: editedGame.description,
                        date: editedGame.date,
                        id: editedGame.id,
                        title: editedGame.title,
                        imageUrl: pickedImage.path,
                        hostTeamId: editedGame.hostTeamId,
                        hostTeamName: editedGame.hostTeamName,
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
                          child: editedGame.imageUrl != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: fb.FirebaseHelper.isNetworkImage(
                                          editedGame.imageUrl)
                                      ? Image.network(editedGame.imageUrl,
                                          fit: BoxFit.cover)
                                      : Image.file(
                                          File(editedGame.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Center(child: Text('+ Scegli un\'immagine')),
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

  String _validateDate(String value) {
    if (value == null || value == '') return 'Inserisci una data';
    if (DateTime.tryParse(value) == null) return 'Inserisci una data valida';
    return null;
  }
}
