import 'package:flutter_app/features/post/data/post_repository.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class User {
  final String userEmail;
  final String userName;
  final String? password;
  final String? uscId;
  final String? profileImage;

  User({
    required this.userEmail,
    required this.userName,
    this.password,
    this.uscId,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': userEmail,
      'password': password,
      'profile_image': profileImage,
      'usc_id': uscId,
      'username': userName,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userEmail: json['email'],
      userName: json['username'],
      password: json['password'],
      uscId: json['usc_id'],
      profileImage: json['profile_image'],
    );
  }

}
