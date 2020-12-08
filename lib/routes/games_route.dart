import 'package:airsoft_tournament/routes/edit_game_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/models/game.dart';

class GamesRoute extends StatefulWidget {
  static const routeName = '/games';

  @override
  _GamesRouteState createState() => _GamesRouteState();
}

class _GamesRouteState extends State<GamesRoute> {
  @override
  Widget build(BuildContext context) {
    List<Game> list = Provider.of<GamesProvider>(context).games;
    return Scaffold(
      appBar: AppBar(
        actions: [_menuPopup(context)],
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) => GameCard(list[i]),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard(this.game);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(game.title),
          Text(game.description),
        ],
      ),
    );
  }
}

PopupMenuButton<String> _menuPopup(BuildContext context) =>
    PopupMenuButton<String>(
      onSelected: (value) => Navigator.of(context).pushNamed(value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: EditGameRoute.routeName,
          child: Text('Crea una giocata'),
        ),
      ],
      offset: Offset(0, 50),
    );
