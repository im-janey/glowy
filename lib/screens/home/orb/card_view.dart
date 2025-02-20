import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/activity_provider.dart';
import '../widgets.dart';

class CustomCardView extends StatefulWidget {
  // (1) sortOrder를 받아오기 위한 필드 추가
  final String sortOrder;

  const CustomCardView({
    super.key,
    required this.sortOrder, required List<Map<String, dynamic>> activities,
  });

  @override
  State<CustomCardView> createState() => _CustomCardViewState();
}

class _CustomCardViewState extends State<CustomCardView> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        // activities를 복사해 정렬하기 전에 작업
        final List<Map<String, dynamic>> activities = [
          ...activityProvider.activities
        ];

        // (2) sortOrder에 따라 정렬 로직 적용
        if (widget.sortOrder == '최신순') {
          // 예: "연/월 내림차순 & 같은 달이면 날짜 오름차순" (필요에 따라 변경)
          activities.sort((a, b) {
            final dateA = a['startedAt'] as DateTime;
            final dateB = b['startedAt'] as DateTime;

            final yearMonthA = dateA.year * 12 + dateA.month;
            final yearMonthB = dateB.year * 12 + dateB.month;

            // 1) 연/월 비교 (내림차순)
            final compareYearMonth = yearMonthB.compareTo(yearMonthA);
            if (compareYearMonth != 0) {
              return compareYearMonth;
            }

            // 2) 같은 연월이면, 일(day)은 오름차순
            return dateA.day.compareTo(dateB.day);
          });
        } else if (widget.sortOrder == '과거순') {
          // 전체 DateTime 오름차순
          activities.sort((a, b) {
            final dateA = a['startedAt'] as DateTime;
            final dateB = b['startedAt'] as DateTime;
            return dateA.compareTo(dateB);
          });
        }

        // (3) 정렬된 목록이 비어있는지 체크
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/initiate.png'),
                const SizedBox(height: 60),
              ],
            ),
          );
        }

        // (4) 정렬된 activities를 사용하여 카드뷰(GridView) 구성
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 한 행에 2개씩
            crossAxisSpacing: 16, // 가로 간격
            mainAxisSpacing: 16.0, // 세로 간격
            childAspectRatio: 0.8, // 카드 세로비
          ),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final title = activity['title'] ?? '기본 제목';
            final color = activity['color'] ?? 'grey';

            return Align(
              alignment: Alignment.center,
              child: ActivityCard(
                title: title,
                color: color,
              ),
            );
          },
        );
      },
    );
  }
}
