import 'package:flutter/material.dart';

import 'form.dart';

class CategoryCreatePage extends StatefulWidget {
  const CategoryCreatePage({super.key});

  @override
  State<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends State<CategoryCreatePage> {
  String _name = "이름 입력";
  Color _selectedColor = Colors.purple.shade200;

  void _saveCategory() async {
    // Firebase에 새 카테고리 저장하는 로직 추가
    // 예: await FirebaseFirestore.instance.collection('category').add({...});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: const Text(
              "저장",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CategoryForm(
          initialName: _name,
          initialColor: _selectedColor,
          isEditing: false,
          onSave: (newName, newColor) {
            setState(() {
              _name = newName;
              _selectedColor = newColor;
            });
          },
        ),
      ),
    );
  }
}
