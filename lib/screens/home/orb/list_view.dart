import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/activity_provider.dart';
import '../widgets.dart';

class CustomListView extends StatefulWidget {
  final String sortOrder; // "최신순" 또는 "과거순" 등

  const CustomListView({super.key, required this.sortOrder, required List<Map<String, dynamic>> activities});

  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activities = [...activityProvider.activities];

        if (activities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '아직 기록한 구슬이 없어요!\n활동기록을 작성하고\n구슬을 수집해 보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB8B8B8),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 60),
                Text('기록이 없습니다.'),
              ],
            ),
          );
        }

        // --- 필터별 정렬 ---
        if (widget.sortOrder == '최신순') {
          // (1) 연/월 내림차순, (2) 같은 월이면 일 오름차순
          activities.sort((a, b) {
            final dateA = a['startedAt'] as DateTime;
            final dateB = b['startedAt'] as DateTime;

            final yearMonthA = dateA.year * 12 + dateA.month;
            final yearMonthB = dateB.year * 12 + dateB.month;

            // 1) 연월 비교 (내림차순)
            final compareYearMonth = yearMonthB.compareTo(yearMonthA);
            if (compareYearMonth != 0) {
              return compareYearMonth;
            }

            // 2) 같은 연월이면, 일은 오름차순
            return dateA.day.compareTo(dateB.day);
          });
        } else {
          // "과거순": 그냥 전체 DateTime 오름차순 예시
          activities.sort((a, b) {
            final dateA = a['startedAt'] as DateTime;
            final dateB = b['startedAt'] as DateTime;
            return dateA.compareTo(dateB);
          });
        }

        // 정렬된 활동 리스트 렌더링
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final startedAt = activity['startedAt'] as DateTime?;
            final title = activity['title'] ?? 'No Title';
            final color = activity['color'] ?? 'grey';

            return _buildDateSection(
              startedAt!,
              title,
              color,
              index,
              activities,
            );
          },
        );
      },
    );
  }

  Widget _buildDateSection(
    DateTime date,
    String title,
    String color,
    int index,
    List<Map<String, dynamic>> events,
  ) {
    final DateTime? prevDate =
        index > 0 ? events[index - 1]['startedAt'] : null;

    // 달이 바뀔 때마다 헤더(연도/월) 표시
    final isFirstInSection = index == 0 ||
        prevDate == null ||
        prevDate.year != date.year ||
        prevDate.month != date.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFirstInSection)
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              _getYear(date),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
        ActivityList(
          date: _getDay(date),
          title: title,
          color: color,
        ),
      ],
    );
  }

  String _getYear(DateTime date) {
    return '${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getDay(DateTime date) {
    return '${date.day} (${_getWeekday(date.weekday)})';
  }

  String _getWeekday(int weekday) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return weekdays[weekday - 1];
  }
}
