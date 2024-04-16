import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class dataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F1),
      body: Column(
        children: [
          TitleSection(),
          FocusTimeCard(),
        ],
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = screenWidth * 0.01;
    final double verticalPadding = screenHeight * 0.01;
    return Padding(
      padding: EdgeInsets.only(
          top: 8 * verticalPadding, bottom: 4 * verticalPadding),
      child: const Text(
        'Tomato Analysis',
        style: TextStyle(
          color: Color(0xFF4F989E), // 字体颜色
          fontSize: 30, // 字体大小
          fontFamily: 'Inter-Display',
          fontWeight: FontWeight.w800, // 字体粗细
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class FocusTimeCard extends StatefulWidget {
  @override
  _FocusTimeCardState createState() => _FocusTimeCardState();
}

class _FocusTimeCardState extends State<FocusTimeCard> {
  bool isSwitched = false;
  int totalTimeMinutes = 0;
  int totalCountNum = 0; // 总记录条数
  int thisMonthTotalMinutes = 0;
  int thisMonthCount = 0; // 本月记录条数
  int thisWeekTotalMinutes = 0;
  int thisWeekCount = 0; // 本周记录条数
  int todayTotalMinutes = 0;
  int todayCount = 0; // 今日记录条数

  @override
  void initState() {
    super.initState();
    fetchTotalTime();
  }

  void fetchTotalTime() {
    FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://happytomato-591f9-default-rtdb.europe-west1.firebasedatabase.app');
    DatabaseReference ref = database.ref('countdowns');

    DateTime now = DateTime.now();
    DateTime startOfCurrentMonth = DateTime(now.year, now.month);
    DateTime startOfCurrentWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    DateTime startOfToday = DateTime(now.year, now.month, now.day);

    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      int totalMinutes = 0;
      int totalCount = 0;
      int monthMinutes = 0;
      int monthCount = 0;
      int weekMinutes = 0;
      int weekCount = 0;
      int dayMinutes = 0;
      int dayCount = 0;

      if (data != null) {
        data.forEach((key, value) {
          if (value != null &&
              value['selectedTime'] != null &&
              value['timestamp'] != null) {
            DateTime timestamp =
                DateTime.tryParse(value['timestamp']) ?? DateTime.now();
            String time = value['selectedTime'];
            List<String> parts = time.split(':');
            if (parts.length == 2) {
              int minutes = int.tryParse(parts[0]) ?? 0;

              // Accumulate total minutes
              totalMinutes += minutes;
              totalCount++;

              // Check and accumulate for current month
              if (timestamp.isAfter(startOfCurrentMonth) &&
                  timestamp.isBefore(DateTime(now.year, now.month + 1))) {
                monthMinutes += minutes;
                monthCount++;
              }

              // Check and accumulate for current week
              if (timestamp.isAfter(startOfCurrentWeek) &&
                  timestamp
                      .isBefore(startOfCurrentWeek.add(Duration(days: 7)))) {
                weekMinutes += minutes;
                weekCount++;
              }

              // Check and accumulate for today
              if (timestamp.year == now.year &&
                  timestamp.month == now.month &&
                  timestamp.day == now.day) {
                dayMinutes += minutes;
                dayCount++;
              }
            }
          }
        });
      }
      setState(() {
        totalTimeMinutes = totalMinutes;
        totalCountNum = totalCount;
        thisMonthTotalMinutes = monthMinutes;
        thisMonthCount = monthCount;
        thisWeekTotalMinutes = weekMinutes;
        thisWeekCount = weekCount;
        todayTotalMinutes = dayMinutes;
        todayCount = dayCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalPadding = screenWidth * 0.01;

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.32,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFECE3DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isSwitched ? 'Total Tomatoes' : 'Total Focus Time',  // 根据 isSwitched 显示不同的文本
                  style: TextStyle(
                    color: Color(0xffEF7453),
                    fontSize: 22,
                    fontFamily: 'Inter-Display',
                    fontWeight: FontWeight.w800,
                  )),
              AnimatedToggleSwitch<bool>.size(
                current: isSwitched,
                values: [false, true],
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                  if (value) {
                    print("tomato"); // 当开关切换到 true 时打印 "tomato"
                  } else {
                    print("time"); // 当开关切换到 false 时打印 "time"
                  }
                },
                iconBuilder: (value) => value
                    ? SvgPicture.asset(
                        'assets/icons/tomato.svg', // SVG 文件的路径
                        width: 18, // 设置图标的适当尺寸
                        height: 18,
                      )
                    : SvgPicture.asset(
                        'assets/icons/history_1.svg', // SVG 文件的路径
                        width: 18, // 设置图标的适当尺寸
                        height: 18,
                      ),
                animationDuration: Duration(milliseconds: 500),
                animationCurve: Curves.easeInOutCirc,
                indicatorSize: Size.fromWidth(48.0),
                height: 30.0,
                borderWidth: 2.0,
                style: ToggleStyle(
                  backgroundColor: Color(0xffBFD8D4),
                  indicatorColor: Color(0xff5A9DA3),
                  borderRadius: BorderRadius.circular(25.0),
                  indicatorBorderRadius: BorderRadius.circular(25.0),
                  borderColor: Colors.transparent,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeBox(
                        'Until Now',
                        isSwitched ? '$totalCountNum' : '$totalTimeMinutes',
                        screenWidth * 0.4,
                        screenHeight * 0.1),
                    SizedBox(width: horizontalPadding * 3),
                    _buildTimeBox(
                        'This Month',
                        isSwitched
                            ? '$thisMonthCount'
                            : '$thisMonthTotalMinutes',
                        screenWidth * 0.4,
                        screenHeight * 0.1),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeBox(
                        'This Week',
                        isSwitched ? '$thisWeekCount' : '$thisWeekTotalMinutes',
                        screenWidth * 0.4,
                        screenHeight * 0.1),
                    SizedBox(width: horizontalPadding * 3),
                    _buildTimeBox(
                        'Today',
                        isSwitched ? '$todayCount' : '$todayTotalMinutes',
                        screenWidth * 0.4,
                        screenHeight * 0.1),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(
      String period, String time, double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF5A9DA3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              period,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter-Display',
                  fontWeight: FontWeight.w800,
                  color: Color(0xffFFF5F1)),
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, // 确保文本基线对齐
              children: [
                Text(time,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Inter-Display',
                      fontWeight: FontWeight.w800,
                      color: Color(0xffFFF5F1),
                    )),
                !isSwitched ? Text(" Mins",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter-Display',
            fontWeight: FontWeight.w800,
            color: Color(0xffFFF5F1),
          )) : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
