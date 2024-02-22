import 'package:flutter/material.dart';
import 'main.dart';

void main() => runApp(CountdownPage());

class CountdownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFFFF5F1), // 从图片提取的背景色
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimeDisplayWidget(time: '57:48'), // 假设时间是动态的
              AnalyzingEmotionTextWidget(),
              DestroyTomatoButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeDisplayWidget extends StatelessWidget {
  final String time;

  TimeDisplayWidget({required this.time});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Time Left\n$time',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF4F989E), // 从图片提取的颜色
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class AnalyzingEmotionTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Analysing Your Emotion...',
        style: TextStyle(
          color: Color(0xFF4F989E), // 从图片提取的颜色
          fontSize: 24,
        ),
      ),
    );
  }
}

class DestroyTomatoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: 实现按钮功能
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Color(0xffEF7453), // 从图片提取的颜色
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18), // 圆角按钮
        ),
      ),
      child: Text(
        'Destroy This Tomato',
        style: TextStyle(
          color: Color(0xFFFFF5F1), // 从图片提取的颜色
          fontSize: 18,
        ),
      ),
    );
  }
}
