# 공통 체크리스트 — 기능 조건부 항목

앱이 가진 기능에 따라 적용되는 항목. iOS·Android 양쪽 근거를 함께 적는다.
각 항목: **근거**(가이드라인) → **적용**(언제 해당) → **확인**(무엇을 보고 판정) → **신호**(scan.sh) → **수정** → **증빙** → **사례**.
판정 등급은 SKILL.md 참고. 작성 기준일 2026-08.

---

## UGC — 사용자 생성 콘텐츠

> Apple **1.2 Safety – User-Generated Content** / Google Play **사용자 제작 콘텐츠(UGC) 정책**
>
> **적용**: 사용자가 입력한 것이 **다른 사용자에게 보이는** 기능이 하나라도 있으면 전부 적용된다. 채팅·댓글·게시물뿐 아니라 **닉네임, 프로필 사진, 상태 메시지, 한 줄 소개, 친구 초대, 그룹/방 이름, 공유 타이머 라벨**도 UGC다. "친구와 함께" 류 소셜 기능이 있는 앱은 예외 없이 걸린다(사례 2026-08-27).
> 신고·차단 없이 "친구 요청 수락제"만으로는 통과하지 못한다.

### UGC-01 약관(EULA) 동의 — 무관용 조항 포함
- 근거: Apple 1.2 (심사 메일: "Require that users agree to terms (EULA) and these terms must make it clear that there is no tolerance for objectionable content or abusive users") / Play UGC ("UGC 생성 전 이용약관 동의 요구, 부적절 콘텐츠·행동을 정의하고 금지")
- 확인:
  1. 회원가입/로그인 **전이나 직후, UGC를 만들기 전**에 약관 동의 UI(필수 체크박스 또는 "동의하고 계속")가 있는가. 소셜 로그인만 있어도 첫 로그인 직후 동의 화면이 있어야 한다.
  2. 약관 본문에 (a) 금지 콘텐츠 정의 (b) **무관용(no tolerance)** 문구 (c) 신고·차단·삭제·계정 정지 권한 (d) 24시간 내 조치 문구가 있는가.
  3. 설정 등에서 약관을 다시 볼 수 있는가.
- 신호: `legal.terms`, `auth.login`
- 수정: 가입/로그인 화면에 필수 동의 → 미동의 시 진행 불가. 약관에 `templates/eula-ugc.md` 조항 삽입. 동의 시각을 서버/로컬에 저장(버전 바뀌면 재동의).
- 증빙: 녹화 첫 장면이 약관 동의 화면.
- 사례: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-02 부적절 콘텐츠 필터
- 근거: Apple 1.2 "A method for filtering objectionable content" / Play UGC "강력하고 효과적이며 지속적인 UGC 검토"
- 적용: 텍스트 입력(닉네임·메시지·소개 등) 또는 이미지 업로드가 있을 때
- 확인: 텍스트 — 금칙어/비속어 필터가 입력 시점 또는 서버 저장 시점에 동작하는가(클라이언트 목록, 서버 함수, 외부 API 무엇이든). 이미지 — 최소한 신고 후 관리자 검토 프로세스가 있고, 가능하면 자동 검출(Cloud Vision SafeSearch, Rekognition 등).
- 신호: `mod.filter`
- 수정: 최소 구현 = 한국어·영어 비속어 목록 기반 필터를 닉네임/메시지 저장 전에 적용 + 걸리면 안내 문구. 이미지는 업로드 시 SafeSearch 검사 또는 "검토 후 공개".
- 증빙: 녹화에서 비속어 입력 → 차단 안내 장면(선택이지만 강력).

