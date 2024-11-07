import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/views/post_detail_screen.dart';
import 'package:flutter_app/features/user/views/edit_post_screen.dart';
import 'package:logger/logger.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
    _refreshPosts();
  }

  void _refreshPosts() async {
    try {
      final fetchedPosts = await postRepository.getAllPostsByUser(widget.email);
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      logger.e('Failed to load posts: $e');
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
      appBar: AppBar(
        title: const Text('Your Posts'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Slidable(
            key: Key(post.id!),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostScreen(postId: post.id!),
                      ),
                    );
                    if (result == true) {
                      _refreshPosts();
                    }
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (context) async {
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this post?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      try {
                        await postRepository.deletePost(post.id!);
                        setState(() {
                          posts.removeAt(index);
                        });

                        logger.i('${post.title} deleted');
                      } catch (e) {
                        logger.e('Failed to delete post: $e');
                      }
                    }
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 3.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                title: Text(post.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LLM Kind: ${post.llmKind.join(', ')}'),
                    if (post.authorNotes.isNotEmpty)
                      Text('Author Notes: ${post.authorNotes}'),
                    if (post.averageRating != null && post.totalRatings != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: _getRatingColor(post.averageRating!),
                            size: 25,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${post.totalRatings} ratings)',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(postId: post.id!),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
