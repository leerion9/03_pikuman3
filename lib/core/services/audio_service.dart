// 오디오 서비스: BGM과 효과음(빈칸 선택·단어 완성·오답·레벨 클리어)을 재생합니다.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'settings_service.dart';

/// BGM과 효과음을 담당하는 오디오 서비스.
class AudioService extends GetxService with WidgetsBindingObserver {
  /// BGM 볼륨 (pikuman2와 동일: 100%)
  static const double bgmVolume = 1.0;

  /// 효과음 볼륨 (pikuman2와 동일: 30%)
  static const double sfxVolume = 0.3;

  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;
  bool _isBgmPlaying = false;

  SettingsService get _settings => Get.find<SettingsService>();

  void _log(String msg) {
    if (kDebugMode) debugPrint('[AudioService] $msg');
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
    _sfxPlayer = AudioPlayer(playerId: 'sfx_player');
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _sfxPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        isSpeakerphoneOn: false,
        stayAwake: false,
      ),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    ));
    playBgm();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        resumeBgm();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pauseBgm();
    }
  }

  Future<void> playBgm() async {
    if (!_settings.musicEnabled) return;
    if (_isBgmPlaying) return;
    try {
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'), volume: bgmVolume);
      _isBgmPlaying = true;
    } catch (e) {
      _log('BGM 재생 실패: $e');
    }
  }

  Future<void> pauseBgm() async {
    if (!_isBgmPlaying) return;
    try {
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
    } catch (e) {
      _log('BGM 일시정지 실패: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (!_settings.musicEnabled) return;
    if (_isBgmPlaying) return;
    try {
      await _bgmPlayer.resume();
      _isBgmPlaying = true;
    } catch (e) {
      await playBgm();
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _isBgmPlaying = false;
    } catch (e) {
      _log('BGM 정지 실패: $e');
    }
  }

  Future<void> _playSfx(String assetPath) async {
    if (!_settings.sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath), volume: sfxVolume);
    } catch (e) {
      _log('효과음 재생 실패 ($assetPath): $e');
    }
  }

  /// 빈칸 선택 효과음
  Future<void> playCellSelectSound() async => _playSfx('sounds/cell_select.wav');

  /// 단어 완성 효과음
  Future<void> playWordCompleteSound() async => _playSfx('sounds/equation_complete.wav');

  /// 오답 입력 효과음
  Future<void> playWrongAnswerSound() async => _playSfx('sounds/tile_incorrect.wav');

  /// 레벨 클리어 효과음
  Future<void> playLevelClearSound() async => _playSfx('sounds/level_clear.mp3');
}