### UGC-03 콘텐츠·사용자 신고
- 근거: Apple 1.2 "A mechanism for users to flag objectionable content" / Play UGC "앱 내 신고 시스템"
- 확인: 모든 UGC 표면(채팅 메시지, 게시물, 댓글, 프로필, 친구 목록)에서 **2탭 이내**로 신고할 수 있는가. 신고 사유 선택 + 제출 완료 안내가 있는가. 신고가 개발자에게 도달하는가(DB 컬렉션, 이메일, Slack 등).
- 신호: `mod.report` (0이면 FAIL 후보; >0이면 실제 신고 UI인지 소스 확인 — 크래시 리포트 오탐 주의)
- 수정: 길게 누르기/⋯ 메뉴 → "신고" → 사유(스팸·욕설·성적·기타) → 저장(`reports` 컬렉션: reporterId, targetId, contentId, reason, createdAt) → 개발자 알림.
- 증빙: 녹화에 신고 흐름 전체.
- 사례: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-04 사용자 차단 — 즉시 숨김 + 개발자 알림
- 근거: Apple 1.2 "A mechanism for users to block abusive users (blocking should also notify the developer of the inappropriate content and should remove it from the user's feed instantly)" / Play UGC "앱 내 차단 시스템"
- 확인: 프로필/채팅/친구 목록에서 차단 가능한가. 차단 즉시 그 사용자의 콘텐츠(메시지·게시물·친구 목록·초대)가 **새로고침 없이** 사라지는가. 차단 목록을 설정에서 보고 해제할 수 있는가. 차단 이벤트가 개발자에게 기록·통지되는가.
- 신호: `mod.block`, `mod.hide`
- 수정: `blockedUsers` 저장 → 모든 UGC 쿼리/렌더에서 필터(클라이언트 즉시 반영 + 서버 규칙) → 차단 시 `reports`에도 자동 기록(사유 "blocked"). 설정 > 차단한 사용자 관리.
- 증빙: 녹화에 차단 → 콘텐츠 즉시 사라짐 장면.
- 사례: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-05 24시간 내 조치 체계 + 연락처 공개
- 근거: Apple 1.2 "act on objectionable content reports within 24 hours by removing the content and ejecting the user" + "Published contact information" / Play UGC "적절한 조치"
- 확인: 신고를 24시간 내 보고 처리할 **운영 절차**가 있는가(알림 채널, 관리자 도구 또는 콘솔에서 콘텐츠 삭제·계정 정지 가능). 약관/앱 내에 문의 이메일이 있는가.
- 신호: `mod.contact`
- 수정: 신고 시 이메일/Slack 알림 + 관리자용 삭제·정지 수단(간단한 Firebase 콘솔 절차라도 문서화). 앱 설정과 스토어 지원 URL에 연락처.
- 증빙: 답신에 "we review reports within 24 hours and remove content / suspend accounts" 명시.

### UGC-06 증빙 — 실기기 녹화 + 데이터 채워진 데모 계정
- 근거: 심사 메일 요구 ("screen recording captured on a physical device", "pre-populated demo account")
- 확인: 녹화 파일이 있는가(시뮬레이터 불가). 데모 계정으로 로그인하면 친구·채팅·게시물이 이미 있는가. 심사관이 2단계 인증 없이 로그인 가능한가.
- 수정: `templates/evidence-recording.md` 순서로 촬영. 데모 계정 2개(A·B)를 서로 친구로 만들고 대화 몇 개 넣어둔다. ACC-03 참고.
- 증빙: 녹화 링크를 심사 노트에, 답신에는 파일 첨부.

---

## ACC — 계정·로그인

### ACC-01 로그인 벽
- 근거: Apple 5.1.1(iv) "핵심 기능과 직접 관련 없으면 개인정보 입력을 요구하지 말 것" / Apple 5.1.1(v) "계정 기반 기능이 크지 않으면 로그인 없이 사용 가능해야" / Play: 명시 조항 없음(단 App access 안내 필수)
- 적용: 앱 첫 화면이 로그인일 때
- 확인: 로그인 없이 쓸 수 있는 핵심 기능이 있는가(예: 혼자 타이머). 소셜 기능만 로그인 요구하면 통과. 전 기능이 로그인 뒤에 있으면 그 이유가 핵심 기능(동기화·친구)과 직결되어야 한다.
- 신호: `auth.login` > 0 & `auth.guest` = 0
- 수정: "로그인 없이 시작" 경로 제공 또는 심사 노트에 로그인이 필수인 이유 설명 + 데모 계정.
- 증빙: 심사 노트.

