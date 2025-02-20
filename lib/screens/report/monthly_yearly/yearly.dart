import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widget/bar_chart.dart';
import 'widget/date_selector.dart';
import 'widget/pie_chart.dart';

class YearlyReportPage extends StatefulWidget {
  final String selectedUnit;

  const YearlyReportPage({required this.selectedUnit, super.key});

  @override
  State<YearlyReportPage> createState() => _YearlyReportPageState();
}

class _YearlyReportPageState extends State<YearlyReportPage> {
  List<Map<String, dynamic>> pieData = [];

  final List<Map<String, dynamic>> barData = [
    {'month': 1, 'value': 16},
    {'month': 2, 'value': 2},
    {'month': 3, 'value': 7},
    {'month': 4, 'value': 9},
    {'month': 5, 'value': 3},
    {'month': 6, 'value': 2},
    {'month': 7, 'value': 3},
    {'month': 8, 'value': 0},
    {'month': 9, 'value': 0},
    {'month': 10, 'value': 9},
    {'month': 11, 'value': 1},
    {'month': 12, 'value': 4},
  ];

  @override
  void initState() {
    super.initState();
    fetchPieData();
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
        return Colors.grey; // 기본 색상
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
          const YearlyStepper(),
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
                YearlyPieChart(pieData: pieData, selectedUnit: null,),
                YearlyLegend(pieData: pieData, selectedUnit: null,),
                const SizedBox(width: 20),
              ],
            ),
          ),
          const SizedBox(height: 30),

          /// 월별 기록 (막대 그래프)
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
                const SizedBox(height: 30),
                SizedBox(
                  height: 200,
                  child: BarChartWidget(barData: barData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
