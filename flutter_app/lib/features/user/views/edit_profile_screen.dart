import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/user/models/user.dart';
import 'package:flutter_app/features/user/data/user_repository.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  String? profileImagePath;
  final UserRepository userRepository = UserRepository();
  late UserState userState;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.userName);
    profileImagePath = widget.user.profileImage;
    userState = Provider.of<UserState>(context, listen: false);
  }

  Future<void> _selectAvatar() async {
    final selectedImagePath = await showDialog(
      context: context,
      builder: (context) => const GridPopup(),
    );
    if (selectedImagePath != null) {
      setState(() {
        profileImagePath = selectedImagePath;
      });
    }
  }

  void _saveChanges() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Changes"),
          content: const Text("Are you sure you want to save these changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                User updatedUser = User(
                  userEmail: widget.user.userEmail,
                  userName: _usernameController.text,
                  profileImage: profileImagePath,
                );

                final response = await userRepository.updateUser(updatedUser);

                if (response.statusCode == 200) {
                  var responseData = jsonDecode(response.body);
                  String token = responseData['access_token'];

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('jwt_token', token);

                  if (mounted) {
                    Provider.of<UserState>(context, listen: false).setToken(token);
                  }

                  logger.i("User updated successfully");
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                } else {
                  logger.e("Failed to update user: ${response.statusCode}");
                  logger.d("Response body: ${response.body}");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectAvatar,
              child: CircleAvatar(
                radius: 64,
                backgroundImage: profileImagePath != null
                    ? AssetImage(profileImagePath!)
                    : const NetworkImage(
                  'https://img.freepik.com/premium-vector/robot-circle-vector-icon_418020-452.jpg',
                ) as ImageProvider,
                backgroundColor: Colors.grey,
                child: profileImagePath == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
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
