import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:flutter_app/features/post/models/post.dart';
import 'package:flutter_app/features/post/views/post_detail_screen.dart';
import 'create_post_screen.dart';

var logger = Logger();

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  PostListScreenState createState() => PostListScreenState();
}

class PostListScreenState extends State<PostListScreen> {
  final PostRepository postRepository = PostRepository();
  final SearchController _searchController = SearchController();
  List<Post> posts = [];
  List<Post> filteredPosts = [];
  bool isDark = false;
  String selectedFilter = 'Title';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchPosts() async {
    try {
      final fetchedPosts = await postRepository.getAllPosts();
      setState(() {
        posts = fetchedPosts;
        filteredPosts = posts;
      });
    } catch (e) {
      logger.e('Failed to load posts: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredPosts = posts.where((post) {
        switch (selectedFilter) {
          case 'Title':
            return post.title.toLowerCase().contains(query);
          case 'LLM':
            return post.llmKind.any((kind) => kind.toLowerCase().contains(query));
          case 'Full Text':
            return post.content.toLowerCase().contains(query);
          default:
            return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Posts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                ).then((_) {
                  _fetchPosts();
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchAnchor(
                builder: (context, controller) {
                  return SearchBar(
                    controller: _searchController,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0)),
                    leading: const Icon(Icons.search),
                    trailing: <Widget>[
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          setState(() {
                            selectedFilter = value;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'Title',
                              child: Text('Title'),
                            ),
                            const PopupMenuItem(
                              value: 'LLM',
                              child: Text('LLM'),
                            ),
                            const PopupMenuItem(
                              value: 'Full Text',
                              child: Text('Full Text'),
                            ),
                          ];
                        },
                      ),
                    ],
                    onTap: () => _searchController.openView(),
                    onChanged: (_) => _searchController.openView(),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return List<ListTile>.generate(
                    filteredPosts.length, (index) => ListTile(
                      title: Text(filteredPosts[index].title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetailScreen(postId: filteredPosts[index].id!),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
  }
}
