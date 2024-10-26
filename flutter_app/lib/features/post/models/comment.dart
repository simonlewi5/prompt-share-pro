import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class Comment {
  final Map<String, String> author;
  final String content;
  final DateTime createdAt;

  Comment({
    this.author = const {},
    required this.content,
    required this.createdAt,
  });

  static final DateFormat customDateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US");

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    var createdAtValue = json['created_at'];
    DateTime parsedCreatedAt = customDateFormat.parseUtc(createdAtValue);

    return Comment(
      author: Map<String, String>.from(json['author']),
      content: json['content'],
      createdAt: parsedCreatedAt,
    );
  }
}