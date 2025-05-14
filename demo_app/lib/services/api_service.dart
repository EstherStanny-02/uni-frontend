
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://your-backend-url.com/api";

  // Login method to authenticate the user
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"success": false, "error": "Invalid credentials"};
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }
}
