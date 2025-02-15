// chatFree.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'free_chips.dart';
import 'free_questions.dart';
import 'recommend.dart';

class ChatFreePage extends StatefulWidget {
  final String title;
  final String category;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String stage;

  const ChatFreePage({
    super.key,
    required this.title,
    required this.category,
    required this.startedAt,
    required this.finishedAt,
    required this.stage,
  });

  @override
  _ChatFreePageState createState() => _ChatFreePageState();
}

class _ChatFreePageState extends State<ChatFreePage> {
  bool _showMenu = false;
  final List<Map<String, dynamic>> _contentList = [];
  final Set<int> _selectedIndices = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // 최초 텍스트 입력 항목 추가
    _contentList.add({
      "type": "text",
      "controller": TextEditingController(),
    });
  }

  Future<void> _saveContentToFirestore() async {
    try {
      User? user = _auth.currentUser;

      // 각 항목의 데이터를 Firestore에 저장할 수 있는 형태로 변환
      List<Map<String, dynamic>> savedContent = _contentList.map((item) {
        if (item['type'] == 'text') {
          return {
            "type": "text",
            "content": item['controller'].text,
          };
        } else if (item['type'] == 'question') {
          return {
            "type": "question",
            "content": item['content'],
            "stage": item['stage'] ?? '',
            "index": item['index'] ?? -1,
          };
        } else if (item['type'] == 'skill') {
          return {
            "type": "skill",
            "content": item['content'],
          };
        } else {
          return {
            "type": item['type'],
            "content": item['content'],
          };
        }
      }).toList();

      await _firestore.collection('activities').add({
        'uid': user?.uid, // ✅ Firestore에 UID 저장
        'title': widget.title,
        'category': widget.category,
        'startedAt': widget.startedAt,
        'finishedAt': widget.finishedAt,
        'stage': widget.stage,
        'mode': 'free',
        'timestamp': FieldValue.serverTimestamp(),
        'content': savedContent,
      });

      print("✅ Firestore에 저장 완료 (UID: ${user?.uid})");
      Navigator.of(context).pop();
    } catch (e) {
      print("❌ Firestore 저장 오류: $e");
    }
  }

  // 추천 질문 페이지로 이동 후 결과를 받아 처리
  void _navigateToRecommendPage() async {
    setState(() {
      _showMenu = false;
    });

    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecommendPage()),
    );

    if (result != null) {
      setState(() {
        _contentList.add({
          "type": "question",
          "content": result['content'],
          "stage": result['stage'],
          "index": result['index'],
        });
        _contentList.add({
          "type": "text",
          "controller": TextEditingController(),
        });
      });
    }
  }

  // 자유 질문 페이지로 이동 후 결과를 받아 처리
  void _navigateToFreeQuestionsPage() async {
    setState(() {
      _showMenu = false;
    });

    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FreeQuestionsPage()),
    );

    if (result != null) {
      setState(() {
        _contentList.add({
          "type": "question",
          "content": result['content'],
          "stage": result['stage'],
          "index": result['index'],
        });
        _contentList.add({
          "type": "text",
          "controller": TextEditingController(),
        });
      });
    }
  }

  // 역량(스킬) 선택 페이지로 이동 후 결과를 받아 처리
  void _navigateToFreeChips() async {
    setState(() {
      _showMenu = false;
    });

    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FreeChips()),
    );

    if (result != null) {
      setState(() {
        _contentList.add({
          "type": "skill",
          "content": result,
        });
        _contentList.add({
          "type": "text",
          "controller": TextEditingController(),
        });
      });
    }
  }

  // 메뉴 항목 위젯
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // 삭제 버튼 위젯 (롱프레스 선택된 항목에 대해 표시)
  Widget _buildDeleteButton(int index) {
    return Positioned(
      top: 4,
      right: 8,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _contentList.removeAt(index);
            // 삭제 후 텍스트 입력 항목이 바로 뒤에 있다면 함께 제거
            if (index < _contentList.length &&
                _contentList[index]['type'] == 'text') {
              _contentList.removeAt(index);
            }
            _selectedIndices.remove(index);
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.close, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  // 질문이나 역량 항목을 보여주는 컨테이너 위젯
  Widget _buildContentContainer(
      String content, int index, Color bgColor, Color textColor) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (_selectedIndices.contains(index)) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              maxLines: null,
            ),
          ),
          if (_selectedIndices.contains(index)) _buildDeleteButton(index),
        ],
      ),
    );
  }

  // 텍스트 입력 필드 위젯
  Widget _buildTextField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          hintText: '자유롭게 작성해보세요...',
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 배경 터치 시 메뉴 숨김
      onTap: () => setState(() => _showMenu = false),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 상단 앱바 영역
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    GestureDetector(
                      onTap: _saveContentToFirestore,
                      child: Container(
                        width: 55,
                        height: 29,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFE7F1FB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Color(0xFF365481),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 본문: 내용 목록을 ListView로 출력
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contentList.length,
                  itemBuilder: (context, index) {
                    final item = _contentList[index];
                    if (item['type'] == 'question') {
                      return _buildContentContainer(
                        item['content'],
                        index,
                        const Color(0xFFE7F1FB),
                        const Color(0xFF365481),
                      );
                    } else if (item['type'] == 'skill') {
                      return _buildContentContainer(
                        item['content'],
                        index,
                        const Color(0xFFD9F3FF),
                        const Color(0xFF0077B6),
                      );
                    } else if (item['type'] == 'text') {
                      return _buildTextField(item['controller']);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        // 플로팅 액션 버튼 영역: 메뉴를 토글하거나, 질문/역량 추가 메뉴 표시
        floatingActionButton: Stack(
          children: [
            if (_showMenu)
              Positioned(
                bottom: 80,
                right: 16,
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem("추천 질문", Icons.question_answer,
                            _navigateToRecommendPage),
                        _buildMenuItem("자유 질문", Icons.help_outline,
                            _navigateToFreeQuestionsPage),
                        _buildMenuItem(
                            "역량 추가", Icons.star, _navigateToFreeChips),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showMenu = !_showMenu;
                  });
                },
                backgroundColor: const Color(0xFF365481),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
