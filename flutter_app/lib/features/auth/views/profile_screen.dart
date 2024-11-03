import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/views/welcome_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {

  void signOut() async {
    final userState = Provider.of<UserState>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    userState.clearUserData();

    logger.i("User signed out successfully");

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (Route<dynamic> route) => false, // This clears all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${userState.username}!',
              style: const TextStyle(fontSize: 24),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Username'),
                    subtitle: Text(userState.username),
                  ),
                  ListTile(
                    title: const Text('Email'),
                    subtitle: Text(userState.email),
                  ),
                ],
              ),
            ),
            ElevatedButton(
                onPressed: signOut,
                child: const Text('Sign Out')
            )
          ],
        ),
      ),
    );
  }
}
