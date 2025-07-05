import 'dart:async';
import 'dart:convert';
import 'package:demo_app/models/user_model.dart';
import 'package:demo_app/services/app_url.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  // Updated login method to match the required JSON payload format
  Future<Map<String, dynamic>> login(String username, String password) async {
    Map<String, dynamic> result;

    // Create the login payload in the required format
    final Map<String, dynamic> loginData = {
      'username': username,
      'password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    try {
      Response response = await post(
        Uri.parse(AppUrl.login),
        body: json.encode(loginData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print(
            "Backend body======> ${response.body}"); // Add this before parsing

        final Map<String, dynamic> responseData = json.decode(response.body);

        User authUser = User.fromJson(responseData);

        UserPreferences().saveUser(authUser);

        _loggedInStatus = Status.LoggedIn;
        notifyListeners();

        result = {
          'status': true,
          'message': 'Login Successful',
          'user': authUser
        };
      } else {
        _loggedInStatus = Status.NotLoggedIn;
        notifyListeners();
        result = {
          'status': false,
          'message': json.decode(response.body)['error'] ?? 'Login failed'
        };
      }
    } catch (error) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {'status': false, 'message': 'Connection error: $error'};
    }

    return result;
  }

  // Updated register method to match the required JSON payload format
  Future<Map<String, dynamic>> register(String firstName, String lastName,
      String username, String email, String password) async {
    // Create the registration payload in the required format
    final Map<String, dynamic> registrationData = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'password': password
    };

    _registeredInStatus = Status.Registering;
    notifyListeners();

    try {
      Response response = await post(
        Uri.parse(AppUrl.register),
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'},
      );

      return await _processRegistrationResponse(response);
    } catch (error) {
      _registeredInStatus = Status.NotRegistered;
      notifyListeners();

      return {'status': false, 'message': 'Connection error: $error'};
    }
  }

  Future<Map<String, dynamic>> _processRegistrationResponse(
      Response response) async {
    Map<String, dynamic> result;
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);

      _registeredInStatus = Status.Registered;
      notifyListeners();

      result = {
        'status': true,
        'message': 'Registration Successful',
        'data': authUser
      };
    } else {
      _registeredInStatus = Status.NotRegistered;
      notifyListeners();

      result = {
        'status': false,
        'message': responseData['error'] ?? 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  Future<Response> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String confirmPassword}) async {
    developer.log('Change password method called in auth provider=========>: ');
    final Response response;
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Please provide current and new password');
    }

    // Using the required format for backend: old_password and new_password
    final Map<String, dynamic> passwordData = {
      'old_password': currentPassword,
      'new_password': newPassword,
    };

    try {
      developer.log(
          'try statement executed in auth provider change-password=========>: ');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Get user token for authorization
      final String accessToken = prefs.getString('access_token') ?? '';
      developer.log(
          'Access token in auth provider change-password=========>: $accessToken');
      response = await http.put(
        Uri.parse(AppUrl.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: jsonEncode(passwordData),
      );

      developer.log(
          'Response status in auth provider change-password=========>: ${response.statusCode}');

      developer.log(
          'Response body in auth provider change-password=========>: ${response.body}');

      developer.log(
          'Final url in auth provider change-password=========>: ${AppUrl.changePassword}');
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Password updated successfully: $result');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            'Error: ${error['message'] ?? 'Failed to update password'}');
      }
    } catch (e) {
      developer.log('Error in auth provider change-password=========>: $e');
      throw Exception('Failed to update password: $e');
    }
    return response;
  }
}
