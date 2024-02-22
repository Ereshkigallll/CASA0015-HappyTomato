import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'settings_page.dart';
import 'CountdownPage.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 组件绑定已初始化
  await Firebase.initializeApp( // 初始化 Firebase
    options: DefaultFirebaseOptions.currentPlatform, // 使用默认 Firebase 配置
  );
  runApp(MyApp()); // 运行您的应用
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedTime = "00:00"; // 用于保存从 TomatoClock 选择的时间

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF5F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF5F1),
          leading: Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/landscape.svg',
                colorFilter: const ColorFilter.mode(Color(0xFF4F989E), BlendMode.srcIn),
                height: 35.0,
                width: 35.0,
              ),
              onPressed: () {
                // Landscape icon 的 onPressed 逻辑
              },
            ),
          ),
          actions: <Widget>[
            AppBarIcons(horizontalPadding: 2 * horizontalPadding),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 1 * verticalPadding, bottom: 3 * verticalPadding),
              child: const TextWidget(text: 'HappyTomato'),
            ),
            Container(
              height: 350,
              color: const Color(0xFFFFF5F1),
              child: TomatoClock(
                onTimeSelected: (String time) {
                  setState(() {
                    _selectedTime = time; // 更新选定的时间
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 4 * verticalPadding),
              child: SwitchWithText(
                initialValue: false, // 开关的初始状态
                onChanged: (bool value) {
                  print("Switch is: ${value ? 'ON' : 'OFF'}");
                },
                text: 'Emotion Analysis', // 描述性文本
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2 * verticalPadding),
              child: StartButton(
                text: 'START',
                onTap: () {
                  // 在这里实现按钮按下后的逻辑
                  print('Button pressed');
                },
                selectedTime: _selectedTime, // 传递选定的时间到 StartButton
              ),
            ),
          ],
        ),
        bottomNavigationBar: const FloatingBottomNavigationBar(),
      ),
    );
  }
}


class AppBarIcons extends StatelessWidget {
  final double horizontalPadding;

  const AppBarIcons({
    Key? key,
    required this.horizontalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: horizontalPadding),
          child: Hero(
            // 使用Hero小部件包裹IconButton的icon
            tag: 'settingsIcon', // 为Hero提供一个唯一的标识符（tag）
            flightShuttleBuilder: (
              BuildContext flightContext,
              Animation<double> animation,
              HeroFlightDirection flightDirection,
              BuildContext fromHeroContext,
              BuildContext toHeroContext,
            ) {
              return SvgPicture.asset(
                'assets/icons/setting.svg',
                colorFilter:
                    const ColorFilter.mode(Color(0xFF4F989E), BlendMode.srcIn),
              );
            },
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/setting.svg',
                colorFilter:
                    const ColorFilter.mode(Color(0xFF4F989E), BlendMode.srcIn),
                height: 35.0,
                width: 35.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SettingsPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
        fontSize: 30,
        color: Color(0xFF4F989E), // 指定文字颜色
        fontFamily: 'Inter-Display',
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// Tomato Clock Function
class TomatoClock extends StatefulWidget {
  final Function(String) onTimeSelected; // 新增一个回调函数参数

  const TomatoClock({Key? key, required this.onTimeSelected}) : super(key: key);

  @override
  _TomatoClockState createState() => _TomatoClockState();
}

class _TomatoClockState extends State<TomatoClock> {
  double _progress = 0; // 进度，范围从0到1
  late double _startAngle; // 拖动开始时的角度
  final double _clockSize = 250.0; // 番茄钟的大小，调整为300x300像素
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
      final String formattedTime = _formatTime(_progress);
      widget.onTimeSelected(formattedTime);
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
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度
    final progressPaint = Paint()
      ..color = const Color.fromRGBO(191, 216, 212, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 1.5, sweepAngle, false, progressPaint);

    // 绘制可拖动的小球
    final handlePaint = Paint()
      ..color = const Color.fromRGBO(239, 116, 83, 1)
      ..style = PaintingStyle.fill;
    final handleAngle = 2 * math.pi * progress - (math.pi / 2);
    const handleRadius = 15.0;
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
          onChanged: (bool value) {
            onChanged(value); // 调用外部传入的onChanged回调
            _vibrate(); // 触发震动
          },
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

  void _vibrate() async {
    // 检查设备是否支持震动
    bool canVibrate = await Vibration.hasVibrator() ?? false;
    if (canVibrate) {
      Vibration.vibrate(
        pattern: [0, 50, 0, 50],
        intensities: [0, 50, 0, 255],
      );
    }
  }
}

// Start Buttom
class StartButton extends StatelessWidget {
  final String text;
  final String selectedTime; // 用于接收用户选择的时间
  final VoidCallback onTap;

  const StartButton({
    Key? key,
    required this.text,
    required this.selectedTime, // 在构造函数中接收 selectedTime
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onTap();
        _vibrate(); // 触发震动

        // 打印被选择的时间，用于调试
        print('Selected Time: $selectedTime');
        _saveTimeToRealtimeDatabase(selectedTime);

        // 使用 selectedTime 参数跳转到倒计时页面
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CountdownPage()), // 跳转到倒计时页面
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffEF7453),
        foregroundColor: const Color(0xFFFFF5F1),
        shadowColor: Colors.black,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size(130, 50),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter-Display',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _vibrate() async {
    bool canVibrate = await Vibration.hasVibrator() ?? false;
    if (canVibrate) {
      Vibration.vibrate(duration: 30, amplitude: 128); // 震动50毫秒
    }
  }

  void _saveTimeToRealtimeDatabase(String time) {
  // 使用提供的 URL 初始化 FirebaseDatabase 实例
  final FirebaseDatabase database = FirebaseDatabase(
      databaseURL: 'https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app');
  
  // 获取数据库引用
  DatabaseReference databaseReference = database.reference();

  // 向 "countdowns" 路径推送新数据
  databaseReference.child("countdowns").push().set({
    'selectedTime': time,
    'timestamp': DateTime.now().toIso8601String(), // 使用 ISO8601 字符串格式保存时间戳
  }).then((_) {
    print('Data saved successfully');
  }).catchError((error) {
    print('Failed to save data: $error');
  });
}

}


// bottom navigation bar function
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
