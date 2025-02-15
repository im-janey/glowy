import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  const DropdownWidget({super.key});

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String selectedMonth = DateTime.now().month.toString();

  final List<String> months =
      List.generate(12, (index) => (index + 1).toString());

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
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
          setState(() {
            selectedMonth = newValue!;
          });
        },
        items: months.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text('$value월'),
          );
        }).toList(),
      ),
    );
  }
}

class StepperWidget extends StatefulWidget {
  const StepperWidget({super.key});

  @override
  _StepperWidgetState createState() => _StepperWidgetState();
}

class _StepperWidgetState extends State<StepperWidget> {
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
