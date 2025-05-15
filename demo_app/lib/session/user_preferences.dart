import 'package:demo_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("firstName", user.firstName ?? '');
    prefs.setString("lastName", user.lastName ?? '');
    prefs.setString("email", user.email ?? '');
    prefs.setString("accessToken", user.accessToken ?? '');
    prefs.setString("renewalToken", user.refreshToken ?? '');

    return prefs.commit();
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? firstName = prefs.getString("firstName");
    String? lastName = prefs.getString("lastName");
    String? email = prefs.getString("email");
    String? token = prefs.getString("accessToken");
    String? renewalToken = prefs.getString("renewalToken");

    return User(
        firstName: firstName,
        email: email,
        accessToken: token,
        lastName: lastName,
        refreshToken: renewalToken);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("firstName");
    prefs.remove("email");
    prefs.remove("lastName");
    prefs.remove("accessToken");
    prefs.remove("renewalToken");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }
}
