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
            crossAxisAlignment: CrossAxisAlignment.center, // 在水平方向上居中对齐
            mainAxisAlignment: MainAxisAlignment.start, // 在竖直方向上靠上对齐
            children: [
              SizedBox(height: 8), // 顶部间距
              Center(child: TimeLeftLabelWidget()), // 显示 "Time Left"
              SizedBox(height: 8), // 添加一些间距
              Center(child: RemainingTimeDisplayWidget(time: '57:48')), // 显示剩余时间，'57:48' 是示例时间
              SizedBox(height: 8), // 添加一些间距
              Center(child: AnalyzingEmotionTextWidget()),
              SizedBox(height: 8), // 添加一些间距
              Center(child: DestroyTomatoButton()),
              SizedBox(height: 8), // 底部间距
            ],
          ),
        ),
      ),
    );
  }
}


class TimeLeftLabelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Time Left',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF4F989E), // 文字颜色
        fontSize: 24, // 文字大小适当调整
        fontWeight: FontWeight.bold, // 加粗
      ),
    );
  }
}

class RemainingTimeDisplayWidget extends StatelessWidget {
  final String time;

  RemainingTimeDisplayWidget({required this.time});

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xffEF7453), // 文字颜色与 "Time Left" 保持一致
        fontSize: 48, // 保持较大的字体大小以突出显示时间
        fontWeight: FontWeight.bold, // 加粗
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
