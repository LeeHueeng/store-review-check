# Android 체크리스트 — Google Play 정책

Google Play 전용 항목. 기능 조건부 항목(UGC·계정·결제 등)은 `common.md` 참고.
작성 기준일 2026-08. 정책 원문: https://support.google.com/googleplay/android-developer/topic/9858052

---

## SDK·빌드

### AND-SDK-01 targetSdk 요구치
- 근거: **타겟 API 수준 요구사항** — 신규 앱·업데이트는 최근 1년 내 출시 Android 버전 이상을 타겟. 매년 8월 31일 기준 상향: 2025-08-31 → API 35(Android 15), **2026-08-31 → API 36(Android 16)**. 미충족 시 새 버전 업로드 자체가 거부된다(연장 신청 가능, 최대 11월 1일).
- 확인: `targetSdk` 숫자. Flutter의 `flutter.targetSdkVersion`은 Flutter SDK 버전에 따라 다름(3.27+ → 35, 3.35+ → 36 확인 필요) → `flutter --version` + `flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt` 확인. Expo SDK 52+ → 35.
- 신호: `Android Gradle` 섹션, 자동 힌트
- 수정: `targetSdk` 상향 + 해당 버전의 동작 변경(FGS 타입, 사진 권한, 알림 권한, edge-to-edge(35+), 16KB 페이지(35+ 네이티브 라이브러리)) 대응.

### AND-SDK-02 16KB 페이지 크기 (Android 15+)
- 근거: 2025-11-01부터 Android 15+ 기기 타겟 신규 앱·업데이트는 16KB 페이지 지원 필수(네이티브 라이브러리 포함 시).
- 확인: `.so` 포함 앱(Flutter, RN, SQLite 등)은 AGP 8.5.1+·NDK r28+로 빌드. Play Console 앱 번들 탐색기에 경고 표시.

### AND-BUILD-01 서명·번들
- 확인: AAB 업로드(APK 불가), 업로드 키로 서명(`signingConfigs.debug` 릴리즈 사용 금지), Play 앱 서명 등록, `debuggable false`, `minifyEnabled`(권장), arm64-v8a 포함(64비트 필수).
- 신호: Gradle 섹션

### AND-BUILD-02 매니페스트 필수 속성
- 확인: `android:exported` 명시(API 31+, 인텐트 필터 있는 컴포넌트), `usesCleartextTraffic="true"` 제거 또는 network_security_config로 도메인 한정, `allowBackup` 의도 확인.
- 신호: Manifest 섹션

---

## 권한 (Play 권한 정책 + 선언 양식)

### AND-PERM-01 SMS·통화 기록
- 근거: 기본 SMS/전화/어시스턴트 앱 외 `READ_SMS`, `RECEIVE_SMS`, `SEND_SMS`, `READ_CALL_LOG`, `PROCESS_OUTGOING_CALLS` 등 사용 금지. OTP는 SMS Retriever API/User Consent API로.
- 신호: 자동 힌트
- 수정: 권한 제거, SMS Retriever로 전환.

### AND-PERM-02 QUERY_ALL_PACKAGES
- 근거: 핵심 기능이 설치 앱 목록을 필요로 할 때만(런처, 보안, 앱 관리 등). 그 외는 `<queries>`로 특정 패키지만. 사용 시 Play Console 선언 양식 필수.
- 적용: 집중 앱이 "차단할 앱 목록"을 보여주려 할 때 흔히 걸림 → 카테고리 인텐트 `<queries>`로 대체하거나 선언 양식에 핵심 기능임을 설명.

### AND-PERM-03 MANAGE_EXTERNAL_STORAGE (모든 파일 접근)
- 근거: 파일 관리자·백업 등 핵심 기능만. 선언 양식 + 영상. 대부분 앱은 Scoped Storage/SAF/Photo Picker로 대체.

### AND-PERM-04 백그라운드 위치
- 근거: `ACCESS_BACKGROUND_LOCATION`은 핵심 기능일 때만, Console 선언 양식 + 데모 영상 + 앱 내 사전 고지(PRIV-04).

