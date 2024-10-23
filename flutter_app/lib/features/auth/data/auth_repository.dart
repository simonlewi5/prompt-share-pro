import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/features/auth/models/login_request.dart';
import 'package:flutter_app/features/auth/models/signup_request.dart';

class AuthRepository {
  final String baseUrl = "https://www.promptsharepro24.com";

  Future<http.Response> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    return response;
  }

  Future<http.Response> signup(SignupRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    return response;
  }
}
