import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/views/welcome_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/user/views/user_posts_screen.dart';

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
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Edit Profile') {
                // we have to add edit profile feature
              } else if (value == 'Sign Out') {
                signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Edit Profile', 'Sign Out'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blue,
                height: 100,
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
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
                    ElevatedButton(
                      // change width of button
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPostsScreen(email: userState.email),
                          ),
                        );
                      },
                      child: const Text('View Your Posts'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
