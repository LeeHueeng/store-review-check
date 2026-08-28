# iOS 체크리스트 — Apple App Store Review Guidelines (한국어 번역)

> 영어 원본 `../ios.md`가 정본. 기준일 2026-08-28, 가이드라인 2026-06-08 개정판(https://developer.apple.com/app-store/review/guidelines/). 기능 조건부 항목은 `common.md`. 출처: `../../references/apple.md`.

---

## 로그인

### IOS-LOGIN-01 Sign in with Apple (4.8 Login Services)
- 근거: 4.8 "제3자/소셜 로그인(Facebook, Google, X, LinkedIn, Amazon, WeChat 등)으로 **주 계정**을 만들거나 인증하는 앱은 다음을 만족하는 다른 로그인을 **동등한 옵션**으로 제공해야 한다: 이름·이메일만 수집; 이메일 비공개 허용; 동의 없이 광고용 상호작용 수집 안 함." 카카오/네이버/LINE 로그인도 해당. Sign in with Apple이 이를 만족.
- 예외(원문 범주): 자사 계정 시스템만 사용; 대체 마켓플레이스 계정 로그인; 기존 교육/기업 계정 필수 앱; 정부/산업 eID; 특정 제3자 서비스 전용 클라이언트.
- 적용: `auth.google/kakao/naver/facebook` > 0
- 확인: Apple 버튼이 소셜 버튼과 **같은 화면·같은 크기**(숨기거나 작게 → 4.8 리젝). `sign_in_with_apple` / `AuthenticationServices` 사용. Xcode Capability + entitlement `com.apple.developer.applesignin`. Firebase: Apple 제공자 + Services ID(Android/웹용).
- 신호: `auth.apple`, entitlements
- 수정: 버튼 추가(HIG: 검정/흰색 Apple 로고 버튼; "로그인은 최대한 늦게") → Firebase/Supabase Apple 제공자 → 계정 병합 정책. 새 릴레이 도메인 `private.icloud.com`도 `privaterelay.appleid.com`과 함께 허용(2026-08).
- 증빙: 없음(심사관 확인). 심사 노트에 "Sign in with Apple available" 한 줄.
- 사례: [2026-08-27 iOS 1.2 UGC](../../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — 메일엔 없지만 구글/카카오만 있어 동반 리젝 위험; IOS-LOGIN-01 태그 커뮤니티 사례
- 중국 사례: 위챗/구글 버튼을 앱 미설치 시 숨겨도 면제되지 않음(iPhone 심사관은 봄); 이메일/비밀번호나 휴대폰 OTP만으로는 "동등"하지 않음; Apple 버튼은 HIG(로고, 동일 크기) 준수. [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### IOS-LOGIN-02 계정 삭제 시 Apple 토큰 폐기
- 근거: 5.1.1(v) + Apple 공지(2022) — Sign in with Apple 사용자 계정 삭제 시 `revoke tokens` REST API 호출
- 확인: 계정 삭제 서버 함수에서 Apple 토큰 폐기.
- 한국 3차 구현(백엔드 4곳, 2026): 로그인 시 `authorizationCode`를 확보(5분 만료) → 서버에서 리프레시 토큰 교환 → 탈퇴 시 폐기; 토큰의 `aud`는 네이티브 로그인은 **App ID**, 웹은 **Services ID** — 그에 맞게 검증. [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### IOS-LOGIN-03 한국: Sign in with Apple 서버 알림
- 근거: Apple 뉴스 2025-10-09 — 한국 기반 개발자는 2026-01-01부터 SIWA에 쓰는 Services ID에 서버 간 알림 엔드포인트 필수(계정 변경/삭제 이벤트 수신)
- 적용: 한국 개발자 계정 + Sign in with Apple
- 확인: Certificates, Identifiers & Profiles > Services ID > Sign in with Apple > 서버 알림 엔드포인트 설정, `consent-revoked` / `account-delete` 처리.

### IOS-LOGIN-04 Sign in with Apple 뒤 이름/이메일 재요청 금지; 릴레이 주소 허용
- 근거: 4.0 Design 리젝 문구 — "Your app requires users to provide their name and/or email address after using Sign in with Apple. This information is already provided by the Authentication Services framework."
- 적용: SIWA 후 프로필 폼을 띄우는 모든 흐름
- 확인: **첫** 인증의 `ASAuthorizationAppleIDCredential`에서 이름/이메일을 즉시 저장(Apple은 한 번만 보냄); `@privaterelay.appleid.com` / `@private.icloud.com`을 검증·백엔드에서 허용; Firebase `displayName == null`이어도 재요청 없음; 버튼 문구는 공식 표현("Sign in with Apple" / "Apple로 로그인").
- 신호: `auth.apple`
- 수정: 자격 증명에서 미리 채우기, 폼은 선택, 릴레이 이메일 허용.
- 사례: [커뮤니티 — 4.0 / SIWA](../../rejections/community-cases.md#40-design--sign-in-with-apple-ux)

---

## 기기·UI

### IOS-IPAD-01 iPad에서 동작 (2.4.1 / 4.0 / 2.1)
- 근거: 심사관은 **iPad로도 테스트**(사례: iPad Air 11-inch M3, iPad Air 5). `TARGETED_DEVICE_FAMILY = 1,2`(유니버설)이면 깨진 iPad 레이아웃은 4.0/2.1 리젝. `1`(iPhone 전용)이어도 호환 모드로 실행되며 크래시 금지 — "'Create PIN' 버튼 무반응", 스플래시 멈춤이 iPad Air에서 거절됨.
- 확인: pbxproj `TARGETED_DEVICE_FAMILY`. 유니버설 → 13"·11" iPad 시뮬레이터에서 전 화면: 늘어난 레이아웃, 모달 크기, 탭 영역, 가로(`UISupportedInterfaceOrientations~ipad` 4방향이면 가로 확인; 세로만이면 `UIRequiresFullScreen = YES` + 세로만). iPhone 전용 → 그래도 iPad 시뮬레이터에서 실행·탭. iPad 13" 스크린샷은 실제 iPad 캡처(늘린 iPhone 이미지 금지).
- 신호: pbxproj, plist orientations
- 수정: 폭 제한 컨테이너(max 600pt 중앙) 최소 대응. 또는 iPhone 전용 — 그래도 iPad 크래시 금지.
- 사례: [2026-08-27 iOS 1.2 UGC](../../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — 심사 기기에 iPad; [커뮤니티](../../rejections/community-cases.md#40-design--sign-in-with-apple-ux)
- 일본 사례(2026): 심사 기기 기록 — iPad Air 11(M3/M4), iPad Pro 11(M4), iPhone 17 Pro Max; iPhone 전용 앱이 iPad를 **체크 해제**했는데도 iPad 레이아웃으로 거절("Appleユーザーは全デバイスで使えることを期待"); `UIRequiresFullScreen` + iPhone 전용으로 한 루프를 끊음. 케이스 파일마다 심사 기기를 기록할 것. [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- 한/일 3차 사례(2026): 거의 모든 리젝이 iPadOS 26.x의 "iPad Air 11-inch (M3)"를 심사 기기로 기록, iPhone 전용이라는 답신은 거부됨; 구체 실패: 호환 모드 윈도우 크기, `flutter_screenutil` `.h` 스케일링, `EnvironmentObject`를 상속 못 한 SwiftUI 시트, 화면 아래로 벗어난 버튼. 제출 전마다 iPadOS 26 호환 창에서 테스트. [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### IOS-IPAD-02 휴대폰 본인인증(PASS/SMS)은 iPad에서 불가
- 근거: iPad Air 심사에서의 한국 2.1 리젝: "Unable to proceed with PASS authentication after selecting a carrier option" — iPad엔 SMS가 없는데 Apple은 iPhone 전용 앱도 iPad로 심사. `TARGETED_DEVICE_FAMILY = 1`, iPad 스크린샷/방향 제거, "Supported Destinations"로는 iPad 심사를 막지 **못했고**, `UIRequiredDeviceCapabilities = [telephony]`로 iPad 설치 불가 처리 후 승인.
- 적용: 가입에 PASS/통신사 SMS 본인인증이 필요한 앱, 휴대폰 전용 흐름
- 확인: SMS 외 대체 경로(이메일 OTP, Sign in with Apple) 존재, 또는 `UIRequiredDeviceCapabilities`에 `telephony`(iPad·Wi-Fi 전용 기기 설치 불가 감수).
- 신호: `auth.phone`, `carrier.auth`
- 수정: 대체 경로 추가 또는 `telephony` 선언.
- 사례: [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### IOS-UI-01 기본 완성도 (4.0 Design)
- 확인: 다크 모드 깨짐(필요 시 `UIUserInterfaceStyle = Light`), safe area·노치·Dynamic Island 침범, 키보드가 입력창 가림, 빈 상태, 큰 Dynamic Type에서 잘림.
- 한국 사례: 가입·탈퇴를 Safari로 열면 4.0 리젝("default web browser… poor user experience") — `SFSafariViewController` / `ASWebAuthenticationSession` 사용.

### IOS-UI-02 비공개 API·다운로드 코드 금지 (2.5.1 / 2.5.2)
- 확인: private API를 쓰는 플러그인(업로드 시 ITMS 경고). 코드 푸시(CodePush/Shorebird…)는 앱의 주 목적을 바꾸지 않는 범위에서만.
- Apple 2차 문구: "The app installed or launched executable code. Specifically, the app uses the itms-services URL scheme"(2.5.2); "uses public APIs with Notification Center in a manner not prescribed by Apple"; PC 에뮬레이터와 VPN/루트 인증서 필터는 2.5.1(CONTENT-14). [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### IOS-UI-03 외부 링크·앱 유도 (3.1.1(a) / 2.3.10)
- 확인: 미국 스토어프론트 외에서는 "웹에서 더 싸게 구독" 링크·버튼·문구 없음(3.1.1(a): 미국만 엔타이틀먼트 없이 허용; EU/일본/한국은 프로그램 — IOS-IAP-02). 다른 앱 설치 유도 최소; 다운로드·리뷰 강요 금지(3.2.2(x)).

---

## Info.plist

### IOS-PLIST-01 권한 문구 누락·부실 (5.1.1(ii))
- 근거: 권한 API 호출에 해당 `NS*UsageDescription`이 없으면 **크래시** → 2.1. 있어도 모호하면 5.1.1 리젝.
- 확인: `perm.*` 신호별 필요 키:
  | 신호 | 키 |
  |---|---|
  | perm.camera | NSCameraUsageDescription, NSPhotoLibraryUsageDescription (+ 저장 시 NSPhotoLibraryAddUsageDescription) |
  | perm.location | NSLocationWhenInUseUsageDescription (+ NSLocationAlwaysAndWhenInUseUsageDescription) |
  | perm.mic | NSMicrophoneUsageDescription (+ NSSpeechRecognitionUsageDescription) |
  | perm.contacts | NSContactsUsageDescription |
  | perm.calendar | NSCalendarsFullAccessUsageDescription (iOS 17+) |
  | perm.bluetooth | NSBluetoothAlwaysUsageDescription |
  | perm.health | NSHealthShareUsageDescription, NSHealthUpdateUsageDescription |
  | track.att | NSUserTrackingUsageDescription |
  | Face ID | NSFaceIDUsageDescription |
  | 로컬 네트워크 | NSLocalNetworkUsageDescription |
  플러그인이 내부적으로 쓰는 것(image_picker → 카메라+사진)도 포함. 문구는 "X를 위해 Y를 사용".
- 신호: `iOS Info.plist` 섹션 vs `perm.*`
- 수정: 키 추가 + `InfoPlist.strings` 현지화(ko/en).

### IOS-PLIST-02 UIBackgroundModes 정당성 (2.5.4)
- `common.md` BG-01. `audio`·`location`·`voip`·`fetch`·`processing` 각각 실제 기능 필요.
- 일본 사례: `expo-audio`는 `enableBackgroundPlayback: true`가 기본이고 `expo-notifications`는 `aps-environment`를 추가 — `npx expo config --type introspect`로 확인; 실제 기능 하나당 백그라운드 모드 하나. [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- Apple 2차 문구: "declares support for external-accessory in the UIBackgroundModes key… does not declare any external accessory protocols". [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### IOS-PLIST-03 URL Scheme·LSApplicationQueriesSchemes
- 확인: 카카오 → `kakao{APP_KEY}` scheme + `LSApplicationQueriesSchemes`에 `kakaokompassauth`, `kakaolink`, `kakaoplus`. 네이버 → `naversearchapp`, `naversearchthirdlogin`. 없으면 카카오톡 앱 로그인 실패.
- 신호: `LSApplicationQueriesSchemes`, `auth.kakao`

### IOS-PLIST-04 ATS
- 확인: `NSAllowsArbitraryLoads = true`면 심사 노트에 사유. 가능하면 도메인 예외만.

### IOS-PLIST-05 플러그인이 주입한 기본 목적 문구
- 근거: Apple의 **자동** 분석이 플레이스홀더 목적 문구를 지적 — "An automated analysis of the submission indicates the following purpose strings… include placeholder text or are otherwise insufficient" — 대개 Expo 설정 플러그인 기본값("Allow $(PRODUCT_NAME) to access your camera/microphone/Face ID/location")이며 앱이 쓰지도 않는 권한(프로젝트에 남은 expo-camera, expo-av, expo-local-authentication, expo-location)
- 적용: 기본 `NS*UsageDescription` 값을 넣는 플러그인을 쓰는 Expo / React Native / Flutter 프로젝트
- 확인: `npx expo config --type introspect`(또는 병합된 Info.plist)에 실제 쓰는 권한만 구체 문구로; 플러그인 옵션에 `cameraPermission: false` / `microphonePermission: false` / `faceIDPermission: false`, 미사용 패키지 제거(Android의 `RECORD_AUDIO` / `ACCESS_*_LOCATION`도 함께 빠짐).
- 신호: `plist.default.purpose`
- 사례: [한/일 3차](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

---

## 개인정보·매니페스트

### IOS-PRIV-01 App Privacy 라벨 (ASC)
- `common.md` PRIV-02. 제출 전 SDK 기준으로 "App Privacy" 작성.

### IOS-PRIV-02 ATT (5.1.2(i))
- `common.md` PRIV-03. 광고·어트리뷰션 SDK → ATT 요청 + `NSUserTrackingUsageDescription`. ATT 거부가 기능을 제한하면 안 됨.

### IOS-PRIV-03 Privacy Manifest — Required Reason API & SDK 매니페스트
- 근거: "2024-05-01부터 required reason API 사용을 매니페스트에 기술하지 않은 앱은 App Store Connect가 받지 않는다." `PrivacyInfo.xcprivacy` 키: `NSPrivacyTracking`, `NSPrivacyTrackingDomains`(ATT 동의 없으면 해당 도메인 요청 실패), `NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes`+사유 코드. Apple 지정 SDK(Firebase*, GoogleSignIn, FBSDK*, Alamofire, Flutter, Kingfisher, SDWebImage, RxSwift, OneSignal, Lottie, Realm…)는 자체 매니페스트·서명 필수 — https://developer.apple.com/support/third-party-SDK-requirements/
- 오류 코드: **ITMS-91053 "Missing API declaration"** = 바이너리(또는 내부 SDK)가 사유 없이 required-reason API 호출. **ITMS-91061 "Missing privacy manifest"** = 지정 SDK에 매니페스트 없음(신규 앱/해당 SDK 추가 업데이트는 ~2025-02부터 차단).
- 확인: 앱 타깃에 `PrivacyInfo.xcprivacy` + Copy Bundle Resources. 범주: FileTimestamp(DDA9.1, C617.1…), SystemBootTime(35F9.1…), DiskSpace(E174.1, 7D6E.1…), ActiveKeyboards(54BD.1), UserDefaults(CA92.1).
- 신호: `PrivacyInfo.xcprivacy 파일 수`
- 수정: Xcode > New File > App Privacy. Flutter/RN: `ios/Runner/PrivacyInfo.xcprivacy` + 프로젝트 추가. 매니페스트를 포함한 SDK 버전으로 갱신.

### IOS-PRIV-04 병합된 프라이버시 매니페스트의 추적 플래그 일관성 (ITMS-91064)
- 근거: 업로드 거절 "ITMS-91064: Invalid privacy manifest… NSPrivacyTracking must be true if NSPrivacyTrackingDomains isn't empty"(그 반대: 도메인이 **비어 있는데** tracking=true) — 병합된 SDK 매니페스트(AdMob, UnityFramework 포드)가 플래그나 도메인을 불일치하게 설정하고, 소스 수정은 빌드 시 덮어써짐
- 적용: 광고/어트리뷰션 SDK, Unity, `NSPrivacyTracking`이 있는 모든 앱
- 확인: 아카이브 후 .xcarchive의 모든 `PrivacyInfo.xcprivacy`(앱 + 프레임워크): `NSPrivacyTracking=true` ⇔ `NSPrivacyTrackingDomains` 1개 이상(예: `googleads.g.doubleclick.net`); 중복 매니페스트 없음(ITMS-91056).
- 수정: 아카이브 후 플래그/도메인을 맞추고 재서명하는 스크립트, 또는 SDK 업데이트.
- 사례: [일본어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

---

## 메타데이터·제출

### IOS-META-01 스크린샷 규격
- 근거: ASC 스크린샷 규격 — 기기 클래스당 1~10장, JPG/PNG 알파 없음. iPhone 6.9" **1320×2868**(또는 2868×1320) 필수(6.9"가 없으면 6.5" 1284×2778을 받아 스케일). iPad 13" **2064×2752 또는 2048×2732**(가로 가능) — iPad에서 실행되면 필수. 실제 앱 사용 화면(2.3.3), 타 플랫폼 이미지 금지(2.3.10), 4+ 적합(2.3.8). 2026 가을 신규 크리에이티브 자산(제품 페이지 헤더, 검색 결과 자산)은 선택.

### IOS-META-02 App Review Information
- 근거: 2.3.1(a) 신규 기능은 "Notes for Review에 구체적으로… (일반적 서술은 거절)"; 2.1(a)/(b) 데모 계정과 IAP 가시성; App Review 페이지 "Incomplete information"이 상위 리젝 사유("미해결 이슈의 40% 이상이 2.1 App Completeness")
- 확인: "Sign-in required" + "만료되지 않는" 데모 계정(추가 계정은 노트에), 노트 ≤ 4000바이트 어떤 언어든(`templates/review-notes.md`), 연락처 이름/이메일/전화("+" 국제 형식), 첨부/링크(녹화). UGC 앱은 녹화 링크 **필수**(사례). 조건부(지역·역할·시간·하드웨어) 기능 설명.
- Apple 2차 사례: 첫 제출부터 심사관의 7문항 템플릿(녹화, 기기, 목적, 접근, 외부 서비스, 지역 차이, 규제 여부)을 미리 채움; "Would you please explain the difference between this app and [App ID]?", "we want to understand your business model"은 노트에서 답변; 데모 계정이 페이월/링크아웃을 *볼 수 있게*(구독자 계정은 숨김). [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### IOS-META-03 수출 규정 준수
- 확인: `ITSAppUsesNonExemptEncryption` 키. HTTPS만 → `false`로 업로드마다 질문 생략. 자체 암호화(E2EE…) → `true` + 연 1회 자가 분류 보고(미국).
- 신호: plist

### IOS-META-04 최소 Xcode / SDK
- 근거: https://developer.apple.com/news/upcoming-requirements/ — "Xcode 26 이상, iOS 26/iPadOS 26/tvOS 26/visionOS 26/watchOS 26 SDK로 빌드", **2026-04-28** 시행(watchOS는 64비트도). 매년 4월 갱신.
- 확인: `xcodebuild -version` ≥ 26; Flutter/RN/Expo가 iOS 26 SDK 지원; CI 이미지 갱신.
- 한국 사례(2026-03): 벤더 SDK가 내 Xcode보다 새 SDK로 빌드된 바이너리를 번들(Kakao Navi KNSDK-UI 1.12.16의 Realm)하면 ITMS-90512 "Invalid SDK value" / ITMS-91065 "Missing signature"로 업로드 실패; 재서명은 서명을 깨뜨림 — SDK 다운/업그레이드.

### IOS-META-05 버전·빌드 번호
- 확인: 재제출 시 `CFBundleVersion` 증가. `MARKETING_VERSION`은 스토어 버전과 일치.

### IOS-META-06 연령 등급 설문 (2025~2026 체계)
- 근거: 등급 4+/9+/13+/16+/18+와 새 문항(앱 내 제어: 자녀 보호·연령 확인; 기능: 무제한 웹 접근, UGC, 소셜 미디어, 메시지·채팅, 광고; 의료/웰니스; 폭력; 확률형: 도박, 모의 도박, 콘테스트, 루트박스). 2026-01-31까지 응답 필수; **2026-09부터 제출 시 소셜미디어 문항 필수**; "Social Media" 기능은 최소 13+(iOS 27 Time Allowances); 루트박스 → 브라질 18+; 한국 비속어/성인 주제 → 2026-10부터 12+. 2.3.6: 정직하게.
- 확인: ASC 설문이 UGC/메시지/소셜 기능과 웹 탐색을 반영; 결과 등급이 마케팅과 일치(Kids 카테고리 외 "for kids" 문구 금지 — 5.1.4(b)).
- 신호: `ugc.*`, `webview`, `pay.iap`(루트박스)

### IOS-META-07 프로모션 인앱 구매 이미지 (2.3.2)
- 근거: 2026년 리젝 6건: "Your promotional image is the same as the app's icon" · "duplicate or identical promotional images for different promoted In-App Purchase products" — 프로모션 IAP마다 앱 아이콘도 스크린샷도 아닌 고유한 1024×1024 이미지, 가격 없음, 글자 최소
- 적용: ASC에서 "프로모션" 표시된 IAP
- 확인: 상품별 고유 아트워크; 가격 텍스트 없음; 아이콘 아님.
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### IOS-META-08 EU DSA 트레이더 상태
- 근거: ASC > Business > Compliance Requirements — 트레이더 상태를 선언하지 않으면 승인된 앱이 EU27에서 조용히 비공개("トレーダーステータスが提供されていません")
- 적용: EU에 배포하는 모든 앱
- 확인: 트레이더 상태 선언(수익화하면 트레이더) + 연락처 검증.
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

---

## Entitlements·특수 기능

### IOS-ENT-01 Capabilities ↔ 코드 일치
- 확인: 푸시 → `aps-environment` entitlement + ASC 앱 ID에 Push 켜짐(없으면 토큰 실패 → 심사 중 기능 미동작). Associated Domains, App Groups(위젯) 등 코드와 일치.
- 신호: entitlements 목록 vs `perm.push`, `deeplink`

### IOS-ENT-02 Screen Time API (FamilyControls) — 별도 승인
- 근거: `com.apple.developer.family-controls`는 **Apple에 신청·승인 필요**(수 주). 승인 없이 제출하면 빌드 실패 또는 리젝. 집중/앱 차단 앱에 흔함.
- 적용: `perm.screentime` > 0
- 확인: 승인된 entitlement가 배포용 프로비저닝 프로파일에 있음(배포 승인은 개발용과 별개).
- 수정: https://developer.apple.com/contact/request/family-controls-distribution 신청 후 대기. 승인 전엔 기능 숨김.

### IOS-ENT-03 Sign in with Apple entitlement
- IOS-LOGIN-01. `com.apple.developer.applesignin` 배열 `Default`.

### IOS-ENT-04 남은 capability·프레임워크 참조 없음
- 근거: 2.5.1 리젝 문구 "binary includes references to HealthKit components, but the app does not appear to include any primary features that require health or fitness data", "still includes ScreenTime API without ScreenTime features", "binary contains references to App Tracking Transparency, but you have indicated you do not intend to ask users for permission to track"; Kids 앱의 ATT 참조는 1.3 리젝
- 적용: Xcode나 App ID에서 한 번이라도 켠 capability; HealthKit/ATT/FamilyControls를 링크하는 SDK; 제거된 기능
- 확인: Signing & Capabilities에 보이는 기능이 있는 capability만; **개발자 포털의 App ID**도 일치(거기만 켜져 있어도 리젝된 사례); 기능이 없어졌으면 바이너리에 `otool -L`/`strings`로 `HealthKit`, `ATTrackingManager`, `FamilyControls`, `DeviceActivity` 확인; 추적 안 하면 `NSUserTrackingUsageDescription` 없음.
- 신호: entitlements 목록, `perm.health`, `track.att`, `perm.screentime`
- 수정: Xcode **와** App ID 양쪽에서 capability 제거; SDK/모듈 제거; plist 키 삭제.
- 사례: [커뮤니티 — 2.5.1](../../rejections/community-cases.md#251--231-software-requirements-leftover-capabilities-hidden-features)

---

## 백그라운드·타이머 (집중/타이머 앱)

### IOS-BG-01 타이머 유지 방식 (2.5.4)
- 근거: 무음 오디오·가짜 위치 업데이트로 앱을 살려두면 리젝. 타이머 앱은 백그라운드 실행 없이 **종료 시각 + 로컬 알림 + Live Activity/위젯**이 가장 안전.
- 확인: `bg.audio` 신호(silence.mp3, 소리 없는 AVAudioSession playback); `audio_service` / `just_audio_background`가 실제 사운드 재생용인지.
- 수정: `common.md` BG-01. 실제 앰비언트 사운드 기능이 있으면 심사 노트에 명시("Background audio is used for the ambient sound feature; the timer itself uses local notifications").

### IOS-BG-02 Live Activity / 위젯
- 확인: `NSSupportsLiveActivities = true`, 위젯 익스텐션 App Group. 심사 항목은 아니지만 크래시 요인.

---

## 결제

### IOS-IAP-01 IAP 제출 상태
- `common.md` PAY-01~04. 첫 제출 시 IAP를 버전에 첨부, Paid Apps Agreement 완료, 페이월에 약관/방침 링크·복원.

### IOS-IAP-02 지역별 외부 결제 프로그램
- 근거: **한국** — StoreKit External Purchase entitlement(한국 전용 바이너리; 승인 PSP KCP·이니시스·토스·NICE; "사용자 지불액의 26% 수수료"; 결제 흐름마다 모달 고지; 월별 매출 보고). **미국** — 3.1.1(a): 엔타이틀먼트 없이 링크·버튼 허용, IAP도 제공해야; 수수료 소송 진행 중(2026-08). **EU** — 2026-10-01부터 통합 조건(Core Technology Commission 5%, IAP와 병행 대체 결제). **일본** — MSCA: iOS 26.2+ 대체 결제/마켓, IAP 병행 제시.
- 적용: `pay.external` > 0 & 디지털 재화
- 확인: 엔타이틀먼트 승인 + 지역 한정 바이너리; 고지 표시; 아니면 3.1.1 리젝.
### IOS-IAP-03 Apple Pay 표시 (4.9)
- 근거: "The Apple Pay button isn't displayed prominently as an equivalent purchase option" — 모든 결제 화면에서 Apple Pay가 다른 결제 버튼과 최소 동등하게 노출; 중개 앱은 시트에 "PAY <merchant> (VIA <app>)" 표시; PassKit을 링크만 하고 안 쓰면 "binary includes the PassKit framework… unable to verify any integration"(IOS-ENT-04)
- 적용: Apple Pay가 있는 실물 상품/서비스 결제(flutter_stripe, Shopify…)
- 확인: 버튼 위치/크기; 가맹점 표기; PassKit은 쓸 때만.
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### IOS-IAP-04 내장 기능은 페이월 기능이 아니다 (4.10)
- 근거: "The app charges users for access to built-in iOS capabilities. Specifically, iCloud sync." — iCloud 동기화, 푸시, 카메라 등 OS 내장 기능을 구매 뒤에 두지 말 것; 백업/내보내기 기능 이름이 동기화가 유료인 것처럼 보이지 않게
- 적용: 프리미엄 등급이 있는 앱
- 확인: 페이월이 해제하는 것; "동기화"/"백업" 문구.
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

