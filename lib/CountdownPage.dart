import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

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
              Center(child: RemainingTimeDisplayWidget()),
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

class RemainingTimeDisplayWidget extends StatefulWidget {
  @override
  _RemainingTimeDisplayWidgetState createState() => _RemainingTimeDisplayWidgetState();
}

class _RemainingTimeDisplayWidgetState extends State<RemainingTimeDisplayWidget> {
  String _remainingTime = "00:00";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchLatestTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fetchLatestTime() {
  final databaseReference = FirebaseDatabase(databaseURL: "https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app").ref("countdowns");

  databaseReference.limitToLast(1).onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    print("Data fetched: $data"); // 打印获取到的数据以供调试

    if (data != null && data.isNotEmpty) {
      final lastEntry = data.values.last;
      if (lastEntry is Map<dynamic, dynamic>) {
        final String selectedTime = lastEntry['selectedTime'];
        print("Selected time: $selectedTime"); // 打印选中的时间以供调试
        _startCountdown(selectedTime);
      } else {
        print("Last entry is not a Map: $lastEntry");
      }
    } else {
      print("Data is null or empty.");
    }
  });
}

  void _startCountdown(String time) {
    final int totalTime = int.parse(time.split(':')[0]) * 60 + int.parse(time.split(':')[1]);
    int currentTime = totalTime;

    setState(() {
      _remainingTime = _formatTime(currentTime);
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentTime > 0) {
        setState(() {
          currentTime--;
          _remainingTime = _formatTime(currentTime);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _remainingTime,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xffEF7453),
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
