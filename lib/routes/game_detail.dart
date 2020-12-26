import 'dart:ui';

import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';

import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/models/player.dart';

class GameDetailRoute extends StatelessWidget {
  static const routeName = '/game-detail';

  @override
  Widget build(BuildContext context) {
    final Game game = ModalRoute.of(context).settings.arguments;

    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetGameParticipations(game.id);

    return Scaffold(
      // appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          GameCover(game),
          GameParticipations(game),
          GameDetails(game),
        ],
      ),
    );
  }
}

class GameCover extends StatelessWidget {
  final Game game;

  GameCover(this.game);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      flexibleSpace: Hero(
        tag: game.id,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: Image.network(
            game.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.width,
      pinned: true,
      elevation: 0,
      bottom: PreferredSize(
        child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Center(
            child: Text(
              game.title,
              style: kCardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        preferredSize: Size.fromHeight(56),
      ),
    );
  }
}

class GameDetails extends StatelessWidget {
  final Game game;

  GameDetails(this.game);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Luogo', style: kTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.place,
              style: kMediumText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Descrizione', style: kTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.description,
              style: kMediumText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Data', style: kTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('dd/MM/yyyy').format(game.date),
              style: kMediumText,
            ),
          ),
        ],
      ),
    );
  }
}

class GameParticipations extends StatelessWidget {
  final Game game;

  GameParticipations(this.game);

  @override
  Widget build(BuildContext context) {
    return Consumer<GamesProvider>(builder: (context, gamesProvider, _) {
      final Player player =
          Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
      final hasReplied = gamesProvider.loggedUserParticipations.isEmpty
          ? false
          : gamesProvider.loggedUserParticipations.indexWhere(
                  ((p) => p.playerId == player.id && p.gameId == game.id)) >
              -1;
      final playerParticipation = hasReplied
          ? gamesProvider.loggedUserParticipations
              .where((p) => p.playerId == player.id && p.gameId == game.id)
              .first
          : null;
      final isGoing = hasReplied ? playerParticipation.isGoing : false;
      final gamePartecipations = gamesProvider.gameParticipations;

      return SliverList(
        delegate: SliverChildListDelegate(
          [
            if (!DateTime.now().isAfter(game.date))
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Fai sapere se parteciperai'),
                  ),
                  ToggleButtons(
                    renderBorder: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Parteciperò',
                          style: kMediumText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Non parteciperò',
                          style: kMediumText,
                        ),
                      ),
                    ],
                    isSelected: [
                      hasReplied && isGoing,
                      hasReplied && !isGoing,
                    ],
                    onPressed: (i) async {
                      if (i == 0 && hasReplied && isGoing) return;
                      if (i == 1 && hasReplied && !isGoing) return;

                      final newParticipation = GameParticipation(
                        id: playerParticipation?.id,
                        gameId: game.id,
                        gameName: game.title,
                        isGoing: i == 0,
                        playerId: player.id,
                        playerName: player.nickname,
                      );

                      // playerParticipation = newParticipation;
                      // hasReplied = true;
                      await gamesProvider.editParticipation(newParticipation);
                    },
                  ),
                  Text(
                      'Parteciperanno alla giocata ${gamePartecipations.where((p) => p.isGoing).length} giocatori!'),
                ],
              ),
            if (DateTime.now().isAfter(game.date))
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    !hasReplied
                        ? 'Non hai risposto alla giocata'
                        : isGoing
                            ? 'Hai partecipato a questa giocata'
                            : 'Non hai partecipato a questa giocata',
                    style: kMediumText,
                  ),
                  Text(
                      'Hanno partecipato a questa giocata ${gamePartecipations.where((p) => p.isGoing).length} giocatori!'),
                ],
              ),
          ],
        ),
      );
    });
  }
}
