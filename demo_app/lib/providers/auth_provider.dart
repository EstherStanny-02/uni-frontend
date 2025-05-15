import 'dart:async';
import 'dart:convert';
import 'package:demo_app/models/user_model.dart';
import 'package:demo_app/services/app_url.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
    var result;

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
        print("Backend body======> ${response.body}"); // Add this before parsing

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
    var result;
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
}
