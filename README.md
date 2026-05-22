# pikuman3 : word puzzle

**한글 크로스워드 퍼즐 게임**  
패키지명: `pikuman3_word_puzzle` | 앱 ID: `com.interpage.pikuman3`  
타겟: 안드로이드 플레이스토어

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱 종류 | 한글 크로스워드 퍼즐 게임 |
| 지원 언어 | 한국어 단독 |
| 레벨 구조 | 시드 기반 무한 생성 (101 레벨 이후는 101 레벨과 동일 난이도 적용) |
| 퍼즐 구조 | 가로 10칸 × 세로 8칸 |
| 단어 범위 | 3~5 음절 명사 (외래어·지명·국가명·사자성어·동물명·식물명) |
| 클루(단어 설명 번호) | 없음. 순수 음절 배치 퍼즐 방식 |
| 광고 모델 | 하단 배너 광고 + 10 레벨마다 전면 광고 |
| 타겟 플랫폼 | 안드로이드 |

---

## 기술 스택

| 분야 | 기술 |
|------|------|
| 프레임워크 | Flutter (Stable) |
| 언어 | Dart |
| 상태관리·라우팅 | GetX |
| 로컬 저장 | SharedPreferences |
| 광고 | Google AdMob (`google_mobile_ads`) |
| 오디오 | audioplayers |
| 앱 평가 | Google Play In-App Review API + 스토어 이동 fallback |
| 외부 링크 | url_launcher |

---

## 폴더 구조

```
lib/
├── core/
│   ├── data/          # 단어·레벨 CSV 로더
│   ├── engine/        # 퍼즐 생성 엔진 (배치, 힌트 선정)
│   ├── services/      # 저장, 오디오, 광고, 설정 서비스
│   └── widgets/       # 공통 위젯 (배너 광고 등)
└── features/
    ├── splash/        # 스플래시 화면 1, 2
    ├── main/          # 메인 화면
    ├── game/          # 게임 플레이 화면
    ├── result/        # 게임 결과 화면
    ├── wordbook/      # 단어장 화면
    └── settings/      # 설정 화면

assets/
├── data/
│   ├── word_pool.csv      # 단어 풀 (word, meaning, category, syllable_count)
│   └── level_design.csv   # 레벨별 난이도 (level, word_count, hint_count)
├── images/            # 앱 아이콘, 로고, 캐릭터 이미지
├── sounds/            # BGM, 효과음 (mp3)
├── splash/            # 스플래시 이미지
└── fonts/             # 폰트
```

---

## 화면 구성 요약

| 화면 | 주요 내용 |
|------|---------|
| 스플래시 1 | 하늘색 배경 + interpage 로고 |
| 스플래시 2 | 빨간 배경 + pikuMAN 캐릭터 + 로딩 표시 |
| 메인 | 캐릭터 + "현재 레벨 : N" + Play / 단어장 버튼 + 하단 배너 |
| 게임 플레이 | Level N 헤더 + 경과 타이머 + 크로스워드 그리드 + 음절 팔레트 + hint 버튼 + 하단 배너 |
| 게임 결과 | 레벨 클리어 + 등장 단어 전체 목록 + 단어 뜻 + Home / Next Level 버튼 |
| 단어장 | 클리어한 레벨의 단어·뜻 목록. **최신 레벨이 가장 위**, 스크롤로 이전 레벨 확인 |
| 설정 | music / sound / vibration 토글 + 평점 버튼 |

---

## 핵심 게임 규칙 요약

| 항목 | 내용 |
|------|------|
| 타이머 | 경과 시간 방식 (증가). 제한 시간 없음. 앱 백그라운드 시 일시 정지 |
| 레벨 표시 | 숫자 단독 (예: `121`). 분수 형식 사용 금지. 전체 화면 통일 |
| 음절 팔레트 | 해당 레벨 정답 음절만 섞어서 표시 (오답 유도 음절 없음) |
| 힌트(유저) | 판당 2회 사용 가능 |
| 힌트 타일(퍼즐) | 미리 오픈된 타일. 단어당 최대 2개. 총 개수는 level_design.csv의 hint_count |
| 세이브 | 시드로 퍼즐 재생성 + 입력 상태 별도 저장 → 이어서 풀기 가능 |
| 102 레벨~ | word_count=11, hint_count=11 고정 (101 레벨과 동일 난이도) |

