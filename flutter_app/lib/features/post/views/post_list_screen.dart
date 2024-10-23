import 'package:flutter/material.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/models/post.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  PostListScreenState createState() => PostListScreenState();
}

class PostListScreenState extends State<PostListScreen> {
  final PostRepository postRepository = PostRepository();
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() async {
    // Mock implementation for fetching posts
    // You would actually call your repository's getPosts method here and parse the response
    setState(() {
      posts = [
        Post(authorEmail: 'user1@example.com', title: 'First Post', llmKind: 'GPT-3', content: 'This is the first post content'),
        Post(authorEmail: 'user2@example.com', title: 'Second Post', llmKind: 'BERT', content: 'This is the second post content'),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text('LLM Kind: ${post.llmKind}\n${post.content}'),
          );
        },
      ),
    );
  }
}
