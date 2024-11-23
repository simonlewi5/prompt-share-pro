import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/features/post/models/gemini.dart';

var logger = Logger();

class GeminiRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<http.Response> getGeminiResponse(String prompt) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/gemini/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(prompt),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      logger.i(response.body);
      throw Exception('Failed to load gemini response');
    }
  }
}