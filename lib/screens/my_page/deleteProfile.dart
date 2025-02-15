import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteProfilePage extends StatefulWidget {
  const DeleteProfilePage({super.key});

  @override
  State<DeleteProfilePage> createState() => _DeleteProfilePageState();
}

class _DeleteProfilePageState extends State<DeleteProfilePage> {
  bool _isChecked = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Firebase 계정 삭제 함수
  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Firestore에서 사용자 데이터 삭제
        await _firestore.collection('users').doc(user.uid).delete();

        // Firebase Auth에서 사용자 삭제
        await user.delete();

        // 로그아웃 후 로그인 페이지로 이동
        await _auth.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      print("회원 탈퇴 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원 탈퇴 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '회원 탈퇴',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '유의사항',
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '• 회원 탈퇴 시 기존에 등록한 기록, 즐겨찾기 내역 등 모든 콘텐츠가 삭제됩니다.\n'
                  '• 회원 탈퇴 시 회원 정보는 모두 삭제되며 복구가 불가능합니다.\n'
                  '• 단, 법령에 의하여 보관해야 하는 경우 개인정보처리방침에 따라 일정 기간 보관될 수 있습니다.',
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: const Color(0xFF121212)),
                          borderRadius: BorderRadius.circular(6),
                          color: _isChecked ? Color(0xFF33568C) : Colors.white,
                        ),
                        child: _isChecked
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '위 유의사항을 모두 확인했으며 탈퇴에 동의합니다.',
                        style: TextStyle(
                          color: Color(0xFF121212),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE3E3E3),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isChecked ? _deleteAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isChecked
                        ? const Color(0xFF33568C)
                        : const Color(0xFFE3E3E3),
                    minimumSize: Size(screenWidth * 0.9, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '탈퇴하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.9, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    side: const BorderSide(color: Color(0xFFCACACA)),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFFCACACA),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
