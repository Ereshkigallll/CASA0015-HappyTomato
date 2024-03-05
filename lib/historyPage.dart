import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F1),
      ),
      body: Center(
        child: Text("这是历史页面"),
      ),
      bottomNavigationBar: const FloatingBottomNavigationBar(),
    );
  }
}

class FloatingBottomNavigationBar extends StatelessWidget {
  const FloatingBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;
    return Padding(
      padding: EdgeInsets.only(
          left: 4 * horizontalPadding,
          right: 4 * horizontalPadding,
          bottom: 4 * verticalPadding), // 创建与边缘的间隙
      child: Material(
        // 使用Material来应用阴影
        elevation: 5.0, // 阴影
        borderRadius: const BorderRadius.all(Radius.circular(25.0)), // 圆角
        child: Container(
          height: 70, // 设置导航栏的高度
          decoration: const BoxDecoration(
            color: Color(0xFFCCE5E4), // 设置底部导航栏的背景颜色
            borderRadius: BorderRadius.all(Radius.circular(25.0)), // 圆角边框
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset('assets/icons/history.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFFFF5F1), BlendMode.srcIn),
                    height: 35.0,
                    width: 35.0),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HistoryPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ));
                },
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/home.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFFFF5F1), BlendMode.srcIn),
                    height: 35.0,
                    width: 35.0),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/trend.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFFFF5F1), BlendMode.srcIn),
                    height: 35.0,
                    width: 35.0),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}