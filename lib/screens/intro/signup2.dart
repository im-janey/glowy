import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/navibation_bar.dart';

class NicknamePage extends StatefulWidget {
  final String uid;
  final String email;

  const NicknamePage({super.key, required this.uid, required this.email});

  @override
  _NicknamePageState createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDuplicateChecked = false;
  bool _isValidNickname = false;

  Future<void> _checkNickname() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty || nickname.length < 2 || nickname.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임은 2~15자 사이로 입력해주세요.")),
      );
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .get();

    if (snapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이미 사용 중인 닉네임입니다.")),
      );
      setState(() {
        _isDuplicateChecked = false;
        _isValidNickname = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 닉네임입니다.")),
      );
      setState(() {
        _isDuplicateChecked = true;
        _isValidNickname = true;
      });
    }
  }

  Future<void> _submitNickname() async {
    if (!_isDuplicateChecked || !_isValidNickname) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임 중복 확인을 진행해주세요.")),
      );
      return;
    }

    final nickname = _nicknameController.text.trim();
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.uid);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      await userRef.update({'nickname': nickname});
    } else {
      await userRef.set({
        'uid': widget.uid,
        'email': widget.email,
        'nickname': nickname,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("닉네임이 저장되었습니다.")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CustomNavigationBar()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey.shade200],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: screenWidth * 0.06,
                    top: screenHeight * 0.12,
                    child: const Text(
                      '닉네임을 입력해주세요',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.06,
                    top: screenHeight * 0.18,
                    child: Container(
                      width: screenWidth * 0.87,
                      height: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color(0xFFBABABA), width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: TextField(
                          controller: _nicknameController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '닉네임',
                            hintStyle: TextStyle(color: Color(0xFFCECECE)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.77,
                    top: screenHeight * 0.19,
                    child: GestureDetector(
                      onTap: _checkNickname,
                      child: const Text(
                        '중복 확인',
                        style: TextStyle(
                          color: Color(0xFF33568C),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.06,
                    top: screenHeight * 0.25,
                    child: const Text(
                      '한글, 영문, 숫자를 포함하여 2~15자까지 가능합니다.',
                      style: TextStyle(
                        color: Color(0xFFBEBEBE),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.06,
                    top: screenHeight * 0.35,
                    child: GestureDetector(
                      onTap: _submitNickname,
                      child: Container(
                        width: screenWidth * 0.87,
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: const Color(0xFF33568C),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            '완료',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
