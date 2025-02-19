import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FreeQuestionsPage extends StatefulWidget {
  const FreeQuestionsPage({Key? key}) : super(key: key);

  @override
  _FreeQuestionsPageState createState() => _FreeQuestionsPageState();
}

class _FreeQuestionsPageState extends State<FreeQuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore의 실제 키 (영어)
  final List<String> _stages = [
    "start",
    "middle",
    "finish",
    "introspection",
    "expert",
    "insight"
  ];

  // 영어 키를 한글 레이블로 변환
  final Map<String, String> _stageLabels = {
    "start": "시작 단계",
    "middle": "진행 단계",
    "finish": "마무리 단계",
    "introspection": "삶의 발견",
    "expert": "전문성",
    "insight": "개인성장",
  };

  String _selectedStage = "start";
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions(_selectedStage);
  }

  Future<void> _fetchQuestions(String stage) async {
    setState(() {
      _isLoading = true;
      _questions.clear();
    });

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('questions')
          .where('stage', isEqualTo: stage)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _questions = querySnapshot.docs.asMap().entries.map((entry) {
            int index = entry.key;
            DocumentSnapshot doc = entry.value;
            return {
              "content": doc['text'],
              "stage": stage,
              "index": index,
            };
          }).toList();
        });
      } else {
        setState(() {
          _questions = [
            {"content": "해당 단계의 질문이 없습니다.", "stage": stage, "index": -1}
          ];
        });
      }
    } catch (e) {
      print("❌ 질문을 불러오는 중 오류 발생: $e");
      setState(() {
        _questions = [
          {"content": "질문을 불러오는 데 실패했습니다.", "stage": stage, "index": -1}
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStageTab(String stageKey) {
    final bool isSelected = (_selectedStage == stageKey);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStage = stageKey;
        });
        _fetchQuestions(stageKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF659AD0) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          _stageLabels[stageKey] ?? stageKey,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w600,
            color:
                isSelected ? const Color(0xFF33568C) : const Color(0xFF5F7EAF),
          ),
        ),
      ),
    );
  }

  // 🔹 recommend.dart와 동일한 스타일 (padding: horizontal 26, vertical 25)
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

  // 🔹 recommend.dart와 동일한 구분선 (Divider) 스타일
  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.7,
      color: const Color(0xFFDADADA),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "질문에 답하기",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Pretendard Variable',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _stages.map((stage) => _buildStageTab(stage)).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF659AD0)),
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
                  for (var question in _questions) ...[
                    _buildQuestionItem(question),
                    _buildDivider(),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }
}
