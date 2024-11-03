import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/core/services/user_state.dart';

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
  List<String> llmKind = [];
  final List<String> llmOptions = ['GPT-3', 'GPT-2', 'BERT', 'RoBERTa', 'T5', 'DistilBERT'];
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
      const text = "Post created successfully";
      logger.i(text);

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      logger.e("Post creation failed: ${response.statusCode}");
      logger.d("Response body: ${response.body}");
    }
  }

  void _showLLMSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> selectedOptions = List.from(llmKind);

        return AlertDialog(
          title: const Text('Select LLM Models'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: llmOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: selectedOptions.contains(option),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        selectedOptions.add(option);
                      } else {
                        selectedOptions.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  llmKind = selectedOptions;
                });
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showLLMSelectionDialog,
              child: Text(
                llmKind.isEmpty ? 'Select LLM Models' : 'Selected: ${llmKind.join(', ')}',
              ),
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
    } else if (llmKind.isEmpty) {
      text = "Please select at least one LLM model!";
    } else {
      return true;
    }

    logger.i(text);
    return false;
  }
}
