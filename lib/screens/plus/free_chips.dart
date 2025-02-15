import 'package:flutter/material.dart';

class FreeChips extends StatelessWidget {
  final List<String> categories = [
    "👥 협업 및 대인관계",
    "🚀 자기계발",
    "🌱 사회적 가치",
    "💡 창의력",
    "🌍 글로벌 역량",
    "📊 전문기술",
    "💪 도전 및 성취"
  ];

  final Map<String, List<String>> skills = {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('질문에 답하기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1FB),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    '💡 이 활동을 통해 얻은 역량은 무엇인가요?',
                    style: TextStyle(fontSize: 17, letterSpacing: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...categories.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      category,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills[category]!.map((skill) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, skill);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F5FF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
