import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TeamMembersRoute extends StatefulWidget {
  static const routeName = '/team/members';
  @override
  _TeamMembersRouteState createState() => _TeamMembersRouteState();
}

class _TeamMembersRouteState extends State<TeamMembersRoute> {
  Team team;
  Player loggedPlayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    team = ModalRoute.of(context).settings.arguments;
    loggedPlayer =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<TeamsProvider>(context, listen: false)
          .fetchAndSetMembers(team.id),
      builder: (context, snapshot) => ModalProgressHUD(
        inAsyncCall: snapshot.connectionState != ConnectionState.done,
        child: MembersScaffold(team, loggedPlayer),
      ),
    );
  }
}

class MembersScaffold extends StatefulWidget {
  final Team team;
  final Player loggedPlayer;

  MembersScaffold(this.team, this.loggedPlayer);

  @override
  _MembersScaffoldState createState() => _MembersScaffoldState();
}

class _MembersScaffoldState extends State<MembersScaffold> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Membri dei ' + widget.team.name,
          overflow: TextOverflow.fade,
        ),
        actions: [
          if (widget.loggedPlayer.isGM &&
              widget.loggedPlayer.teamId.compareTo(widget.team.id) == 0)
            IconButton(
                icon: !isEditing ? Icon(Icons.edit) : Icon(Icons.edit_off),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                })
        ],
      ),
      body: Consumer<TeamsProvider>(
        builder: (context, team, _) => ListView.builder(
            itemCount: team.members.length,
            itemBuilder: (context, i) =>
                PlayerTile(team.members[i], isEditing, widget.loggedPlayer)),
      ),
    );
  }
}

class PlayerTile extends StatelessWidget {
  final Player player;
  final bool isEditing;
  final Player loggedPlayer;

  PlayerTile(this.player, this.isEditing, this.loggedPlayer);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(player.nickname),
      subtitle: Text(player.isGM ? 'Game Maker' : 'Associato'),
      dense: true,
      trailing: isEditing && !(player.id.compareTo(loggedPlayer.id) == 0)
          ? Switch(
              onChanged: (value) {
                Provider.of<TeamsProvider>(context, listen: false)
                    .updateTeamMember(Player(
                  email: player.email,
                  nickname: player.nickname,
                  id: player.id,
                  isGM: value,
                  name: player.email,
                  teamId: player.teamId,
                  dateOfBirth: player.dateOfBirth,
                  lastName: player.lastName,
                  placeOfBirth: player.placeOfBirth,
                ));
              },
              value: player.isGM,
            )
          : null,
    );
  }
}
