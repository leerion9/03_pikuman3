// 게임 플레이 화면의 모든 상태와 로직을 담당하는 컨트롤러입니다.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/engine/puzzle_generator.dart';
import '../../../core/engine/puzzle_model.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/level_progress_service.dart';
import '../../../core/services/save_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/wordbook_service.dart';
import '../models/game_enums.dart';

/// 게임 플레이 컨트롤러.
///
/// 주요 역할:
///  - 레벨 번호 시드로 PuzzleBoard 생성
///  - 칸 선택·음절 입력·자동 다음 빈칸 이동 처리
///  - 경과 타이머 (앱 백그라운드 시 일시 정지)
///  - 유저 힌트 (판당 2회 제한, 선택 칸 오픈 or 랜덤 빈 칸 오픈)
///  - 세이브/로드 (음절 입력·타이머·힌트 횟수를 SharedPreferences에 저장)
///  - 레벨 클리어 감지 → 저장 초기화 + 레벨 진행 업데이트 + 결과 화면 이동
class GameController extends GetxController with WidgetsBindingObserver {
  GameController(this._data, this._save, this._progress, this._wordbook);

  final DataService _data;
  final SaveService _save;
  final LevelProgressService _progress;
  final WordbookService _wordbook;

  /// 판당 유저 힌트 최대 사용 횟수
  static const int _maxHints = 2;

  // ─── 퍼즐 상태 ───────────────────────────────────────────
  late PuzzleBoard _puzzle;
  late int _level;
  late Set<(int, int)> _hintPositions; // 퍼즐 힌트 타일 좌표 집합

  // ─── 반응형 상태 ─────────────────────────────────────────
  /// 사용자 입력 맵: 키="row,col", 값=입력 음절
  final _userInputs = <String, String>{}.obs;

  /// 현재 선택된 칸 (null 이면 선택 없음)
  final selectedPos = Rxn<(int, int)>();

  /// 현재 활성 단어 인덱스 (placedWords 기준, null 이면 없음)
  final currentWordIndex = RxnInt();

  /// 경과 시간 (초)
  final elapsedSeconds = 0.obs;

  /// 레벨 클리어 여부
  final isLevelComplete = false.obs;

  /// 유저가 이번 판에 사용한 힌트 횟수
  final hintsUsed = 0.obs;

  /// 음절 팔레트 (반응형).
  ///
  /// 아직 정답이 채워지지 않은 빈 칸의 음절만 포함합니다.
  /// 힌트 타일(미리 오픈된 칸)은 처음부터 포함하지 않습니다.
  /// 정답 음절이 입력되거나 힌트로 오픈되면 해당 음절이 제거됩니다.
  final palette = <String>[].obs;

  Timer? _timer;

  // ─── 공개 게터 ───────────────────────────────────────────
  PuzzleBoard get puzzle => _puzzle;
  int get level => _level;

  /// 이번 판에 남은 힌트 사용 횟수
  int get remainingHints => _maxHints - hintsUsed.value;

  /// 현재 활성화된 단어 (없으면 null)
  PlacedWord? get currentWord {
    final idx = currentWordIndex.value;
    if (idx == null || idx >= _puzzle.placedWords.length) return null;
    return _puzzle.placedWords[idx];
  }

