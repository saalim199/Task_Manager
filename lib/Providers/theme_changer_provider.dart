import 'package:flutter/material.dart';

class ThemeChangerProvider with ChangeNotifier {
  var _isDark = false;

  bool getTheme() => _isDark;

  void setTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
