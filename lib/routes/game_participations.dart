import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/box_and_texts//kpibox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class GameParticipationsRoute extends StatefulWidget {
  static const routeName = '/game/participations';

  @override
  _GameParticipationsRouteState createState() =>
      _GameParticipationsRouteState();
}

class _GameParticipationsRouteState extends State<GameParticipationsRoute> {
  bool isGM;
  bool isEditing = false;
  Game game;

  final factions = ['Alpha', 'Bravo', 'Charlie'];
  List<DropdownMenuItem> factionsButtons;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = ModalRoute.of(context).settings.arguments;
    isGM = Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM;
    factionsButtons = factions
        .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presenze'),
        actions: [
          if (game.date.isAfter(DateTime.now()))
            IconButton(
                icon: !isEditing ? Icon(Icons.edit) : Icon(Icons.edit_off),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                })
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            Provider.of<GamesProvider>(context, listen: false)
                .fetchAndSetGameParticipations(game.id),
        child: Consumer<GamesProvider>(builder: (context, gameProvider, _) {
          final List<GameParticipation> participations =
              gameProvider.gameParticipations;

          final factionsBoxes = factions.map((e) => KPIBox(
                label: e,
                value: participations
                    .where((element) =>
                        element.isGoing && element.faction?.compareTo(e) == 0)
                    .length
                    .toString(),
              ));

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
                    ...factionsBoxes,
                  ],
                ),
              ),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: participations.length,
                itemBuilder: (context, index) => ParticipationCard(
                    participations[index], isEditing, factionsButtons),
              ),
            ],
          );
        }),
      ),
      persistentFooterButtons: [_ModalBottomSheetButton(game)],
    );
  }
}

class ParticipationCard extends StatelessWidget {
  final GameParticipation participation;
  final bool isEditing;
  final List<DropdownMenuItem> factions;

  const ParticipationCard(this.participation, this.isEditing, this.factions);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      isThreeLine: false,
      key: ValueKey(participation.id),
      title: Text(
        participation.playerName,
        style: kBigText,
      ),
      subtitle: !participation.isGoing
          ? SizedBox()
          : !isEditing
              ? Text(participation.faction ?? 'Non assegnato a nessuna fazione')
              : DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Scegli una fazione'),
                  value: participation.faction,
                  items: factions,
                  onChanged: (value) {
                    final newParticipation = GameParticipation(
                      id: participation.id,
                      gameId: participation.gameId,
                      gameName: participation.gameName,
                      playerName: participation.playerName,
                      playerId: participation.playerId,
                      isGoing: participation.isGoing,
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
      trailing: !isEditing
          ? ParticipationIcon(participation.isGoing)
          : Switch.adaptive(
              value: participation.isGoing,
              onChanged: (value) {
                final newParticipation = GameParticipation(
                  id: participation.id,
                  gameId: participation.gameId,
                  gameName: participation.gameName,
                  playerName: participation.playerName,
                  playerId: participation.playerId,
                  isGoing: value,
                  faction: participation.faction,
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

class _ModalBottomSheetButton extends StatelessWidget {
  final Game game;
  _ModalBottomSheetButton(this.game);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {}, builder: (_) => _BottomSheetContent(game)),
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
  _BottomSheetContent(this.game);

  @override
  __BottomSheetContentState createState() => __BottomSheetContentState();
}

class __BottomSheetContentState extends State<_BottomSheetContent> {
  String hostName;
  bool isLoading = false;

  Future<void> _addHostParticipation() async {
    setState(() {
      isLoading = true;
    });

    await Provider.of<GamesProvider>(context, listen: false).editParticipation(
        GameParticipation(
            id: null,
            gameId: widget.game.id,
            gameName: widget.game.title,
            playerId: DateTime.now().millisecond.toString(),
            playerName: hostName,
            isGoing: true),
        false);

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      offset: Offset(0, MediaQuery.of(context).viewInsets.bottom),
      inAsyncCall: isLoading,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Nome ospite',
              ),
              onChanged: (value) => hostName = value,
            ),
          ),
          ElevatedButton(
            onPressed: _addHostParticipation,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Conferma'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
          )
        ],
      ),
    );
  }
}