### ACC-02 앱 내 계정 삭제
- 근거: Apple 5.1.1(v) "계정 생성을 지원하면 앱 안에서 계정 삭제도 제공" (2022-06-30부터 필수) / Play **계정 삭제 정책**: 앱 내 삭제 + **웹 링크**(Data safety에 URL 등록, 2024-05-31부터)
- 적용: 회원가입/소셜 로그인 있음
- 확인: 설정 > 계정 삭제(회원 탈퇴)가 있고, 실제로 서버 데이터·인증 계정을 지우는가(단순 로그아웃·비활성화 금지). 소셜 로그인(카카오 unlink, Google revoke, Apple token revoke)까지 처리하는가. Play용 웹 삭제 요청 페이지 URL이 있는가.
- 신호: `account.delete`
- 수정: 설정에 "계정 삭제" → 재확인 → 서버 함수로 사용자 문서·스토리지·인증 삭제 → 소셜 연결 해제 → 로그인 화면. 웹 페이지(노션/정적 페이지) "계정 삭제 요청" 만들고 Play Console Data safety에 등록.
- 증빙: 녹화(선택), Play Data safety URL.

### ACC-03 심사용 데모 계정 (소셜 로그인만 있을 때의 함정)
- 근거: Apple 2.1 "로그인이 있으면 데모 계정 정보를 포함하고 백엔드를 켜둘 것; 법적 사유로 불가하면 데모 모드 제공" / Play **App access**: 로그인 뒤 기능이 있으면 자격 증명 제공
- 적용: 로그인 있음
- 확인: 심사 노트에 계정이 있는가. 그 계정이 **심사관 위치(미국 등)에서 2단계 인증·기기 확인·해외 로그인 차단 없이** 들어가지는가. 카카오·구글 계정은 이 조건에서 자주 실패한다.
- 신호: `auth.google/kakao/naver` > 0 & `auth.email` = 0 & `auth.apple` = 0
- 수정 (권장 순): (1) Sign in with Apple 추가(IOS-LOGIN-01과 동시에 해결) + Apple 데모 계정 불필요(심사관 본인 Apple ID로 로그인 가능하지만 데이터가 비어 있으니 데모 데이터 자동 생성 고려) (2) Firebase 등에 이메일/비밀번호 로그인을 켜고 **리뷰어 전용 계정** 생성(UI에 노출 안 해도 딥링크·숨은 진입점으로 가능하나, 노출하는 편이 안전) (3) 카카오/구글 데모 계정을 제공할 땐 2단계 인증 끄기, 복구 이메일 설정, 로그인 알림 대응 준비.
- 증빙: 심사 노트 `templates/review-notes.md`.
- 사례: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — "Please provide a pre-populated demo account (Google or Kakao)"

### ACC-04 소셜 로그인 콘솔 설정
- 근거: 리젝은 아니지만 심사 중 로그인 실패 → 2.1 리젝으로 이어짐
- 확인: 카카오 — 플랫폼에 iOS 번들ID/Android 키해시(릴리즈 키!) 등록, 동의항목(닉네임·프로필·이메일) 설정, 이메일 필수면 비즈앱 전환. 구글 — OAuth 동의 화면 "프로덕션" 상태, iOS 클라이언트 ID·Android SHA-1(업로드 키 + Play 앱 서명 키 둘 다) 등록. Firebase Auth 제공자 활성화.
- 수정: 위 항목 점검. Play 앱 서명 키의 SHA-1은 Play Console > 앱 무결성에서 복사.

---

## PRIV — 개인정보

