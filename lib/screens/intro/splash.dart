import 'dart:async';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _orbAnimations = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration
    );

    // Create a fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize floating animations for orbs
    _initOrbAnimations();

    // Start animation
    _animationController.forward();

    // Navigate to login page after 2.5 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  void _initOrbAnimations() {
    List<double> delays = [0.0, 0.2, 0.4, 0.6]; // 각 구슬의 애니메이션 딜레이

    _orbAnimations = delays.map((delay) {
      return Tween<Offset>(
        begin: const Offset(0, 0.1), // 약간 아래에서 시작
        end: const Offset(0, 0), // 원래 위치로 부드럽게 이동
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 1.0, curve: Curves.easeInOut),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildOrb(
    BuildContext context,
    int index,
    double topFactor, // Vertical position factor
    double leftFactor, // Horizontal position factor
    double widthFactor, // Width factor
    double heightFactor, // Height factor
    String imageName,
    double rotation,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _orbAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: _orbAnimations[index].value * screenHeight, // Y축 이동
          child: Positioned(
            top: screenHeight * topFactor,
            left: screenWidth * leftFactor,
            child: Transform(
              transform: Matrix4.identity()..rotateZ(rotation),
              child: Container(
                width:
                    screenWidth * widthFactor, // Proportional to screen width
                height: screenHeight *
                    heightFactor, // Proportional to screen height
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/orb/$imageName'),
                    fit: BoxFit.cover,
                  ),
                  shape: const OvalBorder(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOrbs(BuildContext context) {
    return [
      _buildOrb(context, 0, 0.15, 0.05, 0.36, 0.28, 'green1.png', -0.31),
      _buildOrb(context, 1, 0.17, 0.53, 0.45, 0.37, 'purple1.png', 0.15),
      _buildOrb(context, 2, 0.08, -0.7, 1.2, 1.2, 'red1.png', -0.3),
      _buildOrb(context, 3, 0.07, 0.2, 1.2, 1.2, 'blue1.png', 0.1),
    ];
  }

  Widget _buildPage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Background Gradient
        Container(
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
        ),

        // Orbs with animation
        ..._buildOrbs(context),

        // Animated GLOWY Image
        Positioned(
          bottom: screenHeight * 0.1, // Responsive padding from the bottom
          left: screenWidth * 0.32, // Center the image horizontally
          right: screenWidth * 0.32,
          child: FadeTransition(
            opacity: _fadeAnimation, // Apply fade animation
            child: Image.asset(
              'assets/logo/GLOWY.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(context),
    );
  }
}
