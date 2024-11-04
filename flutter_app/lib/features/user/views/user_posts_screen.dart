import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/views/post_detail_screen.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class UserPostsScreen extends StatefulWidget {
  final String email;

  const UserPostsScreen({super.key, required this.email});

  @override
  UserPostsScreenState createState() => UserPostsScreenState();
}

class UserPostsScreenState extends State<UserPostsScreen> {
  final PostRepository postRepository = PostRepository();
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() async {
    try {
      final fetchedPosts = await postRepository.getAllPostsByUser(widget.email);
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      logger.e('Failed to load posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Posts'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LLM Kind: ${post.llmKind.join(', ')}'),
                if (post.authorNotes.isNotEmpty)
                  Text('Author Notes: ${post.authorNotes}'),
                if (post.averageRating != null &&
                    post.totalRatings != null)
                  Text(
                      'Rating: ${post.averageRating?.toStringAsFixed(1)} (${post.totalRatings} ratings)'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PostDetailScreen(postId: post.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}