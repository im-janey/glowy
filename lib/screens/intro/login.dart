import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../components/navibation_bar.dart';
import 'emailLogin.dart';
import 'etc/agreement_bottomsheet.dart';
import 'signup2.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPageTimer;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoPageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < 2) {
        _currentIndex++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _autoPageTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _autoPageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _checkUserExists(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    return docSnapshot.exists;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        bool exists = await _checkUserExists(user.uid);
        if (exists) {
          _navigateToHome();
        } else {
          _navigateToNicknamePage(user.uid, user.email);
        }
      }
    } catch (e) {
      debugPrint('구글 로그인 실패: $e');
    }
  }

  Future<void> _kakaoLogin() async {
    try {
      if (await isKakaoTalkInstalled()) {
      } else {}

      final user = await UserApi.instance.me();
      final email = user.kakaoAccount?.email ?? "이메일 없음";
      user.id.toString();

      final authResult = await _auth.signInAnonymously();
      final firebaseUser = authResult.user;

      if (firebaseUser != null) {
        bool exists = await _checkUserExists(firebaseUser.uid);
        if (exists) {
          _navigateToHome();
        } else {
          _navigateToNicknamePage(firebaseUser.uid, email);
        }
      }
    } catch (error) {
      debugPrint("카카오 로그인 실패: $error");
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        bool exists = await _checkUserExists(user.uid);
        if (exists) {
          _navigateToHome();
        } else {
          _navigateToNicknamePage(user.uid, appleCredential.email);
        }
      }
    } catch (error) {
      debugPrint('Apple 로그인 실패: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple 로그인 실패: 다시 시도해주세요.')),
      );
    }
  }

  void _navigateToNicknamePage(String uid, String? email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NicknamePage(uid: uid, email: email ?? "이메일 없음"),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CustomNavigationBar()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE7F1FB),
              Color(0xFFC0C2FC),
              Color(0xFFDCE6FF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.67,
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildPage(
                      image: 'assets/login1.png',
                      title: "GLOWY는 발견과 깨달음을 기록하고\n빛나는 특별한 공간입니다",
                      width: width,
                      height: height,
                    ),
                    _buildPage(
                      image: 'assets/login2.png',
                      title: "Glowy만의 독특한 기록 방법으로\n더욱 즐겁게 활동 기록을 작성할 수 있어요",
                      width: width,
                      height: height,
                    ),
                    _buildPage(
                      image: 'assets/login3.png',
                      title: "이제 GLOWY를 시작할\n시간이 됐어요! 가입을 시작해볼까요?",
                      width: width,
                      height: height,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.05),
              _buildSocialButtons(width: width),
              SizedBox(height: height * 0.02),
              _buildEmailLoginButton(width: width, height: height),
              SizedBox(height: height * 0.02),
              _buildSignUpText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String image,
    required String title,
    required double width,
    required double height,
  }) {
    return Column(
      children: [
        SizedBox(height: height * 0.06),
        Center(
          child: Image.asset(
            image,
            width: width * 0.9,
            height: height * 0.5,
            fit: BoxFit.contain,
          ),
        ),
        Transform.translate(
          offset: Offset(0, height * 0.0001),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                color: Color(0xFF445E86),
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons({required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _kakaoLogin,
          child: Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: const BoxDecoration(
              color: Color(0xFFFDEC05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/logo/kakao.png',
                width: width * 0.06,
                height: width * 0.06,
              ),
            ),
          ),
        ),
        SizedBox(width: width * 0.07),
        GestureDetector(
          onTap: _signInWithGoogle,
          child: Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/logo/google.png',
                width: width * 0.06,
                height: width * 0.06,
              ),
            ),
          ),
        ),
        SizedBox(width: width * 0.07),
        GestureDetector(
          onTap: _signInWithApple,
          child: Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/logo/apple.png',
                width: width * 0.06,
                height: width * 0.06,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLoginButton({
    required double width,
    required double height,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: SizedBox(
        width: width * 0.9,
        height: height * 0.07,
        child: Stack(
          alignment: Alignment.center, // 텍스트를 중앙 정렬
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EmailLoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey.shade300, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    '이메일로 로그인',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: width * 0.12, // 아이콘을 왼쪽 정렬
              child: const Icon(
                Icons.email_outlined,
                color: Colors.black,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '아직 회원이 아니신가요? ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: _showSignUpBottomSheet,
          child: const Text(
            ' 회원가입',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF33568C),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showSignUpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return const AgreementBottomSheet();
      },
    );
  }
}
