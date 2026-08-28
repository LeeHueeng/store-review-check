# iOS 체크리스트 — Apple App Review Guidelines

Apple 전용 항목. 기능 조건부 항목(UGC·계정·결제 등)은 `common.md`에 있고 여기서는 참조만 한다.
작성 기준일 2026-08. 가이드라인 번호는 https://developer.apple.com/app-store/review/guidelines/ 기준.

---

## 로그인

### IOS-LOGIN-01 Sign in with Apple (4.8 Login Services)
- 근거: 4.8 — 제3자/소셜 로그인(Google, Kakao, Naver, Facebook 등)으로 **주 계정**을 만들거나 인증하면, 다음을 만족하는 다른 로그인을 **동등한 옵션**으로 제공해야 한다: (a) 이름·이메일만 수집 (b) 이메일 비공개 허용 (c) 동의 없이 광고용 상호작용 수집 안 함. Sign in with Apple이 이를 만족한다.
- 예외: 자사 계정 시스템만 사용 / 교육·기업 계정 / 정부·산업 ID / 특정 제3자 서비스 전용 클라이언트.
- 적용: `auth.google/kakao/naver/facebook` > 0
- 확인: 로그인 화면에 Apple 버튼이 소셜 버튼과 **같은 화면·같은 크기**로 있는가(숨기거나 작게 두면 4.8 리젝). `sign_in_with_apple`/`AuthenticationServices` 사용. Xcode Capabilities "Sign in with Apple" + entitlements `com.apple.developer.applesignin`. Firebase면 Apple 제공자 활성화 + Services ID(Android용).
- 신호: `auth.apple`, entitlements
- 수정: 버튼 추가(HIG 규격: 검정/흰색 Apple 로고 버튼) → Firebase/Supabase Apple 제공자 연동 → 계정 병합 정책 결정(같은 이메일 다른 제공자). Android에서도 Apple 로그인 노출하려면 웹 플로우 필요(선택).
- 증빙: 없음(심사관이 직접 확인). 심사 노트에 "Sign in with Apple available" 한 줄.
- 사례: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — 메일엔 없지만 Google/Kakao만 있어 동반 리젝 위험

### IOS-LOGIN-02 Apple 계정 삭제 시 토큰 폐기
- 근거: 5.1.1(v) + Apple 공지(2022) — Sign in with Apple 사용자 계정 삭제 시 `revoke tokens` REST API 호출 필요
- 확인: 계정 삭제 서버 함수에서 Apple token revoke 호출.

---

## 기기·UI

### IOS-IPAD-01 iPad에서 정상 동작 (2.4.1 / 4.0 / 2.1)
- 근거: 심사관은 **iPad로도 테스트한다**(사례: iPad Air 11-inch). `TARGETED_DEVICE_FAMILY = 1,2`(유니버설)이면 iPad 레이아웃이 깨지면 4.0 Design/2.1 리젝. `1`(iPhone 전용)이어도 iPad 호환 모드로 실행되며 크래시하면 리젝.
- 확인: pbxproj `TARGETED_DEVICE_FAMILY`. 유니버설이면 iPad 시뮬레이터(13"·11")에서 모든 화면 확인 — 늘어난 레이아웃, 모달 사이즈, 가로 모드(`UISupportedInterfaceOrientations~ipad` 4방향이면 가로도 확인, 세로만 지원하려면 `UIRequiresFullScreen = YES` + 세로만).
- 신호: pbxproj, plist orientations
- 수정: 폭 제한 컨테이너(max 600pt 중앙 정렬) 같은 최소 대응. 또는 iPhone 전용으로 전환(`TARGETED_DEVICE_FAMILY = 1`) — 단 여전히 iPad에서 실행되므로 크래시 없어야 함.
- 사례: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — Review Device에 iPad 포함

### IOS-UI-01 기본 완성도 (4.0 Design)
- 확인: 다크 모드 깨짐(강제 라이트면 `UIUserInterfaceStyle = Light`로 명시), safe area·노치·Dynamic Island 침범, 키보드가 입력창 가림, 빈 상태 화면, 시스템 폰트 크기 확대 시 잘림.

### IOS-UI-02 비공개 API·동적 코드 금지 (2.5.1 / 2.5.2)
- 확인: 플러그인이 private API 사용(업로드 시 ITMS 경고로 드러남). 코드 푸시(CodePush/Shorebird 등)는 "앱의 주 목적을 바꾸지 않는 범위" 조건부 허용.

