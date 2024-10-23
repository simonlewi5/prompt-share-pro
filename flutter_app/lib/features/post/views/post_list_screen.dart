import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/home/views/home_screen.dart';

var logger = Logger();

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
    try {
      final fetchedPosts = await postRepository.getAllPosts();
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Failed to load posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text('LLM Kind: ${post.llmKind}\n${post.content}'),
                );
              },
            ),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
