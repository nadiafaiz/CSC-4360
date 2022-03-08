import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page_app/app.dart';
import 'package:fan_page_app/screens/screens.dart';
import 'package:fan_page_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
    as flutter;

class ProfileScreen extends StatelessWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            const Hero(
              tag: 'hero-profile-picture',
              child: Icon(
                CupertinoIcons.person,
                size: 128,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user?.name ?? 'No name'),
            ),
            const Divider(),
            const Rating(),
            const _SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class Rating extends StatefulWidget {
  const Rating({Key? key}) : super(key: key);

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  final firebase.User? user = firebase.FirebaseAuth.instance.currentUser;

  Widget _buildAverageRatingText(QuerySnapshot snapshot) {
    double averageRating = 0;

    int numberOfRatings = snapshot.size;
    double totalRating = 0;
    for (var userRating in snapshot.docs) {
      totalRating = totalRating + userRating["rating"];
    }
    averageRating = totalRating / numberOfRatings;
    return Text("Average user rating: $averageRating");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("userRatings")
              .where('uid', isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            return _buildAverageRatingText(snapshot.requireData);
          },
        ),
      ],
    );
  }
}

class _SignOutButton extends StatefulWidget {
  const _SignOutButton({
    Key? key,
  }) : super(key: key);

  @override
  __SignOutButtonState createState() => __SignOutButtonState();
}

class __SignOutButtonState extends State<_SignOutButton> {
  Future<void> _signOut() async {
    try {
      await flutter.StreamChatCore.of(context).client.disconnectUser();
      _showConfirmLogoutDialog();
    } on Exception catch (e, st) {
      logger.e('Could not sign out', e, st);
    }
  }

  Future<void> _showConfirmLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text("Are you sure you want to logout?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                await flutter.StreamChatCore.of(context)
                    .client
                    .disconnectUser();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _signOut,
      child: const Text('Sign out'),
    );
  }
}