### IOS-UI-03 외부 링크·앱 유도 (3.1.1 / 2.3.10)
- 확인: "웹에서 더 싸게 구독" 류 링크·문구 없음. 다른 앱 설치 유도 최소화.

---

## Info.plist

### IOS-PLIST-01 권한 목적 문구 누락·부실 (5.1.1(ii))
- 근거: 권한 API를 호출하는데 해당 `NS*UsageDescription`이 없으면 **크래시** → 2.1. 있어도 모호하면 5.1.1 리젝.
- 확인: scan 결과 `perm.*` 신호별 필요 키:
  | 신호 | 키 |
  |---|---|
  | perm.camera | NSCameraUsageDescription, NSPhotoLibraryUsageDescription (+ NSPhotoLibraryAddUsageDescription 저장 시) |
  | perm.location | NSLocationWhenInUseUsageDescription (+ NSLocationAlwaysAndWhenInUseUsageDescription) |
  | perm.mic | NSMicrophoneUsageDescription (+ NSSpeechRecognitionUsageDescription) |
  | perm.contacts | NSContactsUsageDescription |
  | perm.calendar | NSCalendarsFullAccessUsageDescription (iOS 17+) |
  | perm.bluetooth | NSBluetoothAlwaysUsageDescription |
  | perm.health | NSHealthShareUsageDescription, NSHealthUpdateUsageDescription |
  | track.att | NSUserTrackingUsageDescription |
  | Face ID | NSFaceIDUsageDescription |
  | 로컬 네트워크 | NSLocalNetworkUsageDescription |
  플러그인이 내부적으로 쓰는 것(image_picker → 카메라+사진 둘 다)도 포함. 문구는 "무엇을 위해 무엇을" 형식.
- 신호: `iOS Info.plist` 섹션 vs `perm.*`
- 수정: 키 추가 + `InfoPlist.strings` 현지화(ko/en).

### IOS-PLIST-02 UIBackgroundModes 정당성 (2.5.4)
- `common.md` BG-01 참고. `audio`·`location`·`voip`·`fetch`·`processing` 각각 실제 기능 필요.

### IOS-PLIST-03 URL Scheme·LSApplicationQueriesSchemes
- 확인: 카카오 로그인 → `kakao{APP_KEY}` URL scheme + `LSApplicationQueriesSchemes`에 `kakaokompassauth`, `kakaolink`, `kakaoplus`. 네이버 → `naversearchapp`, `naversearchthirdlogin`. 없으면 카카오톡 앱 로그인이 안 돼 심사 중 로그인 실패.
- 신호: `LSApplicationQueriesSchemes`, `auth.kakao`

### IOS-PLIST-04 ATS(App Transport Security)
- 확인: `NSAllowsArbitraryLoads = true`면 심사 노트에 사유 필요. 가능하면 도메인 예외만.

---

## 개인정보·매니페스트

### IOS-PRIV-01 App Privacy 라벨 (ASC)
- `common.md` PRIV-02 참고. 제출 전 "App Privacy" 섹션이 SDK 기준으로 채워졌는지.

### IOS-PRIV-02 ATT (5.1.2(i))
- `common.md` PRIV-03 참고. 광고·어트리뷰션 SDK 있으면 ATT 요청 코드 + `NSUserTrackingUsageDescription`. ATT를 거부해도 앱 기능 제한 금지.

### IOS-PRIV-03 Privacy Manifest — Required Reason API
- 근거: 2024-05-01부터 필수. `PrivacyInfo.xcprivacy`에 `NSPrivacyAccessedAPITypes`(UserDefaults, 파일 타임스탬프, 시스템 부팅 시간, 디스크 공간, 활성 키보드)와 사유 코드, `NSPrivacyTracking`, `NSPrivacyCollectedDataTypes`. 누락 시 업로드 후 **ITMS-91053/91061** 메일 또는 리젝. Apple이 지정한 제3자 SDK(Firebase, AppsFlyer, Kingfisher 등)는 SDK 자체 매니페스트·서명 필요(최신 버전 사용으로 해결).
- 확인: 앱 타깃에 `PrivacyInfo.xcprivacy` 존재 + Copy Bundle Resources 포함. UserDefaults 쓰면 `CA92.1`, 파일 타임스탬프 `C617.1`/`DDA9.1` 등.
- 신호: `PrivacyInfo.xcprivacy 파일 수`
- 수정: Xcode > New File > App Privacy 생성. Flutter/RN은 `ios/Runner/PrivacyInfo.xcprivacy` + Xcode 프로젝트에 추가. SDK 최신화.

---

