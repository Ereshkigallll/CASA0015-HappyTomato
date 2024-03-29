import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() => runApp(MaterialApp(
    home: CountdownPage(emotionModel: 'assets/models/model_best.pt')));

class CountdownPage extends StatefulWidget {
  final dynamic emotionModel; // 添加字段来接收传递的模型

  CountdownPage({Key? key, required this.emotionModel}) : super(key: key);

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  GlobalKey<_RemainingTimeDisplayWidgetState> _timerKey = GlobalKey<_RemainingTimeDisplayWidgetState>();
  bool _isCountdownActive = false;

  @override
void initState() {
  super.initState();

  final cameraStateProvider = Provider.of<CameraStateProvider>(context, listen: false);

  // 只有当表情分析功能启用时，才初始化摄像头并显示弹窗
  if (cameraStateProvider.isCameraEnabled) {
    _requestAndInitializeCamera().then((_) {
      if (mounted) {
        _showCameraPreviewDialog();
      }
    });
  } else {
    // 表情分析功能关闭时，直接激活倒计时
    setState(() {
      _isCountdownActive = true;
    });
  }
}


  Future<void> _requestAndInitializeCamera() async {
    // 请求摄像头权限
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    if (cameraStatus.isGranted) {
      // 获取可用的摄像头列表
      final cameras = await availableCameras();
      // 获取前置摄像头
      final firstCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
      // 创建摄像头控制器
      _controller = CameraController(firstCamera, ResolutionPreset.medium);
      // 初始化控制器
      _initializeControllerFuture = _controller!.initialize();
    } else {
      // 处理权限未被授予的情况
      print('Camera permission was denied.');
    }
  }

  void _showCameraPreviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击弹窗外部关闭
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // 禁止通过返回按钮关闭弹窗
          child: AlertDialog(
            title: Text('请确认自己的脸在预览窗口中'),
            content: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && _controller?.value.isInitialized == true) {
                  return AspectRatio(
                    aspectRatio: 1 / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭弹窗
                  setState(() {
                    _isCountdownActive = true; // 激活倒计时
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose(); // 释放摄像头资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double verticalPadding = screenHeight * 0.01;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF5F1), // 从图片提取的背景色
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 在水平方向上居中对齐
            mainAxisAlignment: MainAxisAlignment.start, // 在竖直方向上靠上对齐
            children: [
              SizedBox(height: 20 * verticalPadding), // 顶部间距
              const Center(child: TimeLeftLabelWidget()), // 显示 "Time Left"
              SizedBox(height: 5 * verticalPadding), // 添加一些间距
              if (_isCountdownActive) // 根据_isCountdownActive的值来决定是否显示倒计时组件
                Center(
                  // 使用 GlobalKey 来获取 RemainingTimeDisplayWidget 的状态
                  child: RemainingTimeDisplayWidget(key: _timerKey),
                ),
              SizedBox(height: 7 * verticalPadding), // 添加一些间距
              const Center(child: AnalyzingEmotionTextWidget()),
              SizedBox(height: 10 * verticalPadding), // 添加一些间距
              Center(
                child: DestroyTomatoButton(
                  onDestroy: () {
                    // 调用 RemainingTimeDisplayWidget 中的方法来停止计时器
                    _timerKey.currentState?.stopTimer();
                  },
                ),
              ),
              const SizedBox(height: 8), // 底部间距
            ],
          ),
        ),
      ),
    );
  }
}

class TimeLeftLabelWidget extends StatelessWidget {
  const TimeLeftLabelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Time Left',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: 'Inter-Display',
          color: Color(0xFF4F989E), // 文字颜色
          fontSize: 50, // 文字大小适当调整
          fontWeight: FontWeight.w800 // 加粗
          ),
    );
  }
}

class RemainingTimeDisplayWidget extends StatefulWidget {
  const RemainingTimeDisplayWidget({super.key});

  @override
  _RemainingTimeDisplayWidgetState createState() =>
      _RemainingTimeDisplayWidgetState();
}

