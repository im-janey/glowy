import 'package:flutter/material.dart';

import 'calendar/calendar_body.dart';
import 'category/grid.dart';
import 'orb/orb_body.dart';
import 'search/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: _showCalendar
                ? const ImageIcon(
                    AssetImage('assets/icon/orb.png'),
                  )
                : const Icon(Icons.calendar_month_outlined),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
          ),
        ),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: Colors.white,
              shadowColor: Colors.black26,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            child: IconButton(
              icon: Image.asset('assets/icon/more.png', width: 20, height: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryGridPage()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: _showCalendar ? const CalendarBody() : const OrbBody(),
    );
  }
}
