import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreetingProvider extends ChangeNotifier {
  GreetingProvider(this._prefs) {
    _name = _prefs.getString(_key);
  }

  static const String _key = 'cached_user_name';
  final SharedPreferences _prefs;

  String? _name;

  String? get name => _name;

  Future<void> cacheName(String newName) async {
    _name = newName;
    await _prefs.setString(_key, newName);
    notifyListeners();
  }

  Future<void> clearName() async {
    _name = null;
    await _prefs.remove(_key);
    notifyListeners();
  }
}
