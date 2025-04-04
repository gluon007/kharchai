import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  User? get user {
    return _user;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }

    final extractedToken = prefs.getString('token');
    final expiryDateString = prefs.getString('expiryDate');
    final userData = prefs.getString('userData');

    if (extractedToken == null ||
        expiryDateString == null ||
        userData == null) {
      return false;
    }

    final expiryDate = DateTime.parse(expiryDateString);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedToken;
    _user = User.fromJson(
      Map<String, dynamic>.from(const JsonDecoder().convert(userData)),
    );
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await ApiService.register(username, email, password);
      _handleAuthentication(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      _handleAuthentication(response);
    } catch (error) {
      rethrow;
    }
  }

  void _handleAuthentication(Map<String, dynamic> response) {
    _token = response['token'];
    _user = User.fromJson(response['user']);

    // Set expiry date (1 day from now)
    _expiryDate = DateTime.now().add(const Duration(days: 1));

    _autoLogout();
    notifyListeners();

    // Save to local storage
    _saveAuthData();
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', _token!);
    prefs.setString('expiryDate', _expiryDate!.toIso8601String());
    prefs.setString('userData', const JsonEncoder().convert(_user!.toJson()));
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
