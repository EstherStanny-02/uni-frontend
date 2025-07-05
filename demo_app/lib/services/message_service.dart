import 'dart:convert';
import 'package:demo_app/services/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageService {
  // Base URL for API calls
  final String baseUrl = AppUrl.messages;

  // Optional API key or auth token if needed

  MessageService();

  // Headers to include in requests
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get all messages
  Future<List<dynamic>> getMessages() async {
  try {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      final responseData = jsonDecode(response.body);
      
      // Ensure response is a Map
      if (responseData is Map<String, dynamic>) {
        // Check if error is false
        if (responseData['error'] == false) {
          // Extract the data field
          final messages = responseData['data'];
          
          // Verify data is a List
          if (messages is List<dynamic>) {
            return messages;
          } else {
                      throw Exception('Invalid API response: "data" must be a list, got ${messages.runtimeType}');
          }
        } else {
          throw Exception('API error: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Invalid API response: Expected a JSON object, got ${responseData.runtimeType}');
      }
    } else {
      throw Exception('Failed to load messages: HTTP ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching messages: $e');
  }
}

  // Get a specific message by ID
  Future<Map<String, dynamic>> getMessage(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load message: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load message: $e');
    }
  }

  // Mark a message as read
  Future<bool> markAsRead(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/messages/$id/read'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Delete a message
  Future<bool> deleteMessage(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/messages/$id'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Archive a message
  Future<bool> archiveMessage(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/messages/$id/archive'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to archive message: $e');
    }
  }
}
