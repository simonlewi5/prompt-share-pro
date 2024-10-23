import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:flutter_app/features/auth/views/welcome_screen.dart';
import 'package:flutter_app/features/home/views/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: userState.token.isNotEmpty ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
