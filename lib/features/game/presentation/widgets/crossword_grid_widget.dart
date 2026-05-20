// 크로스워드 퍼즐 그리드(10×8) UI 위젯입니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/engine/puzzle_model.dart';
import '../../controllers/game_controller.dart';
import '../../models/game_enums.dart';

/// 10열 × 8행 크로스워드 그리드 위젯.
///
/// - 화면 너비에 맞춰 셀 크기를 자동 계산합니다.
/// - Obx 로 감싸서 입력·선택 상태 변화 시 자동 리렌더합니다.
/// - 검은 칸(inactive)은 진한 배경으로, 활성 칸은 상태별 색상으로 표시합니다.
class CrosswordGridWidget extends StatelessWidget {
  final GameController controller;

  const CrosswordGridWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // 화면 너비에서 좌우 패딩을 제외한 만큼을 10칸으로 나눠 셀 크기를 계산합니다.
    final cellSize =
        (MediaQuery.of(context).size.width - 8) / PuzzleBoard.boardCols;

    return Container(
      color: const Color(0xFF37474F), // 그리드 배경 (진한 청회색)
      padding: const EdgeInsets.all(2),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            PuzzleBoard.boardRows,
            (row) => Row(
              children: List.generate(
                PuzzleBoard.boardCols,
                (col) => _buildCell(row, col, cellSize),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double size) {
    final state = controller.cellState(row, col);
    final letter = controller.displayLetter(row, col);

    // 검은 칸: 배경만 표시, 터치 영역 없음
    if (state == CellDisplayState.inactive) {
      return SizedBox(width: size, height: size);
    }

    return GestureDetector(
      onTap: () => controller.onCellTap(row, col),
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(0.8),
        decoration: BoxDecoration(
          color: _bgColor(state),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Text(
            letter ?? '',
            style: TextStyle(
              fontSize: size * 0.48,
              fontWeight: FontWeight.bold,
              color: _textColor(state),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  /// 셀 배경색: 상태별로 다른 색상을 반환합니다.
  Color _bgColor(CellDisplayState state) => switch (state) {
        CellDisplayState.inactive => Colors.transparent,
        CellDisplayState.empty => Colors.white,
        CellDisplayState.activeWord => const Color(0xFFBBDEFB), // blue-100
        CellDisplayState.selected => const Color(0xFFFFD54F), // amber-300
        CellDisplayState.hint => const Color(0xFFA5D6A7), // green-200
        CellDisplayState.correct => const Color(0xFF81C784), // green-300
        CellDisplayState.incorrect => const Color(0xFFEF9A9A), // red-200
      };

  /// 셀 텍스트 색상: 오답은 진한 빨간색, 그 외는 진한 회색
  Color _textColor(CellDisplayState state) =>
      state == CellDisplayState.incorrect
          ? const Color(0xFFB71C1C)
          : const Color(0xFF212121);
}