### PRIV-01 개인정보처리방침 — 앱 내 + 스토어 등록
- 근거: Apple 5.1.1(i) "App Store Connect 메타데이터 **와** 앱 안에 링크" / Play **사용자 데이터 정책**: 스토어 등록정보 + 앱 내 링크 필수
- 확인: 앱 설정/가입 화면에서 열리는 링크가 있고 실제로 열리는가(404 아님). 내용에 수집 항목·목적·보유 기간·제3자 제공(Firebase, 광고 SDK 등)·삭제 방법·문의처가 있는가. ASC/Play Console URL 필드가 채워졌는가.
- 신호: `legal.privacy`, URL 후보
- 수정: 노션/정적 페이지로 방침 게시 → 앱 설정 + 가입 화면 링크 + 두 콘솔 URL 등록.
- 증빙: 콘솔 스크린샷.

### PRIV-02 개인정보 라벨 일치 (App Privacy / Data safety)
- 근거: Apple App Privacy Details / Play Data safety — 실제 수집과 다르면 리젝·정책 위반
- 확인: SDK 목록으로 수집 항목 추정: Firebase Auth(이메일·이름·ID), Analytics(사용 데이터·기기 ID), Crashlytics(진단), AdMob(광고 ID·위치 대략), 카카오(닉네임·프로필·이메일). 콘솔 선언과 비교.
- 신호: `SDK / 의존성` 섹션
- 수정: 콘솔 선언을 SDK 기준으로 갱신. Firebase는 [Firebase 개인정보 문서]의 SDK별 표를 그대로 쓴다.

### PRIV-03 추적·광고 ID 동의
- 근거: Apple 5.1.2(i) **ATT** — 추적하면 `ATTrackingManager` 권한 필수 / Play **광고 ID** 정책 — API 33+는 `com.google.android.gms.permission.AD_ID` 선언, Data safety에 광고 ID 선언
- 적용: 광고 SDK, 어트리뷰션(AppsFlyer/Adjust), 광고 목적 분석
- 확인: iOS — ATT 요청 코드 + `NSUserTrackingUsageDescription` + App Privacy "Tracking" 표시. 광고 SDK가 있는데 ATT가 없으면 SDK 문서대로 non-personalized 설정을 했는지. Android — 매니페스트 AD_ID 권한(광고 SDK가 자동 병합하기도 함), Data safety 광고 ID.
- 신호: `ads.sdk`, `track.att`, `track.adid`
- 수정: ATT 프롬프트를 광고 초기화 **전**에 표시(첫 실행 온보딩 뒤). 거부해도 앱 동작.
- 증빙: 없음(코드).

### PRIV-04 민감 데이터 사전 고지·최소 수집
- 근거: Apple 5.1.1(iii) 데이터 최소화 / Play **눈에 잘 띄는 공개 및 동의(Prominent disclosure)**: 위치·연락처·SMS 등 민감 데이터를 사용자가 예상하지 못한 용도로 쓰면 런타임 권한 **전에** 앱 내 고지 + 동의
- 확인: 위치를 광고/분석에 쓰는가, 연락처를 서버에 올리는가 → 있으면 고지 화면("이 앱은 ~를 위해 ~를 수집합니다") 필요.
- 신호: `perm.*`, `ads.sdk`
- 수정: 권한 요청 직전 설명 다이얼로그. Play 형식: 데이터 종류·용도·공유 여부 명시, "동의" 버튼.

---

## PERM — 권한

### PERM-01 권한 목적 문구
- 근거: Apple 5.1.1(ii) — 목적 문자열이 "구체적이고 완전"해야 함 (예: "사진 접근" ✗ → "프로필 사진을 설정하기 위해 사진 보관함에 접근합니다" ✓) / Android — 런타임 권한 요청 전 `shouldShowRequestPermissionRationale` 안내 권장
- 확인: `IOS-PLIST-01` 참고. Android는 거부 후 재요청 시 안내가 있는가.
- 신호: `perm.*` vs plist 키
- 수정: 각 NS*UsageDescription을 "무엇을 위해" 형태로. 현지화(`InfoPlist.strings`)도.

### PERM-02 권한 거부해도 동작
- 근거: Apple 5.1.1(iv) "권한을 강요·기만 금지" / Play 권한 정책 "핵심 기능 외에는 권한 없어도 사용 가능"
- 확인: 푸시·카메라·위치 거부 시 앱이 막히거나 무한 프롬프트를 띄우지 않는가.
- 수정: 거부 시 기능만 비활성 + 설정 이동 안내.

