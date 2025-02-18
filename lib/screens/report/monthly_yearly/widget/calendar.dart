import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDaySelected;
  final DateTime initialFocusedDay;

  const CalendarWidget({
    super.key,
    required this.onDaySelected,
    required this.initialFocusedDay,
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialFocusedDay;
    _focusedDay = widget.initialFocusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(1900),
          lastDay: DateTime(2100),
          // 현재 보여지는 달력의 포커스 날짜.
          focusedDay: _focusedDay,
          // 달력에서 선택된 날짜를 표시하기 위한 조건.
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDate, day);
          },
          // 날짜 선택 시 호출되는 콜백 함수.
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected(selectedDay);
          },
          // 달력의 형식을 월간(month)으로 설정.
          calendarFormat: CalendarFormat.month,
          // 페이지를 넘길 때(onPageChanged) 포커스된 날짜를 업데이트.
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            // 셀 주변 원형
            defaultDecoration: const BoxDecoration(
              color: Color(0xffEEEDF0),
              shape: BoxShape.circle,
            ),
            // 주말도
            weekendDecoration: const BoxDecoration(
              color: Color(0xffEEEDF0),
              shape: BoxShape.circle,
            ),
            // 오늘 날짜의 스타일을 설정.
            todayDecoration: BoxDecoration(
              color: const Color(0xff9DB2D3).withOpacity(0.47),
              shape: BoxShape.circle,
            ),

            // 선택된 날짜의 스타일을 설정.
            selectedDecoration: BoxDecoration(
              color: const Color(0xff9DB2D3).withOpacity(0.47), // `const` 제거
              shape: BoxShape.circle,
            ),
            // 기본 날짜 텍스트 스타일.
            defaultTextStyle: TextStyle(
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
            // 주말 텍스트 스타일.
            weekendTextStyle: TextStyle(
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
            // 선택된 텍스트 스타일.
            selectedTextStyle: TextStyle(
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
            // 오늘 날짜 텍스트 스타일.
            todayTextStyle: TextStyle(
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
            // 각 날짜 셀 주변의 여백을 추가.
            cellMargin: const EdgeInsets.all(4),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600], // 요일 텍스트 색상을 회색으로 설정
            ),
            weekendStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[600], // 주말 텍스트 색상을 회색으로 설정
            ),
          ),
          // 날짜 행의 높이 설정
          rowHeight: 40, // 기본값: 52. 이 값을 줄이면 간격이 줄어듭니다.
          // 요일 라벨의 높이 설정
          daysOfWeekHeight: 30, // 기본값: 16. 필요에 따라 값을 줄이거나 늘리세요.
          // 달력의 헤더(월, 연도 표시 영역)를 숨김.
          headerVisible: false,
          availableGestures: AvailableGestures.none,
        ),
      ],
    );
  }
}
