import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:flutter_pytorch/flutter_pytorch.dart';

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
  GlobalKey<_RemainingTimeDisplayWidgetState> _timerKey =
      GlobalKey<_RemainingTimeDisplayWidgetState>();
  bool _isCountdownActive = false;
  var _model;

  @override
  void initState() {
    super.initState();

    final cameraStateProvider =
        Provider.of<CameraStateProvider>(context, listen: false);

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
    _loadModel();
  }

  void _loadModel() async {
    _model = await FlutterPytorch.loadClassificationModel(
        "assets/models/model_best.pt",
        48, // 宽度，根据您的模型实际输入尺寸调整
        48, // 高度，根据您的模型实际输入尺寸调整
        labelPath: "assets/labels/labels.txt" // 指向您的标签文件的路径，如果模型需要
        );
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
      final firstCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);
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
            title: const Text('Make sure your face is in the centre of the preview window'),
            content: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _controller?.value.isInitialized == true) {
                  return AspectRatio(
                    aspectRatio: 1 / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Confirm'),
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
                  // 使用 GlobalKey 来获取 RemainingTimeDisplayWidget 的状态，并传递 CameraController
                  child: RemainingTimeDisplayWidget(
                    key: _timerKey,
                    cameraController: _controller, // 传递 CameraController
                    model: _model,
                  ),
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
  final ClassificationModel? model; // 添加模型参数
  final CameraController? cameraController;

  const RemainingTimeDisplayWidget({
    Key? key,
    this.cameraController,
    this.model, // 初始化模型参数
  }) : super(key: key);

  @override
  _RemainingTimeDisplayWidgetState createState() =>
      _RemainingTimeDisplayWidgetState();
}

class _RemainingTimeDisplayWidgetState
    extends State<RemainingTimeDisplayWidget> {
  bool _isControllerDisposed = false;
  String _remainingTime = "00:00";
  Timer? _timer;
  int _totalPhotos = 0; // 总的拍摄次数
  int _unhappyPhotos = 0; // 开心的次数
  double unhappyPercentage = 0.0;
  double happyPercentage = 0.0;


  @override
  void initState() {
    super.initState();
    _fetchLatestTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _photoTimer?.cancel();
    _isControllerDisposed = true; // 添加这一行

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

  Timer? _photoTimer; // 用于拍照操作的计时器

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
            'HappyPercentage': happyPercentage,
          });

          print(
              'Finish data and happy percentage updated successfully with value 1 and $happyPercentage%');
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
                        backgroundColor:  const Color(0xFF4F989E),
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
    // 如果提供了摄像头控制器，则每10秒拍摄一次
    if (widget.cameraController != null) {
      _photoTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        // 检查 CameraController 是否已经被销毁
        if (!_isControllerDisposed &&
            widget.cameraController != null &&
            widget.cameraController!.value.isInitialized) {
          try {
            final image = await widget.cameraController!.takePicture();
            _saveImageToGallery(File(image.path));
          } catch (e) {
            print("拍摄出错：$e");
          }
        }
      });
    }
  }

  Future<void> _saveImageToGallery(File imageFile) async {
    // 读取图片文件为 Image 对象
    img.Image? originalImage = img.decodeImage(imageFile.readAsBytesSync());
    if (originalImage != null) {
      // 逆时针旋转 90 度，注意：这里需要设置正确的旋转角度
      img.Image rotatedImage = img.copyRotate(originalImage, angle: 0);

      // 计算裁剪尺寸和开始点，以实现中心裁剪为 1:1 长宽比
      int size = min(rotatedImage.width, rotatedImage.height);
      int startX = (rotatedImage.width - size) ~/ 2;
      int startY = (rotatedImage.height - size) ~/ 2;

      // 中心裁剪为 1:1 长宽比
      img.Image croppedImage = img.copyCrop(rotatedImage,
          x: startX, y: startY, width: size, height: size);

      // 调整图像尺寸为 48x48
      img.Image resizedImage =
          img.copyResize(croppedImage, width: 48, height: 48);

      // 将裁剪后的图像编码为 JPG
      Uint8List jpg = img.encodeJpg(resizedImage);

if (widget.model != null) {
  final tempDir = await getTemporaryDirectory();
  File tempImageFile = File('${tempDir.path}/temp_image.jpg')
    ..writeAsBytesSync(jpg);

  if (!tempImageFile.existsSync()) {
    return;
  }

  try {
    Uint8List imageBytes = await tempImageFile.readAsBytes();

    // 假设类别的顺序是: angry, disgust, fear, happy, neutral, sad, surprise
    List<double?>? predictionList =
        await widget.model?.getImagePredictionListProbabilities(imageBytes);
    if (predictionList != null && predictionList.length >= 6) {
      // 获取happy和sad的预测概率
      double happyProbability = predictionList[2] ?? 0; // happy的索引为3
      double sadProbability = predictionList[5] ?? 0;   // sad的索引为5

      // 如果sad的概率高于happy，更新unhappyPhotos计数器
      if (sadProbability > happyProbability) {
        _unhappyPhotos++;
      }

      _totalPhotos++; // 更新总照片数

      // 计算不开心的百分比
      unhappyPercentage = (_unhappyPhotos / _totalPhotos) * 100;
      // 计算开心的百分比
      happyPercentage = 100 - unhappyPercentage;
    } else {
      print('预测列表长度不足以提供happy和sad的概率');
    }
  } catch (e) {
    print('情感识别出错：$e');
  } finally {
    await tempImageFile.delete();
    print('临时图像文件已删除');
  }
}

    }
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
