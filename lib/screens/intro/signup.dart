import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../intro/signup2.dart';

class SignUpPage extends StatefulWidget {
  final String? uid;
  final String? email;

  const SignUpPage({super.key, this.uid, this.email});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  Future<bool> _checkUserExists(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    return docSnapshot.exists;
  }

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 입력해주세요.")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
      );
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        bool exists = await _checkUserExists(uid);
        if (!exists) {
          await _firestore.collection('users').doc(uid).set({
            'email': email,
            'nickname': '',
            'createdAt': DateTime.now().toIso8601String(),
            'uid': uid,
          });

          String uuid0 = _uuid.v4().substring(0, 8);
          String uuid1 = _uuid.v4().substring(0, 8);
          String uuid2 = _uuid.v4().substring(0, 8);
          String uuid3 = _uuid.v4().substring(0, 8);
          String uuid4 = _uuid.v4().substring(0, 8);

          await _firestore.collection('categories').doc(uid).set({
            uuid0: {
              'color': 'default',
              'index': 0,
              'title': '전체',
            },
            uuid1: {
              'color': 'blue2',
              'index': 1,
              'title': '봉사활동',
            },
            uuid2: {
              'color': 'purple3',
              'index': 2,
              'title': '동아리',
            },
            uuid3: {
              'color': 'green4',
              'index': 3,
              'title': '여행',
            },
            uuid4: {
              'color': 'red2',
              'index': 4,
              'title': '독서',
            },
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 성공!")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NicknamePage(uid: uid, email: email),
          ),
        );
      } else {
        throw Exception("유저 UID를 가져올 수 없습니다.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.115),
                    Text(
                      '이메일을 입력해주세요',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildTextField(
                        controller: _emailController, hintText: '이메일'),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      '비밀번호를 입력해주세요',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildPasswordField(
                      controller: _passwordController,
                      hintText: '비밀번호',
                      isVisible: _isPasswordVisible,
                      onVisibilityChange: (value) {
                        setState(() {
                          _isPasswordVisible = value;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: '비밀번호 확인',
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityChange: (value) {
                        setState(() {
                          _isConfirmPasswordVisible = value;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    GestureDetector(
                      onTap: _signUp,
                      child: Container(
                        width: screenWidth,
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: const Color(0xFF33568C),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                        child: Center(
                          child: Text(
                            '다음',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.01,
            child: IconButton(
              icon:
                  const Icon(Icons.chevron_left, size: 35, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBABABA), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFCECECE)),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required ValueChanged<bool> onVisibilityChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBABABA), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: controller,
                obscureText: !isVisible,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Color(0xFFCECECE)),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onVisibilityChange(!isVisible),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                isVisible ? Icons.visibility_off_outlined : Icons.visibility,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