class _RemainingTimeDisplayWidgetState
    extends State<RemainingTimeDisplayWidget> {
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
    final databaseReference = FirebaseDatabase(
            databaseURL:
                "https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app")
        .ref("countdowns");

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
    final int totalTime =
        int.parse(time.split(':')[0]) * 60 + int.parse(time.split(':')[1]);
    int currentTime = totalTime;

    setState(() {
      _remainingTime = _formatTime(currentTime);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (currentTime > 0) {
        setState(() {
          currentTime--;
          _remainingTime = _formatTime(currentTime);
        });
      } else {
        timer.cancel();
        // 更新数据库
        final FirebaseDatabase database = FirebaseDatabase(
            databaseURL:
                'https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app');
        DatabaseReference databaseReference = database.ref('countdowns');

        // 查询最新的一条记录
        DataSnapshot snapshot =
            await databaseReference.orderByKey().limitToLast(1).get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          String latestKey = data.keys.first; // 获取最新记录的键

          // 更新最新记录，添加Finish数据为1
          await databaseReference.child(latestKey).update({
            'Finish': 1,
          });

          print('Finish data updated successfully with value 1');
        } else {
          print('No data found');
        }
        // 倒计时结束，展示弹窗
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF5F1),
              title: const Text(
                'Congratulations!',
                style: TextStyle(
                    fontFamily: 'Inter-Display',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xffEF7453)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min, // 使Column的大小仅包裹其子内容
                children: <Widget>[
                  const Text(
                    'You got a fresh tomato!',
                    style: TextStyle(
                        fontFamily: 'Inter-Display',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffEF7453)),
                  ),
                  const SizedBox(height: 20), // 添加一些间距
                  Center(
                    // 使用Center小部件使按钮居中
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF4F989E),
                      ),
                      child: const Text(
                        'Take the Tomato',
                        style: TextStyle(
                          color: Color(0xFFFFF5F1),
                          fontFamily: 'Inter-Display',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // 关闭弹窗
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_remainingTime,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter-Display',
              color: Color(0xffEF7453),
              fontSize: 90,
              fontWeight: FontWeight.w800,
            )),
      ],
    );
  }
}

class AnalyzingEmotionTextWidget extends StatelessWidget {
  const AnalyzingEmotionTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Analysing Your Emotion...',
        style: TextStyle(
            fontFamily: 'Inter-Display',
            color: Color(0xFF4F989E), // 从图片提取的颜色
            fontSize: 24,
            fontWeight: FontWeight.w800),
      ),
    );
  }
}

class DestroyTomatoButton extends StatelessWidget {
  final VoidCallback onDestroy;

  const DestroyTomatoButton({
    super.key,
    required this.onDestroy, // 接受回调函数
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 弹出确认弹窗
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF5F1), // 设置弹窗背景颜色
              title: const Center(
                child: Text(
                  'Destroy Tomato',
                  style: TextStyle(
                      fontFamily: 'Inter-Display',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xffEF7453)),
                ),
              ),
              content: const Text(
                'Are you really going to destroy this lovely tomato? This tomato will wilt!',
                style: TextStyle(
                    fontFamily: 'Inter-Display',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffEF7453)),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      // 使用Padding小部件为取消按钮添加外边距
                      padding: const EdgeInsets.only(left: 20.0), // 仅在左侧添加外边距
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF4F989E),
                        ),
                        child: const Text(
                          'No',
                          style: TextStyle(
                            color: Color(0xFFFFF5F1),
                            fontFamily: 'Inter-Display',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭弹窗
                        },
                      ),
                    ),
                    Padding(
                      // 使用Padding小部件为确定按钮添加外边距
                      padding: const EdgeInsets.only(right: 20.0), // 仅在右侧添加外边距
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffEF7453),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Color(0xFFFFF5F1),
                            fontFamily: 'Inter-Display',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: () async {
                          onDestroy();
                          // 使用提供的 URL 初始化 FirebaseDatabase 实例
                          final FirebaseDatabase database = FirebaseDatabase(
                              databaseURL:
                                  'https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app');

                          // 获取数据库引用
                          DatabaseReference databaseReference =
                              database.ref('countdowns');

                          // 查询最新的一条记录
                          DataSnapshot snapshot = await databaseReference
                              .orderByKey()
                              .limitToLast(1)
                              .get();

                          if (snapshot.exists) {
                            Map<dynamic, dynamic> data =
                                snapshot.value as Map<dynamic, dynamic>;
                            String latestKey = data.keys.first; // 获取最新记录的键

                            // 更新最新记录，添加Finish数据
                            await databaseReference.child(latestKey).update({
                              'Finish': 0,
                            });

                            print('Finish data updated successfully');
                          } else {
                            print('No data found');
                          }

                          Navigator.of(context).pop(); // 关闭弹窗
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffEF7453),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // 圆角按钮
        ),
        elevation: 5, // 设置按钮阴影的高度
        shadowColor: const Color(0xFF000000),
      ),
      child: const Text(
        'Destroy This Tomato',
        style: TextStyle(
          fontFamily: 'Inter-Display',
          color: Color(0xFFFFF5F1), // 从图片提取的颜色
          fontSize: 18,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              // 阴影1
              offset: Offset(2.0, 2.0),
              blurRadius: 5.0,
              color: Color.fromARGB(123, 63, 60, 60),
            ),
          ],
        ),
      ),
    );
  }
}
