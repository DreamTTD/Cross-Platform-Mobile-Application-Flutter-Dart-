
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static String? _authToken;

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static Map<String, String> get _defaultHeaders {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  static void setToken(String? token) {
    _authToken = token;
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _defaultHeaders,
      body: jsonEncode(body),
    );

    return _parseResponse(res.body);
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _defaultHeaders,
    );

    return _parseResponse(res.body);
  }

  static Future<List<dynamic>> list(String endpoint) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _defaultHeaders,
    );

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic> && decoded['tasks'] is List) {
      return decoded['tasks'] as List<dynamic>;
    }
    return [];
  }

  static Map<String, dynamic> _parseResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }
}
