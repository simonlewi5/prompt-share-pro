// login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/auth/models/login_request.dart';
import 'package:flutter_app/features/auth/data/auth_repository.dart';
import 'package:flutter_app/features/home/views/home_screen.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:flutter_app/snackBarMessage.dart';
import 'package:lottie/lottie.dart';

var logger = Logger();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  void login() async {
    LoginRequest request = LoginRequest(
      email: emailController.text,
      password: passwordController.text,
    );
    final response = await authRepository.login(request);

    if (response.statusCode == 200) {
      logger.i("User logged in successfully");

      var responseData = jsonDecode(response.body);
      String token = responseData['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      if (mounted) {
        final userState = Provider.of<UserState>(context, listen: false);
        userState.setToken(token);

        snackBarMessage(context, "Welcome back ${userState.username}!");

        showLoginAnimation();
      }
    } else {
      logger.e("Login failed: ${response.statusCode}");
      logger.d("Response body: ${response.body}");
    }
  }

  void showLoginAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
            'assets/lottie/checkmark.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                );
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('submitLoginButton'),
              onPressed: login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
