import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier(this._themeData);

  ThemeData get themeData => _themeData;
  ThemeMode get themeMode => _themeMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;

    switch (themeMode) {
      case ThemeMode.light:
        // 当设置为亮色主题时，明确指定scaffoldBackgroundColor为0xFFFFF5F1
        _themeData = ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color(0xFFFFF5F1),
        );
        break;
      case ThemeMode.dark:
        // 当设置为暗色主题时，可以选择一个适合的背景颜色
        _themeData = ThemeData.dark(); // 这里可以根据需要设置暗色主题的背景颜色
        break;
      case ThemeMode.system:
        // 保持当前的_themeData不变，待系统亮度变化时在外部处理
        break;
    }

    notifyListeners();
  }

  // 新增方法来处理系统亮度变化
  void updateThemeForSystemBrightness(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      _themeData = brightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFFFF5F1),
            );
      notifyListeners();
    }
  }

  void applySystemTheme() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    updateThemeForSystemBrightness(brightness);
  }
}
