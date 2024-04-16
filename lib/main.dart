import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'settings_page.dart';
import 'CountdownPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'historyPage.dart';
import 'dataPage.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 加载保存的主题选择
  final prefs = await SharedPreferences.getInstance();
  final selectedThemeIndex =
      prefs.getInt('selectedThemeIndex') ?? 0; // 默认使用系统主题

  ThemeMode initialThemeMode = ThemeMode.system; // 默认为系统主题
  ThemeData initialThemeData = ThemeData.light(); // 默认主题数据

  if (selectedThemeIndex == 1) {
    initialThemeMode = ThemeMode.light;
    initialThemeData = lightTheme1; // 你的自定义亮色主题
  } else if (selectedThemeIndex == 2) {
    initialThemeMode = ThemeMode.dark;
    initialThemeData = darkTheme; // 你的自定义暗色主题
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                ThemeNotifier(initialThemeData, initialThemeMode)),
        ChangeNotifierProvider(
            create: (context) => ModelProvider()), // 添加ModelProvider
        ChangeNotifierProvider(create: (context) => CameraStateProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _selectedTime = "00:00"; // 用于保存从 TomatoClock 选择的时间
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    // 当 ThemeMode 为 system 时，根据系统亮度变化更新主题
    if (themeNotifier.themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      themeNotifier.updateThemeForSystemBrightness(brightness);
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return buildMainContent();
      case 1:
        return HistoryPage();
      case 2:
        return dataPage();
      default:
        return buildMainContent();
    }
  }

  Widget buildMainContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    // 返回现有的主页内容 Column Widget
    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: const Color(0xFFFFF5F1),
          leading: Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/landscape.svg',
                colorFilter:
                    const ColorFilter.mode(Color(0xFF4F989E), BlendMode.srcIn),
                height: 35.0,
                width: 35.0,
              ),
              onPressed: () {
                // Landscape icon 的 onPressed 逻辑
              },
            ),
          ),
          actions: <Widget>[
            AppBarIcons(horizontalPadding: 1 * horizontalPadding),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 1.5 * verticalPadding),
          child: const TextWidget(text: 'HappyTomato'),
        ),
        Container(
          height: 350,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TomatoClock(
            onTimeSelected: (String time) {
              setState(() {
                _selectedTime = time; // 更新选定的时间
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 2 * verticalPadding, bottom: 4 * verticalPadding),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    Widget _currentScreen = _getPage(_selectedIndex);

    return MaterialApp(
        theme: themeNotifier.themeData,
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF5F1),
          body: Stack(
            children: <Widget>[
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _currentScreen,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FloatingBottomNavigationBar(
                  onNavigate: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class CameraStateProvider with ChangeNotifier {
  bool _isCameraEnabled = false;

  bool get isCameraEnabled => _isCameraEnabled;

  void enableCamera() {
    _isCameraEnabled = true;
    notifyListeners();
  }

  void disableCamera() {
    _isCameraEnabled = false;
    notifyListeners();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

class ModelProvider with ChangeNotifier {
  dynamic emotionModel;
  bool isModelLoaded = false;

  Future<void> loadModel() async {
    // 加载模型
    emotionModel = await FlutterPytorch.loadClassificationModel(
    "assets/models/model_best.pt",
    48, // 模型预期的输入图像的宽度
    48, // 模型预期的输入图像的高度
    labelPath: "assets/labels/labels.txt" // 如果您的模型需要标签文件，提供标签文件的路径
  );
    isModelLoaded = true;
    print('Model loaded successfully.');
    notifyListeners(); // 通知监听器模型已加载
  }

  void unloadModel() {
    // 释放模型资源
    emotionModel = null;
    isModelLoaded = false;
    print('Model unloaded.');
    notifyListeners(); // 通知监听器模型已卸载
  }
}

// 自定义的开关Widget
class SwitchWithText extends StatefulWidget {
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
  _SwitchWithTextState createState() => _SwitchWithTextState();
}

class _SwitchWithTextState extends State<SwitchWithText> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LiteRollingSwitch(
          width: 100.0,
          value: widget.initialValue,
          textOn: 'ON',
          textOff: 'OFF',
          colorOn: Color(0xffBFD8D4),
          colorOff: Color(0xffEF7453),
          iconOn: Icons.done,
          iconOff: Icons.power_settings_new,
          animationDuration: Duration(milliseconds: 500),
          onChanged: (bool value) async {
            final modelProvider =
                Provider.of<ModelProvider>(context, listen: false);
            final cameraStateProvider =
                Provider.of<CameraStateProvider>(context, listen: false);
            if (value) {
              cameraStateProvider.enableCamera();
              await modelProvider.loadModel();
            } else {
              cameraStateProvider.disableCamera();
              modelProvider.unloadModel();
            }
            widget.onChanged(value); // 调用外部传入的onChanged回调
            _vibrate(); // 触发震动
          },
          onTap: () {}, // 为空的回调函数
          onDoubleTap: () {}, // 为空的回调函数
          onSwipe: () {}, // 为空的回调函数
        ),
        SizedBox(width: 8), // 添加一些间隔
        Text(
          widget.text,
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
        if (selectedTime == '00:00') {
          // 如果 selectedTime 为 0，则显示提示窗口
          _vibrate();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFFFF5F1),
                content: const Text(
                  'Please Select Time',
                  textAlign: TextAlign.center, // 文字居中
                  style: TextStyle(
                    color: Color(0xffEF7453), // 修改文字颜色
                    fontFamily: 'Inter-Display', // 修改字体
                    fontSize: 24, // 修改字体大小
                    fontWeight: FontWeight.w800, // 修改字体粗细
                  ),
                ),
                actions: <Widget>[
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF4F989E),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // 关闭提示窗口
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xFFFFF5F1), // 修改按钮中文字的颜色
                          fontFamily: 'Inter-Display', // 修改按钮中文字的字体
                          fontSize: 20,
                          fontWeight: FontWeight.w800, // 修改按钮中文字的大小
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          onTap();
          _vibrate(); // 触发震动
          print('Selected Time: $selectedTime');
          _saveTimeToRealtimeDatabase(selectedTime);
          final modelProvider =
              Provider.of<ModelProvider>(context, listen: false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CountdownPage(emotionModel: modelProvider.emotionModel),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffEF7453), // 修改按钮的背景颜色
        shadowColor: Colors.black,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(130, 50), // 调整按钮的大小
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter-Display', // 修改文字的字体
          fontSize: 20, // 修改文字的大小
          fontWeight: FontWeight.bold, // 修改文字的粗细
          color: Color(0xFFFFF5F1), // 修改文字的颜色
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
    if (time != '0') {
      final FirebaseDatabase database = FirebaseDatabase(
          databaseURL:
              'https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app');
      DatabaseReference databaseReference = database.reference();
      databaseReference.child("countdowns").push().set({
        'selectedTime': time,
        'timestamp': DateTime.now().toIso8601String(),
      }).then((_) {
        print('Data saved successfully');
      }).catchError((error) {
        print('Failed to save data: $error');
      });
    }
  }
}

// bottom navigation bar function
class FloatingBottomNavigationBar extends StatelessWidget {
  final Function(int) onNavigate; // 添加一个回调函数

  const FloatingBottomNavigationBar({
    super.key,
    required this.onNavigate, // 需要一个回调函数
  });

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
                onPressed: () => onNavigate(1),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/home.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFFFF5F1), BlendMode.srcIn),
                    height: 35.0,
                    width: 35.0),
                onPressed: () => onNavigate(0),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/trend.svg',
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFFFF5F1), BlendMode.srcIn),
                    height: 35.0,
                    width: 35.0),
                onPressed: () => onNavigate(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}