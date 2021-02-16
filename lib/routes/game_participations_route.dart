import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/box_and_texts/kpibox.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:airsoft_tournament/constants/exceptions.dart' as exc;

const kFakeFactionId = 'asdfasdfsadf';

class GameParticipationsRoute extends StatefulWidget {
  static const routeName = '/game/participations';

  @override
  _GameParticipationsRouteState createState() =>
      _GameParticipationsRouteState();
}

class _GameParticipationsRouteState extends State<GameParticipationsRoute> {
  Player loggedPlayer;
  bool isEditing = false;
  Game game;

  List<GameParticipation> participations = [];
  List<Player> playerNotReplied = [];

  List<KPIBox> factionsBoxes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = ModalRoute.of(context).settings.arguments;
    loggedPlayer =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayer;

    //If the game is hosted by my team, then I will do stuff to show the players from my team that have not replied yet
    playerNotReplied = game.hostTeamId.compareTo(
                Provider.of<LoginProvider>(context).loggedPlayerTeam.id) ==
            0
        ? Provider.of<LoginProvider>(context, listen: false)
            .loggedPlayerTeam
            .players
        : [];

    _refreshFactionKPIs();
  }

  void _refreshFactionKPIs() {
    factionsBoxes = game.factions
        .map((e) => KPIBox(
              label: e.name,
              value: participations
                  .where((element) =>
                      element.isGoing && element.faction?.compareTo(e.id) == 0)
                  .length
                  .toString(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presenze'),
        actions: [
          if (game.date.isAfter(DateTime.now()) &&
              loggedPlayer.isGM &&
              loggedPlayer.teamId.compareTo(game.hostTeamId) == 0)
            IconButton(
                icon: !isEditing ? Icon(Icons.edit) : Icon(Icons.edit_off),
                onPressed: () {
                  Provider.of<GamesProvider>(context, listen: false)
                      .sortParticipations();
                  setState(() {
                    isEditing = !isEditing;
                  });
                })
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          Provider.of<GamesProvider>(context, listen: false)
              .fetchAndSetGameParticipations(game);
        },
        child: Consumer<GamesProvider>(builder: (context, gameProvider, _) {
          participations = gameProvider.gameParticipations;

          for (GameParticipation p in participations) {
            playerNotReplied
                .removeWhere((player) => player.id.compareTo(p.playerId) == 0);
          }
          _refreshFactionKPIs();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 132,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // shrinkWrap: true,
                  children: [
                    KPIBox(
                      value:
                          '${participations.where((element) => element.isGoing).length}',
                      label: 'Presenti',
                    ),
                    KPIBox(
                      value:
                          '${participations.where((element) => !element.isGoing).length}',
                      label: 'Assenti',
                    ),
                    KPIBox(
                      value: '${playerNotReplied.length}',
                      label: 'In dubbio',
                    ),
                    ...factionsBoxes,
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: participations.length + playerNotReplied.length,
                  itemBuilder: (context, index) => index < participations.length
                      ? ParticipationCard(
                          participations[index], isEditing, game)
                      : PlayerNotRepliedCard(
                          playerNotReplied[index - participations.length]),
                ),
              ),
            ],
          );
        }),
      ),
      persistentFooterButtons: loggedPlayer.isGM &&
              loggedPlayer.teamId.compareTo(game.hostTeamId) == 0 &&
              !isEditing
          ? [
              _ModalBottomSheetButton(game),
              _ExportButton(game, loggedPlayer),
            ]
          : null,
    );
  }
}

class ParticipationCard extends StatefulWidget {
  final GameParticipation participation;
  final bool isEditing;
  final Game game;

  const ParticipationCard(this.participation, this.isEditing, this.game);

  @override
  _ParticipationCardState createState() => _ParticipationCardState();
}

class _ParticipationCardState extends State<ParticipationCard> {
  List<DropdownMenuItem> factionsButtons;

