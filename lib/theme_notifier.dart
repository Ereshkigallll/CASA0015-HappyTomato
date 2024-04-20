import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testapp/themes.dart';

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
          colorScheme: const ColorScheme.light(
            primary: Color(0xffEF7453), // 主按钮和组件颜色
            secondary: Color(0xFF4F989E), // 次要颜色或其他交互元素颜色
            background: Color(0xFFFFF5F1), // 背景色
            surface: Color(0xFFFFF5F1), // 表面色，如卡片、对话框背景
            onPrimary: Colors.white, // 用于在主色上的文本颜色
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF5F1), // 设置脚手架背景色
          appBarTheme: const AppBarTheme(
            color: Color(0xFFFFF5F1), // 设置应用栏颜色
          ),
        );
        break;
      case ThemeMode.dark:
        _themeData = ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4F989E), // 主按钮和组件颜色
            secondary: Color(0xFF4F989E), // 次要颜色或其他交互元素颜色
            background: Color(0xFF1A1A1A), // 背景色
            surface: Color(0xFF1A1A1A), // 表面色
            onPrimary: Colors.white, // 用于在主色上的文本颜色
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1A1A), // 设置脚手架背景色
          appBarTheme: const AppBarTheme(
            color: Color(0xFF1A1A1A), // 设置应用栏颜色
          ),
        );
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
