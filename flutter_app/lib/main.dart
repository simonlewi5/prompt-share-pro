import 'package:flutter/foundation.dart';
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
      title: 'Prompt Share Pro',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[400],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[400],
          ),
      ),

      home: userState.token.isNotEmpty ? const HomeScreen() : const WelcomeScreen(),
      debugShowCheckedModeBanner: !kDebugMode,
    );
  }
}
