import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> pieData;
  final String selectedUnit; // (1) selectedUnit 파라미터 추가

  const MonthlyPieChart({
    super.key,
    required this.pieData,
    required this.selectedUnit, // (2) 생성자에 반영
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: PieChart(
        PieChartData(
          sections: pieData
              .map((data) => PieChartSectionData(
                    color: data['color'],
                    value: data['value'].toDouble(),
                    radius: 29,
                    showTitle: false,
                  ))
              .toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 49,
        ),
      ),
    );
  }
}

class MonthlyLegend extends StatelessWidget {
  final List<Map<String, dynamic>> pieData;
  final String selectedUnit; // (1) selectedUnit 파라미터 추가

  const MonthlyLegend({
    super.key,
    required this.pieData,
    required this.selectedUnit, // (2) 생성자에 반영
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pieData
          .where((data) => data['value'] > 0)
          .map((data) => Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: data['color'],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 65,
                    child: Expanded(
                      child: Row(
                        children: [
                          Text(
                            data['label'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            '${data['value'].toInt()}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}

class YearlyPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> pieData;
  final dynamic selectedUnit;

  const YearlyPieChart({
    super.key,
    required this.pieData,
    required this.selectedUnit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: PieChart(
        PieChartData(
          sections: pieData
              .map((data) => PieChartSectionData(
                    color: data['color'],
                    value: data['value'].toDouble(),
                    radius: 29,
                    showTitle: false,
                  ))
              .toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 49,
        ),
      ),
    );
  }
}

class YearlyLegend extends StatelessWidget {
  final List<Map<String, dynamic>> pieData;
  final dynamic selectedUnit;

  const YearlyLegend({
    super.key,
    required this.pieData,
    required this.selectedUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pieData
          .where((data) => data['value'] > 0)
          .map((data) => Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: data['color'],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 65,
                    child: Expanded(
                      child: Row(
                        children: [
                          Text(
                            data['label'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            '${data['value'].toInt()}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}
