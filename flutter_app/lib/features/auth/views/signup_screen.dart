// signup_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/auth/models/signup_request.dart';
import 'package:flutter_app/features/auth/data/auth_repository.dart';
import 'package:flutter_app/features/home/views/home_screen.dart';
import 'package:flutter_app/core/services/user_state.dart';

var logger = Logger();

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController uscIdController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  void signup() async {
    SignupRequest request = SignupRequest(
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      uscId: uscIdController.text,
    );
    final response = await authRepository.signup(request);

    if (response.statusCode == 200) {
      logger.i("User signed up successfully");

      var responseData = jsonDecode(response.body);
      String token = responseData['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      if (mounted) {
        Provider.of<UserState>(context, listen: false).setToken(token);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } else {
      logger.e("Signup failed: ${response.statusCode}");
      logger.d("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: uscIdController,
              decoration: const InputDecoration(labelText: 'USC ID'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signup,
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
