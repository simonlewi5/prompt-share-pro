class Post {
  final String authorEmail;
  final String title;
  final String llmKind;
  final String content;

  Post({
    required this.authorEmail,
    required this.title,
    required this.llmKind,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'author_email': authorEmail,
      'title': title,
      'llm_kind': llmKind,
      'content': content,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      authorEmail: json['author_email'],
      title: json['title'],
      llmKind: json['llm_kind'],
      content: json['content'],
    );
  }
}