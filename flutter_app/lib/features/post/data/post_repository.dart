import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/features/post/models/post.dart';

class PostRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<http.Response> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );
    return response;
  }

  Future<http.Response> getPostById(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId'),
    );
    return response;
  }

  Future<http.Response> updatePost(String postId, Post post) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );
    return response;
  }

  Future<http.Response> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
    );
    return response;
  }
}
