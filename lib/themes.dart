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
const Color darkPrimaryColor = Color(0xFF1F1F1F);
const Color darkButtonColor2 = Color(0xFF37474F);
const Color darkBottomNavigationBarColor = Color(0xFF222222);
const Color darkTextColorPrimary = Color(0xFFE0E0E0);
const Color darkTextColorSecondary = Color(0xFFBDBDBD);
const Color darkIconColorPrimary = Color(0xFFE0E0E0);
const Color darkIconColorSecondary = Color(0xFFBDBDBD);

// 亮色主题定义
final ThemeData lightTheme1 = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: backgroundColor,
  primaryColor: backgroundColor,
  colorScheme: ColorScheme.light(
    primary: backgroundColor,
    secondary: backgroundColor, // 替代以前的accentColor
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: backgroundColor,
    selectedItemColor: backgroundColor,
    unselectedItemColor: backgroundColor,
  ),
  textTheme: TextTheme(
    bodyText1: TextStyle(color: textColorPrimary),
    bodyText2: TextStyle(color: textColorSecondary),
  ),
  iconTheme: IconThemeData(
    color: iconColorPrimary,
  ),
);

// 暗色主题定义
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackgroundColor,
  primaryColor: darkPrimaryColor,
  colorScheme: ColorScheme.dark(
    primary: darkPrimaryColor,
    secondary: darkPrimaryColor, // 替代以前的accentColor
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: darkPrimaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkPrimaryColor,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkBottomNavigationBarColor,
    selectedItemColor: darkPrimaryColor,
    unselectedItemColor: darkIconColorSecondary,
  ),
  textTheme: TextTheme(
    bodyText1: TextStyle(color: darkTextColorPrimary),
    bodyText2: TextStyle(color: darkTextColorSecondary),
  ),
  iconTheme: IconThemeData(
    color: darkIconColorPrimary,
  ),
);
