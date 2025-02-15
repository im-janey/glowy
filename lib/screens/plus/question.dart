import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Upload introspection stage questions to Firestore
  await uploadIntrospectionQuestions();
}

/// 🔥 Firestore에 "introspection 단계" 질문 업로드 함수
Future<void> uploadIntrospectionQuestions() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List of introspection stage questions
  List<Map<String, dynamic>> introspectionQuestions = [
    {
      "index": 1,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "최근 나 자신이 성장했다고 느낀 순간은 언제였나요?",
      "tags": ["성장", "순간"]
    },
    {
      "index": 2,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "나의 단점을 개선하기 위해 어떤 노력을 했고, 어떤 결과를 얻었나요?",
      "tags": ["단점", "개선"]
    },
    {
      "index": 3,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "스스로에 대해 새롭게 발견한 점이 있다면 무엇인가요?",
      "tags": ["발견", "자신"]
    },
    {
      "index": 4,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "자신을 가장 크게 변화시킨 경험은 무엇인가요?",
      "tags": ["변화", "경험"]
    },
    {
      "index": 5,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "최근에 도전해본 새로운 일이나 활동은 무엇인가요?",
      "tags": ["도전", "활동"]
    },
    {
      "index": 6,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "스트레스를 극복하며 배운 가장 큰 교훈은 무엇인가요?",
      "tags": ["스트레스", "교훈"]
    },
    {
      "index": 7,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "자신이 가진 강점이 가장 빛났던 순간은 언제였나요?",
      "tags": ["강점", "순간"]
    },
    {
      "index": 8,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "현재의 삶에서 가장 감사함을 느끼는 부분은 무엇인가요?",
      "tags": ["감사", "삶"]
    },
    {
      "index": 9,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "자신을 더 나은 방향으로 변화시키기 위해 가장 집중한 부분은 무엇인가요?",
      "tags": ["변화", "집중"]
    },
    {
      "index": 10,
      "category": "개인적인 자기성장",
      "stage": "introspection",
      "text": "스스로를 칭찬하고 싶은 최근의 성취는 무엇인가요?",
      "tags": ["칭찬", "성취"]
    },
    {
      "index": 11,
      "category": "공동체 안에서의 자기성장",
      "stage": "introspection",
      "text": "이 공동체가 당신에게 준 가장 큰 배움은 무엇인가요?",
      "tags": ["공동체", "배움"]
    },
    {
      "index": 12,
      "category": "공동체 안에서의 자기성장",
      "stage": "introspection",
      "text": "협력 과정에서 가장 도전적이었던 순간은 무엇이었나요?",
      "tags": ["협력", "도전"]
    },
    {
      "index": 13,
      "category": "공동체 안에서의 자기성장",
      "stage": "introspection",
      "text": "이 공동체의 가치를 한 문장으로 요약한다면 어떻게 표현할 수 있을까요?",
      "tags": ["공동체", "가치"]
    },
    {
      "index": 14,
      "category": "공동체 안에서의 자기성장",
      "stage": "introspection",
      "text": "공동체 안에서 당신의 강점이 어떻게 발휘되었나요?",
      "tags": ["강점", "공동체"]
    },
    {
      "index": 15,
      "category": "공동체 안에서의 자기성장",
      "stage": "introspection",
      "text": "공동체 활동 중 가장 인상 깊었던 경험은 무엇인가요?",
      "tags": ["공동체", "경험"]
    }
  ];

  // Upload each question to Firestore
  for (var question in introspectionQuestions) {
    QuerySnapshot existing = await firestore
        .collection("questions")
        .where("text", isEqualTo: question["text"])
        .get();

    if (existing.docs.isEmpty) {
      await firestore.collection("questions").add(question);
    }
  }

  print("📌 Firestore에 'introspection 단계' 질문이 업로드되었습니다!");
}
