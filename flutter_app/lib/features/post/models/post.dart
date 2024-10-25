class Post {
  final String? id;
  final String authorEmail;
  final String title;
  final String llmKind;
  final String content;
  final String authorNotes;
  final Map<String, int>? userRatings;
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
    this.userRatings,
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
      'user_ratings': userRatings,
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
      userRatings: json['user_ratings'] != null
          ? Map<String, int>.from(json['user_ratings'])
          : null,
      totalPoints: json['total_points'],
      totalRatings: json['total_ratings'],
      averageRating: (json['average_rating'] != null)
          ? json['average_rating'].toDouble()
          : null,
    );
  }

  int? getUserRating(String userEmail) {
    return userRatings != null ? userRatings![userEmail] : null;
  }
}
