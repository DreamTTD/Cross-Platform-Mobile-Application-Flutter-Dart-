
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/models/user.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  User? user;
  bool loading = false;
  String? error;

  bool get authenticated => token != null && user != null;

  Future<bool> login(String email) async {
    if (email.isEmpty) {
      error = 'Please enter a valid email.';
      notifyListeners();
      return false;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final res = await ApiClient.post('auth/login', {'email': email});
      token = res['token'] as String?;
      ApiClient.setToken(token);
      await fetchProfile();
      return authenticated;
    } catch (e) {
      error = 'Login failed. Please try again.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    final res = await ApiClient.get('user/profile');
    final profile = res['user'] as Map<String, dynamic>?;
    if (profile != null) {
      user = User.fromJson(profile);
    }
  }

  void logout() {
    token = null;
    user = null;
    ApiClient.setToken(null);
    notifyListeners();
  }
}
