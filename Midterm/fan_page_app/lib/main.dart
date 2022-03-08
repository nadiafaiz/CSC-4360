import 'package:fan_page_app/app.dart';
import 'package:fan_page_app/firebase_options.dart';
import 'package:fan_page_app/screens/home/login_screen.dart';
import 'package:fan_page_app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final client = StreamChatClient(streamKey);
  runApp(
    MyApp(
      client: client,
      appTheme: AppTheme(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.appTheme,
    required this.client,
  }) : super(key: key);

  final AppTheme appTheme;
  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fan Page',
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return StreamChatCore(
          client: client,
          child: ChannelsBloc(
            child: UsersBloc(child: child!),
          ),
        );
      },
      home: const LoginScreen(),
    );
  }
}
