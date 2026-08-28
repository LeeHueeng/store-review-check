# Android 체크리스트 — Google Play 정책 (한국어 번역)

> 영어 원본 `../android.md`가 정본. 기준일 2026-08-28, 정책 센터(https://support.google.com/googleplay/android-developer/topic/9858052)·Play Console 도움말. 기능 조건부 항목은 `common.md`. 출처: `../../references/google-play.md`.

---

## SDK·빌드

### AND-SDK-01 targetSdk 요구치
- 근거: **타겟 API 수준 요구사항**(2026 원문): "신규 앱과 업데이트는 Android 16(API 36) 이상 타겟 필수(Wear OS·Automotive는 Android 15)" — 마감 **2026-08-31**; "기존 앱은 신규 사용자에게 계속 노출되려면 Android 15(API 35) 이상"; "2026-11-01까지 연장 신청 가능". 매년 8월 31일 상향.
- 확인: `targetSdk` 숫자. Flutter `flutter.targetSdkVersion`은 Flutter SDK 버전에 따름(3.27+ → 35, 3.35+ → 36; 확인) → `flutter --version` + `flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`. Expo SDK 52+ → 35, 54+ → 36(확인).
- 신호: `Android Gradle` 섹션, 자동 힌트
- 수정: `targetSdk` 상향 + 해당 버전 동작 변경 대응(FGS 타입·시작 제한, 사진 권한, 알림 권한, edge-to-edge(35+), 16KB 페이지).

### AND-SDK-02 16KB 페이지 크기
- 근거: "2025-11-01부터 Android 15+ 기기를 타겟하는 모든 신규 앱·업데이트는 16KB 페이지 지원 필수"; "**2027-02-01부터** 16KB 미지원 업데이트는 출시 불가"; 기술 품질: "네이티브 코드가 있는 앱은 16KB 지원 필수. Java/Kotlin 전용 앱은 기본 호환"(TV 2026-08-01, Wear 2026-09-15)
- 확인: `.so` 포함 앱(Flutter, RN, SQLite…)은 AGP 8.5.1+ / NDK r28+로 빌드; 아니면 Play Console 앱 번들 탐색기에 경고.

### AND-BUILD-01 서명·번들
- 확인: AAB 업로드(2021-08부터 신규 앱 필수), 업로드 키 서명(릴리즈에 `signingConfigs.debug` 금지; 업로드 키 "RSA 2048비트 이상"), Play 앱 서명, `debuggable false`, `minifyEnabled`(2027-02부터 25% 코드 최적화가 품질 요건), arm64-v8a 포함("네이티브 코드 앱은 64비트 필수").
- 신호: Gradle 섹션
- 한국 사례: `versionCode`는 versionName이 올라가도 반드시 증가(`1.0.0+7` 뒤 `1.0.1+0`은 "앱 업데이트가 거부되었습니다"); 다른 PC에서 다른 업로드 키로 만든 AAB는 재심사 실패.

### AND-BUILD-02 매니페스트 필수 속성
- 확인: `android:exported` 명시(API 31+, 인텐트 필터 컴포넌트), `usesCleartextTraffic="true"` 제거 또는 network_security_config로 도메인 한정, `allowBackup` 의도 확인.
- 신호: Manifest 섹션

---

## 권한 (Play 권한 정책 + 선언 양식)

### AND-PERM-01 SMS·통화 기록
- 근거: "SMS/Call Log 권한을 요청하려면 기본 SMS·전화·어시스턴트 핸들러로 등록돼 있어야"; OTP → SMS Retriever API / User Consent API. **2027-01-27**부터 READ_CALL_LOG는 "전화 통화를 통한 계정 인증" 용도 불허(Digital Credentials API / SMS Retriever 사용).
- 신호: 자동 힌트
- 수정: 제거; SMS Retriever로 전환.

### AND-PERM-02 QUERY_ALL_PACKAGES
- 근거: "핵심 사용자 기능이 설치 앱 전체 가시성을 요구할 때만"(런처, 보안, 앱 관리); 그 외 `<queries>`로 특정 패키지만; Play Console 선언 양식 필수.
- 적용: 집중 앱의 "차단할 앱 목록" — 카테고리 인텐트 `<queries>`로 대체하거나 양식에 핵심 기능 설명.

### AND-PERM-03 MANAGE_EXTERNAL_STORAGE (모든 파일 접근)
- 근거: 파일 관리자·백업·백신·문서 관리…만; 무효 예: "미디어 파일 접근", "사용자가 개별 파일을 수동 선택하는 모든 활동"; 선언 양식 + 승인. 대부분 Scoped Storage / SAF / Photo Picker로 대체.

### AND-PERM-04 백그라운드·정밀 위치
- 근거: "백그라운드 위치는 사용자에게 상당한 이점을 주고 핵심 기능과 관련될 때만"; "광고·분석만을 위한 위치 권한 요청 금지". 선언: 백그라운드가 필요한 기능 1개, 포그라운드로 부족한 이유, **30초 이내 영상**(고지 + 런타임 프롬프트). 사전 고지 형식: "[앱]은 [기능]을 위해 위치 데이터를 수집합니다… 앱이 닫혀 있거나 사용 중이 아닐 때도." 2026-04-15: **위치 버튼**이 "정밀 위치의 권장 최소 범위"; 위치 정책 개정 **2027-01-27** 시행(Android 17+ `onlyForLocationButton`).
- 확인: `ACCESS_BACKGROUND_LOCATION`은 핵심 기능일 때만; 프롬프트 전 고지(PRIV-04); 정밀 위치는 필요할 때만.

### AND-PERM-05 포그라운드 서비스 타입
- 근거: targetSdk 34+는 `<service android:foregroundServiceType="…">` + 타입별 `FOREGROUND_SERVICE_<TYPE>` 권한 필수; 없으면 런타임 예외. Play Console **포그라운드 서비스 권한** 선언(타입별): "각 타입을 쓰는 앱 기능 설명", "작업이 지연·중단될 때 사용자 영향 설명", "각 FGS 기능 시연 영상 링크". 타입: camera, connectedDevice, dataSync, health, location, mediaPlayback, mediaProcessing, mediaProjection, microphone, phoneCall, remoteMessaging, shortService, specialUse, systemExempted. Android 15+: dataSync/mediaPlayback 등은 BOOT_COMPLETED에서 시작 불가; mediaProcessing 24시간당 6시간; `specialUse`는 `PROPERTY_SPECIAL_USE_FGS_SUBTYPE`가 "제출 시 검토됨". 지오펜싱은 2027-01-27부터 FGS 용도에서 제외.
- 타입 가이드: 타이머 알림 유지 → `specialUse`(서브타입 속성 + 양식) 또는 `shortService`(3분). 백색소음 재생 → `mediaPlayback`. 추적 → `location`. 업로드 → `dataSync`(제한).
- 신호: 자동 힌트(`FOREGROUND_SERVICE` 있으나 타입 없음)
- 수정: 매니페스트 타입 + 권한 + `startForeground(id, notification, type)` + 콘솔 양식 + 데모 영상.
- Play 2차 사례: SDK(Zoom Meeting SDK, background-geolocation, expo-video)가 쓰지 않는 FGS 타입을 선언 — 해당 `FOREGROUND_SERVICE_*` 권한 제거 + SDK 서비스에 `tools:replace="android:foregroundServiceType"`; Organic Maps는 `specialUse`를 "필요 없을 때 사용"으로 거절당했다가 기능별 영상 + 타입 지정 서비스로 승인; 매니페스트의 `FOREGROUND_SERVICE_SPECIAL_USE`만으로 업로드 시 선언 게이트 발동.

### AND-PERM-06 접근성 서비스
- 근거: `BIND_ACCESSIBILITY_SERVICE`는 장애 보조 목적만. 그 외(앱 차단, 자동화)는 양식에서 "접근성 이외 용도" 신고 + 눈에 띄는 고지 + 동의. 거부율 높음.
- 적용: 집중 앱의 타 앱 차단 — UsageStats(AND-PERM-07) + 오버레이 조합이 더 잘 통과.
- 사례 교훈: 접근성 서비스를 제거한 뒤에도 Play Console(App content)의 접근성 선언을 삭제해야 계속 거절되지 않음. 스토어 설명의 고지는 인정 안 됨 — 활성화 전 앱 내 고지 필수.

### AND-PERM-07 사용 통계 (PACKAGE_USAGE_STATS)
- 근거: 서명 권한이지만 설정에서 사용자가 부여. Play 정책상 "핵심 기능"이어야 하며 사전 고지. Data safety에 "앱 활동 > 설치된 앱" 등 선언.
- 적용: 집중 앱의 앱 사용시간 측정
- 확인: 설정 이동 전 고지 화면.

### AND-PERM-08 사진·동영상 권한
- 근거: **사진 및 동영상 권한 정책** — API 33+ 타겟 앱은 "시스템 피커(Android Photo Picker 등)로 핵심 기능을 제공하기 부족할 때만" `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` 요청 가능(갤러리형 앱); 커스텀 피커도 "선언 제출 필수". 1단계 2025-01-22; "2025-05-28: 모든 개발자 전면 준수 필수". 프로필 사진 한 장 → **Photo Picker**.
- 확인: `image_picker`(Flutter 0.8.9+는 Photo Picker, 권한 불필요) 등이 매니페스트에 권한을 남기면 `tools:node="remove"`. 콘솔 "사진 및 동영상 권한" 선언 답변.
- 신호: 자동 힌트
- 사례: AND-PERM-08 태그 커뮤니티 사례

### AND-PERM-09 오버레이 (SYSTEM_ALERT_WINDOW)
- 근거: 정책은 완화됐지만 악성 앱 지표. 이유 설명 + 사용자 부여 흐름 필요. 집중 앱 차단 화면 용도는 통과 사례 다수.

### AND-PERM-10 정확한 알람·전체화면 인텐트
- 근거: `USE_EXACT_ALARM`은 "핵심 사용자 기능이 정밀 시간 동작을 요구할 때만, 예: 알람·타이머 앱, 일정 알림을 보여주는 캘린더 앱". 그 외 `SCHEDULE_EXACT_ALARM`(사용자 부여) 또는 비정확 알람. `USE_FULL_SCREEN_INTENT`: "알람 설정 또는 전화·영상 통화 수신이 핵심 기능인 앱만 자동 부여"; 그 외는 사용자 권한 요청 + "우아하게 저하"(선언 2024-05-31~; 그 외 기본 꺼짐 2025-01-22~). 기기·네트워크 남용: "전체화면 인텐트로 방해 광고·알림 강제 금지".
- 적용: 타이머 종료 알림
- 확인: 타이머 앱은 `USE_EXACT_ALARM` 정당(선언). 알림 채널 중요도; 전체화면 인텐트 사용.
- 사례 교훈: `USE_FULL_SCREEN_INTENT`는 알림 라이브러리가 넣는 경우가 많음 — 알람/통화 앱이 아니면 `tools:node="remove"`; Android 14+에서 예약 전 `canScheduleExactAlarms()` 확인(안 하면 Play가 지적).
- Play 2차 사례: Notifee < 9가 `USE_FULL_SCREEN_INTENT` 추가; ML Kit의 datatransport 텔레메트리가 `AlarmManager.setExact` 사용 → 정확한 알람 경고; Play Developer API는 선언 전까지 "You must let us know whether your app uses any exact alarm permissions"로 업로드 거부. 알람 앱이 아닌데 전체화면 인텐트를 몇 분 뒤 자동 닫기로 처리한 앱은 통과.

### AND-PERM-11 POST_NOTIFICATIONS (13+)
- 확인: targetSdk 33+는 런타임 알림 권한. 거부 시 타이머 종료 알림 안 뜸 → 맥락 있는 요청 + 거부 시 안내.

### AND-PERM-12 연락처 (Android 17 / API 37)
- 근거: Android 17(API 37)+ 타겟 앱은 "Android 연락처 피커로 핵심 기능이 부족할 때만" `READ_CONTACTS` 요청 가능; 선언 양식 ~2026-09, **2027-01-27** 의무화
- 적용: 연락처로 친구 찾기, 초대
- 확인: "친구 초대"는 연락처 피커; 광범위 접근은 연락처 관리형 앱만 + 선언 + 사전 고지(PRIV-04).

### AND-PERM-13 병합 매니페스트 감사 — 라이브러리가 주입한 권한
- 근거: 커뮤니티 사례에서 가장 흔한 Play 리젝 원인: `READ_MEDIA_IMAGES/VIDEO`, `READ_EXTERNAL_STORAGE`, `FOREGROUND_SERVICE_*` 타입, `QUERY_ALL_PACKAGES`, `USE_FULL_SCREEN_INTENT`, `ACCESS_BACKGROUND_LOCATION`, `AD_ID`가 image_picker, file_picker, permission_handler, expo-image-picker, expo-video, Agora, 업로드/다운로드 라이브러리, 알림 플러그인… 의 매니페스트 병합으로 들어옴.
- 적용: 모든 앱(의존성 업그레이드마다 확인)
- 확인: **병합된** 매니페스트 검사(`build/intermediates/merged_manifests/release/AndroidManifest.xml`, Android Studio "Merged Manifest" 탭, `bundletool dump manifest`). 실제 사용과 비교.
- 신호: 의존성 목록(`camera/media`, `background`, `push`), 자동 힌트
- 수정: 앱 매니페스트에 `<uses-permission android:name="…" tools:node="remove"/>`(Expo: app.json `android.blockedPermissions`); 병합 매니페스트 재확인. Play가 여전히 옛 빌드를 지적할 수 있음 — AND-CONSOLE-11.
- 사례: [커뮤니티 — 사진·동영상](../../rejections/community-cases.md#photo-and-video-permissions-read_media_images--video), [포그라운드 서비스](../../rejections/community-cases.md#foreground-service-declarations)

### AND-PERM-14 VpnService
- 근거: VpnService는 핵심 VPN + 자녀 보호/기업, 앱 사용 추적, 기기 보안, 네트워크 도구, 브라우저, 통신사 앱만; "눈에 띄는 고지·동의 없이 개인정보 수집", "수익화를 위한 타 앱 트래픽 리디렉션·조작" 금지. 리젝 문구: "We are unable to confirm your app's declared use of VpnService as a permitted use case… should be removed from the app manifest across all release tracks."
- 적용: `perm.vpn` > 0
- 확인: 용도가 목록에 해당; 선언 양식 제출; 핵심이 아니면 VpnService 제거.

### AND-PERM-15 REQUEST_INSTALL_PACKAGES
- 근거: "Permission use is not directly related to your app's core purpose… not compliant with how REQUEST_INSTALL_PACKAGES permission is allowed to be used… Please remove the use of REQUEST_INSTALL_PACKAGES permission from your app." 패키지 전달이 핵심 목적인 앱(브라우저, 파일 공유/전송, 기업 기기 관리, 백업/복원)만 허용.
- 적용: `open_file`(Flutter), 앱 내 업데이터 플러그인, 파일 관리자가 주입
- 확인: 패키지를 설치하는 앱이 아니면 병합 매니페스트에 없음; 설치한다면 선언 제출.
- 수정: 플러그인 교체(`open_filex`) 또는 `tools:node="remove"`.
- 사례: [Play 2차](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### AND-SEC-01 앱 보안 스캐너 플래그
- 근거: Play 보안 검토가 빌드를 거절: "Leaked AWS credentials / Your app contains Exposed Amazon Web Services Credentials", "intent scheme hijacking"(`shouldOverrideUrlLoading`에서 웹 콘텐츠의 `Intent.parseUri`), "WebView that is vulnerable to cross-app scripting"(인텐트/푸시에서 온 URL을 검증 없이 `loadUrl`), 경고 "Authentication via WebView"
- 적용: WebView, 내장 클라우드 키, WebView 기반 OAuth가 있는 모든 앱
- 확인: 클라이언트에 비밀 없음(사전 서명 URL/백엔드); `loadUrl` 전 URL 검증(`Patterns.WEB_URL`, 호스트 허용 목록); 웹 콘텐츠의 `intent://` URI 파싱 금지; OAuth는 Custom Tabs/AppAuth.
- 수정: 위와 같이 고친 뒤 재제출 — 스캐너가 새 AAB를 재검사.
- 사례: [Play 2차](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

---

## Play Console 선언 (코드 밖)

### AND-CONSOLE-01 개인정보처리방침 URL
- 근거: 모든 앱 필수(2024~). 스토어 등록정보 + 앱 내 링크. `common.md` PRIV-01.

### AND-CONSOLE-02 데이터 보안(Data safety)
- 근거: SDK 포함 수집·공유·보안 관행을 정확히 선언. 계정 삭제 URL 포함(AND-CONSOLE-08). 불일치 → 정책 통지·업데이트 거부.
- 확인: `common.md` PRIV-02 SDK 표와 비교. "전송 중 암호화", "삭제 요청 방법".

### AND-CONSOLE-03 Sign-in details (구 "앱 액세스")
- 근거: Play Console > 정책 및 프로그램 > App content > **Sign-in details**("안내 최대 5세트"; OTP/MFA는 "기타 안내"). 요건: "항상 접근 가능, 재사용 가능, 사용자 위치와 무관하게 유효… 2단계 인증/OTP가 필요하면 이를 우회하는 재사용 가능 자격 증명… 영어로 제공… 비밀번호 만료 시 심사 불가로 거부 가능". 유료 콘텐츠도 접근 안내. 거부는 "Broken Functionality"/확인 불가로 나타남.
- 확인: `templates/review-notes.md` Android 부분; 소셜 로그인만 → 이메일 리뷰어 계정(ACC-03); 해외 IP에서 자격 증명 테스트.
- 한국 사례: Play는 자격 증명 대신 데모 영상을 **받지 않음**; QR/하드웨어 게이트 앱은 장기 코드 제공; 한글 ID·관리자 계정 거부; 카카오/네이버/구글만 있는 로그인 불인정 — ID/PW 로그인 추가(ACC-05).

### AND-CONSOLE-04 광고 ID·광고 포함
- 근거: `AD_ID` 권한 선언(targetSdk 33+, 광고 SDK가 병합) + Data safety 광고 ID + "광고 포함" 선언. 광고 ID 안 쓰면 `tools:node="remove"` 후 "아니오".
- 신호: 자동 힌트
- Play 2차 사례: Firebase Analytics만 있고 광고가 없으면 광고 ID 선언에 **예**(분석 용도)로 답하라는 것이 Google 지원의 조언 — 권한 제거보다 안전; 양방향 모순 오류는 대개 옛 활성 번들이 다르기 때문(AND-CONSOLE-11).

### AND-CONSOLE-05 콘텐츠 등급 (IARC)
- 근거: 설문 미완료 시 게시 불가. **UGC·채팅·친구 → "사용자 상호작용/정보 공유" = 예**. 허위 답변은 정지 사유.
- 확인: `common.md` META-03.

### AND-CONSOLE-06 민감 권한 선언 양식
- 근거: 포그라운드 서비스, 정확한 알람, 전체화면 인텐트, 사진/동영상, 백그라운드 위치, 모든 파일 접근, QUERY_ALL_PACKAGES, 접근성, SMS… 는 App content > 민감한 앱 권한/포그라운드 서비스 양식 필수. 각: 핵심 기능 설명 + 데모 영상(YouTube 비공개 OK).
- 확인: 매니페스트 권한 ↔ 제출한 양식.
- 사례 교훈: CI/CD 업로드(Fastlane/Play API)는 새 선언 양식을 띄우는 콘솔 프롬프트를 건너뜀 — 새 민감 권한이 생기면 **콘솔 UI로 한 번** AAB 업로드; 데모 영상은 일반 게임플레이가 아니라 권한/FGS 기능 자체를 보여야; 선언 타입은 코드가 실제 시작하는 타입과 일치.

### AND-CONSOLE-07 타깃 연령·아동
- 근거: 타깃층·콘텐츠 설문(5세 이하 / 6–8 / 9–12 / 13–15 / 16–17 / 18+). 아동 포함 시 **Families 정책**: "Families 자가 인증 광고 SDK만 사용"(프로그램은 "현재 신규 신청 미접수"; AdMob ≥19, Unity Ads, ironSource… 목록; AppLovin 탈퇴), 관심 기반 광고 금지, 아동 전용 앱은 AAID/IMEI 등 전송 금지, AR 안전 경고, 소셜 앱 "온라인 안전 앱 내 안내"; 혼합 연령 → "중립 연령 화면 필수"; 의도치 않게 아동에게 어필하면 "거부 가능"; 검토 "최대 7일 이상". 2026-07-15부터 낯선 사람·익명 채팅 중심 소셜 앱은 아동 타깃 불가.
- 확인: 스토어 문구("학생", "어린이") ↔ 타깃 연령; 아동 포함 시 광고 SDK가 자가 인증 목록에 있는지.
- Play 2차 사례: "non-certified ad SDKs"가 Stripe(광고 SDK 아님), Adjust, Amplitude, 아동 태깅 없는 AdMob에서 발생; 해결은 `tagForChildDirectedTreatment` / SDK 제거 / `AD_ID tools:node="remove"`. **중립 연령 화면**은 월/일/년을 자유 입력해야 — 연령대 버튼 3개는 중립이 아님 — 그 전에 아무것도(Play Games 자동 로그인, 분석) AAID를 보내면 안 됨. Families의 "App stability" 리젝은 심사 환경에서 온디맨드 에셋 팩 실패 때문(AND-REVIEW-01).

### AND-CONSOLE-08 계정 삭제 URL
- 근거: 계정 생성 앱은 Data safety > "계정 삭제 요청 URL" + 앱 내 삭제. `common.md` ACC-02.

### AND-CONSOLE-09 필수 선언 — 답이 "없음"이어도
- 근거: **건강 앱 선언**: "Play에 게시된 앱이 있는 모든 개발자는 비공개/공개 테스트·프로덕션 트랙 포함 건강 앱 선언 완료 필수"(2024-08-31 이후). **금융 기능 선언**: 모든 앱 필수("금융 기능 없음" 옵션); 2025-10-30부터 "완료 전까지 앱 업데이트 불가". **뉴스·잡지** 자가 선언(미준수 시 삭제, 2026-05-27 재고지). **정부 앱** 선언(2023-01-31~). 그 외 COVID-19, 블록체인(금융 기능 양식), VPN.
- 확인: App content 페이지에 모든 선언 완료. "정신 건강" 문구를 쓰는 집중 타이머는 건강 앱 가능(건강 콘텐츠·서비스 정책).
- 사례 교훈: Health Connect·금융 선언은 **전체 스토어 설명**으로 판단 — 데이터 유형별 필요 이유 기재; 대출/SIP 계산기가 "금융 기능 없음"으로 거절됨; 정책 URL은 공개 유지.

### AND-CONSOLE-10 Child Safety Standards 자가 인증
- 근거: 소셜·데이팅(2025-01-22~)과 익명/랜덤 채팅(2026-07-15~) 앱은 "아동 성적 학대·착취(CSAE)에 대한 공개 기준" 전 세계 접근 가능 URL, "앱 내 사용자 피드백 수단", CSAM 처리, 아동 안전법 준수, "아동 안전 담당자" + 게시 전 Play Console 자가 인증. 데이팅/랜덤/익명 채팅/도박 앱은 Play Console 도구로 미성년자 차단(연령 제한 콘텐츠 정책).
- 적용: 소셜/데이팅 카테고리, 낯선 사람과 채팅, 익명 채팅(common UGC-07)
- 확인: CSAE 기준 페이지 URL; 담당자; Play Console App content > 아동 안전 기준 완료.

### AND-CONSOLE-11 재제출 전 모든 트랙의 옛 빌드 비활성화
- 근거: 리젝이 **옛 버전 코드**를 반복 지적(예: "Remove the use of … permission from all version codes within the submission") — 내부/비공개/공개 트랙에 문제 권한·targetSdk·크래시가 있는 빌드가 남아 있기 때문.
- 적용: 권한/targetSdk/크래시 수정 후 모든 재제출
- 확인: Play Console > 출시: 모든 활성 트랙의 최신 출시가 수정 빌드(또는 트랙 일시중지/비활성); 앱 번들 탐색기에 문제 권한의 옛 번들 없음.
- 수정: 수정 빌드를 모든 트랙에 승격하거나 트랙 비활성화; 재제출; 권한이 사라졌어도 필요한 선언 양식은 제출.
- 사례: [커뮤니티](../../rejections/community-cases.md#photo-and-video-permissions-read_media_images--video)
- 한국 사례: VC 6을 고친 뒤에도 **공개 테스트** 트랙의 VC 3이 지적됨 — 그 트랙에 수정 번들로 릴리즈를 만들어 옛 번들을 비활성화; 테스트 트랙 번들은 삭제 불가, 덮어쓰기만 가능.

### AND-CONSOLE-12 정부 정보 앱
- 근거: 혼동을 야기하는 주장 리젝 "Your app doesn't provide a clear source of government information or its description lacks an easy-to-see disclaimer stating that the app doesn't represent a government entity" / "Identify a clear source of government information"; 고지문만으로는 거의 통과 못 함 — 정부 앱 선언 + 서면 승인, 앱 내 소개/고지 페이지, 설명의 완전한 출처 URL(심사관이 그대로 복사)이 있어야 통과
- 적용: 정부/공공 콘텐츠를 재게시·임베드하는 앱(한국 사례는 AND-META-04)
- 확인: 정부 앱 선언 답변; 제휴 주장 시 승인 서한; 등록정보 **와** 앱 내 고지; 모든 출처 URL 완전·접속 가능; 허가 없는 정부 사이트 임베드 없음.
- 사례: [Play 2차](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

---

## 스토어 등록정보

### AND-META-01 메타데이터 정책
- 근거: 앱 제목 "30자 이하"; "이모지·이모티콘·반복 특수문자" 금지; 제목·아이콘·개발자명에 "스토어 성과·순위·가격·홍보 정보" 텍스트/이미지 금지("App of the year", "#1", "Best of Play", "10% off", "free for limited time only", "Editor's choice", "New"); 브랜드 외 전체 대문자 금지; 아이콘의 오도 기호 금지; "출처 없는 익명 사용자 후기" 금지; **기만 행위**: "설명·제목·아이콘·스크린샷의 허위·오도 정보" 금지; **사칭**: 권리 없이 "<유명인> Official" 류 제목 금지.
- 확인: 제목, 짧은 설명(80), 긴 설명, 아이콘.

### AND-META-02 스크린샷·그래픽
- 근거: 등록정보 자산 — 아이콘 512×512 32비트 PNG(알파) ≤ 1024KB; 피처 그래픽 1024×500 JPEG/24비트 PNG(알파 없음) 필수; 스크린샷 최소 2장(추천 노출: ≥4장 ≥1080px, 16:9 또는 9:16), 320–3840px; 태블릿 ≥4장 1080–7680px; 홍보 영상 = 공개/미등록 YouTube URL, 광고 비활성, 임베드 가능. 앱을 정확히 표현.

### AND-META-03 개발자 정보 공개
- 근거: 이메일 필수; 조직은 D-U-N-S + 주소·전화 공개(2024~); 개인은 이름·이메일 공개; 유료/IAP 시 주소 공개.

### AND-META-04 공공정보 앱의 출처 표기·비제휴 고지
- 근거: Play "혼동을 야기하는 주장" 리젝 "제공된 출처가 불충분함": 정부/공공정보 앱은 모든 출처에 동작하는 공식 URL을 달고 정부 제휴를 암시하면 안 됨("공식", "정부 제공", "국가 인증")
- 적용: 정부·의료·법률·금융 정보를 재게시하는 앱
- 확인: 각 콘텐츠에 공식 출처 링크; 등록정보와 앱 내에 "본 앱은 정부 기관을 대표하거나 정부와 제휴한 서비스가 아닙니다" 류 고지.
- 사례: [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

---

## 테스트·계정

### AND-TEST-01 신규 개인 계정 비공개 테스트
- 근거: "2023-11-13 이후 생성된 **개인** 계정은 프로덕션 접근 신청 전 **12명 이상 테스터가 14일 연속 옵트인**한 비공개 테스트 필수"; "테스터가 옵트아웃 후 다시 옵트인하면 14일은 연속이어야". 신청 설문.
- 확인: 계정 생성일·유형. 해당되면 최소 2주 일정.
- 사례 교훈: "테스터가 참여하지 않았다"며 프로덕션 접근 거부 — 옵트인만 하고 앱을 열지 않은 12개 계정은 실패; 테스터에게 자유 탐색을 맡기고, 신청 문항마다 ≥3줄의 실질적 답변(크래시 없음 명시, 구체적 피드백, 개선 계획).
- 한국 사례(2024~2026): 12명 이상 옵트인을 **끝까지** 유지(30명 이상 모집; 품앗이/유료 테스터는 이탈), 실제 사용 세션, 테스트 중 2~3회 업데이트, 설문 항목마다 상세 답변; 멈춰 있던 신청이 비공개 트랙 업데이트 다음 날 승인된 사례.

### AND-ACCOUNT-01 계정 인증
- 근거: 신분증이 결제 프로필과 일치; 조직은 D-U-N-S; 개발자 정보 공개. 미완료 시 게시 불가.
- 한국 사례: 주민등록등본(정부24)이 가장 잘 통과하지만 결제 프로필 주소가 문서와 글자 단위로 일치해야(지번 vs 도로명); 주민번호 뒷자리 마스킹; 주소 없는 명세서는 실패.

### AND-ACCOUNT-02 앱 등록(2026) & 조직 요건
- 근거: Play Console **앱 등록 2026-09-30까지** — 미등록 앱은 "Google Play에서 전 세계 삭제"; 금융·건강·VPN·정부 앱은 "조직으로 등록 필수"(D-U-N-S). 개발자 정보(법적 이름/주소/이메일/전화) 공개; 수익화 계정은 전체 주소 공개.
- 확인: 게시된 모든 앱 등록; 계정 유형이 앱 카테고리와 일치.
- Play 2차 사례: "Some types of apps can only be distributed by organizations"(Play Console 요구사항 정책)가 헬스케어·"돈 벌기"/리워드 앱에서 D-U-N-S로 조직 전환한 뒤에도 발생 — 콘솔이 변경을 인식하려면 지원 티켓 필요; 2016년부터 개인 계정으로 배포한 회사는 새 조직 계정 + 앱 이전 전까지 전 앱 삭제.

### AND-QUALITY-01 기술 품질 기준
- 근거: Play 기술 품질 요건 — 사용자 체감 크래시율 ≤ 1.09%, ANR ≤ 0.47%(초과 시 노출·경고); 네이티브 코드 64비트 + 16KB; 2027-02부터 ≥25% 코드 최적화(R8)와 메모리 제한; Zero-Tap Sign-In 2027-04(발표). 정지는 스트라이크로 누적(집행 정책).
- 확인: 제출 전 Android vitals; `minifyEnabled true`, R8.

### AND-QUALITY-02 멀웨어/"기만 행위" 오탐 방지
- 근거: "MALWARE, BEHAVIOR TRANSPARENCY AND MOBILE UNWANTED SOFTWARE", "사용자 동의 없는 기기 설정 변경"으로 계정이 종료된 사례: 위협 피드에 오른 Firebase 엔드포인트 IP, ads-lite SDK, Unity 플러그인, 화면을 켜두는 `PowerManager.WakeLock`. 차단 뒤 같은 빌드를 재업로드하면 영구 종료.
- 확인: 보이는 사용자 행동 없이 웨이크락/밝기/설정 변경 없음; 동적 코드 로딩 없음; 업로드 전 릴리즈 AAB를 VirusTotal로 검사; 의존성 최소·최신.
- 신호: `wakelock`
- 수정: `WakeLock` 대신 액티비티 `FLAG_KEEP_SCREEN_ON`; 플래그되면 **재업로드 금지** — VirusTotal 보고서·소스 발췌·기능 영상으로 이의 제기, AV 벤더의 오탐 해제 먼저.
- 사례: [커뮤니티](../../rejections/community-cases.md#closed-testing-malware-false-positives-verification-target-api-16-kb)

### AND-ENFORCE-01 리젝 누적·정지·계정 연관
- 근거: "Violation of Enforcement Process policy… Suspension can occur as the result of egregious or multiple policy violations, as well as repeated app rejections or removals… you can submit an updated, policy compliant app using a new package name and a new app name"; 정지된 앱은 업데이트 불가; 정지 후 거의 같은 패키지/앱 이름으로 재제출하면 심사 회피로 간주(「危険性の高いパターンまたは不正使用のパターンが検出された」); 종료된 계정과 연결된 사용자를 콘솔에 초대하면 계정 전체 정지("prior violation of associated, previously terminated account")
- 적용: 모든 개발자
- 확인/규칙: 같은 빌드가 **두 번** 거절되면 멈추고 내부 트랙에서 자가 테스트 + 이의 제기(재업로드 금지); 정지 후 같은/유사 패키지 재업로드 금지; 콘솔에 초대하는 사용자 검증; 정확한 변경 내용을 적은 이의 제기문 보관.
- 사례: [Play 2차](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### AND-REVIEW-01 심사 환경은 Play 스토어가 아니다
- 근거: 심사관은 **Play 서명** 빌드를 설치(사전 출시 보고서와 다른 키 → Google/Firebase 로그인, App Check, 일부 라이브러리 실패); Play Asset Delivery 온디맨드 팩은 `AppNotOwned` / `AppUnavailable` / `InternalError`; 네트워크가 꺼져 있을 수 있음; 실시간/스트리밍 의존 화면은 비어 있음; 다른 릴리즈의 옛 자격 증명이 사용됨
- 적용: 모든 제출
- 확인: 업로드 키와 앱 서명 키 SHA-1/256을 모든 곳(Firebase, Google Cloud OAuth, 카카오/네이버 키해시)에 등록; 첫 세션 에셋 팩은 설치 시 포함; 명시적 오프라인/빈 상태 메시지; 제출 전 내부 트랙 빌드를 직접 설치; Sign-in details를 빌드와 같은 제출에서 갱신.
- 사례: [Play 2차](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

---

## UGC·결제 (Play 고유 추가)

### AND-UGC-01 Play UGC 정책 — 원문 요건
- "UGC를 포함하는 앱은:" "UGC 생성·업로드 전 이용약관/사용자 정책 동의 필수"(UGC-01) · "부적절 콘텐츠·행동을 정의하고 금지"(UGC-01) · "UGC 유형에 맞게 합리적·지속적으로 검토"(UGC-02/05) · "부적절 UGC와 사용자를 신고·차단하고 적절히 조치하는 앱 내 시스템"(UGC-03/04) · "앱 내 수익화가 부적절 행동을 조장하지 않도록 안전장치".
- 부수적 성적 UGC는 "완전 해제에 최소 두 번의 사용자 동작이 필요한 필터 뒤에 기본 숨김"; 중립 연령 화면으로 미성년자 배제; "부적절 UGC가 주 목적인 앱은 삭제"; "사용자 불만 계속 방치"는 위반.
- 또한: Child Safety Standards(AND-CONSOLE-10), 데이팅/랜덤/익명 채팅의 연령 제한 도구, AI 생성 콘텐츠 앱 내 신고(common AI-01), 콘텐츠 등급 "Users Interact" = 예(AND-CONSOLE-05).

### AND-PAY-01 Play 결제 & 지역 프로그램
- `common.md` PAY-01. **한국**: Play 결제 병행 필수; "대체 결제 시 Play 서비스 수수료 4% 인하"; 대체 결제 API 2023-08-02부터 의무; 24시간 내 거래 보고. **EEA**: 사용자 선택 유무 대체 결제, 외부 오퍼 프로그램(사업자 계정, EEA 한정). **미국**: 외부 콘텐츠 링크 + 대체 결제 프로그램(2025-12-09 출시; 2026-01-28까지 준수; 2026-10-01부터 수수료 보고). **일본**: 외부 결제 프로그램; "Play 등록정보에 앱 외 구매 언급 금지". **글로벌 수수료**: 2026-06-30부터(EEA/UK/US) Play 결제 5% 결제 수수료, IAP 20%, 구독 10%; AU 2026-09-30, KR/JP 2026-12-31, 나머지 2027-09-30. 프로그램 밖 외부 링크 결제는 여전히 금지.
