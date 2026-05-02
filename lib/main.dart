import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    Get.put<AdService>(AdService(), permanent: true);
    await Get.find<AdService>().init();
  }

  final prefs = await SharedPreferences.getInstance();
  Get.put<SettingsService>(SettingsService(prefs), permanent: true);
  Get.put<AudioService>(AudioService(), permanent: true);

  Get.locale = Locale(Get.find<SettingsService>().localeCode);

  runApp(const App());
}
