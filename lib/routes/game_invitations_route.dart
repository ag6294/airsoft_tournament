import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_invitation.dart';
import 'package:airsoft_tournament/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameInvitationsRoute extends StatefulWidget {
  static const routeName = '/game/invite';

  @override
  _GameInvitationsRouteState createState() => _GameInvitationsRouteState();
}

class _GameInvitationsRouteState extends State<GameInvitationsRoute> {
  Game game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(game),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, _) => RefreshIndicator(
          onRefresh: () => gameProvider.fetchAndSetInvitations(),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Team invitati'),
            ),
            body: ListView.builder(
              itemCount: gameProvider.invitations.length,
              itemBuilder: (context, i) => InvitationTile(
                teamId: gameProvider.invitations[i].teamId,
                teamName: gameProvider.invitations[i].teamName,
              ),
            ),
            persistentFooterButtons: [_ModalBottomSheetButton(context)],
          ),
        ),
      ),
    );
  }
}

class InvitationTile extends StatelessWidget {
  final String teamName;
  final String teamId;

  const InvitationTile({this.teamName, this.teamId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(teamId),
      child: ListTile(
        title: Text(teamName),
      ),
    );
  }
}

class _ModalBottomSheetButton extends StatelessWidget {
  final BuildContext contextA;

  const _ModalBottomSheetButton(this.contextA);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {}, builder: (_) => _BottomSheetContent(contextA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 'inviteTeam',
          child: Text('Invita un team'),
        ),
      ),
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final BuildContext context;

  const _BottomSheetContent(this.context);

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    //todo aggiungere cerca team
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'inviteTeam',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Aggiungi un post',
              style: kTitle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Game game =
                  Provider.of<GameProvider>(widget.context, listen: false).game;
              Provider.of<GameProvider>(widget.context, listen: false)
                  .addInvitation(GameInvitation(
                gameId: game.id,
                gameName: game.title,
                teamId: 'asdf',
                teamName: 'TeamName',
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              ));
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Conferma'),
            ),
          ),
        ),
      ],
    );
  }
}
