import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  ThemeMode _themeMode;

  // 修改构造函数以同时接受 ThemeData 和 ThemeMode
  ThemeNotifier(this._themeData, this._themeMode) {
    applySystemTheme(); // 确保在构造函数中调用此方法以立即应用正确的主题
  }

  ThemeData get themeData => _themeData;
  ThemeMode get themeMode => _themeMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    // 根据选定的主题模式更新主题数据
    switch (themeMode) {
      case ThemeMode.light:
        _themeData = ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color(0xFFFFF5F1), // 亮色主题背景色
        );
        break;
      case ThemeMode.dark:
        _themeData = ThemeData.dark(); // 暗色主题
        break;
      case ThemeMode.system:
        applySystemTheme(); // 根据系统主题应用亮色或暗色主题
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index); // 使用枚举的 index 作为简单的存储值

    notifyListeners();
  }

  void updateThemeForSystemBrightness(Brightness brightness) {
    // 仅在系统主题模式下根据系统亮度变化更新主题
    if (_themeMode == ThemeMode.system) {
      _themeData = brightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFFFF5F1), // 亮色主题背景色
            );
      notifyListeners();
    }
  }

  void applySystemTheme() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    updateThemeForSystemBrightness(brightness);
  }
}