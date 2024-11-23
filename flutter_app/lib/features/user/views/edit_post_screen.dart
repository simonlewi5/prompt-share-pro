import 'package:flutter/material.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

var logger = Logger();

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  EditPostScreenState createState() => EditPostScreenState();
}

class EditPostScreenState extends State<EditPostScreen> {
  final PostRepository postRepository = PostRepository();
  late Post post;
  bool isLoading = true;
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController authorNotesController;
  List<String> llmKind = [];
  final List<String> llmOptions = ['GPT-3', 'GPT-2', 'BERT', 'RoBERTa', 'T5', 'DistilBERT'];

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  void _fetchPost() async {
    try {
      final response = await postRepository.getPostById(widget.postId);
      if (response.statusCode == 200) {
        setState(() {
          post = Post.fromJson(jsonDecode(response.body));
          titleController = TextEditingController(text: post.title);
          contentController = TextEditingController(text: post.content);
          authorNotesController = TextEditingController(text: post.authorNotes);
          llmKind = List.from(post.llmKind);
          isLoading = false;
        });
      } else {
        logger.e('Failed to load post: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Failed to load post: $e');
      setState(() {
        isLoading = false;
      });
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
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: llmOptions.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: selectedOptions.contains(option),
                      onChanged: (bool? selected) {
                        setDialogState(() {
                          if (selected == true) {
                            selectedOptions.add(option);
                          } else {
                            selectedOptions.remove(option);
                          }
                          setState(() {
                            llmKind = List.from(selectedOptions);
                          });
                        });
                      },
                    );
                  }).toList(),
                );
              },
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
                  llmKind = List.from(selectedOptions);
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
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    authorNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: authorNotesController,
              decoration: const InputDecoration(labelText: 'Author Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('EditPostSubmitButton'),
              onPressed: () async {
                final updatedPost = Post(
                  id: post.id,
                  author: post.author,
                  title: titleController.text,
                  llmKind: llmKind,
                  content: contentController.text,
                  authorNotes: authorNotesController.text,
                  totalPoints: post.totalPoints,
                  totalRatings: post.totalRatings,
                  averageRating: post.averageRating,
                );

                FocusManager.instance.primaryFocus?.unfocus();

                try {
                  final response = await postRepository.updatePost(post.id!, updatedPost);
                  if (response.statusCode == 200) {
                    logger.i('Successfully updated post');
                    Navigator.pop(context, true);
                  } else {
                    logger.e('Failed to update post: ${response.statusCode}');
                  }
                } catch (e) {
                  logger.e('Failed to update post: $e');
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
