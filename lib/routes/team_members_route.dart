import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:flutter/material.dart';

class TeamMembersRoute extends StatefulWidget {
  static const routeName = '/team/members';
  @override
  _TeamMembersRouteState createState() => _TeamMembersRouteState();
}

class _TeamMembersRouteState extends State<TeamMembersRoute> {
  Team team;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    team = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Membri dei ' + team.name,
            overflow: TextOverflow.fade,
          ),
        ),
        body: ListView.builder(
            itemCount: team.players.length,
            itemBuilder: (context, i) => PlayerTile(team.players[i])));
  }
}

class PlayerTile extends StatelessWidget {
  final Player player;

  PlayerTile(this.player);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(player.nickname),
      subtitle: Text(player.isGM ? 'Game Maker' : 'Associato'),
      dense: true,
    );
  }
}
