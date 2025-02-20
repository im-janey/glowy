import 'package:flutter/material.dart';

class MonthlyDropdown extends StatefulWidget {
  final Function(String) onMonthChanged;

  const MonthlyDropdown({required this.onMonthChanged, super.key});

  @override
  State<MonthlyDropdown> createState() => _MonthlyDropdownState();
}

class _MonthlyDropdownState extends State<MonthlyDropdown> {
  String selectedMonth = DateTime.now().month.toString();

  final List<String> months =
      List.generate(12, (index) => (index + 1).toString());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMonth,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
              size: 25,
            ),
            elevation: 16,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedMonth = newValue;
                });
                widget.onMonthChanged(newValue);
              }
            },
            items: months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('$value월'),
              );
            }).toList(),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}

class YearlyStepper extends StatefulWidget {
  const YearlyStepper({super.key});

  @override
  _YearlyStepperState createState() => _YearlyStepperState();
}

class _YearlyStepperState extends State<YearlyStepper> {
  int selectedYear = DateTime.now().year;

  void _incrementYear() {
    setState(() {
      selectedYear++;
    });
  }

  void _decrementYear() {
    setState(() {
      selectedYear--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left, size: 24, color: Colors.black),
          onPressed: _decrementYear,
        ),
        Text(
          '$selectedYear년',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right, size: 24, color: Colors.black),
          onPressed: _incrementYear,
        ),
      ],
    );
  }
}
