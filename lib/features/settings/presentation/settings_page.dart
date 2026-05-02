import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/settings_controller.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.interpage.pikuman2';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settingsTitle'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.back,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _sectionTitle('sectionSound'.tr),
            _switchTile(title: 'sfxTitle'.tr, value: controller.sfxEnabled, onChanged: controller.setSfx),
            _switchTile(title: 'bgmTitle'.tr, value: controller.musicEnabled, onChanged: controller.setMusic),
            _sectionTitle('sectionVibration'.tr),
            _switchTile(
              title: 'vibrationTitle'.tr,
              value: controller.vibrationEnabled,
              onChanged: (v) {
                controller.setVibration(v);
                if (v) HapticFeedback.lightImpact();
              },
            ),
            _sectionTitle('sectionLanguage'.tr),
            _buildLanguageTiles(),
            _sectionTitle('sectionRating'.tr),
            _buildRatingTile(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.8)),
    );
  }

  Widget _switchTile({required String title, required RxBool value, required void Function(bool) onChanged}) {
    return Obx(() => SwitchListTile(
          title: Text(title),
          value: value.value,
          onChanged: onChanged,
          activeThumbColor: Colors.deepOrange,
        ));
  }

  Widget _buildLanguageTiles() {
    const codes = ['en', 'ko', 'es', 'ja'];
    const nameKeys = ['languageNameEn', 'languageNameKo', 'languageNameEs', 'languageNameJa'];
    return Obx(() {
      final current = controller.selectedLocaleCode.value;
      return Column(
        children: List.generate(codes.length, (i) {
          return ListTile(
            title: Text(nameKeys[i].tr),
            trailing: current == codes[i] ? Icon(Icons.check_circle, color: Colors.deepOrange.shade400) : null,
            onTap: () => controller.setLocale(codes[i]),
          );
        }),
      );
    });
  }

  Widget _buildRatingTile() {
    return ListTile(
      title: Text('ratingTitle'.tr),
      subtitle: Row(children: List.generate(5, (_) => Icon(Icons.star, color: Colors.amber.shade500, size: 22))),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: _openPlayStore,
    );
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not open Play Store.');
    }
  }
}
