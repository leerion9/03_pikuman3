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

### Phase 1: 데이터 레이어 구축
- [ ] `WordModel`, `WordLoader` 구현 (`assets/data/word_pool.csv` 파싱)
- [ ] `LevelDesignModel`, `LevelDesignLoader` 구현 (`assets/data/level_design.csv` 파싱)
- [ ] **테스트**: 단어 리스트 및 레벨 설계 데이터 콘솔 출력 확인

### Phase 2: 퍼즐 생성 엔진
- [ ] Incremental Growth 배치 알고리즘 구현
- [ ] 인접 칸 격리 규칙 (옆구리 접촉 금지, 평행 배치 금지, 헤드/테일 여유) 구현
- [ ] Backtracking 로직 (500회 초과 시 단어 교체)
- [ ] 힌트 타일 선정 로직 (교차점 우선, 단어당 최대 2개, 총량은 hint_count)
- [ ] **테스트**: 퍼즐 구조를 텍스트로 콘솔 출력하여 규칙 준수 확인

### Phase 3: 화면 뼈대 + 네비게이션
- [ ] GetX 라우팅 설정
- [ ] 스플래시 화면 1 (하늘색 + interpage 로고)
- [ ] 스플래시 화면 2 (빨간 배경 + pikuMAN 캐릭터 + 로딩)
- [ ] 메인 화면 기본 UI
- [ ] **테스트**: 화면 전환 흐름 확인

### Phase 4: 게임 플레이 화면
- [ ] 크로스워드 그리드 렌더링 (10×8)
- [ ] 음절 타일 팔레트 표시
- [ ] 타일 선택 로직 (빈칸 선택 → 음절 입력)
- [ ] 자동 다음 빈칸 이동 (가로 우선)
- [ ] 타일 색상 구분 (선택 / 현재 단어 / 정답 / 오답 / 힌트)
- [ ] 경과 타이머 표시 (앱 백그라운드 시 일시 정지)
- [ ] **테스트**: 실제 터치 입력 및 자동 이동 동작 확인

### Phase 5: 게임 로직 완성
- [ ] 단어 완성 체크 로직
- [ ] 레벨 클리어 판정
- [ ] 힌트 기능 구현 (2회 제한)
- [ ] 세이브/로드 시스템 (시드 재생성 + 입력 상태 저장)
- [ ] **테스트**: 앱 종료 후 재진입 시 이어서 풀기 확인

### Phase 6: 게임 결과 & 부가 화면
- [ ] 게임 결과 화면 (레벨 클리어 + 등장 단어 전체 + 단어 뜻)
- [ ] 단어장 화면 (최신 레벨 최상단, 스크롤로 이전 레벨 확인)
- [ ] 설정 화면 (music / sound / vibration 토글 + 평점 버튼)
- [ ] **테스트**: 각 화면 데이터 연동 확인

### Phase 7: 사운드 & 광고
- [ ] BGM (게임 중 재생, 백그라운드 시 정지)
- [ ] 효과음 (빈칸 선택 / 단어 완성 / 오답 / 레벨 클리어)
- [ ] AdMob 배너 광고 (하단 고정)
- [ ] AdMob 전면 광고 (10 레벨마다)
- [ ] **테스트**: 광고 테스트 ID로 동작 확인

### Phase 8: 완성도 & 출시 준비
- [ ] In-App Review API 연동 + 스토어 이동 fallback
- [ ] 앱 아이콘, 스플래시 이미지 적용
- [ ] AdMob 테스트 ID → 실제 ID 교체
- [ ] 릴리즈 빌드 및 서명
- [ ] 플레이스토어 업로드

---

## 진행 상황

> 마지막 업데이트: 2026-05-19

### 완료된 작업
- Flutter 프로젝트 생성 및 기본 패키지 설정
- `.cursorrules` 및 `README.md` 작성 (기획 전체 확정 내용 반영)
- **Phase 0 완료**: 프로젝트 기반 설정 전체 완료
  - `word_pool.csv` (10,489개), `level_design.csv` -> `assets/data/` 배치
  - `in_app_review` 패키지 추가, `assets/data/` pubspec 등록
  - 한국어 전용으로 통일, 다국어 제거
  - game / result / wordbook 스텁 화면 생성
  - 모든 파일 UTF-8 재저장, `flutter analyze` 이슈 0개

### 다음 할 일
- **Phase 1**: 데이터 레이어 구축
  - `WordModel`, `WordLoader` 구현
  - `LevelDesignModel`, `LevelDesignLoader` 구현
  - 단어 로드 콘솔 테스트

---

## 광고 ID 관리

> **출시 전 반드시 테스트 ID를 실제 AdMob ID로 교체할 것**

| 위치 | 파일 |
|------|------|
| 배너 광고 | `lib/core/widgets/banner_ad_widget.dart` |
| 전면 광고 | `lib/core/services/ad_service.dart` |
