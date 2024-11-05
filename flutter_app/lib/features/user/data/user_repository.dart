import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/features/user/models/user.dart';

var logger = Logger();

class UserRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<User> getUserByEmail(String email) async {
    String? token = await _getToken();
    final response = await http.get(
        Uri.parse('$baseUrl/users/$email'),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<http.Response> updateUser(User user) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.userEmail}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );
    return response;
  }
}