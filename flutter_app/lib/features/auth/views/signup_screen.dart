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
import 'package:flutter_app/snackBarMessage.dart';
import 'package:lottie/lottie.dart';

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
  String? _profileImage;
  final AuthRepository authRepository = AuthRepository();

  void signup() async {
    SignupRequest request = SignupRequest(
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      uscId: uscIdController.text,
      profileImage: _profileImage ?? 'assets/images/image_2.jpg',
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

        snackBarMessage(context, 'Welcome to PromptShare ${usernameController.text}!');

        showSignUpAnimation();
      }
    } else {
      logger.e("Signup failed: ${response.statusCode}");
      logger.d("Response body: ${response.body}");
    }
  }

  void showSignUpAnimation() {
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

    snackBarMessage(context, text);
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
              backgroundImage: _profileImage != null
                  ? AssetImage(_profileImage!)
                  : const NetworkImage(
                'https://img.freepik.com/premium-vector/robot-circle-vector-icon_418020-452.jpg',
              ) as ImageProvider,
            ),
            Center(
              child: GestureDetector(
                onTap: () async {
                  final selectedImagePath = await showDialog(
                    context: context,
                    builder: (context) => const GridPopup(),
                  );
                  if (selectedImagePath != null) {
                    setState(() {
                      _profileImage = selectedImagePath;
                    });
                  }
                },
                child: const Icon(
                  Icons.add_a_photo,
                  size: 32,
                  color: Colors.grey,
                ),
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
              key: const Key('submitSignupButton'),
              onPressed: signup,
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPopup extends StatelessWidget {
  const GridPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = [
      'assets/images/image_1.webp',
      'assets/images/image_2.jpg',
      'assets/images/image_3.webp',
      'assets/images/image_4.jpg',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 300,
        height: 325,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a Profile Picture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, imagePaths[index]);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
