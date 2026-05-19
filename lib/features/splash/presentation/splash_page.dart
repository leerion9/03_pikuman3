// 스플래시 화면 UI: 앱 최초 실행 시 잠깐 보여주는 화면입니다.
// 스플래시1(회사 로고) -> 스플래시2(게임 로고 + 로딩) -> 메인 화면 순서로 전환합니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';

/// 스플래시 화면 (회사 로고 -> 게임 로고 -> 메인)
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _stage = 1; // 1: 회사 로고, 2: 게임 로고+로딩

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _stage = 2);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Get.offNamed(AppRoutes.main);
  }

  static const Color _splash1Bg = Color(0xFF00B0F0); // 하늘색
  static const Color _splash2Bg = Color(0xFFCC0000); // 빨간색

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _stage == 1 ? _splash1Bg : _splash2Bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _stage == 1 ? _buildStage1() : _buildStage2(),
      ),
    );
  }

  /// 스플래시 1단계: interpage 회사 로고 전체 화면
  Widget _buildStage1() {
    return SizedBox.expand(
      key: const ValueKey('stage1'),
      child: Image.asset(
        'assets/splash/splash_1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  /// 스플래시 2단계: 게임 로고 + 로딩 인디케이터
  Widget _buildStage2() {
    return Stack(
      key: const ValueKey('stage2'),
      fit: StackFit.expand,
      children: [
        Image.asset('assets/splash/splash2.png', fit: BoxFit.cover),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            minimum: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: const [Shadow(blurRadius: 8, color: Colors.black26)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