---

## 개발 단계 계획

### Phase 0: 프로젝트 기반 설정 ✅ 완료
- [x] pubspec.yaml 패키지 추가 (`in_app_review` 추가, `http` 제거, `assets/data/` 등록)
- [x] 전체 폴더 구조 생성 및 각 폴더 가이드 파일 작성
- [x] 앱 세로 모드 고정, 기본 테마 설정 (오렌지 계열)
- [x] assets/data 폴더에 `word_pool.csv`(10,489개), `level_design.csv` 배치
- [x] 다국어 제거 (한국어 단독 지원), `app_translations.dart` 재작성
- [x] 모든 기존 파일 UTF-8 재저장 (인코딩 오류 수정)
- [x] game / result / wordbook 화면 스텁 파일 생성
- [x] `flutter analyze` 이슈 0개 확인

### Phase 1: 데이터 레이어 구축 ✅ 완료
- [x] `WordModel`, `WordLoader` 구현 (`assets/data/word_pool.csv` 파싱, 3~5 음절 필터 포함)
- [x] `LevelDesignModel`, `LevelDesignLoader` 구현 (`assets/data/level_design.csv` 파싱, 102 레벨 이상 자동 처리)
- [x] `flutter analyze` 이슈 0개 확인

### Phase 2: 퍼즐 생성 엔진 ✅ 완료
- [x] `lib/core/engine/puzzle_model.dart` — Direction, PlacedWord, HintTile, PuzzleBoard 모델
- [x] `lib/core/engine/word_placer.dart` — Incremental Growth 배치 + 격리 규칙 + Freezing 방지
- [x] `lib/core/engine/hint_selector.dart` — 교차점 우선, 단어당 최대 2개, 총량 hint_count
- [x] `lib/core/engine/puzzle_generator.dart` — 시드 기반 결정론적 퍼즐 생성 진입점
- [x] `flutter analyze` 이슈 0개 확인

### Phase 3: 화면 뼈대 + 네비게이션 ✅ 완료
- [x] GetX 라우팅 설정 (splash → main → game → result → wordbook → settings)
- [x] 스플래시 화면 1 (하늘색 배경 + interpage 로고 1.5초)
- [x] 스플래시 화면 2 (빨간 배경 + pikuMAN 캐릭터 + 로딩 인디케이터 + **실제 CSV 데이터 로드**)
- [x] 메인 화면 기본 UI (캐릭터·레벨 표시·PLAY·단어장·설정 버튼·하단 배너)
- [x] `DataService` 구현 — word_pool + level_design CSV를 Splash Stage2에서 한 번만 로드·캐시
- [x] `flutter analyze` 이슈 0개 확인

### Phase 4: 게임 플레이 화면 ✅ 완료
- [x] `lib/features/game/models/game_enums.dart` — CellDisplayState enum (7가지 상태)
- [x] `lib/features/game/controllers/game_controller.dart` — 퍼즐 로드·셀 선택·음절 입력·자동 이동·타이머·레벨 클리어 감지
- [x] `lib/features/game/presentation/widgets/crossword_grid_widget.dart` — 10×8 그리드 (상태별 색상)
- [x] `lib/features/game/presentation/widgets/syllable_palette_widget.dart` — 음절 팔레트 (탭 → 입력)
- [x] `lib/features/game/presentation/game_page.dart` — 게임 화면 조립 (헤더·그리드·팔레트·힌트·배너)
- [x] `lib/features/game/bindings/game_binding.dart` — GameController 바인딩
- [x] `flutter analyze` 이슈 0개 확인

### Phase 5: 게임 로직 완성 ✅ 완료
- [x] 단어 완성 체크 로직 (모든 빈 칸 정답 일치 시 클리어 감지)
- [x] 레벨 클리어 → 결과 화면 이동 (`Get.offNamed` + level·elapsed·words 전달)
- [x] 힌트 기능 구현 (판당 2회 제한, 선택 칸 오픈 or 랜덤 빈 칸 오픈)
- [x] 세이브/로드 시스템 (`SaveService` — 음절 입력·타이머·힌트 횟수 SharedPreferences 저장)
- [x] `flutter analyze` 이슈 0개 확인

