import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/activity_provider.dart';
import '../widgets.dart';

class CustomListView extends StatefulWidget {
  const CustomListView({super.key});

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activities = activityProvider.activities;

        if (activities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '아직 기록한 구슬이 없어요!\n활동기록을 작성하고\n구슬을 수집해 보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffB8B8B8),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final startedAt = (activity['startedAt'] as Timestamp?)?.toDate();
            final title = activity['title'] ?? 'No Title';
            final color = activity['color'] ?? 'grey';

            return _buildDateSection(
                startedAt!, title, color, index, activities);
          },
        );
      },
    );
  }

  Widget _buildDateSection(DateTime? date, String title, String color,
      int index, List<Map<String, dynamic>> events) {
    final isFirstInSection = index == 0 ||
        (events[index - 1]['startedAt'] as Timestamp?)?.toDate().month !=
            date?.month ||
        (events[index - 1]['startedAt'] as Timestamp?)?.toDate().year !=
            date?.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFirstInSection)
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              _getYear(date!),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
        ActivityList(
          date: _getDay(date!),
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
