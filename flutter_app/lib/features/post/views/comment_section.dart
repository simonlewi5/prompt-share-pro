import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/post/data/comment_repository.dart';
import 'package:flutter_app/features/post/models/comment.dart';
import 'package:flutter_app/core/services/user_state.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final CommentRepository commentRepository = CommentRepository();
  final TextEditingController contentController = TextEditingController();
  List<Comment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() async {
    try {
      final fetchedComments = await commentRepository.getAllComments(widget.postId);
      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addComment() async {
    final userState = Provider.of<UserState>(context, listen: false);

    if (contentController.text.isEmpty) {
      return;
    }

    Comment newComment = Comment(
      authorEmail: userState.email,
      content: contentController.text,
      createdAt: DateTime.now(),
    );

    try {
      final response = await commentRepository.createComment(widget.postId, newComment);
      if (response.statusCode == 201) {
        contentController.clear();
        _fetchComments(); // Refresh comments after adding
      } else {
        print('Failed to add comment');
      }
    } catch (e) {
      print('Failed to add comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        isLoading
            ? const CircularProgressIndicator()
            : comments.isEmpty
            ? const Text('No comments yet.')
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              title: Text(comment.authorEmail),
              subtitle: Text(comment.content),
            );
          },
        ),
        const SizedBox(height: 20),
        TextField(
          controller: contentController,
          decoration: const InputDecoration(
            labelText: 'Add a comment...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addComment,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