### PERM-03 안 쓰는 권한 선언 금지
- 근거: Play 권한 정책 / Apple 심사관 질문("왜 이 권한이 필요한가")
- 확인: 매니페스트/plist 권한 중 코드에서 실제 쓰지 않는 것. SDK가 병합한 권한(READ_PHONE_STATE 등)은 `tools:node="remove"`로 제거.
- 신호: 권한 목록 vs `perm.*` 신호
- 수정: 제거. 남기면 심사 노트에 이유.

---

## PAY — 결제

### PAY-01 디지털 재화는 IAP / Play Billing
- 근거: Apple 3.1.1 (앱 내 디지털 콘텐츠·기능·구독은 IAP만; 외부 결제 링크·버튼 금지 — 미국/EU/한국·일본 등 지역별 예외 엔타이틀먼트 별도) / Play **결제 정책** (디지털 재화는 Google Play 결제; 한국은 제3자 결제 병행 가능하나 선언·수수료 조건)
- 적용: 프리미엄 해제, 구독, 코인, 테마 등
- 확인: Stripe/토스/아임포트 등 외부 결제로 디지털 재화를 파는가 → FAIL. 실물 상품·오프라인 서비스는 외부 결제 OK(Apple 3.1.3(e), 3.1.5).
- 신호: `pay.external`, `pay.iap`
- 수정: StoreKit/Play Billing 또는 RevenueCat으로 전환. 웹 결제 안내 문구·링크 제거.

### PAY-02 구독 고지 + 약관 링크
- 근거: Apple 3.1.2(a) — 구독 기간·가격·자동 갱신·해지 방법을 구매 전 명확히, **이용약관(EULA)과 개인정보처리방침 링크를 앱 안과 메타데이터에** / Play 구독 정책 — 가격·기간·무료체험 조건·해지 명시
- 확인: 페이월에 가격·기간·자동갱신 문구·약관/방침 링크·"구매 복원". 무료 체험이면 체험 후 가격.
- 신호: `pay.iap`, `legal.terms`
- 수정: 페이월 하단 표준 문구 + 링크. ASC "라이선스 계약" 필드에 EULA URL(또는 Apple 표준 EULA 사용 시 링크).

### PAY-03 구매 복원
- 근거: Apple 3.1.1 "복원 가능한 IAP는 복원 메커니즘 제공"
- 확인: "구매 복원" 버튼이 페이월/설정에 있는가. 비소모성·구독 모두.
- 신호: `pay.iap` (restorePurchases)
- 수정: 버튼 추가 → `restorePurchases()`/`queryPurchases`.

### PAY-04 심사 중 IAP 테스트 가능
- 근거: Apple 2.1 — 심사관이 Sandbox로 구매 가능해야 함; 첫 제출 시 IAP 상품을 앱 버전과 **함께 제출**
- 확인: ASC에서 IAP 상품 상태 "Ready to Submit"이고 버전에 첨부됐는가. Paid Apps Agreement 서명·은행·세금 정보 완료. Play — 라이선스 테스터, 상품 활성.
- 수정: 콘솔 작업. 상품 미첨부는 흔한 2.1/3.1.1 리젝 사유.

---

## ADS — 광고

### ADS-01 광고 ↔ 동의·라벨
- 근거: PRIV-03 참고. 추가로 Play "광고 포함" 선언(App content > Ads).
- 확인: ASC App Privacy에 광고 데이터, Play Ads 선언 "예".

### ADS-02 방해·오도 광고 금지, 아동 대상 제한
- 근거: Apple 4.0/2.3.1, Play **광고 정책** (전면 광고는 예상 가능한 시점에, 닫기 버튼, 시스템 알림 흉내 금지) / Play Families 광고 제한
- 확인: 앱 진입 직후·버튼 클릭마다 전면 광고 → WARN. 광고가 콘텐츠처럼 보이지 않는가.

