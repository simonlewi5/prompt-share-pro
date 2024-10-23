// signup_request.dart
class SignupRequest {
  final String email;
  final String username;
  final String uscId;
  final String password;

  SignupRequest({required this.email, required this.username, required this.uscId, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'usc_id': uscId,
      'password': password,
    };
  }
}
