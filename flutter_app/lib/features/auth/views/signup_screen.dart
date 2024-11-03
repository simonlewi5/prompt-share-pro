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

    if (!verifyFields()) {
      return;
    }

    final response = await authRepository.signup(request);

    if (response.statusCode == 200) {
      logger.i("User signed up successfully");

      var responseData = jsonDecode(response.body);
      String token = responseData['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      if (mounted) {
        Provider.of<UserState>(context, listen: false).setToken(token);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      logger.e("Signup failed: ${response.statusCode}");
      logger.d("Response body: ${response.body}");
    }
  }

  bool verifyFields() {
    String text = "";

    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        uscIdController.text.isEmpty) {
      text = "Please fill out all fields!";
    } else if (!emailController.text.endsWith('@usc.edu')) {
      text = "Please enter a valid USC email!";
    } else if (uscIdController.text.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(uscIdController.text)) {
      text = "Please enter a valid USC ID!";
    } else {
      return true;
    }

    final snackBarMessage = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage);
    logger.i(text);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: NetworkImage(
                  'https://img.freepik.com/premium-vector/robot-circle-vector-icon_418020-452.jpg'),
            ),
            Positioned(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_a_photo),
              ),
            ),
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
