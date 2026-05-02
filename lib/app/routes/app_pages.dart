// ?±ì˜ ëª¨ë“  ?¼ìš°???”ë©´ ê²½ë¡œ) ?´ë¦„ê³?GetPage ëª©ë¡???•ì˜?˜ëŠ” ?Œì¼?…ë‹ˆ??

import 'package:get/get.dart';

import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/main/bindings/main_binding.dart';
import '../../features/main/presentation/main_page.dart';
import '../../features/completion/bindings/completion_binding.dart';
import '../../features/completion/presentation/completion_page.dart';
import '../../features/game/bindings/game_binding.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/presentation/settings_page.dart';

/// ?¼ìš°???´ë¦„ ?ìˆ˜ (?”ë©´ ?´ë™ ???¬ìš©)
abstract class AppRoutes {
  static const splash = '/splash';
  static const main = '/main';
  static const game = '/game';
  static const completion = '/completion';
  static const settings = '/settings';
}

/// GetX ?¼ìš°??ëª©ë¡ (ê²½ë¡œ ???”ë©´Â·ë°”ì¸??ë§¤í•‘)
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GamePage(),
      binding: GameBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.completion,
      page: () => const CompletionPage(),
      binding: CompletionBinding(),
    ),
  ];
}
