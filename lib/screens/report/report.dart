import 'package:flutter/material.dart';

import 'monthly_yearly/report_monthly.dart';
import 'monthly_yearly/report_yearly.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool isMonthly = true;
  String selectedMonth = DateTime.now().month.toString();
  String selectedYear = DateTime.now().year.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계 및 분석'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSegmentControl(),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: isMonthly
                    ? MonthlyReportPage(selectedUnit: selectedMonth)
                    : YearlyReportPage(selectedUnit: selectedYear),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Segment Button
  Widget _buildSegmentControl() {
    return Container(
      width: 289,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xffC9D6EA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: AnimatedAlign(
              alignment:
                  isMonthly ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 190),
              child: Container(
                width: 143,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSegmentButton('월간', true),
              _buildSegmentButton('연간', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String text, bool isLeft) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMonthly = isLeft;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 143,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
