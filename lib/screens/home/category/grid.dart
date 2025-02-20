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
            crossAxisSpacing: 0, // 가로 간격
            mainAxisSpacing: 10, // 세로 간격
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
                child: Column(
                  children: [
                    // 카드 형태의 버튼
                    Container(
                      width: 55, // 고정된 크기 설정
                      height: 67,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 32, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 아래 텍스트
                    Text(
                      '추가',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
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
              color: color,
              isSelected: isSelected,
              onTap: () {
                setState(() {
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
