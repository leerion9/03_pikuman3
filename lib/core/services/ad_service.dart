// 광고 서비스: AdMob 전면 광고를 로드하고 10레벨마다 표시합니다.

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 전면 광고 로드·표시를 담당하는 서비스.
class AdService extends GetxService {
  InterstitialAd? _interstitialAd;

  /// 전면 광고 ID (출시 전 실제 ID로 교체 필요)
  static String get interstitialAdUnitId {
    return 'ca-app-pub-2850426593033777/9348660021';
  }

  /// 앱 시작 시 전면 광고를 미리 로드합니다.
  Future<void> init() async {
    if (kIsWeb) return;
    await loadInterstitial();
  }

  /// 전면 광고를 로드합니다.
  Future<void> loadInterstitial() async {
    if (kIsWeb) return;
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _setFullScreenCallback(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            debugPrint('[AdService] 전면 광고 로드 실패: $error');
          }
          _interstitialAd = null;
        },
      ),
    );
  }

  void _setFullScreenCallback(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
      },
    );
  }

  /// 10레벨마다 전면 광고를 표시합니다.
  void showInterstitialEvery10Levels(int clearedLevel) {
    if (kIsWeb) return;
    if (clearedLevel <= 0 || clearedLevel % 10 != 0) return;
    if (_interstitialAd == null) return;
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
