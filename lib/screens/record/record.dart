import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Page'),
      ),
      body: const Center(
        child: Text('이곳에 기록 페이지 관련 내용을 작성하세요.'),
      ),
    );
  }
}
