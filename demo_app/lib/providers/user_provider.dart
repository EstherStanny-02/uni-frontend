import 'package:demo_app/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User _user = User();

  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
