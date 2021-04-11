import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_invitation.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/providers/game_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

List<Team> allTeams = [];

class GameInvitationsRoute extends StatefulWidget {
  static const routeName = '/game/invite';

  @override
  _GameInvitationsRouteState createState() => _GameInvitationsRouteState();
}

class _GameInvitationsRouteState extends State<GameInvitationsRoute> {
  GameProvider game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    allTeams = [];
    return ChangeNotifierProvider<GameProvider>.value(
      value: game,
      builder: (context, _) => FutureBuilder(
        future: Future.wait([
          Provider.of<TeamsProvider>(context, listen: false)
              .fetchTeams()
              .then((value) => allTeams.addAll(value)),
          Provider.of<GameProvider>(context, listen: false)
              .fetchAndSetInvitations()
        ]),
        builder: (context, snapshot) => ModalProgressHUD(
          inAsyncCall: snapshot.connectionState != ConnectionState.done,
          child: RefreshIndicator(
            onRefresh: () => Provider.of<GameProvider>(context, listen: false)
                .fetchAndSetInvitations(),
            child: Scaffold(
              appBar: AppBar(
                title: Text('Team invitati'),
              ),
              body: Consumer<GameProvider>(
                builder: (context, gameProvider, _) => ListView.builder(
                  itemCount: gameProvider.invitations.length,
                  itemBuilder: (context, i) =>
                      InvitationTile(invitation: gameProvider.invitations[i]),
                ),
              ),
              persistentFooterButtons: [_ModalBottomSheetButton(context)],
            ),
          ),
        ),
      ),
    );
  }
}

class InvitationTile extends StatelessWidget {
  final GameInvitation invitation;

  const InvitationTile({this.invitation});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(invitation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Rimuovi team',
            style: kAccentMediumText,
          ),
        ),
      ),
      onDismissed: (_) => Provider.of<GameProvider>(context, listen: false)
          .removeInvitation(invitation)
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Invito eliminato')))),
      child: ListTile(
        title: Text(invitation.teamName),
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
  Team _selectedTeam;
  Game _game;
  List<Team> _invitableTeams;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game = Provider.of<GameProvider>(widget.context, listen: false).game;
    _invitableTeams = Provider.of<GameProvider>(widget.context, listen: false)
        .invitableTeams(List<Team>.from(allTeams));
    print(allTeams);
    print(_invitableTeams);
  }

  void _createInvitation() {
    Provider.of<GameProvider>(widget.context, listen: false)
        .addInvitation(GameInvitation(
      gameId: _game.id,
      gameName: _game.title,
      teamId: _selectedTeam.id,
      teamName: _selectedTeam.name,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'inviteTeam',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Invita un team',
              style: kTitle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchableDropdown.single(
            hint: 'Seleziona un team',
            searchHint: 'Cerca un team',
            closeButton: 'Chiudi',
            isExpanded: true,
            items: _invitableTeams
                .map(
                  (e) => DropdownMenuItem<Team>(
                    child: Text(e.name),
                    value: e,
                  ),
                )
                .toList(),
            onChanged: (value) => _selectedTeam = value,
            searchFn: (keyword, items) {
              List<int> shownIndexes = [];
              int i = 0;
              items.forEach((item) {
                if (item.value.name
                        .toLowerCase()
                        .contains(keyword.toLowerCase()) ||
                    (keyword?.isEmpty ?? true)) {
                  shownIndexes.add(i);
                }
                i++;
              });
              return (shownIndexes);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _selectedTeam == null
                ? null
                : () {
                    _createInvitation();
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
