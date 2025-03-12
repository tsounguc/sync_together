import 'package:flutter/material.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  set user(UserModel? user) {
    if (_user != user) {
      _user = user;
      Future.delayed(Duration.zero, notifyListeners);
    }
  }

  void initUser(UserModel? user) {
    if (_user != user) _user = user;
    Future.delayed(Duration.zero, notifyListeners);
  }
}
