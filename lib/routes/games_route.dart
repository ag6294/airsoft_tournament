import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/models/game.dart';

class GamesRoute extends StatelessWidget {
  static const routeName = '/games';
  @override
  Widget build(BuildContext context) {
    List<Game> list = Provider.of<GamesProvider>(context).games;
    return Scaffold(
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) => Card(
          child: Column(
            children: [
              Text(list[i].title),
              Text(list[i].description),
            ],
          ),
        ),
      ),
    );
  }
}
