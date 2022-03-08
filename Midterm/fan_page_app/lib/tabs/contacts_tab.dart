import 'package:fan_page_app/app.dart';
import 'package:fan_page_app/screens/messaging/chat_screen.dart';
import 'package:fan_page_app/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserListCore(
      limit: 20,
      filter: Filter.notIn('id', ['nadiafaiz', context.currentUser!.id]),
      emptyBuilder: (context) {
        return const Center(child: Text('There are no users'));
      },
      loadingBuilder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error) {
        return DisplayErrorMessage(error: error);
      },
      listBuilder: (context, items) {
        return Scrollbar(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return items[index].when(
                headerItem: (_) => const SizedBox.shrink(),
                userItem: (user) => _ContactTile(user: user),
              );
            },
          ),
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  Future<void> createChannel(BuildContext context) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id,
        user.id,
      ]
    });
    await channel.watch();

    Navigator.of(context).push(
      ChatScreen.routeWithChannel(channel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        createChannel(context);
      },
      child: ListTile(
        leading: const Icon(
          CupertinoIcons.person_circle_fill,
          size: 40,
        ),
        title: Text(user.name),
      ),
    );
  }
}
