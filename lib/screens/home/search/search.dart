import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchFirestore(String query) async {
    if (query.isEmpty) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final results = <Map<String, dynamic>>[];

    try {
      final snapshot = await firestore.collection('activities').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';
        final tags = (data['tags'] as List<dynamic>?)
                ?.map((tag) => tag.toString().toLowerCase())
                .toList() ??
            [];

        if (title.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase()) ||
            tags.any((tag) => tag.contains(query.toLowerCase()))) {
          results.add(data);
        }
      }

      setState(() => _searchResults = results);
    } catch (e) {
      print('검색 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 구슬 검색")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: TextField(
              controller: _controller,
              onSubmitted: _searchFirestore,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xff121212)),
                  onPressed: () => _searchFirestore(_controller.text),
                ),
                hintText: '검색',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xffF2F2F2),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff121212)),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text("검색 결과 없음"))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.white,
                            title: Text(item['title'] ?? '제목 없음'),
                            subtitle: Text(item['description'] ?? '설명 없음'),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
