import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:flutter_app/features/post/views/create_post_screen.dart';
import 'package:flutter_app/features/post/views/post_list_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${userState.username}!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
              child: const Text("Create Post"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostListScreen(),
                  ),
                );
              },
              child: const Text("View Posts"),
            ),
          ],
        ),
      ),
    );
  }
}