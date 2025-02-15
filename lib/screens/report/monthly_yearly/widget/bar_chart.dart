import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> barData;

  const BarChartWidget({super.key, required this.barData});

  @override
  Widget build(BuildContext context) {
    final int currentMonth = DateTime.now().month;

    final barGroups = barData.map((data) {
      final month = data['month'];
      final value = data['value'];
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: month == currentMonth
                ? const Color(0xFFC3D8F8)
                : const Color(0xFFE2E2E2),
            width: 20,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 15, // Y축 최대값
        barGroups: barGroups, // BarChartGroupData 리스트 추가
        gridData: FlGridData(
          show: true, // 격자선 활성화
          drawHorizontalLine: true, // 가로선만 표시
          drawVerticalLine: false, // 세로선 비활성화
          horizontalInterval: 5, // 가로선 간격 (5 단위로 표시)
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0xFFF6F6F6), // 연한 회색 선 색상
              strokeWidth: 1, // 선 두께
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}월',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 28, // 좌측 여백 크기
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}개',
                  style:
                      const TextStyle(color: Color(0xffD9D9D9), fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // 우측 글자 숨김
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // 상단 글자 숨김
          ),
        ),
        borderData: FlBorderData(
          show: true, // 테두리 활성화
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF6F6F6), width: 1), // 아래쪽 테두리
          ),
        ),
      ),
    );
  }
}
