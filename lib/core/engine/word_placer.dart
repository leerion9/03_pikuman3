// word_pool 에서 단어를 골라 크로스워드 보드에 배치하는 알고리즘입니다.

import 'dart:math';

import '../data/word_model.dart';
import 'puzzle_model.dart';

/// 크로스워드 단어 배치기 (Incremental Growth 방식).
///
/// 동작 순서:
///  1. 첫 단어를 보드 중앙에 가로로 배치
///  2. 이미 배치된 단어와 교차 가능한 모든 후보 위치를 탐색
///  3. 후보를 랜덤 셔플 후 유효한 위치에 배치
///  4. word_count 에 도달하거나 단어 풀이 소진될 때까지 반복
///  5. 한 단어에 대해 유효 위치가 없으면 다음 단어로 넘어감 (Freezing 방지)
class WordPlacer {
  /// 보드 행 수 (세로)
  static const int _rows = PuzzleBoard.boardRows; // 8

  /// 보드 열 수 (가로)
  static const int _cols = PuzzleBoard.boardCols; // 10

  /// 시드 기반 난수 생성기
  final Random _rng;

  /// 배치 중인 2D 격자: _grid[row][col] = 음절 문자 (빈칸이면 '')
  final List<List<String>> _grid;

  /// 배치 완료된 단어 목록
  final List<PlacedWord> _placed;

  /// [seed] 를 시드로 사용해 WordPlacer 를 생성합니다.
  WordPlacer(int seed)
      : _rng = Random(seed),
        _grid = List.generate(_rows, (_) => List.filled(_cols, '')),
        _placed = [];

  // ─── 공개 API ────────────────────────────────────────────

  /// [pool] 에서 최대 [wordCount] 개의 단어를 보드에 배치하고 결과를 반환합니다.
  ///
  /// [pool] 은 호출 전에 시드로 미리 셔플된 상태여야 합니다.
  List<PlacedWord> place(List<WordModel> pool, int wordCount) {
    if (pool.isEmpty) return const [];

    // 첫 번째 단어: 교차 없이 중앙에 배치
    _placeFirstWord(pool[0]);

    // 나머지 단어를 순서대로 시도 (배치 실패 시 다음 단어로 넘어감)
    for (int i = 1; i < pool.length && _placed.length < wordCount; i++) {
      _tryPlace(pool[i]);
    }

    return List.unmodifiable(_placed);
  }

  /// 배치 완료된 격자의 복사본을 반환합니다.
  List<List<String>> get grid =>
      _grid.map((row) => List<String>.from(row)).toList();

  // ─── 내부 메서드 ─────────────────────────────────────────

  /// 첫 단어를 보드 중앙에 가로로 배치합니다.
  void _placeFirstWord(WordModel word) {
    final row = _rows ~/ 2 - 1; // 세로 중앙 (행 3)
    final col = (_cols - word.syllableCount) ~/ 2; // 가로 중앙
    if (col >= 0) _apply(word, row, col, Direction.across);
  }

  /// 단어 하나를 보드에 배치 시도합니다. 유효 위치가 없으면 조용히 건너뜁니다.
  void _tryPlace(WordModel word) {
    final candidates = _findCandidates(word)..shuffle(_rng);
    for (final (r, c, dir) in candidates) {
      if (_isValid(word, r, c, dir)) {
        _apply(word, r, c, dir);
        return;
      }
    }
  }

  /// 보드에서 [word] 를 배치할 수 있는 후보 위치 목록을 반환합니다.
  ///
  /// 기존에 배치된 단어의 글자와 교차할 수 있는 (행, 열, 방향) 조합을 탐색합니다.
  List<(int, int, Direction)> _findCandidates(WordModel word) {
    // Set 을 사용해 중복 후보 제거
    final result = <(int, int, Direction)>{};

    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_grid[r][c].isEmpty) continue;
        final ch = _grid[r][c];

