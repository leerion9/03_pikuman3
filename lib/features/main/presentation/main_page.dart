// 메인 화면 UI: 현재 레벨 표시, Play/단어장 버튼, 하단 배너 광고를 제공합니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../controllers/main_controller.dart';

/// 메인 화면
class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildCenter(context)),
            const SafeArea(top: false, child: BannerAdWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'pikuman3 : word puzzle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B2B),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCharacterImage(context),
        const SizedBox(height: 24),
        _buildLevelAndButtons(),
      ],
    );
  }

  Widget _buildCharacterImage(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.35;
    return Image.asset(
      'assets/images/pikuman_back.png',
      fit: BoxFit.contain,
      height: imageHeight,
      errorBuilder: (_, __, ___) => SizedBox(height: imageHeight),
    );
  }

  Widget _buildLevelAndButtons() {
    return Obx(() {
      final level = controller.currentLevel.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Text(
              'currentLevel'.trParams({'level': '$level'}),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: controller.goToGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('PLAY'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: controller.goToWordbook,
            icon: const Icon(Icons.menu_book_outlined),
            label: Text('wordbook'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: const BorderSide(color: Color(0xFFFF6B2B)),
              foregroundColor: const Color(0xFFFF6B2B),
            ),
          ),
        ],
      );
    });
  }
}