  /// 경과 시간을 "MM:SS" 형식으로 반환합니다.
  String get formattedTime {
    final m = elapsedSeconds.value ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ─── 생명주기 ────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _level = Get.arguments as int? ?? 1;
    _initPuzzle();
    _loadSavedState();
    _syncPaletteAfterLoad(); // 저장된 상태 반영: 이미 정답이 입력된 칸의 음절 제거
    _startTimer();
    ever(isLevelComplete, _handleLevelComplete);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isLevelComplete.value) _startTimer();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _saveState(); // 백그라운드 진입 시 즉시 저장
    }
  }

  // ─── 초기화 ──────────────────────────────────────────────
  void _initPuzzle() {
    _puzzle = PuzzleGenerator.generate(
      level: _level,
      wordPool: _data.wordPool,
      designs: _data.levelDesigns,
    );
    _hintPositions = {
      for (final h in _puzzle.hintTiles) (h.row, h.col),
    };
    _buildPalette();
  }

  /// 빈 칸(힌트 타일 제외)의 정답 음절 목록을 셔플하여 팔레트를 초기화합니다.
  ///
  /// 힌트 타일은 이미 정답이 표시되므로 팔레트에 포함하지 않습니다.
  /// 같은 음절이 여러 빈 칸에 사용될 경우 중복 포함됩니다.
  void _buildPalette() {
    final syllables = <String>[];
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (_isHint(r, c)) continue; // 힌트 타일은 이미 오픈됨 → 팔레트 불필요
        syllables.add(pw.word.word[i]);
      }
    }
    syllables.shuffle(Random(_level + 999));
    palette.assignAll(syllables);
  }

  /// 저장된 상태 로드 후 이미 정답이 채워진 칸의 음절을 팔레트에서 제거합니다.
  void _syncPaletteAfterLoad() {
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (_isHint(r, c)) continue;
        if (_userInputs['$r,$c'] == pw.word.word[i]) {
          // 이미 정답이 입력된 칸 → 팔레트에서 해당 음절 제거
          palette.remove(pw.word.word[i]);
        }
      }
    }
  }

  // ─── 세이브/로드 ─────────────────────────────────────────
  /// 이전에 저장된 게임 진행 상태를 복원합니다.
  /// 저장 데이터가 없거나 다른 레벨의 데이터면 무시합니다.
  void _loadSavedState() {
    final saved = _save.load(_level);
    if (saved == null) return;

    elapsedSeconds.value = saved['elapsed'] as int;
    hintsUsed.value = saved['hintsUsed'] as int;

    final inputs = saved['inputs'] as Map<String, String>;
    _userInputs.addAll(inputs);
  }

  /// 현재 게임 진행 상태를 로컬에 저장합니다.
  Future<void> _saveState() async {
    await _save.save(
      level: _level,
      elapsedSeconds: elapsedSeconds.value,
      hintsUsed: hintsUsed.value,
      inputs: Map<String, String>.from(_userInputs),
    );
  }

  // ─── 타이머 ──────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => elapsedSeconds.value++,
    );
  }

  // ─── 칸 선택 ─────────────────────────────────────────────
  /// [row], [col] 칸을 선택합니다.
  ///
  /// - 단어가 없는 칸(검은 칸)은 무시합니다.
  /// - 교차점 칸을 재선택하면 가로 ↔ 세로 방향을 전환합니다.
  /// - 기본 선택 방향은 가로 우선입니다.
  void onCellTap(int row, int col) {
    if (isLevelComplete.value) return;
    if (_puzzle.grid[row][col].isEmpty) return;

    final pos = (row, col);
    final wordsHere = _puzzle.placedWords
        .where((w) => w.positions.contains(pos))
        .toList();
    if (wordsHere.isEmpty) return;

    if (selectedPos.value == pos && wordsHere.length > 1) {
      // 같은 교차점 재선택 → 방향 전환
      final curDir = currentWord?.direction;
      final toggled = wordsHere.firstWhere(
        (w) => w.direction != curDir,
        orElse: () => wordsHere.first,
      );
      currentWordIndex.value = _puzzle.placedWords.indexOf(toggled);
    } else {
      // 새 칸 선택: 가로 단어 우선
      final horiz =
          wordsHere.where((w) => w.direction == Direction.across).firstOrNull;
      currentWordIndex.value =
          _puzzle.placedWords.indexOf(horiz ?? wordsHere.first);
    }
    selectedPos.value = pos;
    _audio.playCellSelectSound(); // 빈칸 선택 효과음
  }

  // ─── 음절 입력 ───────────────────────────────────────────
  /// 팔레트에서 [syllable] 을 선택해 현재 칸에 입력합니다.
  ///
  /// 정답이면 팔레트에서 해당 음절을 제거합니다.
  void onSyllableTap(String syllable) {
    final pos = selectedPos.value;
    if (pos == null || isLevelComplete.value) return;
    if (_isHint(pos.$1, pos.$2)) return; // 퍼즐 힌트 칸은 입력 불가

    final correctAnswer = _puzzle.grid[pos.$1][pos.$2];
    final wordBeforeInput = currentWord; // 자동이동 전 현재 단어 보관

    _userInputs['${pos.$1},${pos.$2}'] = syllable;

    // 정답이면 팔레트에서 해당 음절 제거
    if (syllable == correctAnswer) {
      palette.remove(syllable);
    }

    _autoMove(pos);
    _saveState(); // 입력마다 상태 저장

    // 정답 여부에 따라 효과음 + 햅틱 피드백
    if (syllable != correctAnswer) {
      _audio.playWrongAnswerSound();
      _vibrate(); // 오답 진동
    } else if (wordBeforeInput != null && _isWordComplete(wordBeforeInput)) {
      _audio.playWordCompleteSound(); // 단어 완성 효과음
    }

    _checkLevelComplete();
  }

  /// 입력 후 현재 단어에서 다음 빈 칸으로 커서를 자동 이동합니다.
  void _autoMove((int, int) from) {
    final cw = currentWord;
    if (cw == null) return;
    final idx = cw.positions.indexOf(from);
    if (idx == -1) return;

    for (int i = idx + 1; i < cw.length; i++) {
      final next = cw.positions[i];
      if (!_isHint(next.$1, next.$2) && !_hasInput(next.$1, next.$2)) {
        selectedPos.value = next;
        return;
      }
    }
    // 현재 단어에 남은 빈 칸 없음 → 위치 유지
  }

  // ─── 힌트 기능 ───────────────────────────────────────────
  /// 힌트 버튼을 눌렀을 때 호출됩니다.
  ///
  /// 동작 규칙:
  ///  - 남은 힌트가 0이면 아무것도 하지 않습니다.
  ///  - 비어 있는 칸이 선택된 상태 → 해당 칸을 정답으로 오픈합니다.
  ///  - 선택 없음 또는 이미 채워진 칸 선택 → 아직 비어 있는 칸 중 하나를 랜덤 선택 후 오픈합니다.
  void onHintTap() {
    if (isLevelComplete.value) return;
    if (remainingHints <= 0) return;

    final pos = selectedPos.value;
    // 선택된 칸이 비어 있는 경우 → 그 칸을 오픈
    if (pos != null &&
        !_isHint(pos.$1, pos.$2) &&
        !_hasInput(pos.$1, pos.$2)) {
      _revealCell(pos.$1, pos.$2);
      return;
    }

    // 그 외 → 비어 있는 칸 중 랜덤 선택
    _revealRandomEmptyCell();
  }

  /// [row],[col] 칸을 정답 음절로 채우고, 팔레트에서 해당 음절을 제거하며,
  /// 힌트 사용 횟수를 1 증가시킵니다.
  void _revealCell(int row, int col) {
    final correctSyllable = _puzzle.grid[row][col];
    _userInputs['$row,$col'] = correctSyllable;
    palette.remove(correctSyllable); // 힌트 오픈 시 팔레트에서 제거
    hintsUsed.value++;
    _saveState();
    _checkLevelComplete();
  }

  /// 아직 비어 있는 칸(퍼즐 힌트·정답이 아닌) 중 하나를 랜덤 선택해 오픈합니다.
  void _revealRandomEmptyCell() {
    final emptyCells = <(int, int)>[];
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (!_isHint(r, c) && !_hasInput(r, c)) {
          emptyCells.add((r, c));
        }
      }
    }
    if (emptyCells.isEmpty) return;

    final chosen = emptyCells[Random().nextInt(emptyCells.length)];
    _revealCell(chosen.$1, chosen.$2);
    selectedPos.value = chosen; // 오픈된 칸으로 커서 이동
  }

  // ─── 레벨 클리어 감지 ────────────────────────────────────
  /// 모든 빈 칸이 정답으로 채워졌는지 확인합니다.
  void _checkLevelComplete() {
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (_isHint(r, c)) continue; // 퍼즐 힌트 칸은 이미 정답
        if (_userInputs['$r,$c'] != pw.word.word[i]) return; // 틀리거나 비어 있음
      }
    }
    isLevelComplete.value = true;
    _timer?.cancel();
  }

  /// 레벨 클리어 시 처리합니다.
  /// 단어 저장 → 게임 상태 삭제 → 레벨 진행 업데이트 → 결과 화면으로 이동.
  void _handleLevelComplete(bool complete) {
    if (!complete) return;
    _audio.playLevelClearSound(); // 레벨 클리어 효과음 즉시 재생
    _tryShowInterstitial(); // 10레벨마다 전면 광고
    Future.delayed(const Duration(milliseconds: 500), () async {
      // 이번 레벨 단어 목록을 단어장에 저장
      final wordEntries = _puzzle.placedWords
          .map((pw) => WordEntry(word: pw.word.word, meaning: pw.word.meaning))
          .toList();
      await _wordbook.saveLevel(_level, wordEntries);
      // 저장된 게임 상태 삭제 (클리어했으므로 더 이상 필요 없음)
      await _save.clear();
      // 다음 레벨을 현재 진행 레벨로 저장
      await _progress.setCurrentLevel(_level + 1);
      // 결과 화면으로 이동 (뒤로가기 시 게임 화면으로 돌아오지 않음)
      Get.offNamed(
        AppRoutes.result,
        arguments: {
          'level': _level,
          'elapsed': elapsedSeconds.value,
          'words': _puzzle.placedWords,
        },
      );
    });
  }

  // ─── 칸 상태 조회 (그리드 위젯에서 사용) ─────────────────
  /// [row], [col] 칸의 시각적 표시 상태를 반환합니다.
  CellDisplayState cellState(int row, int col) {
    if (_puzzle.grid[row][col].isEmpty) return CellDisplayState.inactive;
    if (selectedPos.value == (row, col)) return CellDisplayState.selected;
    if (_isHint(row, col)) return CellDisplayState.hint;

    final input = _userInputs['$row,$col'];
    if (input != null) {
      return input == _puzzle.grid[row][col]
          ? CellDisplayState.correct
          : CellDisplayState.incorrect;
    }

    final cw = currentWord;
    if (cw != null && cw.positions.contains((row, col))) {
      return CellDisplayState.activeWord;
    }
    return CellDisplayState.empty;
  }

  /// [row], [col] 칸에 표시할 글자를 반환합니다.
  /// 퍼즐 힌트 칸이면 정답 글자, 그 외엔 사용자 입력값 (없으면 null).
  String? displayLetter(int row, int col) {
    if (_isHint(row, col)) return _puzzle.grid[row][col];
    return _userInputs['$row,$col'];
  }

  bool _isHint(int row, int col) => _hintPositions.contains((row, col));
  bool _hasInput(int row, int col) => _userInputs.containsKey('$row,$col');

  /// [word] 의 모든 칸이 정답으로 채워졌는지 확인합니다 (힌트 칸 포함).
  bool _isWordComplete(PlacedWord word) {
    for (int i = 0; i < word.length; i++) {
      final (r, c) = word.positions[i];
      if (_isHint(r, c)) continue;
      if (_userInputs['$r,$c'] != word.word.word[i]) return false;
    }
    return true;
  }

  // ─── 사운드·진동·광고 헬퍼 ──────────────────────────────
  /// AudioService 를 반환합니다 (항상 등록되어 있음).
  AudioService get _audio => Get.find<AudioService>();

  /// 진동 설정이 켜져 있으면 햅틱 피드백을 발생시킵니다.
  void _vibrate() {
    try {
      if (Get.find<SettingsService>().vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  /// 10레벨마다 전면 광고를 표시합니다.
  void _tryShowInterstitial() {
    try {
      Get.find<AdService>().showInterstitialEvery10Levels(_level);
    } catch (_) {}
  }

  void goBack() => Get.back();
}
