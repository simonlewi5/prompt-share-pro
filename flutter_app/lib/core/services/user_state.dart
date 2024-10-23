import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

var logger = Logger();

class UserState with ChangeNotifier {
  String _email = '';
  String _token = '';
  String _username = '';
  DateTime _expiration = DateTime.now();

  String get email => _email;
  String get token => _token;
  String get username => _username;
  DateTime get expiration => _expiration;

  UserState() {
    _loadUserData();
  }

  void setToken(String token) async {
    _token = token;
    _decodeToken(token);
    if (_expiration.isBefore(DateTime.now())) {
      clearUserData();
      logger.d("Token has expired");
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    notifyListeners();
  }

  void _decodeToken(String token) {
    final jwt = JWT.decode(token);
    logger.d(jwt.payload);
    final subPayload = jwt.payload['sub'];
    _email = subPayload['email'];
    _username = subPayload['username'];
    _expiration = DateTime.fromMillisecondsSinceEpoch(jwt.payload['exp'] * 1000);
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('jwt_token');

    if (storedToken != null) {
      _token = storedToken;
      _decodeToken(storedToken);
      if (_expiration.isBefore(DateTime.now())) {
        clearUserData();
        logger.d("Token has expired");
        return;
      }
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = '';
    _email = '';
    _username = '';
    _expiration = DateTime.now();
    notifyListeners();
  }
}