  @override
  void initState() {
    super.initState();
    factionsButtons = widget.game.factions
        .map((e) => DropdownMenuItem(
              value: e.id,
              child: Text(e.name),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      isThreeLine: false,
      key: ValueKey(widget.participation.id),
      title: Text(
        widget.participation.playerName,
        style: kBigText,
      ),
      subtitle: !widget.participation.isGoing
          ? Text('Assente')
          : !widget.isEditing
              ? widget.participation.faction == null ||
                      widget.participation.faction == ''
                  ? Text('Non assegnato a nessuna fazione')
                  : Text(widget.game.factions
                      .firstWhere(
                        (element) => element.id == widget.participation.faction,
                        orElse: () => Faction(
                          id: kFakeFactionId,
                          name: 'Non assegnato a nessuna fazione',
                        ),
                      )
                      .name)
              : DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Scegli una fazione'),
                  value: widget.participation.faction,
                  items: factionsButtons,
                  onChanged: (value) {
                    final newParticipation = GameParticipation(
                      id: widget.participation.id,
                      gameId: widget.participation.gameId,
                      gameName: widget.participation.gameName,
                      playerName: widget.participation.playerName,
                      playerId: widget.participation.playerId,
                      isGoing: widget.participation.isGoing,
                      faction: value,
                    );

                    Provider.of<GamesProvider>(context, listen: false)
                        .editParticipation(
                            newParticipation,
                            newParticipation.playerId ==
                                Provider.of<LoginProvider>(context,
                                        listen: false)
                                    .loggedPlayer
                                    .id);
                  }),
      trailing: !widget.isEditing
          ? ParticipationIcon(widget.participation.isGoing)
          : Switch.adaptive(
              value: widget.participation.isGoing,
              onChanged: (value) {
                final newParticipation = GameParticipation(
                  id: widget.participation.id,
                  gameId: widget.participation.gameId,
                  gameName: widget.participation.gameName,
                  playerName: widget.participation.playerName,
                  playerId: widget.participation.playerId,
                  isGoing: value,
                  faction: widget.participation.faction,
                );

                Provider.of<GamesProvider>(context, listen: false)
                    .editParticipation(
                        newParticipation,
                        newParticipation.playerId ==
                            Provider.of<LoginProvider>(context, listen: false)
                                .loggedPlayer
                                .id);
              }),
    );
  }
}

class ParticipationIcon extends StatelessWidget {
  final bool isGoing;

  ParticipationIcon(this.isGoing);

  @override
  Widget build(BuildContext context) {
    return Icon(
      isGoing ? Icons.check_circle_rounded : Icons.cancel_outlined,
      color: isGoing ? Colors.green : Colors.red,
      size: 20,
    );
  }
}

class PlayerNotRepliedCard extends StatelessWidget {
  final Player player;

  const PlayerNotRepliedCard(this.player);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      isThreeLine: false,
      key: ValueKey(player.id),
      title: Text(
        player.nickname,
        style: kBigText,
      ),
      subtitle: Text('Non ha ancora risposto'),
    );
  }
}

class _ModalBottomSheetButton extends StatelessWidget {
  final Game game;
  _ModalBottomSheetButton(this.game);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => _BottomSheetContent(game: game),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 'AddParticipant',
          child: Text('Aggiungi un ospite'),
        ),
      ),
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final Game game;
  final Player guestPlayer;
  _BottomSheetContent({this.game, this.guestPlayer});

  @override
  __BottomSheetContentState createState() => __BottomSheetContentState();
}

class __BottomSheetContentState extends State<_BottomSheetContent> {
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();

  Player player;
  var isNewPlayer = false;

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.guestPlayer == null) {
      isNewPlayer = true;
      player = Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nickname: '',
        email: '',
        isGM: false,
      );
    } else {
      player = widget.guestPlayer;
      if (player.dateOfBirth != null) {
        _dateController.text =
            DateFormat('dd/MM/yyyy').format(player.dateOfBirth);
      }
    }
  }

  void _saveForm(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      try {
        if (isNewPlayer) {
          player = await Provider.of<LoginProvider>(context, listen: false)
              .addNewPlayer(player);
        } else {
          await Provider.of<LoginProvider>(context, listen: false)
              .updatePlayer(player);
        }

        Provider.of<GamesProvider>(context, listen: false).editParticipation(
            GameParticipation(
                id: null,
                gameId: widget.game.id,
                gameName: widget.game.title,
                playerId: player.id,
                playerName: player.nickname,
                isGoing: true,
                isGuest: true),
            false);
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
      offset: Offset(MediaQuery.of(context).size.width / 2, 100),
      inAsyncCall: _isLoading,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Hero(
                tag: 'AddParticipant',
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Aggiungi un ospite',
                    style: kTitle,
                  ),
                ),
              ),
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
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ElevatedButton(
                  onPressed: () => _saveForm(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Conferma'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatefulWidget {
  final Game game;
  final Player loggedPlayer;

  _ExportButton(this.game, this.loggedPlayer);

  @override
  __ExportButtonState createState() => __ExportButtonState();
}

class __ExportButtonState extends State<_ExportButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });

        try {
          await Provider.of<GamesProvider>(context, listen: false)
              .exportParticipations(widget.game, widget.loggedPlayer.email);
          // Scaffold.of(context).showSnackBar(SnackBar(
          //   content: Text(
          //       'Abbiamo inviato la lista dei partecipanti al tuo indirizzo email'),
          //   duration: Duration(seconds: 5),
          // ));
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          exc.showCustomErrorDialog(context, e.toString());
        }

        setState(() {
          isLoading = false;
        });
      },
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Invia file .csv via mail'),
            ),
    );
  }
}

String _validateText(String value) {
  if (value == null || value == '')
    return 'Compila questo campo!';
  else
    return null;
}
