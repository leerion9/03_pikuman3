// 게임 화면 하단의 음절 팔레트 위젯입니다.

import 'package:flutter/material.dart';

/// 음절 팔레트 위젯.
///
/// 해당 레벨 퍼즐에 사용된 모든 단어의 음절을 중복 없이 타일로 표시합니다.
/// 타일을 탭하면 [onTap] 콜백으로 선택된 음절을 전달합니다.
class SyllablePaletteWidget extends StatelessWidget {
  /// 표시할 음절 목록 (셔플됨)
  final List<String> syllables;

  /// 타일 탭 시 호출되는 콜백
  final void Function(String syllable) onTap;

  const SyllablePaletteWidget({
    super.key,
    required this.syllables,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // 팔레트 최대 높이 제한 (초과 시 스크롤 가능)
      constraints: const BoxConstraints(maxHeight: 140),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: syllables.map(_buildTile).toList(),
        ),
      ),
    );
  }

  Widget _buildTile(String syllable) {
    return GestureDetector(
      onTap: () => onTap(syllable),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B2B),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            syllable,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
