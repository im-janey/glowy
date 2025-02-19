import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(Set<DateTime>) onDaysSelected;
  final DateTime initialFocusedDay;
  final Set<DateTime> initiallySelectedDays; // 초기에 선택된 날짜들

  const CalendarWidget({
    super.key,
    required this.onDaysSelected,
    required this.initialFocusedDay,
    this.initiallySelectedDays = const {},
    required Null Function(DateTime date) onDaySelected,
    required bool Function(DateTime day) enabledDayPredicate,
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Set<DateTime> _selectedDates;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDates = {...widget.initiallySelectedDays};
    _focusedDay = widget.initialFocusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(1900),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return _selectedDates
                .any((selectedDay) => isSameDay(selectedDay, day));
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_selectedDates.contains(selectedDay)) {
                _selectedDates.remove(selectedDay);
              } else {
                _selectedDates.add(selectedDay);
              }
              _focusedDay = focusedDay;
            });
            widget.onDaysSelected(_selectedDates);
          },
          calendarFormat: CalendarFormat.month,
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            defaultDecoration: const BoxDecoration(
              color: Color(0xffEEEDF0),
              shape: BoxShape.circle,
            ),
            weekendDecoration: const BoxDecoration(
              color: Color(0xffEEEDF0),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: const Color(0xff9DB2D3).withOpacity(0.47),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: const Color(0xff9DB2D3).withOpacity(0.47),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            todayTextStyle: TextStyle(
              color: Colors.grey[600]!,
              fontWeight: FontWeight.bold,
            ),
            cellMargin: const EdgeInsets.all(4),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            weekendStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          rowHeight: 40,
          daysOfWeekHeight: 30,
          headerVisible: false,
          availableGestures: AvailableGestures.none,
        ),
      ],
    );
  }
}
