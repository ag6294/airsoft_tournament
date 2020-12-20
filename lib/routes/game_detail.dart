import 'dart:ui';

import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameDetailRoute extends StatelessWidget {
  static const routeName = '/game-detail';

  @override
  Widget build(BuildContext context) {
    final Game game = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      // appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          GameCover(game),
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
