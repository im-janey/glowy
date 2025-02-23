import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widget/calendar.dart';
import 'widget/date_selector.dart';
import 'widget/pie_chart.dart';

class MonthlyReportPage extends StatefulWidget {
  final String selectedUnit;

  const MonthlyReportPage({required this.selectedUnit, super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  List<Map<String, dynamic>> pieData = [];
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    fetchPieData();
  }

  void updateSelectedMonth(String month) {
    setState(() {
      selectedMonth = int.parse(month);
    });
  }

  Future<void> fetchPieData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) return;
      final data = doc.data()!;

      List<Map<String, dynamic>> tempData = [];

      for (var key in data.keys) {
        if (data[key]['title'] == '전체') continue;

        Color categoryColor = await fetchCategoryColor(data[key]['color']);
        int activityCount = await fetchActivityCount(key, uid);

        tempData.add({
          'color': categoryColor,
          'label': data[key]['title'],
          'value': activityCount,
        });
      }

      setState(() {
        pieData = tempData;
      });
    } catch (e) {
      debugPrint('Error fetching pie chart data: ${e.toString()}');
    }
  }

  Future<Color> fetchCategoryColor(String colorName) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('colors')
          .doc(colorName)
          .get();

      if (!doc.exists) {
        return Colors.grey;
      }

      final data = doc.data() as Map<String, dynamic>;
      return Color(int.parse("0xFF${data['hexColor']}"));
    } catch (e) {
      debugPrint('Error fetching color: $e');
      return Colors.grey;
    }
  }

  Future<int> fetchActivityCount(String categoryId, String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('activities')
          .where('uid', isEqualTo: uid)
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching activity count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MonthlyDropdown(onMonthChanged: updateSelectedMonth),

          const SizedBox(height: 16),

          /// 파이 차트 위젯
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MonthlyPieChart(pieData: pieData),
                MonthlyLegend(pieData: pieData),
                const SizedBox(width: 20),
              ],
            ),
          ),
          const SizedBox(height: 30),

          /// 일별 기록 (캘린더)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarWidget(
                  onDaySelected: (DateTime date) {
                    debugPrint('Selected Date: $date'); // 선택된 날짜 출력
                  },
                  initialFocusedDay: DateTime.now(),
                  onDaysSelected: (Set<DateTime> selectedDates) {
                    debugPrint('Selected Dates: $selectedDates');
                  },
                  initiallySelectedDays: {
                    DateTime(DateTime.now().year, 2, 3), // 2월 3일
                    DateTime(DateTime.now().year, 2, 7), // 2월 7일
                  },
                  enabledDayPredicate: (DateTime day) {
                    return {
                      DateTime(DateTime.now().year, 2, 3),
                      DateTime(DateTime.now().year, 2, 7),
                    }.contains(DateTime(day.year, day.month, day.day));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
