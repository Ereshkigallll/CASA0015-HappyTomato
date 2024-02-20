import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF5F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF5F1),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: SvgPicture.asset('assets/icons/landscape.svg',
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF4F989E), BlendMode.srcIn),
                  height: 35.0,
                  width: 35.0),
              onPressed: () {},
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: SvgPicture.asset('assets/icons/setting.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF4F989E), BlendMode.srcIn),
                    height: 35.0,
                    width: 35.0),
                onPressed: () {},
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 50.0),
              child: TextWidget(text: 'HappyTomato'),
            ),
            Container(
              height: 350,
              color: const Color(0xFFFFF5F1),
              child: const TomatoClock(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: SwitchWithText(
                initialValue: false, // 开关的初始状态
                onChanged: (bool value) {
                  // 这里处理开关状态改变的逻辑
                  print("Switch is: ${value ? 'ON' : 'OFF'}");
                },
                text: 'Emotion Analysis', // 描述性文本
              ),
            ),
          ],
        ),
        bottomNavigationBar: const FloatingBottomNavigationBar(),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String text;

  const TextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 40,
        color: Color(0xFF4F989E), // 指定文字颜色
        fontFamily: 'Inter-Display',
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// Tomato Clock Function
class TomatoClock extends StatefulWidget {
  const TomatoClock({super.key});

  @override
  _TomatoClockState createState() => _TomatoClockState();
}

class _TomatoClockState extends State<TomatoClock> {
  double _progress = 0; // 进度，范围从0到1
  late double _startAngle; // 拖动开始时的角度
  final double _clockSize = 300.0; // 番茄钟的大小，调整为300x300像素
  int _lastVibratedMinute = -1; // 上一次震动时的分钟数

  @override
  void initState() {
    super.initState();
    _startAngle = 0.0;
  }

  void _onPanStart(Offset localPosition) {
    _startAngle = math.atan2(localPosition.dy - _clockSize / 2,
            localPosition.dx - _clockSize / 2) -
        (2 * math.pi * _progress);
  }

  void _updateProgress(Offset localPosition) {
    final angle = math.atan2(
        localPosition.dy - _clockSize / 2, localPosition.dx - _clockSize / 2);
    final newProgress = (angle - _startAngle) / (2 * math.pi);

    setState(() {
      _progress = newProgress % 1.0;
      if (_progress < 0) {
        _progress = 1.0 + _progress;
      }
    });

    // 计算当前分钟数
    final int totalMinutes = (_progress * 60).round();
    if (totalMinutes != _lastVibratedMinute) {
      // 如果分钟数发生变化，则触发震动
      _vibrate();
      // 更新上一次震动时的分钟数
      _lastVibratedMinute = totalMinutes;
    }
  }

  Future<void> _vibrate() async {
    bool canVibrate =
        await Vibration.hasVibrator() ?? false; // 如果返回null，则默认为false
    if (canVibrate) {
      Vibration.vibrate(duration: 10); // 设置震动时长为50毫秒
    }
  }

  String _formatTime(double progress) {
    if (progress >= 0.98) {
      return '60:00'; // 当进度接近1时，直接显示60:00
    }
    final int totalMinutes = (progress * 60).round();
    final int minutes = totalMinutes % 60;
    return '${minutes.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTime(_progress);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F1),
      body: Center(
        child: GestureDetector(
          onPanStart: (details) => _onPanStart(details.localPosition),
          onPanUpdate: (details) => _updateProgress(details.localPosition),
          child: Container(
            width: _clockSize,
            height: _clockSize,
            child: CustomPaint(
              painter: ClockPainter(_progress, formattedTime),
            ),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double progress;
  final String formattedTime;

  ClockPainter(this.progress, this.formattedTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制背景
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度
    final progressPaint = Paint()
      ..color = const Color.fromRGBO(191, 216, 212, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;
    double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 1.5, sweepAngle, false, progressPaint);

    // 绘制可拖动的小球
    final handlePaint = Paint()
      ..color = const Color.fromRGBO(239, 116, 83, 1)
      ..style = PaintingStyle.fill;
    final handleAngle = 2 * math.pi * progress - (math.pi / 2);
    const handleRadius = 20.0;
    final handleCenter = Offset(math.cos(handleAngle) * radius + center.dx,
        math.sin(handleAngle) * radius + center.dy);
    canvas.drawCircle(handleCenter, handleRadius, handlePaint);

    // 绘制时间文本
    final textSpan = TextSpan(
      text: formattedTime,
      style: const TextStyle(
          color: Color.fromRGBO(239, 116, 83, 1),
          fontSize: 40,
          fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = Offset((size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 自定义的开关Widget
class SwitchWithText extends StatelessWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final String text;

  const SwitchWithText({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LiteRollingSwitch(
          width: 100.0,
          value: initialValue,
          textOn: 'ON',
          textOff: 'OFF',
          colorOn: Color(0xffBFD8D4),
          colorOff: Color(0xffEF7453),
          iconOn: Icons.done,
          iconOff: Icons.power_settings_new,
          animationDuration: Duration(milliseconds: 500),
          onChanged: onChanged,
          onTap: () {}, // 传递空的回调函数
          onDoubleTap: () {}, // 传递空的回调函数
          onSwipe: () {}, // 传递空的回调函数
        ),
        SizedBox(width: 8), // 添加一些间隔
        Text(
          text,
          style: const TextStyle(
              fontFamily: 'Inter-Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F989E)),
        ),
      ],
    );
  }
}

// bottom navigation bar function
class FloatingBottomNavigationBar extends StatelessWidget {
  const FloatingBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 创建与边缘的间隙
      child: Material(
        // 使用Material来应用阴影
        elevation: 10.0, // 阴影
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
                onPressed: () {},
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
