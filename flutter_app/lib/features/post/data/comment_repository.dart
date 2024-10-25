import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/features/post/models/comment.dart';

var logger = Logger();

class CommentRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<http.Response> createComment(String postId, Comment comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comment.toJson()),
    );
    return response;
  }

  Future<List<Comment>> getAllComments(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<http.Response> deleteComment(String postId, String commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId/comments/$commentId'),
    );
    return response;
  }
}