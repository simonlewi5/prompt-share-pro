import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app/features/post/data/comment_repository.dart';
import 'package:flutter_app/features/post/models/comment.dart';

var logger = Logger();

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
      logger.e('Failed to load comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addComment() async {
    if (contentController.text.isEmpty) {
      return;
    }

    Comment newComment = Comment(
      content: contentController.text,
      createdAt: DateTime.now(),
    );

    try {
      final response = await commentRepository.createComment(widget.postId, newComment);
      if (response.statusCode == 201) {
        contentController.clear();
        _fetchComments();
      } else {
        logger.i('Failed to add comment');
      }
    } catch (e) {
      logger.i('Failed to add comment: $e');
    }
  }

  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[400],
          title: const Text('Add a comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Enter your comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addComment();
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddCommentDialog,
              tooltip: 'Add Comment',
            ),
          ],
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
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: ListTile(
                title: Text(
                  '${comment.author['username']} (${comment.author['email']})',
                  style: const TextStyle(fontSize: 15),
                ),
                subtitle: Text(comment.content),
              ),
            );
          },
        ),
      ],
    );
  }
}
