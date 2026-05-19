// 앱 최초 실행 시 공통으로 주입되는 바인딩 파일입니다.

import 'package:get/get.dart';

/// 앱 시작 시 한 번만 등록하는 전역 바인딩.
/// main.dart에서 서비스 등록이 완료되므로 별도 항목 없음.
class InitialBinding extends Bindings {
  @override
  void dependencies() {}
}
