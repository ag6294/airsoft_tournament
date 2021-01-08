import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

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
import 'package:airsoft_tournament/routes/game_participations.dart';

import 'package:airsoft_tournament/widgets/box_and_texts/detail_routes_elements.dart';

import 'edit_game_route.dart';

class GameDetailRoute extends StatefulWidget {
  static const routeName = '/game-detail';

  @override
  _GameDetailRouteState createState() => _GameDetailRouteState();
}

class _GameDetailRouteState extends State<GameDetailRoute> {
  Game game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Game gameFromPop = ModalRoute.of(context).settings.arguments;
    game = gameFromPop ?? game;
    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetGameParticipations(game.id);
  }

  void onModifyPop(Game editedGame) {
    if (editedGame != null) {
      setState(() {
        game = editedGame;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          GameCover(game, onModifyPop),
          GameParticipations(game),
          GameDetails(game),
          _BottomButtons(game),
        ],
      ),
    );
  }
}

class GameCover extends StatelessWidget {
  final Game game;
  final Function editCallBack;

  GameCover(this.game, this.editCallBack);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: [MenuPopUp(game, editCallBack)],
      pinned: true,
      floating: true,
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 56),
        child: Container(
          // height: 56,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                game.title,
                style: kCardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      forceElevated: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
              game.imageUrl,
            ),
          ),
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.width,
      elevation: 0,
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
          TitleAndInfo('Data e Luogo',
              '${DateFormat('dd/MM/yyyy').format(game.date)}\n${game.place}'),
          TitleAndInfo('Descrizione', game.description),
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
    return Consumer<GamesProvider>(
      builder: (context, gamesProvider, _) {
        final Player player =
            Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
        final gameParticipations = gamesProvider.gameParticipations;

        final hasReplied = gameParticipations.isEmpty
            ? false
            : gameParticipations.indexWhere(((p) => p.playerId == player.id)) >
                -1;
        final playerParticipation = hasReplied
            ? gameParticipations.where((p) => p.playerId == player.id).first
            : null;
        final isGoing = hasReplied ? playerParticipation.isGoing : false;

        return SliverList(
          delegate: SliverChildListDelegate(
            [
              if (!DateTime.now().isAfter(game.date))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Parteciperai?',
                            style: kMediumText,
                          ),
                        ),
                        ToggleButtons(
                          renderBorder: true,
                          borderWidth: 10,
                          borderRadius: BorderRadius.circular(24),
                          borderColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          selectedBorderColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Parteciperò',
                                style: hasReplied && isGoing
                                    ? kMediumText
                                    : TextStyle(),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Non parteciperò',
                                style: hasReplied && !isGoing
                                    ? kMediumText
                                    : TextStyle(),
                              ),
                            ),
                          ],
                          isSelected: [
                            hasReplied && isGoing,
                            hasReplied && !isGoing,
                          ],
                          onPressed: (i) {
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
                            gamesProvider.editParticipation(
                                newParticipation, true);
                          },
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //       'Parteciperanno alla giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                    // ),
                  ],
                ),
              if (DateTime.now().isAfter(game.date))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        !hasReplied
                            ? 'Non hai risposto alla giocata'
                            : isGoing
                                ? 'Hai partecipato a questa giocata'
                                : 'Non hai partecipato a questa giocata',
                        style: kMediumText,
                      ),
                    ),
                    // Text(
                    //     'Hanno partecipato a questa giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class MenuPopUp extends StatelessWidget {
  final Game game;
  final Function editCallback;

  MenuPopUp(this.game, this.editCallback);

  @override
  Widget build(BuildContext context) {
    final itemsList = [
      if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
        PopupMenuItem(
          value: () => Navigator.of(context)
              .pushNamed(EditGameRoute.routeName, arguments: game)
              .then((value) => editCallback(value)),
          child: Text('Modifica'),
        ),
      if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
        PopupMenuItem(
          value: () {
            Provider.of<GamesProvider>(context, listen: false).deleteGame(game);
            // Navigator.of(context).pop();
          },
          child: Text('Elimina'),
        ),
    ];

    return PopupMenuButton<Function>(
      enabled: itemsList.isNotEmpty,
      onSelected: (value) => value(),
      itemBuilder: (context) => itemsList,
      offset: Offset(0, 50),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final Game game;

  _BottomButtons(this.game);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                        GameParticipationsRoute.routeName,
                        arguments: game),
                    child: Text('Lista dei partecipanti'),
                  ),
                ),
                if (game.attachmentUrl != null && game.attachmentUrl != '')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => _openAttachment(game.attachmentUrl),
                      child: Row(
                        children: [
                          Icon(Icons.insert_link),
                          SizedBox(width: 8),
                          Text('Apri allegato'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _openAttachment(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

//
// return SliverAppBar(
// actions: [MenuPopUp(game, editCallBack)],
// floating: true,
// flexibleSpace: Hero(
// tag: game.id,
// child: ClipRRect(
// borderRadius: BorderRadius.only(
// bottomLeft: Radius.circular(24),
// bottomRight: Radius.circular(24),
// ),
// child: Image.network(
// game.imageUrl,
// fit: BoxFit.cover,
// ),
// ),
// ),
// // expandedHeight: MediaQuery.of(context).size.width,
// pinned: true,
// elevation: 0,
// bottom: PreferredSize(
// child: Container(
// // height: 56,
// // width: MediaQuery.of(context).size.width,
// decoration: BoxDecoration(
// color: Colors.black.withOpacity(0.5),
// borderRadius: BorderRadius.only(
// bottomLeft: Radius.circular(24),
// bottomRight: Radius.circular(24),
// ),
// ),
// child: Padding(
// padding: const EdgeInsets.all(8.0),
// child: Align(
// alignment: Alignment.centerLeft,
// child: Text(
// game.title,
// style: kCardTitle,
// maxLines: 1,
// overflow: TextOverflow.ellipsis,
// ),
// ),
// ),
// ),
// preferredSize: Size.fromHeight(56),
// ),
// );
