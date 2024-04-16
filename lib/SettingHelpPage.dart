import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_browser/web_browser.dart'; // 引入 web_browser 包

class SettingHelpPage extends StatelessWidget {
  const SettingHelpPage({Key? key}) : super(key: key);

  // 用于在应用内打开浏览器的方法
  void _openBrowser(BuildContext context, String url) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BrowserPage(url: url)));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F1),
      appBar: const CustomAppBar(), // 确保您已经有了CustomAppBar的实现
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 7 * verticalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/icons/help.svg', // 使用适用于帮助页面的图标
                  colorFilter: const ColorFilter.mode(Color(0xFF4F989E), BlendMode.srcIn),
                  width: 30.0 * horizontalPadding,
                  height: 30.0 * horizontalPadding,
                ),
              ),
              SizedBox(height: 8 * verticalPadding),
              Button(
                text: 'Github Repository',
                onPressed: () => _openBrowser(context, 'https://github.com/Ereshkigallll/CASA0015-HappyTomato/tree/main'),
              ),
              SizedBox(height: 2 * verticalPadding),
              Button(
                text: 'Personal Website',
                onPressed: () => _openBrowser(context, 'https://ereshkigallll.github.io/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrowserPage extends StatelessWidget {
  final String url;

  const BrowserPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebBrowser(
          initialUrl: url,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFF5F1),
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
        'Help',
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


class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const Button({
    Key? key,
    required this.text,
    required this.onPressed,
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter-Display',
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFF5F1),
              fontSize: 25, // 字体大小根据实际情况调整
            ),
          ),
        ),
      ),
    );
  }
}
