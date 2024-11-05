import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class Post {
  final String? id;
  final Map<String, String> author;
  final String title;
  final List<String> llmKind;
  final String content;
  final String authorNotes;
  final int? totalPoints;
  final int? totalRatings;
  final double? averageRating;

  Post({
    this.id,
    this.author = const {},
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
      'author': author,
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
      author: Map<String, String>.from(json['author']),
      title: json['title'],
      llmKind: json['llm_kind'] is List
          ? List<String>.from(json['llm_kind'])
          : [json['llm_kind'] as String],
      content: json['content'],
      authorNotes: json['author_notes'],
      totalPoints: json['total_points'],
      totalRatings: json['total_ratings'],
      averageRating: (json['average_rating'] != null)
          ? json['average_rating'].toDouble()
          : null,
    );
  }

}
