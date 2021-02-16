import 'dart:io';

import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/routes/game_detail_route.dart';
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
class EditGameRoute extends StatefulWidget {
  static const routeName = '/game/edit';

  @override
  _EditGameRouteState createState() => _EditGameRouteState();
}

class _EditGameRouteState extends State<EditGameRoute> {
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _placeFN = FocusNode();
  final _descriptionFN = FocusNode();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();
  final TextEditingController _factionsController = TextEditingController();

  Game args;
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
    attachmentUrl: '',
    isPrivate: false,
    factions: [],
  );

  var isEditing = false;
  String oldImageUrl;

  var isAttachmentUrlValid = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      editedGame = args;
      isEditing = true;
      oldImageUrl = args.imageUrl;
      _dateController.text = DateFormat('dd/MM/yyyy').format(args.date);
      _attachmentController.text = args.attachmentUrl;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _placeFN.dispose();
    _descriptionFN.dispose();

    _dateController.dispose();
    _imageController.dispose();
    _attachmentController.dispose();
    _factionsController.dispose();
  }

  void _saveForm(BuildContext context) async {
    final isValid = await canLaunch(_attachmentController.text);

    setState(() {
      isAttachmentUrlValid = isValid;
    });

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
        attachmentUrl: editedGame.attachmentUrl,
        factions: editedGame.factions,
        isPrivate: editedGame.isPrivate,
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

  void removeFaction(Faction faction) {
    setState(() {
      editedGame.factions
          .removeWhere((element) => element.id.compareTo(faction.id) == 0);
    });
  }

  void addFaction() {
    if (_factionsController != null && _factionsController.text != '') {
      setState(() {
        final faction = Faction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _factionsController.text);
        editedGame.factions.add(faction);
        _factionsController.clear();
      });
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
                      labelText: 'Titolo',
                      hintText: 'Inserisci il nome della giocata',
                      hintStyle: kFormHint,
                    ),
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
                        attachmentUrl: editedGame.attachmentUrl,
                        factions: editedGame.factions,
                        isPrivate: editedGame.isPrivate,
                      );
                    },
                    validator: (value) => _validateText(value),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descrizione',
                      hintText:
                          'Inserisci informazioni logistiche, il tipo di giocata, oppure lo storyboard di questa',
                      hintStyle: kFormHint,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
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
                        attachmentUrl: editedGame.attachmentUrl,
                        factions: editedGame.factions,
                        isPrivate: editedGame.isPrivate,
                      );
                    },
                    validator: (value) => _validateText(value),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Luogo',
                      hintText:
                          'Inserisci la città o l\'indirizzo della giocata',
                      hintStyle: kFormHint,
                    ),
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
                        attachmentUrl: editedGame.attachmentUrl,
                        factions: editedGame.factions,
                        isPrivate: editedGame.isPrivate,
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
                        attachmentUrl: editedGame.attachmentUrl,
                        factions: editedGame.factions,
                        isPrivate: editedGame.isPrivate,
                      );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Link Allegato',
                      hintText:
                          'Inserisci un link a un PDF o sito web (Opzionale)',
                      hintStyle: kFormHint,
                    ),
                    controller: _attachmentController,
                    onSaved: (value) {
                      editedGame = Game(
                        place: editedGame.place,
                        lastModifiedOn: editedGame.lastModifiedOn,
                        lastModifiedBy: editedGame.lastModifiedBy,
                        description: editedGame.description,
                        date: editedGame.date,
                        id: editedGame.id,
                        title: editedGame.title,
                        imageUrl: editedGame.imageUrl,
                        hostTeamId: editedGame.hostTeamId,
                        hostTeamName: editedGame.hostTeamName,
                        factions: editedGame.factions,
                        isPrivate: editedGame.isPrivate,
                        attachmentUrl: value,
                      );
                    },
                    validator: (value) => _validateUrl(value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();

                          final picker = ImagePicker();
                          final pickedImage = await picker.getImage(
                              source: ImageSource.gallery);

                          _imageController.text = pickedImage.path;

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
                            attachmentUrl: editedGame.attachmentUrl,
                            factions: editedGame.factions,
                            isPrivate: editedGame.isPrivate,
                          );

                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                          child: SizedBox(
                            height: 120,
                            width: 120,
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
                                        borderRadius: BorderRadius.circular(12),
                                        child: fb.FirebaseHelper.isNetworkImage(
                                                editedGame.imageUrl)
                                            ? Image.network(editedGame.imageUrl,
                                                fit: BoxFit.cover)
                                            : Image.file(
                                                File(editedGame.imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    : Center(
                                        child: Text(
                                        '+ Scegli un\'immagine (Obbligatorio)',
                                        textAlign: TextAlign.center,
                                      )),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Switch(
                                value: !editedGame.isPrivate,
                                onChanged: (value) {
                                  setState(() {
                                    editedGame = Game(
                                      place: editedGame.place,
                                      lastModifiedOn: editedGame.lastModifiedOn,
                                      lastModifiedBy: editedGame.lastModifiedBy,
                                      description: editedGame.description,
                                      date: editedGame.date,
                                      id: editedGame.id,
                                      title: editedGame.title,
                                      imageUrl: editedGame.imageUrl,
                                      hostTeamId: editedGame.hostTeamId,
                                      hostTeamName: editedGame.hostTeamName,
                                      attachmentUrl: editedGame.attachmentUrl,
                                      factions: editedGame.factions,
                                      isPrivate: !value,
                                    );
                                  });
                                }),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12, right: 8.0, left: 12),
                              child: Text(
                                editedGame.isPrivate
                                    ? 'Evento non visibile ad altri team'
                                    : 'Evento visibile ad altri team',
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                      height: editedGame.factions.length == 0 ? 0 : 50,
                      //   child: ListView.builder(
                      //       reverse: true,
                      //       // padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      //       // shrinkWrap: true,
                      //       scrollDirection: Axis.horizontal,
                      //       itemCount: editedGame.factions.length,
                      //       itemBuilder: (context, i) => Padding(
                      //             padding:
                      //                 const EdgeInsets.symmetric(horizontal: 4.0),
                      //             child: FactionChip(
                      //                 ValueKey(editedGame.factions[i].id),
                      //                 editedGame.factions[i],
                      //                 removeFaction),
                      //           )),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        children: editedGame.factions.reversed
                            .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: FactionChip(
                                      ValueKey(e.id), e, removeFaction),
                                ))
                            .toList(),
                      )),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlatButton(
                          onPressed: addFaction,
                          child: Text('Aggiungi fazione')),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextField(
                            controller: _factionsController,
                            onSubmitted: (_) => addFaction(),
                          ),
                        ),
                      ),
                    ],
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

  String _validateDate(String value) {
    if (value == null || value == '') return 'Inserisci una data';
    if (DateTime.tryParse(value) == null) return 'Inserisci una data valida';
    return null;
  }

  String _validateUrl(String value) {
    if (value == null || value == '') return null;
    if (isAttachmentUrlValid) return null;
    return 'Inserisci un URL corretto, copiandolo dal browser';
  }
}

class FactionChip extends StatelessWidget {
  final Faction faction;
  final Function onDelete;
  const FactionChip(
    Key key,
    this.faction,
    this.onDelete,
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text('${faction.name}'),
      deleteIcon: Icon(
        Icons.cancel,
        size: 20,
      ),
      onDeleted: () => onDelete(faction),
    );
  }
}
