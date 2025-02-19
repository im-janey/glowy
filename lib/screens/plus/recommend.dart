import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'free_chips.dart';
import 'free_questions.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _randomQuestions = [];
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

  // 구분선
  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.7,
      color: const Color(0xFFDADADA),
    );
  }

  // 🔹 질문 클릭 시 `content`, `stage`, `index` 반환
  Widget _buildQuestionItem(Map<String, dynamic> questionData) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, questionData);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 25),
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

  // 🔹 추천 질문 카드 (클릭 시 FreeChips 페이지로 이동)
  // 기존 코드
/*
Widget _buildRecommendedQuestion(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FreeChips()),
      );
    },
    child: Container(
      ...
    ),
  );
}
*/

// 변경된 코드: FreeChips 선택 후 스킬을 받아, RecommendPage를 pop하면서 ChatFreePage로 전달
  Widget _buildRecommendedQuestion(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // FreeChips에서 스킬(String)을 받아옴
        final skillResult = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => FreeChips()),
        );

        // 스킬을 선택했다면, RecommendPage를 pop하면서 ChatFreePage로 데이터 전달
        if (skillResult != null) {
          Navigator.pop(context, {
            "type": "skill",
            "content": skillResult,
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F1FB),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '    💡 이 활동을 통해 얻은 역량은 무엇인가요?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.6,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.arrow_forward_ios,
                  size: 17, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 '다른 질문 더보기' 버튼
  Widget _buildMoreQuestionsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 20, 30),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.zero,
          ),
          onPressed: () async {
            // 🔹 FreeQuestionsPage에서 질문을 선택하면 result로 받음
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                  builder: (context) => const FreeQuestionsPage()),
            );
            // 만약 result가 있으면 RecommendPage를 pop하면서, 그 result를 그대로 넘김
            if (result != null) {
              Navigator.pop(context, result);
            }
          },
          child: const Text(
            '다른 질문 더보기 ',
            style: TextStyle(
              color: Color(0xFF33568C),
              fontSize: 15,
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w600,
              height: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  bottom: BorderSide(width: 1.5, color: Color(0xFF659AD0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 35),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // 타이틀
                  const Text(
                    '오늘의 추천 질문',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // 새로고침 버튼
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchQuestions,
                  ),
                ],
              ),
            ),

            // 🔹 로딩 중이면 로딩 표시, 아니면 ListView
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF659AD0),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // (1) 추천 질문 카드
                        _buildRecommendedQuestion(context),

                        // (2) 무작위 질문들
                        for (var question in _randomQuestions) ...[
                          _buildQuestionItem(question),
                          _buildDivider(),
                        ],

                        // (3) 다른 질문 더보기 버튼
                        _buildMoreQuestionsButton(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
