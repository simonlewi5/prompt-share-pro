import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/features/post/models/post.dart';

var logger = Logger();

class PostRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<http.Response> createPost(Post post) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(post.toJson()),
    );
    return response;
  }

  Future<List<Post>> getAllPosts() async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Post>> getAllPostsByUser(String email) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/user/$email'),
      headers: {
        'Authorization': 'Bearer $token',
        }
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts by user');
    }
  }

  Future<http.Response> getPostById(String postId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<http.Response> updatePost(String postId, Post post) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(post.toJson()),
    );
    return response;
  }

  Future<http.Response> deletePost(String postId) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<http.Response> ratePost(String postId, int rating) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/rate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rating': rating,
      }),
    );
    return response;
  }

  Future<Map<String, dynamic>> hasRatedPost(String postId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/has_rated'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return {
        'has_rated': jsonResponse['has_rated'] ?? false,
        'user_rating': jsonResponse['rating']
      };
    } else {
      throw Exception('Failed to check if user has rated the post');
    }
  }
}