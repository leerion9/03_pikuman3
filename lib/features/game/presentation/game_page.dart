// 게임 플레이 화면 UI: 헤더, 크로스워드 그리드, 음절 팔레트, 힌트 버튼을 조립합니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/banner_ad_widget.dart';
import '../controllers/game_controller.dart';
import 'widgets/crossword_grid_widget.dart';
import 'widgets/syllable_palette_widget.dart';

/// 게임 플레이 화면.
///
/// 레이아웃 (위→아래):
///  1. 헤더 — "Level N" + 경과 타이머
///  2. 크로스워드 그리드 (10×8)
///  3. 음절 팔레트
///  4. 힌트 버튼 (Phase 5 에서 기능 구현)
///  5. 하단 배너 광고
class GamePage extends GetView<GameController> {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            // 그리드: 화면 너비를 기준으로 고정 높이
            CrosswordGridWidget(controller: controller),
            // 남은 공간을 팔레트 + 힌트 버튼이 채움
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPalette(),
                  _buildHintButton(),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            // 하단 배너 광고
            const SafeArea(top: false, child: BannerAdWidget()),
          ],
        ),
      ),
    );
  }

  /// 레벨 번호와 경과 타이머를 표시하는 헤더
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFFF6B2B),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: controller.goBack,
            tooltip: '뒤로',
          ),
          Expanded(
            child: Text(
              'Level ${controller.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Obx(
            () => Text(
              controller.formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// 음절 팔레트 영역
  Widget _buildPalette() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEEEEEE),
      child: SyllablePaletteWidget(
        syllables: controller.palette,
        onTap: controller.onSyllableTap,
      ),
    );
  }

  /// 힌트 버튼: 남은 횟수를 표시하며, 0이 되면 비활성화됩니다.
  Widget _buildHintButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final remaining = controller.remainingHints;
        final active =
            remaining > 0 && !controller.isLevelComplete.value;
        return OutlinedButton.icon(
          onPressed: active ? controller.onHintTap : null,
          icon: Icon(
            Icons.lightbulb_outline,
            color: active ? const Color(0xFFFF6B2B) : Colors.grey,
          ),
          label: Text(
            '힌트  남은 횟수: $remaining회',
            style: TextStyle(
              color: active ? const Color(0xFFFF6B2B) : Colors.grey,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            side: BorderSide(
              color: active ? const Color(0xFFFF6B2B) : Colors.grey,
            ),
          ),
        );
      }),
    );
  }
}
