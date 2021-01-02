import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/KPIs/kpibox.dart';
import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        key: ValueKey(participation.id),
        title: Text(
          participation.playerName,
          style: kBigText,
        ),
        subtitle: !participation.isGoing
            ? Container()
            : !isEditing
                ? Text(
                    participation.faction ?? 'Non assegnato a nessuna fazione')
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
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
                              .editParticipation(newParticipation);
                        }),
                  ),
        trailing: ParticipationIcon(participation.isGoing),
      ),
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
    );
  }
}
