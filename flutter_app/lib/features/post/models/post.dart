import 'package:flutter_app/features/post/data/post_repository.dart';

class Post {
  final String? id;
  final String authorEmail;
  final String title;
  final String llmKind;
  final String content;
  final String authorNotes;
  final int? totalPoints;
  final int? totalRatings;
  final double? averageRating;

  Post({
    this.id,
    required this.authorEmail,
    required this.title,
    required this.llmKind,
    required this.content,
    required this.authorNotes,
    this.totalPoints,
    this.totalRatings,
    this.averageRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'author_email': authorEmail,
      'title': title,
      'llm_kind': llmKind,
      'content': content,
      'author_notes': authorNotes,
      'total_points': totalPoints,
      'total_ratings': totalRatings,
      'average_rating': averageRating,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorEmail: json['author_email'],
      title: json['title'],
      llmKind: json['llm_kind'],
      content: json['content'],
      authorNotes: json['author_notes'],
      totalPoints: json['total_points'],
      totalRatings: json['total_ratings'],
      averageRating: (json['average_rating'] != null)
          ? json['average_rating'].toDouble()
          : null,
    );
  }

  static Future<bool> hasUserRated(String postId, String userEmail) async {
    final PostRepository postRepository = PostRepository();
    try {
      return await postRepository.hasRatedPost(postId);
    } catch (e) {
      return false;
    }
  }
}
