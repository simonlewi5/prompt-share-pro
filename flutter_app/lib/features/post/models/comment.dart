import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';  // Assuming you're using logger for debugging

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

  Map<String, dynamic> toJson() {
    return {
      'author_email': authorEmail,
      'content': content,
      'created_at': createdAt,  // Firestore can handle DateTime directly
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    var createdAtValue = json['created_at'];

    // Add a debug log to see what the 'created_at' value looks like
    logger.d('CreatedAt value: $createdAtValue');

    DateTime parsedCreatedAt;

    // Try to handle different types of the created_at field
    if (createdAtValue is Timestamp) {
      parsedCreatedAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      // Try parsing the string as a DateTime
      try {
        parsedCreatedAt = DateTime.parse(createdAtValue);
      } catch (e) {
        logger.e('Failed to parse created_at: $createdAtValue');
        throw FormatException('Invalid date format: $createdAtValue');
      }
    } else {
      logger.e('Unknown created_at type: ${createdAtValue.runtimeType}');
      throw FormatException('Unexpected created_at type: ${createdAtValue.runtimeType}');
    }

    return Comment(
      authorEmail: json['author_email'],
      content: json['content'],
      createdAt: parsedCreatedAt,
    );
  }
}
