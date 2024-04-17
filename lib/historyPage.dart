import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // 用于格式化日期时间

class HistoryPage extends StatelessWidget {
  final FirebaseDatabase database = FirebaseDatabase(
    databaseURL:
        'https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app',
  );

  @override
  Widget build(BuildContext context) {
    DatabaseReference databaseReference = database.ref().child("countdowns");
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F1),
      body: FutureBuilder<DataSnapshot>(
        future: databaseReference.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('数据加载出错'));
          } else if (snapshot.hasData && snapshot.data!.value != null) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(snapshot.data!.value as Map);
            // 转换数据为列表并排序
            List<Widget> listItems = _convertAndSortData(data);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8 * verticalPadding, bottom: 4 * verticalPadding),
                    child: const Text(
                      'Tomato History',
                      style: TextStyle(
                        color: Color(0xFF4F989E), // 字体颜色
                        fontSize: 30, // 字体大小
                        fontFamily: 'Inter-Display',
                        fontWeight: FontWeight.w800, // 字体粗细
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...listItems,
                ],
              ),
            );
          } else {
            return Center(child: Text('没有数据'));
          }
        },
      ),
    );
  }

  // 转换并排序数据
  List<Widget> _convertAndSortData(Map<String, dynamic> data) {
    List<MapEntry<String, dynamic>> entries = data.entries.toList();

    // 排序，根据时间戳从新到旧
    entries.sort((a, b) {
      DateTime timestampA = DateTime.parse(a.value['timestamp']);
      DateTime timestampB = DateTime.parse(b.value['timestamp']);
      return timestampB.compareTo(timestampA); // 从新到旧排序
    });

    // 转换为Widget列表
    // 转换为Widget列表
    return entries.map<Widget>((entry) {
      DateTime timestamp = DateTime.parse(entry.value['timestamp']);
      String happiness; // 修改为String类型，用于显示处理后的数值
      if (entry.value.containsKey('HappyPercentage')) {
        // 先转换为double
        double happyPercentage =
            double.parse(entry.value['HappyPercentage'].toString());
        // 转换为字符串，保留一位小数
        happiness = happyPercentage.toStringAsFixed(1);
      } else {
        // 如果没有HappyPercentage，则显示特定的信息
        happiness = "Emotion Analysis Disabled";
      }

      return DataCard(
        date: DateFormat('yyyy.MM.dd').format(timestamp),
        time: DateFormat('HH:mm').format(timestamp),
        minutes: _getMinutesFromSelectedTime(entry.value['selectedTime']),
        happiness: happiness, // 使用处理后的字符串值
      );
    }).toList();
  }

  int _getMinutesFromSelectedTime(String selectedTime) {
    List<String> parts = selectedTime.split(":");
    return int.parse(parts[0]) + int.parse(parts[1]);
  }
}

class DataCard extends StatelessWidget {
  final String date;
  final String time;
  final int minutes;
  final String happiness; // 将类型改为String

  const DataCard({
    required this.date,
    required this.time,
    required this.minutes,
    required this.happiness,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: const Color(0xFF5A9DA3),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white, thickness: 2.0),
            const SizedBox(height: 8),
            buildMinutesRow(),
            const SizedBox(height: 12),
            buildHappinessRow(),
          ],
        ),
      ),
    );
  }

  Widget buildMinutesRow() {
    return Row(
      children: <Widget>[
        SvgPicture.asset(
          'assets/icons/duration.svg',
          colorFilter:
              const ColorFilter.mode(Color(0xFFFFF5F1), BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 20),
        Text(
          '$minutes',
          style: const TextStyle(
            color: Color(0xFFFFF5F1),
            fontSize: 16,
            fontFamily: 'Inter-Display',
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Minutes',
          style: TextStyle(
            color: Color(0xFFFFF5F1),
            fontSize: 16,
            fontFamily: 'Inter-Display',
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  String getHappinessIcon(String happiness) {
    if (happiness == "Emotion Analysis Disabled") {
      return 'assets/icons/disabled.svg'; // 假设neutral.svg是表情识别未开启的图标
    }

    double happinessValue = double.parse(happiness.replaceAll('%', ''));
    if (happinessValue >= 0 && happinessValue <= 25) {
      return 'assets/icons/nothappy.svg'; // 假设sad.svg是0-25%的图标
    } else if (happinessValue <= 50) {
      return 'assets/icons/notnothappy.svg'; // 假设lessHappy.svg是26-50%的图标
    } else if (happinessValue <= 75) {
      return 'assets/icons/happy.svg'; // 假设happy.svg是51-75%的图标
    } else {
      return 'assets/icons/superHappy.svg'; // 假设superHappy.svg是76-100%的图标
    }
  }

  Widget buildHappinessRow() {
    String iconPath = getHappinessIcon(happiness);

    return Row(
      children: <Widget>[
        SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 20),
        Text(
          happiness != "Emotion Analysis Disabled"
              ? '$happiness%     Happiness'
              : 'Emotion Analysis Disabled',
          style: const TextStyle(
            color: Color(0xFFFFF5F1),
            fontSize: 16,
            fontFamily: 'Inter-Display',
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
