import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'SettingDarkPage.dart';
import 'SettingEAPage.dart';
import 'SettingDataPage.dart';
import 'SettingHelpPage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 7 * verticalPadding), // 仅顶部添加间隔
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 确保竖直方向上靠上
            children: [
              Center(
                // 使用 Center 确保水平方向上居中
                child: Hero(
                  tag: 'settingsIcon',
                  child: SvgPicture.asset(
                    'assets/icons/setting.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF4F989E), BlendMode.srcIn),
                    width: 30.0 * horizontalPadding,
                    height: 30.0 * horizontalPadding,
                  ),
                ),
              ),
              SizedBox(height: 8 * verticalPadding), // 图标与第一个按钮之间的间隔
              Center(
                // 每个按钮都使用 Center 包裹以确保水平居中
                child: CustomButton(
                    text: 'Theme Mode',
                    onPressed: () {
                      Navigator.of(context)
                          .push(_createRoute(SettingDarkPage()));
                    }),
              ),
              SizedBox(height: 2 * verticalPadding),
              Center(
                child: CustomButton(
                    text: 'Expression Analysis',
                    onPressed: () {
                      Navigator.of(context).push(_createRoute(SettingEAPage()));
                    }),
              ),
              SizedBox(height: 2 * verticalPadding),
              Center(
                child: CustomButton(
                    text: 'Data Analysis',
                    onPressed: () {
                      Navigator.of(context).push(_createRoute(SettingDataPage()));
                    }),
              ),
              SizedBox(height: 2 * verticalPadding),
              Center(
                child: CustomButton(text: 'Help', onPressed: () {Navigator.of(context).push(_createRoute(SettingHelpPage()));}),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget targetPage) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // 新页面初始位置在屏幕右侧
        const end = Offset.zero; // 新页面最终位置
        const curve = Curves.ease; // 动画曲线

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
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
        'Settings',
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

  const CustomButton({
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
      width: 90 * horizontalPadding, // 使用屏幕宽度的比例计算按钮宽度
      height: 9 * verticalPadding, // 使用屏幕高度的比例计算按钮高度
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // 阴影颜色
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 2), // 阴影偏移量
          ),
        ],
        borderRadius: BorderRadius.circular(25.0), // 统一圆角弧度
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F989E), // 统一按钮颜色
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0), // 统一圆角弧度，确保与Container一致
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 5 * horizontalPadding), // 添加水平内边距
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter-Display',
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFF5F1), // 统一文本颜色
              fontSize: 25, // 统一文本大小
            ),
          ),
        ),
      ),
    );
  }
}
