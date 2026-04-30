
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const baseUrl = "http://localhost:3000/api";

  static Future<Map<String, dynamic>> post(String endpoint, Map body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }
}
