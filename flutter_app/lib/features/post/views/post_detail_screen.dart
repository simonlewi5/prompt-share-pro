import 'package:flutter/material.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/views/comment_section.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

var logger = Logger();

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  PostDetailScreenState createState() => PostDetailScreenState();
}

class PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepository postRepository = PostRepository();
  final logger = Logger();
  late Post post;
  bool isLoading = true;
  bool hasRated = false;
  int? userRating;

  @override
  void initState() {
    super.initState();
    _fetchPost();
    _checkIfRated();
  }

  void _fetchPost() async {
    try {
      final response = await postRepository.getPostById(widget.postId);
      if (response.statusCode == 200) {
        setState(() {
          post = Post.fromJson(jsonDecode(response.body));
          logger.i(jsonEncode(post.toJson()));
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

  void _checkIfRated() async {
    try {
      final result = await postRepository.hasRatedPost(widget.postId);
      setState(() {
        hasRated = result['has_rated'];
        userRating = result['user_rating'];
      });
    } catch (e) {
      logger.e('Error checking if rated: $e');
    }
  }

  void _ratePost(int rating) async {
    try {
      final response = await postRepository.ratePost(widget.postId, rating);
      if (response.statusCode == 200) {
        logger.i('Successfully rated post');
        setState(() {
          userRating = rating;
          hasRated = true;
          _fetchPost();
        });
      } else {
        logger.e('Failed to rate post: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Failed to rate post: $e');
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) {
      return Colors.green;
    } else if (rating >= 2) {
      return Colors.yellow;
    } else {
      return Colors.red;
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
            Row(
              children: [
                Flexible(
                  child: Text(
                    post.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                if (post.averageRating != null)
                  Row(
                    children: [
                      Text(
                        post.averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Icon(
                          Icons.star,
                          color: _getRatingColor(post.averageRating!)
                      ),
                    ],
                  )
                else
                  const Text(
                    'This post has not been rated yet.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Author: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: post.author["username"] ?? 'Unknown',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text('LLM Kind: ${post.llmKind.join(', ')}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(post.content),
            ),
            const SizedBox(height: 10),
            if (post.authorNotes.isNotEmpty)
              Text('Author Notes: ${post.authorNotes}'),
            const SizedBox(height: 10),
            if (hasRated)
              Text(
                  'You have rated this post: $userRating',
                  style: const TextStyle(fontStyle: FontStyle.italic),
              )
            else
              Row(
                children: [
                  const Text('Rate this post:'),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: userRating,
                    hint: const Text('Select Rating'),
                    items: [1, 2, 3, 4, 5].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _ratePost(newValue);
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Divider(),
            CommentSection(postId: widget.postId),
          ],
        ),
      ),
    );
  }
}
