// 게임 결과 화면 스텁 (Phase 6 구현 예정)

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';

/// 게임 결과 화면 스텁
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final level = Get.arguments as int? ?? 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level 클리어!'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '결과 화면\n(Phase 6 구현 예정)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.main),
              child: const Text('홈'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.offNamed(AppRoutes.game, arguments: level + 1),
              child: const Text('다음 레벨'),
            ),
          ],
        ),
      ),
    );
  }
}
