import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class Comment {
  final String authorEmail;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.authorEmail,
    required this.content,
    required this.createdAt,
  });

  static final DateFormat customDateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US");

  Map<String, dynamic> toJson() {
    return {
      'author_email': authorEmail,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    var createdAtValue = json['created_at'];
    DateTime parsedCreatedAt = customDateFormat.parseUtc(createdAtValue);

    return Comment(
      authorEmail: json['author_email'],
      content: json['content'],
      createdAt: parsedCreatedAt,
    );
  }
}