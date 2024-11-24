import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/post/models/comment.dart';

var logger = Logger();

class CommentRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<http.Response> createComment(String postId, Comment comment) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(comment.toJson()),
    );
    return response;
  }

  Future<List<Comment>> getAllComments(String postId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<http.Response> deleteComment(String postId, String commentId) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<http.Response> updateComment(String postId, String commentId, String content) async {
    logger.i(commentId);
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$postId/comments/$commentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );
    return response;
  }
}