### Phase 6: 게임 결과 & 부가 화면 ✅ 완료
- [x] 단어장 화면 (최신 레벨 최상단, 레벨별 단어·뜻 목록, 스크롤로 이전 레벨 확인)
- [x] 설정 화면 완성 (효과음/BGM/진동 토글 + 인앱 리뷰 + 스토어 fallback)
- [x] `flutter analyze` 이슈 0개 확인

### Phase 7: 사운드 & 광고 ✅ 완료
- [x] BGM (`bgm.mp3`) — 앱 포그라운드 시 재생, 백그라운드 시 자동 정지
- [x] 효과음 연결 — 빈칸 선택(`cell_select.wav`) / 단어 완성(`equation_complete.wav`) / 오답(`tile_incorrect.wav`) / 레벨 클리어(`level_clear.mp3`)
- [x] 오답 입력 시 햅틱 피드백 (진동 설정 ON 시)
- [x] AdMob 배너 광고 — 메인·게임·결과 화면 하단 고정
- [x] AdMob 전면 광고 — 10레벨 클리어마다 자동 표시
- [x] `.tr` 전면 제거 (한국어 직접 표기로 전환)
- [x] `flutter analyze` 이슈 0개 확인

### Phase 8: 완성도 & 출시 준비
- [ ] In-App Review API 연동 + 스토어 이동 fallback
- [ ] 앱 아이콘, 스플래시 이미지 적용
- [ ] AdMob 테스트 ID → 실제 ID 교체
- [ ] 릴리즈 빌드 및 서명
- [ ] 플레이스토어 업로드

---

## 진행 상황

> 마지막 업데이트: 2026-05-22 (게임 플레이 버그 수정 2차)

### 완료된 작업
- Flutter 프로젝트 생성 및 기본 패키지 설정
- `.cursorrules` 및 `README.md` 작성 (기획 전체 확정 내용 반영)
- **Phase 0 완료**: 프로젝트 기반 설정 전체 완료
  - `word_pool.csv` (10,489개), `level_design.csv` -> `assets/data/` 배치
  - `in_app_review` 패키지 추가, `assets/data/` pubspec 등록
  - 한국어 전용으로 통일, 다국어 제거
  - game / result / wordbook 스텁 화면 생성
  - 모든 파일 UTF-8 재저장, `flutter analyze` 이슈 0개
- **Phase 1 완료**: 데이터 레이어 구축
  - `lib/core/data/word_model.dart` — 단어 모델 (word, meaning, syllableCount 자동 계산)
  - `lib/core/data/word_loader.dart` — CSV 파싱 + 3~5 음절 필터링
  - `lib/core/data/level_design_model.dart` — 레벨 설계 모델 (level, wordCount, hintCount)
  - `lib/core/data/level_design_loader.dart` — CSV 파싱 + 102 레벨 이상 자동 처리
  - `flutter analyze` 이슈 0개
- **Phase 2 완료**: 퍼즐 생성 엔진 구축
  - `lib/core/engine/puzzle_model.dart` — Direction enum, PlacedWord, HintTile, PuzzleBoard 모델
  - `lib/core/engine/word_placer.dart` — Incremental Growth 배치 알고리즘 (격리 규칙, Freezing 방지)
  - `lib/core/engine/hint_selector.dart` — 교차점 우선 힌트 타일 선정 (단어당 최대 2개)
  - `lib/core/engine/puzzle_generator.dart` — 레벨 번호 시드 기반 결정론적 퍼즐 생성
  - `flutter analyze` 이슈 0개
- **Phase 3 완료**: 화면 뼈대 + 네비게이션
  - 스플래시 1 (하늘색 + interpage 로고) / 스플래시 2 (빨간 배경 + 로딩)
  - 메인 화면 UI (레벨 표시·PLAY·단어장·설정·배너 광고)
  - GetX 라우팅 전체 설정 (6개 화면)
  - `lib/core/services/data_service.dart` — Splash Stage2에서 CSV 한 번만 로드·캐시
  - `flutter analyze` 이슈 0개
