// 단어장 화면 스텁 (Phase 6 구현 예정)

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 단어장 화면 스텁
class WordbookPage extends StatelessWidget {
  const WordbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('wordbookTitle'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: Text(
          '단어장 화면\n(Phase 6 구현 예정)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
