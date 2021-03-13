import 'package:airsoft_tournament/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/helpers/form_helper.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/models/team_post.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TeamPostsRoute extends StatefulWidget {
  static const routeName = '/team/posts';
  @override
  _TeamPostsRouteState createState() => _TeamPostsRouteState();
}

class _TeamPostsRouteState extends State<TeamPostsRoute> {
  Team team;
  Player loggedPlayer;
  Team loggedPlayerTeam;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    team = ModalRoute.of(context).settings.arguments;
    loggedPlayer =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
    loggedPlayerTeam =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayerTeam;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<TeamsProvider>(context, listen: false)
            .fetchAndSetPosts(team.id, team.id == loggedPlayerTeam.id),
        builder: (context, snapshot) => ModalProgressHUD(
              inAsyncCall: snapshot.connectionState != ConnectionState.done,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    team.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                body: Consumer<TeamsProvider>(
                  builder: (context, teamsProvider, _) {
                    final posts = teamsProvider.posts;
                    return posts.isEmpty
                        ? Center(
                            child: Text('Non ci sono ancora post!'),
                          )
                        : ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, i) => PostCard(
                              loggedPlayer: loggedPlayer,
                              loggedPlayerTeam: loggedPlayerTeam,
                              post: posts[i],
                            ),
                          );
                  },
                ),
                persistentFooterButtons: loggedPlayer.isGM &&
                        loggedPlayer.teamId.compareTo(team.id) == 0
                    ? [_ModalBottomSheetButton(team, loggedPlayer)]
                    : null,
              ),
            ));
  }
}

class PostCard extends StatelessWidget {
  final TeamPost post;
  final Team loggedPlayerTeam;
  final Player loggedPlayer;

  PostCard({this.post, this.loggedPlayerTeam, this.loggedPlayer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      subtitle: Text(DateFormat('dd/MM/yyyy').format(post.creationDate)),
      title: Text(
        post.title,
        style: kBigText,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Text(
            post.description,
            textAlign: TextAlign.start,
          ),
        ),
        if (loggedPlayer.isGM && loggedPlayerTeam.id == post.teamId)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.edit_outlined),
                    onPressed: () => showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => BottomSheet(
                              onClosing: () {},
                              builder: (_) => _BottomSheetContent(
                                  loggedPlayerTeam, loggedPlayer, post)),
                        )),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => showConfirmationDialog(context).then(
                    (value) {
                      if (value) {
                        Provider.of<TeamsProvider>(context, listen: false)
                            .deletePost(post);
                      }
                    },
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}

class _ModalBottomSheetButton extends StatelessWidget {
  final Team team;
  final Player loggedPlayer;

  _ModalBottomSheetButton(this.team, this.loggedPlayer);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {},
            builder: (_) => _BottomSheetContent(team, loggedPlayer, null)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 'AddPost',
          child: Text('Aggiungi un post'),
        ),
      ),
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final Team team;
  final Player loggedPlayer;
  final TeamPost oldPost;

  _BottomSheetContent(this.team, this.loggedPlayer, this.oldPost);

  @override
  __BottomSheetContentState createState() => __BottomSheetContentState();
}

class __BottomSheetContentState extends State<_BottomSheetContent> {
  bool isLoading = false;
  TeamPost post;
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();

    post = widget.oldPost == null
        ? TeamPost(isPrivate: false)
        : TeamPost.fromMap(widget.oldPost.id, widget.oldPost.asMap);
  }

  Future<void> _addPost() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.validate();
      setState(() {
        isLoading = true;
      });

      if (post.id == null) {
        //new
        post.teamId = Provider.of<LoginProvider>(context, listen: false)
            .loggedPlayerTeam
            .id;
        post.creationDate = DateTime.now();
        post.editDate = DateTime.now();
        post.authorName = widget.loggedPlayer.nickname;
        post.authorId = widget.loggedPlayer.id;
      } else {
        // edit
        post.editDate = DateTime.now();
      }

      await Provider.of<TeamsProvider>(context, listen: false)
          .addOrEditPost(post);

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            height: 200, child: Center(child: CircularProgressIndicator()))
        : Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Hero(
                  tag: 'AddPost',
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
                  child: TextFormField(
                    autofocus: true,
                    initialValue: post.title,
                    decoration: InputDecoration(
                      labelText: 'Titolo',
                    ),
                    onChanged: (value) => post.title = value,
                    validator: FormHelper.validateGenericText,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: post.description,
                    decoration: InputDecoration(
                      labelText: 'Contenuto',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (value) => post.description = value,
                    validator: FormHelper.validateGenericText,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(post.isPrivate
                                ? 'Post privato'
                                : 'Post pubblico'),
                          ),
                          Switch(
                            value: !post.isPrivate,
                            onChanged: (_) {
                              setState(() {
                                post.isPrivate = !post.isPrivate;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _addPost,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Conferma'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
