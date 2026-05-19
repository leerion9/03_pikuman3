// 하단 고정 배너 광고 위젯: AdMob 배너를 로드해서 표시합니다.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 화면 하단 배너 광고 위젯
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  /// 배너 광고 ID (출시 전 실제 ID로 교체 필요)
  static String get _adUnitId => 'ca-app-pub-2850426593033777/7736195455';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  Future<void> _loadAd() async {
    if (kIsWeb || !mounted) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (!mounted) return;
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;

    final ad = BannerAd(
      adUnitId: _adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
    if (mounted) setState(() => _bannerAd = ad);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        height: 50,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Text(
          'bannerAdPlaceholder'.tr,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      );
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
