import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../provider/activity_provider.dart';
import '../widgets.dart';

class CalendarBody extends StatefulWidget {
  const CalendarBody({super.key});

  @override
  State<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<CalendarBody> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 상단 달 표시와 버튼
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('MMM').format(_focusedDay)} ${_focusedDay.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            1,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            1,
                          );
                        });
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(30, 0),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDay = DateTime.now();
                          _focusedDay = DateTime.now();
                        });
                      },
                      child: const Text('오늘'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 달력
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerVisible: false,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black),
              weekendStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(10),
              todayDecoration: const BoxDecoration(),
              todayTextStyle: const TextStyle(fontWeight: FontWeight.w700),
              selectedDecoration: BoxDecoration(
                color: Color(0xff9DB2D3).withOpacity(0.47),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
              weekendTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // 선택된 날짜의 Activity 표시
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, activityProvider, child) {
                final activities = activityProvider.activities;

                // Provider에서 이미 startedAt은 DateTime?으로 변환되어 있다고 가정
                final filteredActivities = activities.where((activity) {
                  final DateTime? startedAt =
                      activity['startedAt'] as DateTime?;
                  if (startedAt == null || _selectedDay == null) return false;

                  // 날짜 부분만 비교
                  final startedAtDateOnly = DateTime(
                    startedAt.year,
                    startedAt.month,
                    startedAt.day,
                  );
                  final selectedDayOnly = DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                  );

                  return startedAtDateOnly == selectedDayOnly;
                }).toList();

                return SingleChildScrollView(
                  child: Column(
                    children: filteredActivities.map((activity) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ActivityList(
                          date: _selectedDay != null
                              ? DateFormat('   d (EEE)').format(_selectedDay!)
                              : '',
                          title: activity['title'] ?? 'No Title',
                          color: activity['color'] ?? 'grey',
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
