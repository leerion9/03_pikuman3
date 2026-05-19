// 게임 플레이 화면 (Phase 4 구현 예정)

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 게임 플레이 화면 스텁
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final level = Get.arguments as int? ?? 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: Text(
          '게임 화면\n(Phase 4 구현 예정)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
