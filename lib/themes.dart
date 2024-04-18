import 'package:flutter/material.dart';

// 定义颜色常量
const Color lightBackgroundColor = Color(0xFFFFF5F1);
const Color lightPrimaryColor = Color(0xffEF7453);
const Color lightTextColorPrimary = Color(0xffEF7453);
const Color lightTextColorSecondary = Color(0xFFFFF5F1);
const Color lightIconColorSecondary = Color(0xFF4F989E);

const Color darkBackgroundColor = Color(0xFF0F1C2E);
const Color darkPrimaryColor = Color(0xFF1F1F1F);
const Color darkTextColorPrimary = Color(0xFFE0E0E0);
const Color darkTextColorSecondary = Color(0xFFBDBDBD);
const Color darkIconColorSecondary = Color(0xFFBDBDBD);

// 亮色主题定义
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: lightBackgroundColor,
  primaryColor: lightPrimaryColor,
  appBarTheme: const AppBarTheme(
    color: lightBackgroundColor,
    elevation: 0,
  ),
  colorScheme: const ColorScheme.light(
    primary: lightPrimaryColor,
    secondary: lightIconColorSecondary,
    background: lightBackgroundColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: lightTextColorSecondary,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: lightPrimaryColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: lightBackgroundColor,
    selectedItemColor: lightPrimaryColor,
    unselectedItemColor: lightTextColorSecondary,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(color: lightTextColorPrimary), // bodyText1 替换为 subtitle1
    bodyMedium: TextStyle(color: lightTextColorSecondary),
  ),
  iconTheme: const IconThemeData(
    color: lightIconColorSecondary,
  ),
);

// 暗色主题定义
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackgroundColor,
  primaryColor: darkPrimaryColor,
  appBarTheme: const AppBarTheme(
    color: darkBackgroundColor,
    elevation: 0,
  ),
  colorScheme: const ColorScheme.dark(
    primary: darkPrimaryColor,
    secondary: darkIconColorSecondary,
    background: darkBackgroundColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: darkTextColorSecondary,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: darkPrimaryColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkBackgroundColor,
    selectedItemColor: darkPrimaryColor,
    unselectedItemColor: darkIconColorSecondary,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(color: darkTextColorPrimary), // bodyText1 替换为 subtitle1
    bodyMedium: TextStyle(color: darkTextColorSecondary),
  ),
  iconTheme: const IconThemeData(
    color: darkIconColorSecondary,
  ),
);
