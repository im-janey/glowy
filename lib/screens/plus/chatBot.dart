import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatBotPage extends StatefulWidget {
  final String activityName;
  final String category; // 추가됨: 활동 카테고리
  final DateTime startDate; // 추가됨: 활동 시작일
  final DateTime endDate; // 추가됨: 활동 종료일
  final String stage;

  const ChatBotPage({
    Key? key,
    required this.activityName,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.stage,
  }) : super(key: key);

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _chatController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _questions = [];
  List<Map<String, dynamic>> _conversation = [];
  int _currentQuestionIndex = 0;
  String _nickname = "사용자";
  int? _editingIndex; // 편집 모드일 때 인덱스 (null이면 일반 입력)

  // 역량(스킬) 선택 관련 변수
  bool _isSkillSelection = false;
  String? _selectedCategory;

  // 7가지 카테고리와 각 카테고리의 하위 역량 목록
  final List<String> _categories = [
    "👥 협업 및 대인관계",
    "🚀 자기계발",
    "🌱 사회적 가치",
    "💡 창의력",
    "🌍 글로벌 역량",
    "📊 전문기술",
    "💪 도전 및 성취"
  ];

  final Map<String, List<String>> _skills = {
    "👥 협업 및 대인관계": [
      "소통 능력",
      "팀워크",
      "공감 능력",
      "문제 해결",
      "협업",
      "조정 및 중재",
      "신뢰 구축",
      "갈등 관리",
      "리더십",
      "대인관계"
    ],
    "🚀 자기계발": [
      "도전 정신",
      "책임감",
      "자기 주도성",
      "시간 관리",
      "스트레스 관리",
      "목표 설정",
      "실패 극복",
      "끈기",
      "자기계발"
    ],
    "🌱 사회적 가치": ["봉사 정신", "공정성", "환경 의식", "포용성", "다양성 존중", "사회적 책임감", "헌신"],
    "💡 창의력": [
      "아이디어 창출",
      "혁신적 사고",
      "분석적 사고",
      "포용성",
      "유연한 사고",
      "의사 결정 능력",
      "디자인 사고",
      "데이터 해석 능력"
    ],
    "🌍 글로벌 역량": ["다문화 이해", "외국어 능력", "글로벌 사고", "문화 적응력", "네트워킹 능력"],
    "📊 전문기술": [
      "전문 지식",
      "디지털 리터러시",
      "프로그래밍 기술",
      "마케팅 역량",
      "프로젝트 관리",
      "리서치 능력",
      "기술 적응력"
    ],
    "💪 도전 및 성취": [
      "모험심",
      "목표 달성 능력",
      "끊임없는 학습",
      "실패로부터 배우기",
      "새로운 시도",
      "위기 극복",
      "도전정신"
    ]
  };

  @override
  void initState() {
    super.initState();
    _fetchNickname();
    _fetchQuestions();
  }

  /// Firestore에서 사용자 닉네임을 가져옵니다.
  Future<void> _fetchNickname() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (userSnapshot.exists) {
          setState(() {
            _nickname = userSnapshot['nickname'] ?? "사용자";
          });
        }
      }
    } catch (e) {
      print("❌ 사용자 닉네임 불러오기 오류: $e");
    }
  }

  /// Firestore에서 질문 리스트를 가져옵니다.
  Future<void> _fetchQuestions() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('questions')
          .where('stage', isEqualTo: widget.stage)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _questions = querySnapshot.docs;
          // 첫 번째 질문 추가
          _conversation.add({
            "question": _questions[0]['text'],
            "answer": "",
            "stage": _questions[0]['stage'],
            "index": _questions[0]['index'],
          });
        });
      } else {
        setState(() {
          _conversation.add({"question": "해당 단계의 질문이 없습니다.", "answer": ""});
        });
      }
    } catch (e) {
      print("❌ 질문 불러오기 오류: $e");
      setState(() {
        _conversation.add({"question": "질문을 불러오는 데 실패했습니다.", "answer": ""});
      });
    }
  }

  /// Firestore에 답변(활동 기록)을 저장합니다.
  Future<void> _saveResponsesToFirestore() async {
    try {
      await _firestore.collection('responses').add({
        'activityName': widget.activityName,
        'category': widget.category,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'stage': widget.stage,
        'mode': 'chatbot',
        'timestamp': FieldValue.serverTimestamp(),
        'conversation': _conversation,
        'isFavorite': false,
      });
      print("✅ 답변 저장 완료");
    } catch (e) {
      print("❌ 답변 저장 오류: $e");
    }
  }

  /// 텍스트 입력을 통한 답변 처리
  /// 5번째 질문까지는 일반 텍스트 입력 후 진행하고,
  /// 5번째 답변 후 6번째(역량) 질문에서는 인라인 칩 선택 모드로 전환합니다.
  void _nextQuestion(String answer) {
    if (answer.trim().isNotEmpty) {
      if (_editingIndex != null) {
        // 편집 모드인 경우
        setState(() {
          _conversation[_editingIndex!] = {
            ..._conversation[_editingIndex!],
            "answer": answer
          };
          _editingIndex = null;
        });
      } else {
        // 일반 답변 입력인 경우
        setState(() {
          _conversation[_currentQuestionIndex]["answer"] = answer;
        });
        if (_conversation.length == 5) {
          // 5번째 답변 후 6번째(역량) 질문 추가 및 칩 선택 모드 활성화
          _addCustomQuestion();
          return; // 이후는 칩 선택으로 진행
        } else if (_conversation.length < 5) {
          _addRandomQuestion();
        }
        setState(() {
          _currentQuestionIndex = _conversation.length - 1;
        });
      }
      _chatController.clear();
      _scrollToBottom();
    }
  }

  /// 6번째(역량) 질문 추가 후 인라인 칩 선택 모드를 활성화합니다.
  void _addCustomQuestion() {
    String question = widget.stage == "start"
        ? "이 활동을 통해 얻고싶은 $_nickname님의 역량은 무엇인가요?"
        : "이 활동을 통해 얻은 $_nickname님의 역량은 무엇인가요?";
    setState(() {
      _conversation.add({
        "question": question,
        "answer": "",
        "stage": widget.stage,
        "index": -1, // 커스텀 질문은 -1
      });
      _currentQuestionIndex = _conversation.length - 1;
      _isSkillSelection = true; // 칩 선택 모드 활성화
    });
  }

  /// 6번째 질문 전까지 랜덤 질문을 추가합니다.
  void _addRandomQuestion() {
    if (_questions.isNotEmpty && _conversation.length < 6) {
      int randomIndex = Random().nextInt(_questions.length);
      DocumentSnapshot selectedQuestion = _questions[randomIndex];
      setState(() {
        _conversation.add({
          "question": selectedQuestion['text'],
          "answer": "",
          "stage": selectedQuestion['stage'],
          "index": selectedQuestion['index']
        });
      });
    }
  }

  void _skipToNextQuestion() {
    if (_questions.isNotEmpty && _conversation.isNotEmpty) {
      setState(() {
        _conversation.removeLast();
        _addRandomQuestion();
        _currentQuestionIndex = _conversation.length - 1;
      });
    }
  }

  void _previousQuestion() {
    setState(() {
      if (_conversation.isNotEmpty) {
        if (_conversation.last["answer"].toString().isNotEmpty) {
          _conversation.last["answer"] = "";
        } else {
          _conversation.removeLast();
          if (_conversation.isNotEmpty) {
            _conversation.last["answer"] = "";
          }
        }
        if (_currentQuestionIndex > 0) {
          _currentQuestionIndex--;
        }
      }
      if (_conversation.isEmpty) {
        _currentQuestionIndex = 0;
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _editAnswer(int index) {
    setState(() {
      _chatController.text = _conversation[index]["answer"] ?? "";
      _editingIndex = index;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _copyAnswer(int index) {
    Clipboard.setData(ClipboardData(text: _conversation[index]["answer"]));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("답변이 복사되었습니다.")),
    );
  }

  /// 카테고리 칩 위젯 (7가지 카테고리 모두 표시)
  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        return ChoiceChip(
          label: Text(category),
          selected: _selectedCategory == category,
          onSelected: (_) {
            setState(() {
              _selectedCategory = category;
            });
          },
        );
      }).toList(),
    );
  }

  /// 하위 역량(스킬) 칩 위젯 (선택된 카테고리의 하위 아이템만 표시)
  Widget _buildSkillChips() {
    if (_selectedCategory == null) return const SizedBox();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skills[_selectedCategory]!.map((skill) {
        return ActionChip(
          label: Text(skill),
          onPressed: () {
            // 선택한 역량을 현재 질문의 답변으로 저장하고 칩 선택 모드를 종료합니다.
            setState(() {
              _conversation.last["answer"] = skill;
              _isSkillSelection = false;
              _selectedCategory = null;
            });
            _scrollToBottom();
          },
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 질문이 커스텀(역량) 질문이고 아직 답변이 없는 경우,
    // 인라인 칩 선택 모드를 활성화합니다.
    bool isCustomQuestionActive = _conversation.isNotEmpty &&
        _conversation.last["index"] == -1 &&
        (_conversation.last["answer"] == null ||
            _conversation.last["answer"].toString().isEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 영역
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.activityName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 대화 목록 영역
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _conversation.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = _conversation[index]["answer"] != null &&
                      _conversation[index]["answer"].toString().isNotEmpty;
                  return Column(
                    crossAxisAlignment: isUserMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F1FB),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              _conversation[index]["question"] ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isUserMessage)
                        GestureDetector(
                          onLongPress: () {
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                MediaQuery.of(context).size.width * 0.5,
                                MediaQuery.of(context).size.height * 0.5,
                                MediaQuery.of(context).size.width * 0.5,
                                MediaQuery.of(context).size.height * 0.5,
                              ),
                              items: [
                                PopupMenuItem(
                                  child: const Text("편집"),
                                  onTap: () {
                                    _editAnswer(index);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("복사"),
                                  onTap: () {
                                    _copyAnswer(index);
                                  },
                                ),
                              ],
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF365481),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  _conversation[index]["answer"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            // 인라인 칩 선택 영역 (커스텀 질문일 때만 표시)
            if (isCustomQuestionActive && _isSkillSelection)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _selectedCategory == null
                    ? _buildCategoryChips()
                    : _buildSkillChips(),
              ),
            // 이전/다음/완료 버튼 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFF365481)),
                    onPressed:
                        _currentQuestionIndex > 0 ? _previousQuestion : null,
                  ),
                  const Text('이전 질문', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Color(0xFF365481)),
                    onPressed: _skipToNextQuestion,
                  ),
                  const Text('다음 질문', style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await _saveResponsesToFirestore();
                      Navigator.of(context).pop();
                    },
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            // 하단 텍스트 입력창 (커스텀 질문 시에는 입력 불가)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _chatController,
                readOnly: isCustomQuestionActive,
                decoration: InputDecoration(
                  hintText: isCustomQuestionActive
                      ? '역량 선택은 위의 칩을 이용하세요.'
                      : (_editingIndex != null
                          ? '답변을 수정하세요...'
                          : '답변을 입력하세요...'),
                  filled: true,
                  fillColor: const Color(0xFFE7F1FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (!isCustomQuestionActive) {
                        _nextQuestion(_chatController.text);
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF33578C),
                        shape: OvalBorder(),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                onSubmitted: (answer) {
                  if (!isCustomQuestionActive) {
                    _nextQuestion(answer);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
