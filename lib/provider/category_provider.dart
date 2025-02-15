import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategory = '';

  List<Map<String, dynamic>> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  get activities => null;

  Future<void> fetchCategories(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) return;

      final data = doc.data()!;
      _categories = [];

      data.forEach((key, value) {
        _categories.add({
          'id': key,
          'title': value['title'] ?? 'No Title',
          'color': value['color'] ?? 'grey',
          'index': value['index'],
        });
      });

      _categories
          .sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

      _selectedCategory =
          _categories.isNotEmpty ? _categories.first['title'] : '';

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: ${e.toString()}');
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
