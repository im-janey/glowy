import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'deleteProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _nickname = '로딩중..';
  String _email = '로딩중..';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          _nickname =
              userData.exists ? (userData['nickname'] ?? '닉네임 없음') : '닉네임 없음';
          _email = userData.exists
              ? (userData['email']?.isNotEmpty == true
                  ? userData['email']
                  : '이메일 없음')
              : user.email ?? '이메일 없음';
        });
      } catch (e) {
        print("데이터 불러오기 오류: $e");
        setState(() {
          _nickname = '닉네임 없음';
          _email = _auth.currentUser?.email ?? '이메일 없음';
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      print("로그아웃 성공");
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      print("로그아웃 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '내 계정',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title:
                          const Text('닉네임 변경', style: TextStyle(fontSize: 15)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _nickname,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.grey, size: 18),
                        ],
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      title:
                          const Text('비밀번호 변경', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.grey, size: 18),
                      onTap: () {},
                    ),
                    ListTile(
                      title:
                          const Text('알림 설정', style: TextStyle(fontSize: 15)),
                      trailing: GestureDetector(
                        onTap: () {
                          setState(() {
                            _notificationsEnabled = !_notificationsEnabled;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _notificationsEnabled
                                ? Colors.green
                                : Colors.grey,
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 100),
                            alignment: _notificationsEnabled
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Row(
                        children: [
                          Text('언어', style: TextStyle(fontSize: 15)),
                          SizedBox(width: 3),
                          Icon(Icons.language, size: 18)
                        ],
                      ),
                      trailing: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '한국어',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.grey, size: 18),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 3, color: Color(0xffE3E3E3)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('문의하기', style: TextStyle(fontSize: 15)),
                      onTap: () {},
                    ),
                    ListTile(
                      title:
                          const Text('문의 내역', style: TextStyle(fontSize: 15)),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text('서비스이용 약관',
                          style: TextStyle(fontSize: 15)),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text('버전', style: TextStyle(fontSize: 15)),
                      trailing:
                          const Text('1.0.0', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 3, color: Color(0xffE3E3E3)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('로그아웃', style: TextStyle(fontSize: 15)),
                      onTap: _logout,
                    ),
                    ListTile(
                      title: const Text(
                        '회원탈퇴',
                        style: TextStyle(
                          color: Color(0xFF121212),
                          fontSize: 15,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w500,
                          height: 1.47,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DeleteProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
