import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/views/welcome_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/user/views/user_posts_screen.dart';
import 'package:flutter_app/features/user/models/user.dart';
import 'package:flutter_app/features/user/data/user_repository.dart';
import 'package:flutter_app/features/user/views/edit_profile_screen.dart';
import 'package:lottie/lottie.dart';

var logger = Logger();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final UserRepository userRepository = UserRepository();
  User? user;

  @override
  void initState() {
    super.initState();
    final userState = Provider.of<UserState>(context, listen: false);
    _fetchUser();
  }

  void _fetchUser() async {
    try {
      final userState = Provider.of<UserState>(context, listen: false);
      User fetchedUser = await userRepository.getUserByEmail(userState.email);

      if (mounted) {
        setState(() {
          user = fetchedUser;
        });
      }
    } catch (e) {
      logger.e("Failed to fetch user data: $e");
    }
  }

  void signOut() async {
    final userState = Provider.of<UserState>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    userState.clearUserData();
    logger.i("User signed out successfully");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
                'assets/lottie/signout.json',
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    Navigator.of(context).pop();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  });
                },
              ),
        );
      },
    );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: user!),
                  ),
                ).then((shouldRefresh) {
                  if (shouldRefresh == true) {
                    _fetchUser();
                  }
                }
                );
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: user?.profileImage != null
                        ? Image.asset(
                      user!.profileImage!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Username', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(userState.username),
                    ),
                    ListTile(
                      title: const Text('Email', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(userState.email),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[350],
                        foregroundColor: Colors.lightBlue,
                      ),
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