        // 새 단어의 글자 중 일치하는 인덱스 i 를 찾아 후보 추가
        for (int i = 0; i < word.syllableCount; i++) {
          if (word.word[i] != ch) continue;

          // 가로 배치: i번째 글자가 (r, c) 위치 → 시작 열 = c - i
          result.add((r, c - i, Direction.across));

          // 세로 배치: i번째 글자가 (r, c) 위치 → 시작 행 = r - i
          result.add((r - i, c, Direction.down));
        }
      }
    }

    return result.toList();
  }

  /// 주어진 위치·방향으로 [word] 를 배치할 수 있는지 검사합니다.
  ///
  /// 아래의 규칙을 모두 통과해야 배치 가능 판정을 내립니다:
  ///  - 보드 범위 내에 완전히 들어올 것
  ///  - 단어 머리·꼬리의 앞뒤 칸이 비어 있을 것
  ///  - 기존 글자와 충돌 없이 교차할 것 (같은 방향 단어가 이미 있으면 불가)
  ///  - 비교차 칸의 수직 인접 칸이 비어 있을 것 (평행 접촉 금지)
  ///  - 최소 1개 이상의 교차점이 있을 것
  bool _isValid(WordModel word, int startRow, int startCol, Direction dir) {
    final len = word.syllableCount;

    // ── 1) 범위 체크 ──────────────────────────────────────
    if (dir == Direction.across) {
      if (startRow < 0 || startRow >= _rows) return false;
      if (startCol < 0 || startCol + len > _cols) return false;
    } else {
      if (startCol < 0 || startCol >= _cols) return false;
      if (startRow < 0 || startRow + len > _rows) return false;
    }

    // ── 2) 머리·꼬리 여유 공간 체크 ──────────────────────
    if (dir == Direction.across) {
      if (startCol > 0 && _grid[startRow][startCol - 1].isNotEmpty) {
        return false;
      }
      if (startCol + len < _cols &&
          _grid[startRow][startCol + len].isNotEmpty) {
        return false;
      }
    } else {
      if (startRow > 0 && _grid[startRow - 1][startCol].isNotEmpty) {
        return false;
      }
      if (startRow + len < _rows &&
          _grid[startRow + len][startCol].isNotEmpty) {
        return false;
      }
    }

    bool hasIntersection = false;

    // ── 3) 각 칸 검사 ─────────────────────────────────────
    for (int i = 0; i < len; i++) {
      final r = dir == Direction.across ? startRow : startRow + i;
      final c = dir == Direction.across ? startCol + i : startCol;
      final expected = word.word[i];

      if (_grid[r][c].isNotEmpty) {
        // 기존 글자와 다르면 배치 불가
        if (_grid[r][c] != expected) return false;

        // 같은 방향 단어가 이미 이 칸을 사용 중이면 배치 불가
        if (_hasWordThrough(r, c, dir)) return false;

        // 반드시 수직 방향 단어가 있어야 교차점으로 인정
        final perpDir =
            dir == Direction.across ? Direction.down : Direction.across;
        if (!_hasWordThrough(r, c, perpDir)) return false;

        hasIntersection = true;
      } else {
        // 빈 칸: 수직 인접 칸이 비어 있어야 함 (평행 접촉 금지)
        if (dir == Direction.across) {
          if (r > 0 && _grid[r - 1][c].isNotEmpty) return false;
          if (r + 1 < _rows && _grid[r + 1][c].isNotEmpty) return false;
        } else {
          if (c > 0 && _grid[r][c - 1].isNotEmpty) return false;
          if (c + 1 < _cols && _grid[r][c + 1].isNotEmpty) return false;
        }
      }
    }

    // 최소 1개 이상의 교차점이 있어야 배치 가능
    return hasIntersection;
  }

  /// [row], [col] 을 지나는 [dir] 방향의 단어가 있으면 true 를 반환합니다.
  bool _hasWordThrough(int row, int col, Direction dir) {
    for (final pw in _placed) {
      if (pw.direction != dir) continue;
      if (dir == Direction.across &&
          pw.row == row &&
          col >= pw.col &&
          col < pw.col + pw.length) {
        return true;
      }
      if (dir == Direction.down &&
          pw.col == col &&
          row >= pw.row &&
          row < pw.row + pw.length) {
        return true;
      }
    }
    return false;
  }

  /// 검증을 통과한 단어를 보드에 실제로 기록합니다.
  void _apply(WordModel word, int startRow, int startCol, Direction dir) {
    _placed.add(
      PlacedWord(word: word, row: startRow, col: startCol, direction: dir),
    );
    for (int i = 0; i < word.syllableCount; i++) {
      final r = dir == Direction.across ? startRow : startRow + i;
      final c = dir == Direction.across ? startCol + i : startCol;
      _grid[r][c] = word.word[i];
    }
  }
}
