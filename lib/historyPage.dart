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
                    padding: EdgeInsets.only(top: 8 * verticalPadding, bottom: 4 * verticalPadding),
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
    return entries.map<Widget>((entry) {
      DateTime timestamp = DateTime.parse(entry.value['timestamp']);
      return DataCard(
        date: DateFormat('yyyy.MM.dd').format(timestamp),
        time: DateFormat('HH:mm').format(timestamp),
        minutes: _getMinutesFromSelectedTime(entry.value['selectedTime']),
        happiness: 80, // 假定的幸福指数
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
  final int happiness;

  const DataCard(
      {required this.date,
      required this.time,
      required this.minutes,
      required this.happiness});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), // 圆角边框
      color: const Color(0xFF5A9DA3), // 卡片的背景颜色
      margin:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 外边距
      elevation: 5.0, // 设置阴影效果
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        child: Column(
          // 用Column替换原先的Row，使内容垂直排列
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              // 第一行显示年月日和时间
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  date, // 年月日
                  style: const TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  time, // 时间
                  style: const TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // 间距
            const Divider(
              color: Colors.white, // 分隔线的颜色
              thickness: 2.0, // 分隔线的粗细
            ), // 分隔符
            const SizedBox(height: 8), // 间距
            Row(
              // 专注时间行
              children: <Widget>[
                SvgPicture.asset(
                  'assets/icons/duration.svg', // SVG图标路径
                  colorFilter: const ColorFilter.mode(
                      Color(0xFFFFF5F1), BlendMode.srcIn), // 图标颜色
                  width: 24, // 图标宽度
                  height: 24, // 图标高度
                ),
                const SizedBox(width: 20), // 图标与数值之间的距离
                Text(
                  '$minutes', // 时间数值
                  style: const TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10), // 数值与"Minutes"之间的小间距
                const Text(
                  'Minutes', // "Minutes"文字
                  style: TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // 间距
            Row(
              // 幸福指数行，样式与专注时间相似
              children: <Widget>[
                SvgPicture.asset(
                  'assets/icons/superHappy.svg', // 假设使用相同的图标，根据需要替换
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 20),
                Text(
                  '$happiness',
                  style: const TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '% Happiness',
                  style: TextStyle(
                    color: Color(0xFFFFF5F1),
                    fontSize: 16,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
