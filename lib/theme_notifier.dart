import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  ThemeMode _themeMode = ThemeMode.system; // 添加一个变量来存储主题模式

  ThemeNotifier(this._themeData);

  ThemeData get themeData => _themeData;
  ThemeMode get themeMode => _themeMode; // 允许外部获取当前主题模式

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // 新增方法来设置主题模式
  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;

    // 根据不同的主题模式设置不同的主题数据
    switch (themeMode) {
      case ThemeMode.light:
        _themeData = ThemeData.light(); // 这里可以替换为你的自定义亮色主题
        break;
      case ThemeMode.dark:
        _themeData = ThemeData.dark(); // 这里可以替换为你的自定义暗色主题
        break;
      case ThemeMode.system:
        // 这里你可以根据系统主题来决定使用亮色还是暗色主题
        // 例如: _themeData = MediaQuery.of(context).platformBrightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
        // 注意: 这需要你传入BuildContext参数到这个方法或者使用其他方式来获取当前的亮度
        break;
    }

    notifyListeners(); // 通知监听器主题已更改
  }
}
