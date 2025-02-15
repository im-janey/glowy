import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String initialFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterDropdown({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedFilter,
      items: const [
        DropdownMenuItem(
          value: '최신순',
          child: Text('최신순'),
        ),
        DropdownMenuItem(
          value: '과거순',
          child: Text('과거순'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedFilter = value;
          });
          widget.onFilterChanged(value);
        }
      },
    );
  }
}
