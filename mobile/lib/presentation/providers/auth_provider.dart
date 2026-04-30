
import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  bool loading = false;

  Future<void> login(String email) async {
    loading = true;
    notifyListeners();

    final res = await ApiClient.post("auth/login", {"email": email});
    token = res['token'];

    loading = false;
    notifyListeners();
  }
}
