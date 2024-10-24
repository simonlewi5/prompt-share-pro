import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

    logger.d('CreatedAt value: $createdAtValue');

    DateTime parsedCreatedAt;

    if (createdAtValue is Timestamp) {
      parsedCreatedAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      try {
        parsedCreatedAt = customDateFormat.parseUtc(createdAtValue);
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