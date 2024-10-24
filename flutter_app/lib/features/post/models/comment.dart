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
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      authorEmail: json['author_email'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
