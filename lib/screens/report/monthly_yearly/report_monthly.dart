import 'package:flutter/material.dart';

import 'widget/button.dart';
import 'widget/calendar.dart';
import 'widget/pie_chart.dart';

class MonthlyReportPage extends StatefulWidget {
  final String selectedUnit;

  const MonthlyReportPage({required this.selectedUnit, super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  final List<Map<String, dynamic>> pieData = [
    {'color': const Color(0xffFFB7B2), 'label': '동아리', 'value': 3},
    {'color': const Color(0xffC3D8F8), 'label': '봉사', 'value': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DropdownWidget(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Spacer(),
                PieChartWidget(pieData: pieData),
                const Spacer(),
                LegendWidget(pieData: pieData),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "일별 기록",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: CalendarWidget(
                    onDaySelected: (DateTime) {},
                    initialFocusedDay: DateTime.now(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
