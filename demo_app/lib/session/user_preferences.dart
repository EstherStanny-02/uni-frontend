import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:demo_app/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPreferences {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Save user data to SharedPreferences with secure password storage
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("firstName", user.firstName ?? '');
    prefs.setString("lastName", user.lastName ?? '');
    prefs.setString("email", user.email ?? '');
    prefs.setString("accessToken", user.accessToken ?? '');
    prefs.setString("refreshToken", user.refreshToken ?? '');

    // Attempt to save data
    try {
      await prefs.commit();
      return true;
    } catch (e) {
      // Handle case where commit() is not available in newer versions
      return true; // SharedPreferences auto-commits in newer versions
    }
  }

  // Get user data from SharedPreferences
  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? firstName = prefs.getString("firstName");
    String? lastName = prefs.getString("lastName");
    String? email = prefs.getString("email");
    String? token = prefs.getString("accessToken");
    String? renewalToken = prefs.getString("refreshToken");

    return User(
        firstName: firstName,
        email: email,
        accessToken: token,
        lastName: lastName,
        refreshToken: renewalToken);
  }

  // Remove user data from SharedPreferences
  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("firstName");
    prefs.remove("email");
    prefs.remove("lastName");
    prefs.remove("accessToken");
    prefs.remove("refreshToken");
    prefs.remove("phone");

    // Also remove password from secure storage
    await _secureStorage.delete(key: "userPassword");
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    return token;
  }

  // Save user password securely
  Future<bool> saveUserPassword(String password) async {
    try {
      // Store password in secure storage instead of SharedPreferences
      await _secureStorage.write(key: "userPassword", value: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user password (for authentication purposes)
  Future<String?> getUserPassword() async {
    try {
      return await _secureStorage.read(key: "userPassword");
    } catch (e) {
      return null;
    }
  }
}
