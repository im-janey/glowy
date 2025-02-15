import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'provider/activity_provider.dart';
import 'provider/category_provider.dart';
import 'firebase_options.dart';
import 'screens/home/home.dart';
import 'screens/intro/login.dart';
import 'screens/intro/splash.dart';
import 'provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'b9752314b9dc337ca3c64cb644e70781',
  );

  // 앱 실행
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final categoryProvider = CategoryProvider();
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              categoryProvider.fetchCategories(uid);
            }
            return categoryProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final activityProvider = ActivityProvider();
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              activityProvider.fetchActivities(); // ✅ UID 기반으로 필터링
              activityProvider.listenToActivities(); // ✅ UID 기반 실시간 데이터 구독
            }
            return activityProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
