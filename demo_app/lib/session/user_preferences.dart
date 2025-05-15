import 'package:demo_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt("userId", user.userId ?? 0);
    prefs.setString("name", user.name ?? '');
    prefs.setString("email", user.email ?? '');
    prefs.setString("phone", user.phone ?? '');
    prefs.setString("token", user.token ?? '');
    prefs.setString("renewalToken", user.refreshToken ?? '');

    return prefs.commit();
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt("userId");
    String? name = prefs.getString("name");
    String? email = prefs.getString("email");
    String? phone = prefs.getString("phone");
    String? token = prefs.getString("token");
    String? renewalToken = prefs.getString("renewalToken");

    return User(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        token: token,
        refreshToken: renewalToken);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("name");
    prefs.remove("email");
    prefs.remove("phone");
    prefs.remove("type");
    prefs.remove("token");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }
}