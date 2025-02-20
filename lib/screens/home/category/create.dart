import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'form.dart';

class CategoryCreatePage extends StatefulWidget {
  const CategoryCreatePage({super.key});

  @override
  State<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends State<CategoryCreatePage> {
  String _name = "이름 입력";
  Color _selectedColor = Colors.purple.shade200;
  String? _categoryId; // 새 카테고리의 ID를 저장

  /// Firestore에 카테고리를 저장 (이름 변경 포함)
  Future<void> _saveCategory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // 로그인 정보 없으면 종료

    // 새로운 카테고리 ID가 없으면 생성 (최초 저장 시)
    _categoryId ??= const Uuid().v4().substring(0, 8);

    // Firestore에 저장할 데이터
    final categoryData = {
      'title': _name,
      'color': _selectedColor.value,
      'index': 5,
    };

    try {
      await FirebaseFirestore.instance.collection('categories').doc(uid).set({
        _categoryId!: categoryData,
      }, SetOptions(merge: true));

      // 저장 성공 시 화면 닫기
      Navigator.pop(context);
    } catch (e) {
      debugPrint('카테고리 저장 오류: $e');
    }
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

            // 이름이 변경될 때 Firestore에도 즉시 반영
            _saveCategory();
          },
        ),
      ),
    );
  }
}