### ADS-03 테스트 광고 ID 제거
- 근거: 릴리즈에 테스트 유닛(`ca-app-pub-3940256099942544/...`)이 남으면 수익 0 + AdMob 정책 위반. 반대로 개발 중 실광고 클릭도 위반.
- 신호: `test.keys`
- 수정: flavor/빌드 타입으로 분기.

---

## PUSH — 푸시

### PUSH-01 푸시 없이도 동작, 마케팅 푸시 옵트인
- 근거: Apple 4.5.4 — 푸시가 앱 동작의 필수 조건이면 안 되고, 마케팅 푸시는 명시적 옵트인 + 앱 내 옵트아웃 / Play — 스팸성 알림 금지
- 확인: 첫 실행에 곧바로 권한 요청하지 않고 맥락 있는 시점에 요청하는가(권장). 설정에 알림 끄기. 마케팅용이면 별도 동의.
- 신호: `perm.push`
- 수정: 알림 설정 화면, 마케팅 토글 분리.

---

## BG — 백그라운드

### BG-01 백그라운드 모드는 본래 목적만
- 근거: Apple 2.5.4 — `audio`는 실제 오디오 재생, `location`은 위치 기능 등 **의도된 용도**로만. **타이머·카운트다운을 살리려고 무음 오디오를 재생하는 것은 대표적 리젝 사유**.
- 적용: `UIBackgroundModes` 있음, 특히 타이머·집중·습관 앱
- 확인: `audio` 모드가 있는데 사용자가 듣는 소리(백색소음, 음악)가 실제로 있는가. 타이머 종료 알림은 로컬 알림으로 처리하는가.
- 신호: `bg.modes`, `bg.audio`, plist `UIBackgroundModes`
- 수정: 타이머는 종료 시각을 저장 + `UNUserNotificationCenter` 로컬 알림 예약 + 포그라운드 복귀 시 남은 시간 재계산. 백색소음 기능이 진짜 있으면 `audio` 유지하고 심사 노트에 설명.
- 증빙: 심사 노트에 백그라운드 모드 사용 이유 한 줄.

### BG-02 Android 포그라운드 서비스
- 근거: Android 14(targetSdk 34)+ `foregroundServiceType` 필수 + 타입별 권한 + Play Console 선언 (AND-PERM-05, AND-CONSOLE-06)
- 확인: 타이머 유지용 FGS면 타입은 보통 `specialUse`(선언 양식에 설명 필요) 또는 `mediaPlayback`(실제 재생 시). `shortService`는 3분 제한.
- 수정: 매니페스트 타입 선언 + `FOREGROUND_SERVICE_<TYPE>` 권한 + 콘솔 양식 + 데모 영상.

---

## CONTENT — 완성도·콘텐츠

### CONTENT-01 플레이스홀더·크래시·미완성 없음
- 근거: Apple 2.1 (placeholder, 빈 화면, 깨진 링크, 크래시) / Play "손상된 기능" 정책
- 확인: "준비 중", "coming soon", lorem ipsum, 빈 리스트에 안내 없음, 동작 안 하는 버튼. 실기기(특히 **iPad**·구형 Android)에서 크래시. 모든 외부 링크 200 응답.
- 신호: `placeholder`, `todo.marks`
- 수정: 미완성 기능은 숨긴다. 빈 상태 화면 문구 추가.

### CONTENT-02 테스트·디버그 흔적 제거
- 확인: 디버그 메뉴, 테스트 서버 URL, 테스트 결제 키, 콘솔 로그에 개인정보, `usesCleartextTraffic=true`.
- 신호: `test.keys`, `cleartext`
- 수정: 릴리즈 빌드에서 제외.

### CONTENT-03 최소 기능 — 웹 래퍼 금지
- 근거: Apple 4.2 (웹사이트를 감싼 앱, 마케팅용 앱, 단일 기능 앱 거절) / Play 최소 기능 정책
- 적용: 웹뷰가 주 UI일 때
- 확인: 네이티브 기능(푸시·카메라·오프라인·위젯 등)이 의미 있게 있는가.
- 신호: `webview`

