// signup_request.dart
import 'dart:convert';
import 'dart:typed_data';

class SignupRequest {
  final String email;
  final String username;
  final String uscId;
  final String password;
  final String? profileImage;

  SignupRequest({
    required this.email,
    required this.username,
    required this.uscId,
    required this.password,
    Uint8List? profileImage
  }) : profileImage = profileImage != null ? base64Encode(profileImage) : null;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'usc_id': uscId,
      'password': password,
      'profile_image': profileImage,
    };
  }
}
