class Post {
  final String? id;
  final String authorEmail;
  final String title;
  final String llmKind;
  final String content;
  final String authorNotes;
  final Map<String, int>? userRatings;

  Post({
    this.id,
    required this.authorEmail,
    required this.title,
    required this.llmKind,
    required this.content,
    required this.authorNotes,
    this.userRatings,
  });

  Map<String, dynamic> toJson() {
    return {
      'author_email': authorEmail,
      'title': title,
      'llm_kind': llmKind,
      'content': content,
      'author_notes': authorNotes,
      'user_ratings': userRatings,
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
    );
  }

  int? getUserRating(String userEmail) {
    return userRatings != null ? userRatings![userEmail] : null;
  }

  
}
