import 'package:flutter/material.dart';
import 'package:gudang_pro/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getString('token') != null;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      bool success = await _apiService.login(username, password);
      if (success) {
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isLoggedIn = false;
    notifyListeners();
  }
}