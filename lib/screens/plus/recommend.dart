import 'package:bossam/screens/plus/free_chips.dart'; // FreeChips 페이지 import
import 'package:bossam/screens/plus/free_questions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _randomQuestions = []; // 질문 리스트 수정
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedQuestions = [];
      List<String> stages = ["expert", "insight", "introspection"];

      for (String stage in stages) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('questions')
            .where('stage', isEqualTo: stage)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final randomIndex =
              DateTime.now().microsecond % querySnapshot.docs.length;
          final questionDoc = querySnapshot.docs[randomIndex];

          fetchedQuestions.add({
            "content": questionDoc['text'],
            "stage": stage,
            "index": randomIndex,
          });
        } else {
          fetchedQuestions.add({
            "content": "해당 단계의 질문이 없습니다.",
            "stage": stage,
            "index": -1,
          });
        }
      }

      setState(() {
        _randomQuestions = fetchedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Firestore 질문 가져오기 오류: $e");
      setState(() {
        _randomQuestions = [
          {"content": "질문을 불러오는 데 실패했습니다.", "stage": "", "index": -1}
        ];
        _isLoading = false;
      });
    }
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.7,
      color: const Color(0xFF659BD1),
    );
  }

  /// 🔹 질문 클릭 시 `content`, `stage`, `index` 반환
  Widget _buildQuestionItem(Map<String, dynamic> questionData) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, questionData); // 🔹 Map 형태로 반환
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Text(
          questionData['content'],
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1.47,
          ),
        ),
      ),
    );
  }

  /// 🔹 추천 질문 카드 (클릭 시 FreeChips 페이지로 이동)
  Widget _buildRecommendedQuestion(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FreeChips()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F1FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '💡 이 활동을 통해 얻은 역량은 무엇인가요?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.6,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단 바
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(width: 2.5, color: Color(0xFF659AD0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    '오늘의 추천 질문',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchQuestions,
                  ),
                ],
              ),
            ),

            _buildRecommendedQuestion(context),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF659AD0)),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    for (var question in _randomQuestions) ...[
                      _buildQuestionItem(question),
                      _buildDivider(),
                    ],
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FreeQuestionsPage()),
                  );
                },
                child: const Text(
                  '다른 질문 더보기',
                  style: TextStyle(
                    color: Color(0xFF5C5C5C),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.92,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
