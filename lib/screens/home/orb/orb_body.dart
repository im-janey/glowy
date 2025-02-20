import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/activity_provider.dart'; // ActivityProvider 임포트
import '../../../provider/category_provider.dart';
import '../widgets.dart';
import 'card_view.dart';
import 'filter.dart';
import 'list_view.dart';

class OrbBody extends StatefulWidget {
  const OrbBody({super.key});

  @override
  State<OrbBody> createState() => _OrbBodyState();
}

class _OrbBodyState extends State<OrbBody> {
  String selectedTitle = '';
  bool _showList = false;
  String _selectedFilter = '최신순';

  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드되면 ActivityProvider의 실시간 구독 시작 (또는 fetchActivities() 사용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);
      activityProvider.listenToActivities();
      // activityProvider.fetchActivities(); // 실시간이 아닌 1회성 조회를 원하면 이쪽
    });
  }

  Widget buildActivitiesRow(List<Map<String, dynamic>> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final title = category['title'] ?? 'No Title';
          final color = category['color'] ?? 'grey';
          final isSelected = selectedTitle == title;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CategoryCard(
              title: title,
              color: color,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  selectedTitle = isSelected ? '' : title;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) 카테고리 선택 Row
              buildActivitiesRow(categories),
              const SizedBox(height: 20),

              // 2) 필터를 선택할 Dropdown (최신순, 과거순)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilterDropdown(
                    initialFilter: _selectedFilter,
                    onFilterChanged: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: _showList
                        ? const ImageIcon(
                            AssetImage('assets/icon/list.png'),
                            size: 20,
                          )
                        : const ImageIcon(
                            AssetImage('assets/icon/card.png'),
                          ),
                    onPressed: () {
                      setState(() {
                        _showList = !_showList;
                      });
                    },
                  ),
                ],
              ),

              Expanded(
                // 실제로 CustomListView / CustomCardView 내부에서
                // ActivityProvider의 데이터(activities)를 직접 구독하므로,
                // 아래 activities 인자에 뭘 넣든 상관없습니다 (없애도 무방).
                child: _showList
                    ? CustomCardView(
                        sortOrder: _selectedFilter,
                        activities: const [],
                      )
                    : CustomListView(
                        sortOrder: _selectedFilter,
                        activities: const [], // 사용 안 하지만 필요하면 제거 가능
                        selectedCategoryTitle: selectedTitle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