### AND-PERM-05 포그라운드 서비스 타입
- 근거: targetSdk 34+는 `<service android:foregroundServiceType="…">` 필수 + 타입별 `FOREGROUND_SERVICE_<TYPE>` 권한. 선언 없으면 런타임 예외. Play Console **Foreground service permissions** 선언(타입별 용도 설명 + 영상 링크).
- 타입 가이드: 타이머 알림 유지 → `specialUse`(양식에 `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` 설명) 또는 `shortService`(3분). 백색소음 재생 → `mediaPlayback`. 위치 추적 → `location`. 파일 업로드 → `dataSync`(제한 있음).
- 신호: 자동 힌트 (`FOREGROUND_SERVICE` 있으나 타입 없음)
- 수정: 매니페스트 타입 + 권한 + `startForeground(id, notification, type)` 호출 + 콘솔 양식.

### AND-PERM-06 접근성 서비스
- 근거: `BIND_ACCESSIBILITY_SERVICE`는 장애 보조 목적일 때만. 그 외 용도(앱 차단, 자동화)는 선언 양식에서 "접근성 이외 용도"로 신고 + 눈에 띄는 공개 + 사용자 동의. 거부율 높음.
- 적용: 집중 앱의 "다른 앱 차단" 구현에 흔함 → UsageStats(AND-PERM-07) + 오버레이 조합이 더 통과 잘 됨.

### AND-PERM-07 사용 통계 (PACKAGE_USAGE_STATS)
- 근거: 서명 권한이지만 설정 화면으로 사용자가 부여. Play 정책상 "핵심 기능"이어야 하며 사전 고지 필요. Data safety에 "앱 활동 > 설치된 앱" 등 선언.
- 적용: 집중 앱 앱 사용시간 측정
- 확인: 설정 이동 전 고지 화면.

### AND-PERM-08 사진·동영상 권한
- 근거: **사진 및 동영상 권한 정책** — `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO`/`READ_EXTERNAL_STORAGE`는 핵심 기능이 광범위·빈번한 접근을 요구할 때만(갤러리, 사진 편집기). 프로필 사진 한 장 고르기는 **Photo Picker** 사용. 위반 시 선언 양식 요구 + 거부.
- 확인: `image_picker`(Flutter 0.8.9+는 Photo Picker 사용, 권한 불필요) 등이 매니페스트에 권한을 남겼는지 → `tools:node="remove"`로 제거. Console에 "사진 및 동영상 권한" 선언 답변.
- 신호: 자동 힌트

### AND-PERM-09 오버레이 (SYSTEM_ALERT_WINDOW)
- 근거: 명시 정책은 완화됐으나 악성 앱 지표. 사용 이유 설명 + 사용자 부여 흐름 필요. 집중 앱의 차단 화면 용도는 통과 사례 많음.

### AND-PERM-10 정확한 알람·전체화면 인텐트
- 근거: `USE_EXACT_ALARM`은 **알람시계·타이머·캘린더가 핵심 기능**인 앱만(Play 정책, 선언 필요). 그 외는 `SCHEDULE_EXACT_ALARM`(사용자 부여) 또는 비정확 알람. `USE_FULL_SCREEN_INTENT`(Android 14)는 알람·통화 앱만 자동 부여, 그 외는 콘솔 선언 + 사용자 설정 유도.
- 적용: 타이머 종료 알림
- 확인: 타이머 앱이면 `USE_EXACT_ALARM` 정당. 알림 채널 중요도·전체화면 인텐트 사용 여부.

### AND-PERM-11 POST_NOTIFICATIONS (13+)
- 확인: targetSdk 33+는 런타임 알림 권한. 거부 시 타이머 종료 알림이 안 오므로 맥락 있는 요청 + 거부 시 안내.

---

## Play Console 선언 (코드 밖)

### AND-CONSOLE-01 개인정보처리방침 URL
- 근거: 모든 앱 필수(2024~). 스토어 등록정보 + 앱 내 링크. `common.md` PRIV-01.

### AND-CONSOLE-02 데이터 보안(Data safety)
- 근거: 수집·공유·보안 관행 정확히 선언. SDK 수집분 포함. 계정 삭제 URL 포함(AND-CONSOLE-08). 불일치 시 정책 위반 통지·업데이트 거부.
- 확인: `common.md` PRIV-02 SDK 표와 비교. "암호화 전송", "삭제 요청 방법" 답변.

### AND-CONSOLE-03 앱 액세스 (App access)
- 근거: 로그인·지역·결제 뒤 기능이 있으면 "전체 또는 일부 기능 제한됨" 선택 + 자격 증명·안내. 없으면 심사관이 못 들어가 정책 위반("기능 확인 불가")으로 거부.
- 확인: `templates/review-notes.md` Android 부분. 소셜 로그인만 있으면 이메일 리뷰어 계정(ACC-03).

