import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/notification.dart';
import 'package:airsoft_tournament/providers/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsRoute extends StatelessWidget {
  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, _) => RefreshIndicator(
        onRefresh: () async =>
            await notificationsProvider.fetchAndSetPlayerNotifications(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Notifiche'),
          ),
          body: notificationsProvider.notifications.length > 0
              ? ListView.builder(
                  itemCount: notificationsProvider.notifications.length,
                  itemBuilder: (context, i) => NotificationListTile(
                      notificationsProvider.notifications[i]),
                )
              : Stack(
                  children: [
                    ListView(),
                    Center(
                      child: Text('Non ci sono nuove notifiche'),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

class NotificationListTile extends StatelessWidget {
  final CustomNotification _notification;

  const NotificationListTile(this._notification);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(_notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).accentColor,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Segna come letta',
            style: kAccentMediumText,
          ),
        ),
      ),
      onDismissed: (_) async =>
          await Provider.of<NotificationsProvider>(context, listen: false)
              .readNotification(_notification),
      child: ListTile(
        onTap: () {
          Provider.of<NotificationsProvider>(context, listen: false)
              .readNotification(_notification);
          _notification.type.onTap(_notification)(context);
        },
        trailing: _notification.read
            ? null
            : Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).accentColor),
              ),
        title: Text(_notification.title),
        subtitle: Text(_notification.description),
      ),
    );
  }
}
