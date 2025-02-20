import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/home/home.dart';
import '../screens/my_page/profile.dart';
import '../screens/record/record.dart';
import '../screens/report/report.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const ReportPage(),
    const HomePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: _pages[_selectedIndex],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: (index) => index != 1 ? _onItemTapped(index) : null,
                  selectedItemColor: const Color(0xFF33568C),
                  unselectedItemColor: const Color(0xFFdbdbdb),
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/nav/report.svg',
                        color: _selectedIndex == 0
                            ? const Color(0xFF33568C)
                            : const Color(0xFFdbdbdb),
                      ),
                      label: '리포트',
                    ),
                    const BottomNavigationBarItem(
                      icon: IgnorePointer(
                        // 가운데 아이템 영역 터치를 막는다
                        ignoring: true,
                        child: SizedBox.shrink(),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/nav/my_page.svg',
                        color: _selectedIndex == 2
                            ? const Color(0xFF33568C)
                            : const Color(0xFFdbdbdb),
                      ),
                      label: '마이페이지',
                    ),
                  ],
                ),
                Positioned(
                  top: -12,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(1),
                    child: CircleAvatar(
                      radius: 27.5,
                      backgroundColor: _selectedIndex == 1
                          ? const Color(0xff33568C)
                          : const Color(0xFFdbdbdb),
                      child: SvgPicture.asset(
                        'assets/nav/home.svg',
                        color: Colors.white,
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                ),
                if (_selectedIndex == 1)
                  Positioned(
                    top: -12,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RecordPage()),
                      ),
                      child: const CircleAvatar(
                        radius: 27.5,
                        backgroundColor: Color(0xff33568C),
                        child: Icon(Icons.add, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