## 메타데이터·제출

### IOS-META-01 스크린샷 규격
- 확인: iPhone 6.9"(1320×2868 또는 1290×2796) 필수, iPad 13"(2064×2752) — 유니버설 앱이면 필수. 스크린샷 안에 실제 앱 화면(2.3.3).

### IOS-META-02 App Review Information
- 확인: Sign-in required 체크 + 데모 계정, Notes(`templates/review-notes.md`), Contact 정보(전화번호 국가코드), 첨부(녹화 링크). UGC 앱은 녹화 링크 **필수**(사례).

### IOS-META-03 수출 규정 준수 (Export Compliance)
- 확인: `ITSAppUsesNonExemptEncryption` 키. HTTPS만 쓰면 `false` → 업로드마다 질문 생략. 자체 암호화(E2EE 등)면 `true` + 연 1회 자가 분류 보고(미국).
- 신호: plist

### IOS-META-04 최소 Xcode/SDK
- 근거: Apple은 매년 4월경 "이 날짜 이후 제출은 Xcode N / iOS N SDK로 빌드" 공지(2025-04-24부터 Xcode 16/iOS 18 SDK). 2026년엔 Xcode 26/iOS 26 SDK 요구 가능성이 높으니 제출 시점에 [Apple 뉴스](https://developer.apple.com/news/)에서 확인.
- 확인: `xcodebuild -version`, Flutter/RN이 요구 SDK 지원하는 버전인지.

### IOS-META-05 버전·빌드 번호
- 확인: 재제출 시 `CFBundleVersion`(빌드) 증가. `MARKETING_VERSION`은 스토어 버전과 일치.

---

## Entitlements·특수 기능

### IOS-ENT-01 Capabilities ↔ 코드 일치
- 확인: 푸시 쓰면 `aps-environment` entitlement + ASC 앱 ID에 Push 켜짐(없으면 토큰 발급 실패 → 심사 중 기능 미동작). Associated Domains(Universal Links), App Groups(위젯) 등 코드에서 쓰는 것과 entitlements 일치.
- 신호: entitlements 목록 vs `perm.push`, `deeplink`

### IOS-ENT-02 Screen Time API (FamilyControls) — 별도 승인
- 근거: `com.apple.developer.family-controls` entitlement는 **Apple에 신청·승인 필요**(수 주). 승인 없이 제출하면 빌드 실패 또는 리젝. 집중·앱 차단 앱이 흔히 씀.
- 적용: `perm.screentime` > 0
- 확인: 승인된 entitlement가 프로비저닝 프로파일에 있는가. 배포용은 별도 신청(개발용과 다름).
- 수정: https://developer.apple.com/contact/request/family-controls-distribution 신청 후 대기. 승인 전엔 기능 숨김.

### IOS-ENT-03 Sign in with Apple entitlement
- IOS-LOGIN-01 참고. `com.apple.developer.applesignin` 배열 `Default`.

---

## 백그라운드·타이머 (집중/타이머 앱 특화)

### IOS-BG-01 타이머 유지 방식 (2.5.4)
- 근거: 무음 오디오·가짜 위치 업데이트로 앱을 살려두는 것은 리젝. 타이머 앱은 백그라운드 실행 없이 **종료 시각 저장 + 로컬 알림 + Live Activity/위젯**으로 구현하는 것이 심사 안전.
- 확인: `bg.audio` 신호(silent.mp3, AVAudioSession playback + 소리 없음), `audio_service`/`just_audio_background`가 실제 사운드 재생용인지.
- 수정: `common.md` BG-01. 진짜 백색소음·앰비언트 재생 기능이 있으면 그 기능을 심사 노트에 명시("Background audio is used for the ambient sound feature; the timer itself uses local notifications").

### IOS-BG-02 Live Activity / 위젯
- 확인: 쓰면 `NSSupportsLiveActivities = true`, 위젯 익스텐션 App Group. 심사와 직접 관련은 적지만 크래시 요인.

---

## 결제

### IOS-IAP-01 IAP 제출 상태
- `common.md` PAY-01~04. 첫 제출 시 IAP를 버전에 첨부, Paid Apps Agreement 완료, 페이월에 약관/방침 링크·복원 버튼.

### IOS-IAP-02 한국 외부 결제 엔타이틀먼트
- 근거: 한국은 StoreKit External Purchase entitlement로 제3자 결제 허용(수수료 26%). 신청·승인 없이 외부 결제 넣으면 3.1.1 리젝.
- 적용: `pay.external` > 0 & 디지털 재화