### AND-CONSOLE-04 광고 ID·광고 포함
- 근거: `AD_ID` 권한 선언(targetSdk 33+, 광고 SDK가 병합) + Data safety 광고 ID + "광고 포함" 선언. 광고 ID 안 쓰면 `tools:node="remove"`로 제거하고 "아니오".
- 신호: 자동 힌트

### AND-CONSOLE-05 콘텐츠 등급 (IARC)
- 근거: 설문 미완료 시 게시 불가. **UGC·채팅·친구 기능 → "사용자 간 상호작용/정보 공유" 예**로 답해야 함. 거짓 답변은 정지 사유.
- 확인: `common.md` META-03.

### AND-CONSOLE-06 민감 권한 선언 양식
- 근거: 포그라운드 서비스, 정확한 알람, 전체화면 인텐트, 사진/동영상, 백그라운드 위치, 모든 파일 접근, QUERY_ALL_PACKAGES, 접근성, SMS 등은 App content > 민감한 앱 권한/포그라운드 서비스 양식 필수. 각 항목: 핵심 기능 설명 + 데모 영상(YouTube 비공개 링크 OK).
- 확인: 매니페스트 권한 목록 ↔ 양식 제출 여부.

### AND-CONSOLE-07 타깃 연령·아동
- 근거: 타깃층 설문에서 13세 미만 포함 시 **Families 정책**(광고 SDK 인증, 데이터 제한, UGC 제한) 적용. 학생 대상 집중 앱은 "13~15세" 포함 여부 신중히.
- 확인: 스토어 문구("학생", "초등") ↔ 타깃 연령 일치.

### AND-CONSOLE-08 계정 삭제 URL
- 근거: 계정 생성 앱은 Data safety > "계정 삭제 요청 URL" 필수 + 앱 내 삭제. `common.md` ACC-02.

### AND-CONSOLE-09 특수 카테고리 선언
- 근거: 건강(Health Connect·건강 기능), 금융(대출·투자), 뉴스, 정부, VPN, 코로나 등은 별도 선언·증빙. 집중 타이머가 "정신 건강" 문구를 쓰면 건강 앱 선언 대상 가능.

---

## 스토어 등록정보

### AND-META-01 메타데이터 정책
- 근거: 앱 이름 30자, 이모지·특수기호·"최고/1위/무료/신규/다운로드" 같은 홍보 문구 금지(제목·아이콘·개발자명), 가격·순위·평점 언급 금지, 대문자 남용 금지, 타 플랫폼 언급 지양.
- 확인: 제목·짧은 설명(80자)·긴 설명.

### AND-META-02 스크린샷·그래픽
- 근거: 앱 기능을 정확히 표현, 최소 2장(권장 4~8, 16:9 또는 9:16, 320~3840px), 피처 그래픽 1024×500 필수.

### AND-META-03 개발자 정보 공개
- 근거: 이메일 필수, 조직은 D-U-N-S + 주소·전화 공개(2024~), 개인 개발자는 이름·이메일 공개, 주소는 유료/IAP 시 공개.

---

## 테스트·계정

### AND-TEST-01 신규 개인 개발자 계정 비공개 테스트
- 근거: 2023-11-13 이후 생성된 **개인** 계정은 프로덕션 접근 전 **비공개 테스트에서 12명 이상 테스터가 14일 연속 옵트인** 필요 + 프로덕션 접근 신청 설문.
- 확인: 계정 생성일·유형. 해당되면 일정에 최소 2주 반영.

### AND-ACCOUNT-01 계정 인증
- 근거: 개발자 신원 확인(신분증·전화·이메일), 조직은 D-U-N-S. 미완료 시 게시 불가.

---

## UGC·결제 (Play 고유 추가 조건)

### AND-UGC-01 Play UGC 정책 추가 항목
- `common.md` UGC-01~06 전부 + Play 고유: (a) 앱 내 수익화(선물·팁)가 부적절 행동을 조장하지 않을 것 (b) 성적 콘텐츠는 기본 차단·연령 확인 (c) UGC 주 목적이 부적절 콘텐츠면 앱 자체 거부.
- 콘텐츠 등급 설문 "사용자 상호작용" 예(AND-CONSOLE-05).

### AND-PAY-01 Play 결제
- `common.md` PAY-01. 한국: 제3자 결제 병행 시 Play Console에서 "대체 결제" 등록, 사용자 선택 결제 UI 요건 준수. 외부 링크 결제는 여전히 금지.
