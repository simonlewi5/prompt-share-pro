import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Text(
          'Welcome, ${userState.username}!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}