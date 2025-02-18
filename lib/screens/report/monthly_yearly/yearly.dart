import 'package:flutter/material.dart';

import 'widget/bar_chart.dart';
import 'widget/button.dart';
import 'widget/pie_chart.dart';

class YearlyReportPage extends StatefulWidget {
  final String selectedUnit;

  const YearlyReportPage({required this.selectedUnit, super.key});

  @override
  State<YearlyReportPage> createState() => _YearlyReportPageState();
}

class _YearlyReportPageState extends State<YearlyReportPage> {
  final List<Map<String, dynamic>> pieData = [
    {'color': const Color(0xffFFB7B2), 'label': '동아리', 'value': 3},
    {'color': const Color(0xffC3D8F8), 'label': '봉사', 'value': 3},
    {'color': const Color(0xffFFD4F8), 'label': '공부', 'value': 2},
    {'color': const Color(0xffCEECFF), 'label': '독서', 'value': 2},
    {'color': const Color(0xffD9FEB5), 'label': '여행', 'value': 1},
    {'color': const Color(0xffCCB8FE), 'label': '공모전', 'value': 1},
  ];

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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16.0), // ✅ 전체 여백 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepperWidget(),
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
                YearlyPieChart(pieData: pieData),
                YearlyLegend(pieData: pieData),
                const SizedBox(width: 20),
              ],
            ),
          ),
          const SizedBox(height: 40),

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
                const Text(
                  "월별 기록",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChartWidget(barData: barData),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
