import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/views/post_list_screen.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:flutter_app/features/home/views/home_screen.dart';

var logger = Logger();

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController authorNotesController = TextEditingController();
  String llmKind = 'GPT-3';
  final PostRepository postRepository = PostRepository();

  void createPost() async {
    final userState = Provider.of<UserState>(context, listen: false);

    if (!isFieldsValid()) {
      return;
    }

    Post post = Post(
      title: titleController.text,
      llmKind: llmKind,
      content: contentController.text,
      authorNotes: authorNotesController.text,
    );

    final response = await postRepository.createPost(post);

    if (response.statusCode == 201) {
      logger.i("Post created successfully");

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      logger.e("Post creation failed: ${response.statusCode}");
      logger.d("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            DropdownButton<String>(
              value: llmKind,
              items: ['GPT-3', 'BERT', 'T5'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  llmKind = newValue!;
                });
              },
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 6,
            ),
            TextField(
              controller: authorNotesController,
              decoration: const InputDecoration(labelText: 'Author Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createPost,
              child: const Text('Create Post'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: const Text("Home"),
            ),
          ],
        ),
      ),
    );
  }

  bool isFieldsValid() {
    String text = "";

    if (titleController.text.isEmpty ||
        contentController.text.isEmpty) {
      text = "Please fill out all fields!";
    } else {
      return true;
    }

    final snackBarMessage = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage);
    logger.i(text);
    return false;
  }
}
