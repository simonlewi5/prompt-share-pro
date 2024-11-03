import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:flutter_app/features/post/views/create_post_screen.dart';
import 'package:flutter_app/features/post/views/post_list_screen.dart';
import 'package:flutter_app/features/auth/views/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default to the Post List screen

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    // List of screens for each tab
    final List<Widget> screens = <Widget>[
      const PostListScreen(), // Main screen (default view)
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'View Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
