import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:airsoft_tournament/routes/games_route.dart';

class HomeRoute extends StatelessWidget {
  static const routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {},
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Logged in as ${Provider.of<LoginProvider>(context).loggedPlayer.nickname}, Team: ${Provider.of<LoginProvider>(context).loggedPlayerTeam.name} !!'),
              ElevatedButton(
                child: Text('Vai alla lista delle partite'),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(GamesRoute.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
