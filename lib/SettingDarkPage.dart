import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_notifier.dart';
import 'package:provider/provider.dart';

class SettingDarkPage extends StatefulWidget {
  const SettingDarkPage({Key? key}) : super(key: key);

  @override
  _SettingDarkPageState createState() => _SettingDarkPageState();
}

class _SettingDarkPageState extends State<SettingDarkPage> {
  int _selectedDarkIndex = 1;
  static const String selectedButtonIndexKey = 'selectedDarkIndex';

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDarkIndex = prefs.getInt(selectedButtonIndexKey) ?? 0;
    });
  }

  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedButtonIndexKey, index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    return Scaffold(
      appBar: const CustomAppBar(), // 确保您已经有了CustomAppBar的实现
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 7 * verticalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/icons/settingDark.svg', // 使用适用于暗黑模式设置的图标
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF4F989E), BlendMode.srcIn),
                  width: 30.0 * horizontalPadding,
                  height: 30.0 * horizontalPadding,
                ),
              ),
              SizedBox(height: 8 * verticalPadding),
              _buildButton(0, 'Follow System'),
              _buildButton(1, 'Light By Default'),
              _buildButton(2, 'Dark By Default'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(int index, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 2 * MediaQuery.of(context).size.width * 0.01),
      child: CustomButton(
        text: text,
        isSelected: _selectedDarkIndex == index,
        onPressed: () async {
          if (_selectedDarkIndex != index) {
            // 只有在主题改变时才更新
            setState(() {
              _selectedDarkIndex = index;
            });
            await _saveSelectedIndex(index);

            ThemeMode selectedMode = _getThemeModeFromIndex(index);

            final themeNotifier =
                Provider.of<ThemeNotifier>(context, listen: false);
            if (themeNotifier.themeMode != selectedMode) {
              // 避免重复设置相同的主题模式
              themeNotifier.setThemeMode(selectedMode);
              if (selectedMode == ThemeMode.system) {
                themeNotifier.applySystemTheme();
              }

              // 提供用户反馈
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Theme changed to $text"),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
    );
  }

  ThemeMode _getThemeModeFromIndex(int index) {
    switch (index) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/back.svg', // 请确保使用正确的图标文件
          colorFilter:
              const ColorFilter.mode(Color(0xFF4F989E), BlendMode.srcIn),
          width: 30.0, // 根据实际情况调整大小
          height: 30.0,
        ),
        onPressed: () {
          Navigator.of(context).pop(); // 返回上一页
        },
      ),
      title: const Text(
        'Theme Mode',
        style: TextStyle(
          color: Color(0xFF4F989E), // 文本颜色
          fontFamily: 'Inter-Display', // 字体
          fontWeight: FontWeight.w800,
          fontSize: 24, // 字体大小
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected; // 新增参数，用于控制对勾的显示

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isSelected = false, // 默认未选中
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    return Container(
      width: 90 * horizontalPadding,
      height: 9 * verticalPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F989E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5 * horizontalPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter-Display',
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFF5F1),
                  fontSize: 25,
                ),
              ),
            ),
            if (isSelected) // 如果按钮被选中，显示对勾图标
              SvgPicture.asset(
                'assets/icons/tick.svg',
                colorFilter:
                    const ColorFilter.mode(Color(0xFFFFF5F1), BlendMode.srcIn),
                width: 24.0,
                height: 24.0,
              ),
          ],
        ),
      ),
    );
  }
}
