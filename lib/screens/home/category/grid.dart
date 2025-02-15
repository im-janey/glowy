import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/category_provider.dart';
import '../widgets.dart';
import 'create.dart';
import 'edit.dart';

class CategoryGridPage extends StatefulWidget {
  const CategoryGridPage({super.key});

  @override
  State<CategoryGridPage> createState() => _CategoryGridPageState();
}

class _CategoryGridPageState extends State<CategoryGridPage> {
  String selectedTitle = '';

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: GridView.builder(
          // +1로 '추가' 버튼 포함
          itemCount: categories.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 한 행에 4개씩
            crossAxisSpacing: 16, // 가로 간격
            mainAxisSpacing: 16, // 세로 간격
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            // 마지막 칸은 + 버튼
            if (index == categories.length) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryCreatePage(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.add, size: 30),
                ),
              );
            }

            // 기존 카테고리
            final category = categories[index];
            final title = category['title'] ?? 'No Title';
            final color = category['color'] ?? 'grey';
            final isSelected = (selectedTitle == title);

            return CategoryCard(
              title: title,
              color: color, // HomeBody 처럼 String 그대로 전달
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  // 선택/해제
                  selectedTitle = isSelected ? '' : title;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryEditPage(
                      categoryTitle: title,
                      categoryColor: color,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