- **Phase 4 완료**: 게임 플레이 화면
  - `CellDisplayState` enum 7가지 상태 (inactive / empty / activeWord / selected / hint / correct / incorrect)
  - `GameController` — 퍼즐 로드, 셀 선택(교차점 방향 전환), 음절 입력, 자동 다음 빈칸 이동, 경과 타이머, 레벨 클리어 감지
  - `CrosswordGridWidget` — 10×8 그리드, 상태별 색상, GestureDetector 탭
  - `SyllablePaletteWidget` — 중복 제거 음절 타일, 탭하면 입력
  - `GamePage` — 헤더(Level N + 타이머) + 그리드 + 팔레트 + 힌트 버튼 + 배너
  - `flutter analyze` 이슈 0개
- **Phase 5 완료**: 게임 로직 완성
  - `lib/core/services/save_service.dart` — 음절 입력·타이머·힌트 횟수 SharedPreferences 저장/로드/삭제
  - `GameController` 확장 — 힌트 기능(선택 칸 오픈 or 랜덤 빈 칸 오픈, 판당 2회), 세이브/로드, 클리어 시 저장 삭제 + 레벨 진행 업데이트 + 결과 화면 이동
  - `GamePage` — 힌트 버튼 활성화 (남은 횟수 표시, 0이면 비활성)
  - `ResultPage` — 실제 결과 화면 구현 (클리어 레벨·시간·단어 목록·뜻, 홈/다음 레벨 버튼)
  - `flutter analyze` 이슈 0개
- **Phase 6 완료**: 게임 결과 & 부가 화면
  - (위에 서술됨)
- **Phase 7 완료**: 사운드 & 광고
  - `AudioService` — BGM·효과음 4종 GameController에 연결 (빈칸 선택·단어 완성·오답·레벨 클리어)
  - 오답 시 햅틱 피드백 (진동 설정 연동)
  - `AdService` — `showInterstitialEvery10Levels()` 레벨 클리어 시 자동 호출
  - `BannerAdWidget`, `MainPage`, `CompletionPage` 등 `.tr` 전면 제거
  - `flutter analyze` 이슈 0개
- **디바이스 실행 버그 수정** (2026-05-21)
  - `android/app/src/main/AndroidManifest.xml` — `INTERNET` 권한 누락 추가 (AdMob 초기화 오류 방지)
  - `android/app/src/main/kotlin/com/interpage/pikuman3/MainActivity.kt` — 패키지명 불일치 수정 (`pikuman3_word_puzzle` → `pikuman3`): ClassNotFoundException 크래시 원인
  - 실기기(SM A546S, Android 16) 정상 실행 확인
- **게임 플레이 버그 수정 1차** (2026-05-21)
  - `crossword_grid_widget.dart` — 그리드 타일 정렬 불일치 수정 (margin→Padding 교체, SizedBox 통일) + 오른쪽 overflow 제거 (cellSize 계산식 수정)
  - `game_controller.dart` — 팔레트 reactive화 (`RxList<String>`) + 힌트 타일 음절 팔레트 제외 + 정답 입력/힌트 오픈 시 해당 음절 팔레트에서 제거
  - `syllable_palette_widget.dart` — 타일별 GlobalKey 및 index 콜백 추가 (애니메이션 위치 계산용)
  - `game_page.dart` — StatefulWidget 변환 + 팔레트 타일 → 크로스워드 칸 날아가는 애니메이션(Overlay) 구현
  - `main_controller.dart` — 테스트용 `goToLevel()` 메서드 추가
  - `main_page.dart` — 테스트용 레벨 이동 UI 추가 (레벨 번호 입력 + 이동 버튼)
  - `flutter analyze` 이슈 0개
