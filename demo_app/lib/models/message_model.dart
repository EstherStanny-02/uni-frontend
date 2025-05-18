import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Models
class Message {
  final int id;
  final String title;
  final String content;
  final DateTime timestamp;
  final int senderId;
  final String senderName;
  bool isRead;

  Message({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      senderId: json['sender'],
      senderName: json['sender_name'],
      isRead: json['is_read'] ?? false,
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isStaff: json['is_staff'] ?? false,
    );
  }

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) {
      return username;
    }
    return '$firstName $lastName'.trim();
  }
}

// API Service
class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  String? _token;
  User? _currentUser;

  // Singleton implementation
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Getters
  String? get token => _token;
  User? get currentUser => _currentUser;

  // Headers
  Map<String, String> get headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Token $_token';
    }

    return headers;
  }

  // Initialize from SharedPreferences
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      try {
        await getUserProfile();
        return true;
      } catch (e) {
        _token = null;
        _currentUser = null;
        await prefs.remove('auth_token');
        return false;
      }
    }
    return false;
  }

  // User authentication
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password,
      String firstName, String lastName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    // Clear token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get user profile
  Future<User> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      _currentUser = User.fromJson(jsonDecode(response.body));
      return _currentUser!;
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Get messages
  Future<List<Message>> getMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Mark message as read
  Future<bool> markMessageAsRead(int messageId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/$messageId/mark_as_read/'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // Admin: Create a new message
  Future<Message?> createMessage(String title, String content) async {
    if (_currentUser == null || !_currentUser!.isStaff) {
      return null; // Only admins can create messages
    }

    final response = await http.post(
      Uri.parse('$baseUrl/messages/'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create message');
    }
  }
}
