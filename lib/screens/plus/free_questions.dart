import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FreeQuestionsPage extends StatefulWidget {
  const FreeQuestionsPage({Key? key}) : super(key: key);

  @override
  _FreeQuestionsPageState createState() => _FreeQuestionsPageState();
}

class _FreeQuestionsPageState extends State<FreeQuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _stages = [
    "start",
    "middle",
    "finish",
    "introspection",
    "expert",
    "insight"
  ];

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
              "index": index, // 🔹 인덱스 저장
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

  Widget _buildStageTab(String stage) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStage = stage;
        });
        _fetchQuestions(stage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedStage == stage
                  ? const Color(0xFF659AD0)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          stage.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _selectedStage == stage ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> questionData) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, questionData);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("질문에 답하기"),
        backgroundColor: Colors.white,
        elevation: 0,
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
                children: _questions
                    .map((question) => _buildQuestionItem(question))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
