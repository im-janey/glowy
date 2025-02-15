import 'package:flutter/material.dart';

import 'form.dart';

class CategoryEditPage extends StatefulWidget {
  final String categoryTitle;
  final Color categoryColor;

  const CategoryEditPage({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
  });

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late String _name;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _name = widget.categoryTitle;
    _selectedColor = widget.categoryColor;
  }

  void _saveCategory() async {
    // Firebase에서 기존 문서를 업데이트하는 로직 추가
    // 예: await FirebaseFirestore.instance.collection('category')
    //     .doc(...) // 문서 ID
    //     .update({"name": _name, "color": _selectedColor.value});

    Navigator.pop(context);
  }

  void _deleteCategory() async {
    // Firebase에서 카테고리 삭제하는 로직 추가
    // 예: await FirebaseFirestore.instance.collection('category')
    //     .doc(...) // 문서 ID
    //     .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("카테고리 수정"),
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
          isEditing: true,
          onSave: (newName, newColor) {
            setState(() {
              _name = newName;
              _selectedColor = newColor;
            });
          },
          onDelete: _deleteCategory,
        ),
      ),
    );
  }
}
