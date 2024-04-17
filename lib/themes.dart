import 'package:flutter/material.dart';

// 亮色主题颜色
const Color backgroundColor = Color(0xFFFFF5F1);
const Color primaryColor = Color(0xffEF7453);
const Color buttonColor2 = Color(0xFF4F989E);
const Color bottomNavigationBarColor = Color(0xFFCCE5E4);
const Color textColorPrimary = Color(0xffEF7453);
const Color textColorSecondary = Color(0xFFFFF5F1);
const Color iconColorPrimary = Color(0xFFFFF5F1);
const Color iconColorSecondary = Color(0xFF4F989E);

// 暗色主题颜色占位符
const Color darkBackgroundColor = Color(0xFF0F1C2E);
const Color darkPrimaryColor = Color(0xFF0F1C2E);
const Color darkButtonColor2 = Color(0xFF0F1C2E);
const Color darkBottomNavigationBarColor = Color(0xFF0F1C2E);
const Color darkTextColorPrimary = Color(0xFF0F1C2E);
const Color darkTextColorSecondary = Color(0xFF0F1C2E);
const Color darkIconColorPrimary = Color(0xFF0F1C2E);
const Color darkIconColorSecondary = Color(0xFF0F1C2E);

// 亮色主题定义
final ThemeData lightTheme1 = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: backgroundColor,
  primaryColor: primaryColor,
  appBarTheme: AppBarTheme(
    color: backgroundColor, // 设置AppBar的背景颜色
    elevation: 0, // 可以根据需要设置阴影
  ),
  colorScheme: const ColorScheme.light(
    primary: backgroundColor,
    secondary: backgroundColor,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: backgroundColor,
    selectedItemColor: backgroundColor,
    unselectedItemColor: backgroundColor,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(color: textColorPrimary),
    bodyText2: TextStyle(color: textColorSecondary),
  ),
  iconTheme: const IconThemeData(
    color: iconColorPrimary,
  ),
);

// 暗色主题定义
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackgroundColor,
  primaryColor: darkPrimaryColor,
  appBarTheme: const AppBarTheme(
    color: darkBackgroundColor, // 设置AppBar的背景颜色
    elevation: 0, // 可以根据需要设置阴影
  ),
  colorScheme: const ColorScheme.dark(
    primary: darkPrimaryColor,
    secondary: darkPrimaryColor,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: darkPrimaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: darkPrimaryColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkBottomNavigationBarColor,
    selectedItemColor: darkPrimaryColor,
    unselectedItemColor: darkIconColorSecondary,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(color: darkTextColorPrimary),
    bodyText2: TextStyle(color: darkTextColorSecondary),
  ),
  iconTheme: const IconThemeData(
    color: darkIconColorPrimary,
  ),
);
