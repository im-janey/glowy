import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/category_provider.dart';
import 'card_view.dart';
import 'filter.dart';
import 'list_view.dart';
import '../widgets.dart';

class OrbBody extends StatefulWidget {
  const OrbBody({super.key});

  @override
  State<OrbBody> createState() => _OrbBodyState();
}

class _OrbBodyState extends State<OrbBody> {
  String selectedTitle = '';
  bool _showList = false;
  String _selectedFilter = '최신순';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                child:
                    _showList ? const CustomCardView() : const CustomListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