### CONTENT-04 타 플랫폼 언급 금지
- 근거: Apple 2.3.10 — 앱·메타데이터에 다른 모바일 플랫폼 이름·아이콘 금지("Android에서도 만나요" ✗) / Play — 유사 관행(스크린샷에 iPhone 프레임 등)
- 확인: 현지화 문자열·스크린샷·설명에 "Android", "Google Play", "iPhone", "App Store" 언급.
- 신호: `문자열에 … 언급`
- 수정: 플랫폼 중립 표현("다른 기기에서도").

### CONTENT-05 지원 연락처
- 근거: Apple 1.5 — 앱과 지원 URL에 연락 수단 / Play 개발자 이메일 공개
- 확인: 설정 > 문의하기(메일 or 폼), 지원 URL 페이지에 이메일.
- 신호: `mod.contact`

### CONTENT-06 평가 요청·인센티브
- 근거: Apple 5.6.4 — `SKStoreReviewController` 사용, 보상 제공 금지 / Play — 리뷰 유도 보상 금지
- 확인: 커스텀 "별점 주면 프리미엄" 류 → FAIL.
- 신호: `review.prompt`

---

## META — 스토어 메타데이터 (코드 밖)

### META-01 스크린샷은 실제 화면
- 근거: Apple 2.3.3 — 앱 사용 중 화면, 스플래시·로그인·타이틀만은 불가; 기기 프레임·문구 허용 / Play 메타데이터 정책 — 앱을 정확히 반영
- 확인: 필수 규격(iPhone 6.9", iPad 13")과 내용. `store-screenshots` 스킬로 만든 이미지면 화면 부분이 실제 앱인지.

### META-02 설명·키워드·이름
- 근거: Apple 2.3.7/2.3.8, Play 메타데이터 정책 (제목 30자, "최고"·"무료"·"1위"·이모지·가격 언급 금지, 순위·평점 언급 금지)
- 확인: 설명에 미출시 기능 약속, 타 플랫폼 언급(CONTENT-04), 다른 앱 이름.

### META-03 연령 등급 설문
- 근거: Apple 연령 등급 / Play IARC 콘텐츠 등급
- 확인: **UGC·채팅·친구 기능이 있으면 "사용자 상호작용/무제한 웹 접근" 항목을 정직하게 예**로. 설문 답과 앱 기능이 다르면 리젝.
- 신호: `ugc.*`

### META-04 URL 동작
- 확인: 지원 URL, 마케팅 URL, 개인정보 URL 모두 200 + 내용 있음. 노션 페이지면 "웹에 게시" 켜짐.

### META-05 심사 노트
- 확인: `templates/review-notes.md` 내용이 ASC App Review Information / Play App access에 있는가. 데모 계정 + 기능 위치 + 녹화 링크 + 백그라운드 모드 사유.

---

## KR — 한국 법규·관행

### KR-01 만 14세 미만 법정대리인 동의
- 근거: 개인정보보호법 제22조의2 — 14세 미만 아동의 개인정보 수집은 법정대리인 동의 필요. 대부분 서비스는 가입 시 "만 14세 이상입니다" 확인으로 대응.
- 적용: 회원가입 있음, 아동 대상 아님
- 확인: 가입/약관 동의 화면에 만 14세 이상 확인 항목.
- 신호: `legal.age`
- 수정: 약관 동의 체크박스에 "만 14세 이상입니다(필수)" 추가.

### KR-02 약관·방침 필수 기재
- 근거: 개인정보보호법 제30조(처리방침 기재 사항), 전자상거래법(유료 서비스 시 청약철회·환불)
- 확인: 방침에 수집 항목·목적·보유기간·제3자 제공·처리위탁(Firebase/AWS 등 해외 이전 포함)·정보주체 권리·보호책임자 연락처. 유료면 환불 규정.

### KR-03 게임이면 등급 분류
- 근거: 게임산업진흥법 — IARC(Apple/Google 자체등급)로 대체 가능, 청소년이용불가 게임은 GRAC 직접 심의
- 적용: 게임 카테고리
