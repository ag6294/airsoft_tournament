import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/routes/team_edit_route.dart';
import 'package:airsoft_tournament/widgets/box_and_texts/detail_routes_elements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const defaultImageUrl =
    'https://d31sxl6qgne2yj.cloudfront.net/wordpress/wp-content/uploads/20200701094722/M81-Woodland-Camo-thumb.jpg';

class TeamDetailRoute extends StatefulWidget {
  static const routeName = '/team-detail';

  @override
  _TeamDetailRouteState createState() => _TeamDetailRouteState();
}

class _TeamDetailRouteState extends State<TeamDetailRoute> {
  Team team;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Team tempTeam = ModalRoute.of(context).settings.arguments;
    team = tempTeam ?? team;
  }

  void onModifyPop(Team editedTeam) {
    if (editedTeam != null) {
      setState(() {
        team = editedTeam;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        TeamCover(
          team,
          onModifyPop,
        ),
        TeamDetails(team),
      ],
    ));
  }
}

class TeamCover extends StatelessWidget {
  final Team team;
  final Function editCallback;

  TeamCover(this.team, this.editCallback);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: [MenuPopUp(team, editCallback)],
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
                team?.name,
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
              team.imageUrl ?? defaultImageUrl,
            ),
          ),
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.width,
      elevation: 0,
    );
  }
}

class MenuPopUp extends StatelessWidget {
  final Team team;
  final Function editCallback;

  MenuPopUp(this.team, this.editCallback);

  @override
  Widget build(BuildContext context) {
    final itemsList = [
      if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
        PopupMenuItem(
          value: () => Navigator.of(context)
              .pushNamed(TeamEditRoute.routeName, arguments: team)
              .then((value) => editCallback(value)),
          child: Text('Modifica'),
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

class TeamDetails extends StatelessWidget {
  final Team team;
  TeamDetails(this.team);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          TitleAndInfo(
              'Descrizione',
              team.description == null || team.description == ''
                  ? 'Nessuna descrizione inserita'
                  : team.description),
          TitleAndInfo(
              'Contatti',
              team.contacts == null || team.contacts == ''
                  ? 'Nessun contatto inserito'
                  : team.contacts),
        ],
      ),
    );
  }
}