- **게임 플레이 버그 수정 2차** (2026-05-22)
  - `main_page.dart` — Play/단어장 버튼 가로 나란히 배치 (크기 축소) + overflow 수정 (SingleChildScrollView 적용)
  - `game_enums.dart` — `filled` 상태 추가 (입력됐지만 단어 미완성, 판별 전 상태)
  - `game_controller.dart` — 정답 판별 로직 전면 개선
    - 음절 단위 판별 → **단어 전체 채워진 후** 정답/오답 판별로 변경
    - `_judgedWords` (정답 확정 단어 목록) 추가
    - 정답 확정 칸 수정 불가 처리 (`onSyllableTap` 가드)
    - 정답 확정 후 **다음 미완성 단어로 커서 자동 이동** (`_moveToNextIncompleteWord`, 가로 우선)
    - 오답 단어 전체 칸을 빨간색으로 표시 (`cellState` 수정)
    - 입력된 개별 타일 탭 → 해당 타일만 팔레트로 반환 (`_clearSingleCell`)
    - 힌트 오픈 시 `_judgedWords` 업데이트 추가 (`_revealCell`)
    - **팔레트 교차점 중복 버그 수정** — 교차점 칸 음절이 2개 들어가던 문제 수정 (`_buildPalette`, `_syncPaletteAfterLoad` 좌표 Set 중복 방지)
  - `game_page.dart` — 게임 화면 헤더에 설정 버튼 추가
  - `crossword_grid_widget.dart` — 정답 확정 색상 초록→파란색 변경, `filled` 상태 연한 오렌지 색상 추가
  - `flutter analyze` 이슈 0개

### 다음 할 일
- **`level_design.csv` vs 실제 퍼즐 생성 불일치 점검** (다음 작업 우선 진행)
  - `level_design.csv`의 word_count·hint_count 값이 실제 생성 퍼즐과 맞지 않는 레벨 확인
  - 원인 분석 후 CSV 수정 또는 퍼즐 생성 로직 조정
- **게임 플레이 추가 테스트** (실기기 재테스트 필요)
- **Phase 8**: 완성도 & 출시 준비
  - 앱 아이콘 이미지 `assets/images/app_icon.png` 준비 후 `dart run flutter_launcher_icons` 실행
  - 스플래시·캐릭터 이미지 `assets/images/` 에 배치 (`pikuman_back.png` 등)
  - BGM 파일 교체 (`assets/sounds/bgm.mp3` 새 파일로 덮어쓰기)
  - AdMob 콘솔에서 pikuman3 앱 등록 → App ID / 배너 ID / 전면 ID 발급 후 교체
  - In-App Review API 연동 확인 (설정 화면 이미 구현됨 ✅)
  - 릴리즈 빌드 및 서명 (`flutter build appbundle --release`)
  - 플레이스토어 업로드

---

## 출시 전 필수 교체 항목

> **아래 항목들을 반드시 출시 전에 교체/추가해야 합니다**

| 항목 | 현재 상태 | 교체 방법 |
|------|----------|----------|
| AdMob App ID | pikuman2 App ID 임시 사용 중 | AdMob 콘솔 → pikuman3 앱 등록 → `AndroidManifest.xml` 의 `APPLICATION_ID` 교체 |
| AdMob 배너 광고 ID | pikuman2 ID 사용 중 | `lib/core/widgets/banner_ad_widget.dart` 의 `_adUnitId` 교체 |
| AdMob 전면 광고 ID | pikuman2 ID 사용 중 | `lib/core/services/ad_service.dart` 의 `interstitialAdUnitId` 교체 |
| 캐릭터 이미지 | 없음 (빈 공간으로 표시됨) | `assets/images/pikuman_back.png` 추가 |
| 앱 아이콘 | 없음 | `assets/images/app_icon.png` 추가 후 `dart run flutter_launcher_icons` |
| BGM 파일 | 구버전 `bgm.mp3` 사용 중 | 새 파일로 `assets/sounds/bgm.mp3` 덮어쓰기 |
| 플레이스토어 URL | pikuman3 패키지명으로 작성됨 | 앱 출시 후 자동으로 유효해짐 (별도 수정 불필요) |

## 광고 ID 위치

| 광고 종류 | 파일 | 변수명 |
|----------|------|-------|
| AdMob App ID | `android/app/src/main/AndroidManifest.xml` | `APPLICATION_ID` meta-data |
| 배너 광고 ID | `lib/core/widgets/banner_ad_widget.dart` | `_adUnitId` |
| 전면 광고 ID | `lib/core/services/ad_service.dart` | `interstitialAdUnitId` |
