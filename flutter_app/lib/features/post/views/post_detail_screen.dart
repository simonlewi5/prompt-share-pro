import 'package:flutter/material.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/views/comment_section.dart';
import 'dart:convert';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepository postRepository = PostRepository();
  late Post post;
  bool isLoading = true;

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
          isLoading = false;
        });
      } else {
        print('Failed to load post');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load post: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('LLM Kind: ${post.llmKind}'),
            const SizedBox(height: 10),
            Text(post.content),
            const SizedBox(height: 20),
            const Divider(),
            CommentSection(postId: widget.postId),
          ],
        ),
      ),
    );
  }
}
