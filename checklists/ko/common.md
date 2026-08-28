# 공통 체크리스트 — 기능 조건부 항목 (한국어 번역)

> 영어 원본 `../common.md`가 정본이며, 번역은 뒤처질 수 있다. ID·인용문·URL은 원본과 동일. 기준일 2026-08-28 (App Store Review Guidelines 2026-06-08 개정판, Play 정책 센터 2026-08). 출처 인용: `../../references/`.
> 항목 형식: **근거** → **적용** → **확인** → **신호**(scan.sh) → **수정** → **증빙** → **사례**.

---

## UGC — 사용자 생성 콘텐츠

> Apple **1.2 Safety – User-Generated Content** / Google Play **사용자 제작 콘텐츠(UGC) 정책**
>
> **적용**: 사용자가 입력·업로드한 것이 *하나라도* 다른 사용자에게 보이면 전부 적용. 채팅·댓글·게시물뿐 아니라 **닉네임, 프로필 사진, 상태 메시지, 한 줄 소개, 친구 초대, 그룹/방 이름, 공유 타이머 라벨**도 UGC다. "친구와 함께" 류 소셜 기능은 예외 없이 걸린다(사례 2026-08-27).
> "친구 요청 수락제"는 신고+차단을 대체하지 못한다.
> 2026-02부터 Apple은 **랜덤/익명 채팅**에 1.2를 명시 적용하고, 2026-06 개정판은 "위반 콘텐츠를 제거할 책임은 개발자에게 있으며… 발견 시 제거와 함께 **개선 계획 제출**을 요구… 심각하거나 반복되면 즉시 삭제"를 추가했다. Play는 소셜/데이팅(2025-01-22), 익명·랜덤 채팅(2026-07-15) 앱에 **Child Safety Standards 자가 인증**을 요구한다 — UGC-07 / AND-CONSOLE-10.

### UGC-01 약관(EULA) 동의 — 무관용 조항 포함
- 근거: Apple 1.2 (리젝 문구 "Require that users agree to terms (EULA) and these terms must make it clear that there is no tolerance for objectionable content or abusive users") / Play UGC ("UGC 생성·업로드 전 이용약관 동의 필수", "부적절 콘텐츠·행동을 정의하고 금지")
- 확인: (1) 가입/로그인 **전이나 직후, UGC 생성 전**에 동의 UI(필수 체크박스 또는 "동의하고 계속"). 소셜 로그인만 있어도 첫 로그인 직후 동의 화면 필요. (2) 약관에 (a) 금지 콘텐츠 정의 (b) **무관용(no tolerance)** 문구 (c) 삭제·차단·정지·퇴출 권한 (d) 24시간 내 조치. (3) 설정에서 약관 재열람 가능.
- 신호: `legal.terms`, `auth.login`
- 수정: 가입/로그인 화면 필수 동의 → 미동의 시 진행 불가. `templates/eula-ugc.md` 조항 삽입. 동의 시각 저장(약관 버전 변경 시 재동의).
- 증빙: 녹화 첫 장면이 동의 화면.
- 사례: [2026-08-27 iOS 1.2 UGC](../../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-02 부적절 콘텐츠 필터
- 근거: Apple 1.2 "A method for filtering objectionable content" / Play UGC "합리적이고 지속적인 UGC 검토"
- 적용: 텍스트 입력(닉네임·메시지·소개…) 또는 이미지 업로드
- 확인: 텍스트 — 금칙어/비속어 필터가 입력 시 또는 서버 저장 시 동작(클라이언트 목록·서버 함수·외부 API 모두 인정). 이미지 — 최소 신고→검토 절차, 가능하면 자동 검출(Cloud Vision SafeSearch, Rekognition…).
- 신호: `mod.filter`
- 수정: 최소 = 한/영 비속어 목록을 닉네임·메시지 저장 전에 적용 + 안내 문구. 이미지는 업로드 시 SafeSearch 또는 "검토 후 공개".
- 증빙: 선택이지만 강력 — 금칙어 입력 → 경고 장면.

### UGC-03 콘텐츠·사용자 신고
- 근거: Apple 1.2 "A mechanism for users to flag objectionable content" / Play UGC "부적절 UGC와 **사용자**를 신고하는 앱 내 시스템"
- 확인: 모든 UGC 표면(채팅 메시지, 게시물, 댓글, 프로필, 친구 목록)에서 **2탭 이내** 신고. 사유 선택 + 완료 안내. 신고가 개발자에게 도달(DB, 이메일, Slack…).
- 신호: `mod.report` (0 → FAIL 후보; >0이면 파일 열어 확인 — 크래시 리포트는 오탐)
- 수정: 길게 누르기/⋯ → 신고 → 사유(스팸·욕설·성적·기타) → 저장(`reports`: reporterId, targetUserId, contentId, reason, createdAt) → 개발자 알림.
- 증빙: 녹화에 신고 흐름 전체.
- 사례: [2026-08-27 iOS 1.2 UGC](../../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) · [커뮤니티 — 1.2 / Play UGC](../../rejections/community-cases.md#12-user-generated-content) (콘텐츠뿐 아니라 **사용자** 신고도 필요 — Discourse 사례)

### UGC-04 사용자 차단 — 즉시 제거 + 개발자 알림
- 근거: Apple 1.2 "A mechanism for users to block abusive users (blocking should also notify the developer of the inappropriate content and should remove it from the user's feed instantly)" / Play UGC "UGC와 사용자를 차단하는 앱 내 시스템"
- 확인: 프로필/채팅/친구 목록에서 차단 가능. 차단 즉시 그 사용자의 콘텐츠(메시지·게시물·친구 항목·초대)가 **새로고침 없이** 사라짐. 설정에 차단 목록·해제. 차단 이벤트가 개발자에게 기록·통지.
- 신호: `mod.block`, `mod.hide`
- 수정: `blockedUsers` 저장 → 모든 UGC 쿼리/렌더에서 필터(클라이언트 즉시 + 서버 규칙) → `reports`에 사유 "blocked" 자동 기록 → 설정 > 차단한 사용자.
- 증빙: 차단 → 콘텐츠 즉시 사라짐 녹화.
- 사례: [2026-08-27 iOS 1.2 UGC](../../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-05 24시간 내 조치 체계 + 연락처 공개
- 근거: Apple 1.2 리젝 문구 "act on objectionable content reports within 24 hours by removing the content and ejecting the user" + 가이드라인 "Published contact information so users can easily reach you" + (2026-06) "위반 콘텐츠 제거 책임… 개선 계획 제출" / Play UGC "적절한 조치"; 위반 예시 "사용자 불만을 계속 방치"
- 확인: 24시간 내 신고를 보고 처리하는 **운영 절차**(알림 채널, 관리자 도구 또는 콘솔에서 삭제·정지). 약관·앱·지원 URL에 연락처(Apple 1.5).
- 신호: `mod.contact`
- 수정: 신고 시 이메일/Slack 알림 + 삭제·정지 런북 문서화(Firebase 콘솔 절차라도). 설정과 스토어 지원 URL에 연락처. 짧은 모더레이션 계획서를 보관 — Apple이 요구할 수 있다.
- 증빙: 답신에 "we review reports within 24 hours and remove content / suspend accounts".

### UGC-06 증빙 — 실기기 녹화 + 데이터 채운 데모 계정
- 근거: 리젝 문구 ("screen recording captured on a physical device", "pre-populated demo account")
- 확인: 녹화 파일 존재(시뮬레이터 불가). 데모 계정으로 로그인하면 친구·채팅·게시물이 이미 있음. 심사관이 2단계 인증 없이 로그인 가능.
- 수정: `templates/evidence-recording.md` 순서로 촬영. 데모 계정 A·B를 서로 친구로 만들고 메시지 몇 개 넣어둠. ACC-03 참고.
- 증빙: 심사 노트에 녹화 링크; 답신에 파일 첨부.

### UGC-07 미성년자·연령 제한·아동 안전 의무
- 근거: Apple 1.2.1(a) / 4.7.5 (크리에이터·미니앱 콘텐츠가 앱 등급을 넘으면 검증/신고 연령 기반 제한 필요); Apple 5.1.4 (키즈 앱: 제3자 광고·분석 금지); Play **Child Safety Standards** (소셜·데이팅 2025-01-22, 익명/랜덤 채팅 2026-07-15): 공개 URL의 CSAE 기준, 앱 내 피드백 수단, CSAM 처리, 아동 안전 담당자, Play Console 자가 인증; Play **연령 제한 콘텐츠**: 데이팅·랜덤/익명 채팅·실제 도박 앱은 "Play Console 도구로 미성년자 차단 필수"(2025-10-30)
- 적용: 소셜, 데이팅, 채팅(특히 익명/랜덤), 크리에이터/UGC 피드, 18+ 앱
- 확인: 스토어 카테고리; 연령 화면(중립 연령 게이트) 또는 Declared Age Range API; 공개 아동 안전 기준 페이지·담당 연락처(Play); Play Console 자가 인증 완료.
- 신호: `ugc.chat`, `ugc.anonymous`, 카테고리
- 수정: 가입 시 중립 연령 화면; 아동 안전 기준 페이지 게시(약관의 한 절이어도 됨); Play Console App content > 아동 안전 기준; Apple: Age Suitability URL, 지역 법규 해당 시 Declared Age Range API(LAW-01).
- 증빙: 기준 페이지 URL; 콘솔 스크린샷.

---

## ACC — 계정·로그인

### ACC-01 로그인 벽
- 근거: Apple 5.1.1(iv) "핵심 기능과 직접 관련 없으면 개인정보 요구 금지" / 5.1.1(v) "계정 기반 기능이 크지 않으면 로그인 없이 사용 가능해야" / Play: 명시 조항 없음(단 Sign-in details 안내 필수)
- 적용: 첫 화면이 로그인
- 확인: 로그인 없이 쓸 수 있는 핵심 기능(예: 혼자 타이머)이 있는가. 소셜 기능만 로그인 요구하면 통과. 전 기능이 로그인 뒤면 그 이유가 핵심(동기화·친구)이어야 함.
- 신호: `auth.login` > 0 & `auth.guest` = 0
- 수정: "로그인 없이 시작" 경로 또는 심사 노트에 로그인 필수 이유 + 데모 계정.
- 증빙: 심사 노트.

### ACC-02 앱 내 계정 삭제
- 근거: Apple 5.1.1(v) "계정 생성을 지원하면 앱 안에서 계정 삭제도 제공… 앱 안에서 소셜 네트워크 자격 증명을 해제하고 데이터 접근을 끊는 수단도 포함… 소셜 토큰을 기기 밖에 저장 금지" (2022-06-30부터; 지원 페이지: "일시 비활성화만 제공하는 것은 불충분", "전화·이메일 등 지원 절차 요구 금지") / Play **계정 삭제** 요건: 앱 내 삭제 **및** Data safety에 등록하는 **웹 링크**(2024-05-31 시행); "일시 비활성화·정지·동결은 삭제로 인정 안 됨"
- 적용: 회원가입 또는 소셜 로그인 있음
- 확인: 설정 > 계정 삭제가 찾기 쉽고 서버 데이터·인증 계정을 실제로 삭제(로그아웃·비활성화 아님). 앱 안에서 소셜 연결 해제(카카오 unlink, Google revoke, Apple `revoke tokens` REST API). 공개 웹 삭제 요청 페이지가 있고 Play Data safety에 등록. 최종 단계가 웹이면 앱 내 직접 링크 허용.
- 신호: `account.delete`
- 수정: 설정 > 계정 삭제 → 확인 → 서버 함수로 사용자 문서·스토리지·인증 삭제 → 제공자 연결 해제 → 로그인 화면. 웹 페이지(노션/정적) "계정 삭제 요청" → Play Console Data safety.
- 증빙: 녹화(선택); Play Data safety URL.
- 사례 교훈: Play 삭제 URL은 브라우저가 아닌 클라이언트가 검사 — 특수 TLS 설정 없는 일반 HTTPS; 카카오 사용자는 Unlink API로 해제; 일반 설정 페이지 링크는 불인정, 삭제 단계로 직접 링크; 심사관이 못 찾으면 리젝 — 노트에 경로 기재 또는 영상 첨부. [사례](../../rejections/community-cases.md#account-deletion)
- 한국 사례: 탈퇴 후 **같은 Apple/Google 계정으로 재가입이 되어야** 함(리다이렉트 전에 서버 사용자 문서 저장; 휴대폰 인증·단일 기기 잠금 해제); Play 삭제 페이지는 앱·개발자명과 절차를 명시 — "고객센터 문의"나 로그인 필요 페이지는 실패. [사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- Apple 2차 사례: **계정이 없는** 앱이 로컬 프로필/이름 입력 단계가 가입처럼 보여 5.1.1(v)로 거절 — 심사 노트에 "계정 없음, 로컬 프로필만, 삭제 경로: …"를 상시 기재. [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- 한/일 3차 사례: 삭제는 **새 심사관 계정이 도달하는 상태**(승인 대기 화면, 버튼이 접힘 아래로 간 iPad 레이아웃, 회색 저대비 텍스트)에서 도달·가시적이어야. [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### ACC-03 심사용 데모 계정 (소셜 로그인만 있을 때의 함정)
- 근거: Apple 2.1(a) "로그인이 있으면 데모 계정 정보 포함(백엔드 켜둘 것)… 법적·보안상 불가하면 Apple 사전 승인으로 내장 데모 모드"; ASC 도움말: 데모 계정은 "만료되면 안 됨" / Play **Sign-in details**(구 App access): "항상 접근 가능, 재사용 가능, 사용자 위치와 무관하게 유효… 2단계 인증/OTP가 필요하면 이를 우회하는 재사용 가능 자격 증명 제공… 영어로 제공… 비밀번호가 만료되면 앱이 거부될 수 있음"
- 적용: 모든 로그인
- 확인: 심사 노트에 계정. 그 계정이 **심사관 위치(미국 등)에서 2단계 인증·기기 확인·해외 로그인 차단 없이** 로그인되고 만료되지 않음. 카카오·구글 계정은 여기서 자주 실패.
- 신호: `auth.google/kakao/naver` > 0 & `auth.email` = 0 & `auth.apple` = 0
- 수정(권장 순): (1) Sign in with Apple 추가(IOS-LOGIN-01 동시 해결; 심사관 본인 Apple ID로 로그인 — 빈 계정에 데모 데이터 자동 생성 고려) (2) Firebase 등에 이메일/비밀번호 켜고 **리뷰어 전용 계정**(버튼 노출이 숨김 진입보다 안전) (3) 카카오/구글 데모 계정을 줄 땐 2단계 끄기, 복구 이메일, 로그인 알림 승인 대기. 채팅·친구 요청 양쪽을 볼 수 있게 두 번째 계정 제공.
- 증빙: `templates/review-notes.md` (Apple 노트 ≤ 4000바이트; Play 안내 최대 5세트 + OTP/MFA용 "기타 안내").
- 사례: [2026-08-27 iOS 1.2 UGC](../../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — "Please provide a pre-populated demo account (Google or Kakao)"; [커뮤니티 사례](../../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)
- 한국 사례: 데모 계정은 새 기기에서 반복 로그인 가능해야 — 오래된 푸시 토큰/기기 바인딩, 일회용 휴대폰 인증 금지, 고정 OTP; GitHub/Google 데모는 2FA 끔 **그리고** 새 기기 확인 없음; Play는 한글 ID·관리자 계정·자격 증명 대신 영상을 거부; QR/하드웨어 게이트 앱은 장기 코드 제공. 막힌 건은 App Review와 한국어 전화 통화로 해결된 사례. [사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- 일본 사례: 데모 Google 계정의 "본인 확인"은 코드 없이 2FA를 켜고 답신에 **백업 코드**를 적어 해결. [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### ACC-04 소셜 로그인 콘솔 설정
- 근거: 가이드라인은 아니지만 심사 중 로그인 실패 → 2.1 리젝
- 확인: 카카오 — iOS 번들ID/Android 키해시(**릴리즈 키!**) 등록, 동의항목(닉네임·프로필·이메일), 이메일 필수면 비즈앱. 구글 — OAuth 동의 화면 "프로덕션", iOS 클라이언트 ID·Android SHA-1(업로드 키 **와** Play 앱 서명 키). Firebase Auth 제공자 활성화.
- 수정: 위 점검. Play 앱 서명 SHA-1은 Play Console > 앱 무결성에서 복사.
- 한국 사례: Play 앱 서명 사용 시 업로드 키 해시 외에 **legacy** 앱 서명 키 해시도 등록(Play Console > 앱 무결성, "legacy" 필터) — Flutter 팀의 카카오 로그인이 그제야 동작.

### ACC-05 카카오/네이버 로그인 심사 플레이북 (한국)
- 근거: 카카오 DevTalk 공식 답변 + 반복된 한국 사례: 심사관 기기(미등록 기기·해외 IP)에서 2단계 인증·해외 로그인 차단을 꺼도 카카오 위험 감지로 2단계 인증이 뜸; "카카오톡으로 열겠습니까?"에서 취소하면 "카카오톡 설치" 페이지가 떠 심사관이 버그로 스크린샷; Play는 카카오/네이버/구글만 있는 로그인을 Sign-in details에서 거부
- 적용: 카카오 / 네이버 / LINE 로그인
- 확인: 심사 노트에 (a) **카카오톡과 연동되지 않은** 카카오 계정(비카카오 이메일) 또는 8자리 코드를 읽을 수 있는 이메일함, (b) "설치" 페이지가 뜨면 웹/계정 로그인 흐름을 쓰거나 카카오톡 삭제·Safari 데이터 삭제 안내, (c) ID/PW 또는 Sign in with Apple 경로.
- 신호: `auth.kakao`, `auth.naver`
- 수정: 카카오톡 미연동 리뷰어 계정 생성; 해외 IP에서 테스트; SIWA(IOS-LOGIN-01) + 이메일/비밀번호 리뷰어 로그인(ACC-03).
- 사례: [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28) — DevTalk 135699 / 135723 / 139785
- 3차 세부: 카카오 계정은 한국 전화번호 필요, Sign in with Apple은 항상 *새* 사용자를 만들어 SMS 인증에 걸림 — 그래서 팀들이 문서화된 리뷰어 로그인 + 고정 OTP를 추가(ACC-07). [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### ACC-06 규제·민감 데이터 앱의 조직 등록 (5.1.1(ix))
- 근거: "The account that submits the app must be enrolled in the Apple Developer Program as an organization, and not as an individual" — 건강/신체 데이터, 보험, 대출, 도박, 암호화폐 거래소; 개인 계정의 서류로 대체 불가(Apple 5.1.1(ix)); Play: "Some types of apps can only be distributed by organizations"(AND-ACCOUNT-02)
- 적용: 고도 규제 분야 또는 건강/금융 데이터를 다루는 앱
- 확인: 제출하는 Apple 개발자 계정이 조직(D-U-N-S); Play 계정 유형 일치.
- 수정: 제출 전 조직으로 등록; 개인은 규제 기능 제거.
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### ACC-07 리뷰 모드 백엔드: 문서화된 심사관 경로, 숨은 동작 아님
- 근거: 카카오(한국 전화번호 필요)나 Sign in with Apple(항상 새 사용자 생성 → SMS 인증)만 있는 한국 팀들이 **심사관 전용 경로**를 만듦: 이메일/비밀번호 또는 숨은 진입(로고 길게 누르기) 로그인 + 고정 우회 OTP, 신고/차단 테스트용으로 가짜 친구/게시물을 미리 채운 서버 측 "리뷰 모드" 계정. 이는 **심사 노트에 명시**하고 다른 동작은 바뀌지 않을 때만 허용 — 문서화되지 않은 심사 감지는 Apple 2.3.1 / Play 기만 행위(CONTENT-10)
- 적용: 해외 심사관 기기에서 프로덕션 로그인을 완료할 수 없는 앱
- 확인: App Review Information / Play Sign-in details에 심사관 경로를 단계별 기술(진입 제스처, 자격 증명, 고정 OTP); 심사관 계정이 일반 사용자와 같은 기능을 봄; 시드 데이터에 "test/테스트/준비중" 문자열 없음(CONTENT-02); 출시 후에도 경로 유효(Google 재테스트).
- 수정: 정상적이고 문서화된 로그인 옵션으로 구현; 심사관 IP/기기로 동작 분기 금지.
- 사례: [한/일 3차](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

---

## PRIV — 개인정보

### PRIV-01 개인정보처리방침 — 앱 내 + 스토어 등록
- 근거: Apple 5.1.1(i) "App Store Connect 메타데이터 필드 **와** 앱 안에 쉽게 접근 가능한 링크" / Play **사용자 데이터**: Play Console **및** 앱 내 링크; 개발자 정보·문의처, 수집/사용/공유 데이터 유형, "안전한 데이터 처리 절차", 보유/삭제 정책, 개인정보처리방침이라고 명확히 표시, "스토어 등록 개발자명이 방침에 나오거나 앱 이름이 방침에 나와야"
- 확인: 설정/가입 화면의 링크가 실제로 열림(404 아님). 위 항목 + 제3자(Firebase, 광고 SDK, AI 제공자…)·삭제·연락처·개발자 명칭 포함. ASC·Play Console URL 필드 기입. Apple App Review 페이지도 "Broken links… 개인정보처리방침 링크는 모든 앱 필수"를 상위 리젝 사유로 명시.
- 신호: `legal.privacy`, URL 후보
- 수정: 방침 게시(노션/정적) → 설정 + 가입 링크 → 두 콘솔 URL 등록.
- 증빙: 콘솔 스크린샷.
- 사례 교훈(Play 리젝된 호스팅): GitHub 마크다운, Blogspot, PDF, JS 전용 페이지, 수정 가능한 블로그 글, 비공개/지역 제한 URL. 자체 도메인의 고정 공개 HTML 페이지 권장. [사례](../../rejections/community-cases.md#user-data-privacy-policy-data-safety-prominent-disclosure)

### PRIV-02 개인정보 라벨 일치 (App Privacy / Data safety)
- 근거: Apple App Privacy Details / Play Data safety — 실제 수집과 다르면 리젝·정책 위반
- 확인: SDK 목록으로 수집 추정: Firebase Auth(이메일·이름·ID), Analytics(사용 데이터·기기 ID), Crashlytics(진단), AdMob(광고 ID·대략 위치), 카카오(닉네임·프로필·이메일). 콘솔 선언과 비교.
- 신호: `SDK / 의존성` 섹션
- 수정: SDK 기준으로 콘솔 선언 갱신. Firebase는 개인정보 문서의 SDK별 표 사용.
- Play 2차 사례: "Invalid Data safety form"은 대개 생각 못 한 SDK 때문 — play-services-ads(전화번호), 분석/Adjust/Amplitude/AppLovin/Segment(기기 ID), OSM 로그인(이메일), 키즈 앱의 yandex 광고. SDK 수집 항목(벤더 표)을 선언하거나 SDK 제거; SDK 버전 올릴 때마다 양식 갱신. [사례](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### PRIV-03 추적·광고 ID 동의
- 근거: Apple 5.1.2(i) "App Tracking Transparency API로 명시적 허가… 푸시·위치·추적 등 시스템 기능 활성화를 기능 사용·보상의 조건으로 요구 금지"; 핑거프린팅 금지 / Play **광고**: "AAID는 광고와 사용자 분석에만 사용"; **광고 ID**: Android 13+ 타겟은 `com.google.android.gms.permission.AD_ID` 선언; Data safety에 "광고 식별자"; Android ID는 더 이상 영구 식별자 아님(2025-04)
- 적용: 광고 SDK, 어트리뷰션(AppsFlyer/Adjust), 광고용 분석
- 확인: iOS — ATT 요청 코드 + `NSUserTrackingUsageDescription` + App Privacy "Tracking"; 앱 간 데이터를 결합하는 SDK는 "직접 쓰지 않아도" 추적으로 간주. 동의를 조건으로 기능·보상 제공 금지. Android — 매니페스트 AD_ID(광고 SDK가 병합), Data safety 광고 ID, 옵트아웃/리셋 존중.
- 신호: `ads.sdk`, `track.att`, `track.adid`
- 수정: ATT 프롬프트를 광고 초기화 **전**(온보딩 뒤)에. 거부해도 동작. 동일 벤더 분석용 IDFV는 ATT 불필요.
- 증빙: 없음(코드).
- 한국 사례: ATT는 **첫 번째** 시스템 프롬프트로 앱 실행 시 표시(가입 후·4번째 프롬프트 불가); Flutter는 요청 전 ~1초 지연; plist에 남은 미사용 목적 키도 함께 지적됨.

### PRIV-04 민감 데이터 사전 고지·최소 수집
- 근거: Apple 5.1.1(iii) "가능하면 사진·연락처 전체 접근 대신 out-of-process 피커나 공유 시트" / Play **눈에 잘 띄는 공개 및 동의** — 사용자가 "합리적으로 예상하지 못하는" 접근(광고용 위치, 연락처 업로드, 백그라운드 수집)에 필요: "앱 안에… 정상 사용 흐름에서 표시되고 메뉴 탐색 불필요… 접근·수집 데이터 설명… 사용·공유 방식 설명"; 동의는 "적극적 행동(탭, 체크) 필요", "이탈을 동의로 해석 금지", "자동 닫힘·만료 메시지 금지", 런타임 권한 전에
- 확인: 광고/분석용 위치? 연락처 업로드? 백그라운드 수집? → Google 형식의 앱 내 고지: **"[앱]은(는) ['기능']을 위해 [데이터 유형]을 수집/전송/동기화/저장합니다, [시나리오]."**
- 신호: `perm.*`, `ads.sdk`
- 수정: 권한 요청 직전 명시적 수락 버튼이 있는 다이얼로그; 광범위 권한 대신 피커(Photo Picker, 연락처 피커, 공유 시트).
- Play 3차 문구 — "Requests for in-app user consent and runtime permission are not immediately preceded by an in-app disclosure"; "토글 버튼은 명시적 동의 기준을 충족하지 못함… 두 개의 버튼으로 동의 옵션을 명확히 표시". [사례](../../rejections/community-cases.md#google-play--3rd-pass-2026-08-28-thin-areas--child-safety-declarations-health-connect-form-factors-enforcement)

### PRIV-05 ATT 프롬프트는 새 심사 기기에서 도달 가능해야
- 근거: 2026 리젝 "We were unable to locate the App Tracking Transparency permission request when reviewed on iOS/iPadOS" — ATT 호출은 있었지만 발동하지 않은 앱들: 앱이 활성 상태가 되기 전 요청(`undetermined`가 조용히 반환되고 재시도 없음), 마운트되지 않은 배너에 묶임, 광고 재고에 의존(AdMob은 미출시 앱에 광고를 주지 않음), 깊은 진행도(게임오버 6회)에 의존, 권한 체인의 4번째, 설치 24시간 뒤
- 적용: ATT를 링크하는 모든 앱(광고/분석 SDK가 링크함)
- 확인: `applicationState == .active`일 때 요청(SwiftUI: `scenePhase`, Flutter/RN: 첫 프레임 + 라이프사이클 active 이후), `notDetermined`면 재시도, 광고 SDK 초기화 **전**에 요청, 광고 재고·진행도 무관, 설정에 수동 진입점, `NSUserTrackingUsageDescription` 현지화, 화면 녹화 + 심사 노트에 위치. 바이너리에 ATT가 있으면 App Privacy에 추적 선언(아니면 ASC가 차단).
- 신호: `track.att`, `ads.sdk`
- 수정: 온보딩 뒤 첫 활성 포그라운드로 요청을 이동.
- 사례: [일본어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28), [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- Apple 2차 사례: App Privacy "Used to Track You" 라벨, `NSUserTrackingUsageDescription`, 번들된 SDK 프라이버시 매니페스트(Meta, TikTok, 광고 SDK)가 실제 ATT 요청 여부와 모두 일치해야 — "App Privacy information… indicates tracking… but the app never shows an ATT prompt" 및 그 반대("the app still does not use App Tracking Transparency"). [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- 한/일 3차 사례(iPadOS 26, 독립 앱 4개): 자체 "이미 물어봄" 플래그를 저장하지 말 것(Keychain은 재설치에도 남음 — 시스템 `notDetermined` 사용), 윈도우 활성 후 첫 화면 안에서 요청, 깊은 트리거 뒤에 가두지 말 것; 답신에 ~20초 새 설치 녹화 첨부. [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### AI-01 AI 기능 (제3자 AI 공유, AI 생성 콘텐츠)
- 근거: Apple 5.1.2(i) (2025-11) "제3자 AI를 포함한 제3자와 개인정보를 공유하는 곳을 명확히 고지하고 사전에 명시적 허가" / Play **AI 생성 콘텐츠**: "AI로 콘텐츠를 생성하는 앱은 앱을 나가지 않고 불쾌한 콘텐츠를 신고할 수 있는 앱 내 신고 기능 포함"; Play 사용자 데이터 요건은 "제3자 AI 통합에도 적용"(2026-07)
- 적용: 사용자 데이터를 OpenAI/Gemini/Claude 등에 보내는 모든 호출; AI 채팅·요약·이미지 생성
- 확인: 첫 AI 호출 전 고지(방침 + 앱 내)와 명시적 허가; AI 출력에 신고 수단; AI 출력도 UGC 필터/신고 규칙 적용.
- 신호: `ai.sdk`
- 수정: 첫 사용 전 동의 화면; AI 응답에 "이 응답 신고"; 방침과 Data safety(공유 데이터)에 AI 제공자 기재.
- Apple 2차 사례(2025-11 규칙): 각 AI 제공자를 명시한 동의 단계가 **첫 AI 호출 전**에 있어야; "Note that only including this information in the app's Terms of Service or Privacy Policy is not sufficient"; 목적 문구에 오디오/텍스트가 기기를 떠난다고 명시. [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- 한/일 3차 사례: 동의 게이트는 첫 AI 호출 전에 수신자를 **법인명**(예: Anthropic, OpenAI)으로 나열해야; 방침 한 줄만으로는 두 번 거절. [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

---

## PERM — 권한

### PERM-01 권한 목적 문구
- 근거: Apple 5.1.1(ii) — 목적 문자열은 "구체적이고 완전"("사진 접근" ✗ → "프로필 사진 설정을 위해" ✓) / Android — 재요청 전 사유 안내 권장
- 확인: `IOS-PLIST-01` 참고. Android는 거부 후 재요청 시 안내.
- 신호: `perm.*` vs plist 키
- 수정: 모든 NS*UsageDescription을 "무엇을 위해 무엇을" 형식. `InfoPlist.strings` 현지화.
- 사례 교훈: **"허용 안 함" 이후 표시되는 메시지**도 심사 대상; 기기 언어로 현지화 필수; 공유 시트·FlutterFlow 같은 라이브러리는 사진을 안 써도 `NSPhotoLibraryUsageDescription` 요구(ITMS-90683). [사례](../../rejections/community-cases.md#511ii-purpose-strings)

### PERM-02 권한 거부해도 동작
- 근거: Apple 5.1.1(iv) "동의를 조작·기만·강요 금지" / Play 권한: 비핵심 권한 없이도 사용 가능
- 확인: 푸시·카메라·위치 거부 시 앱이 막히거나 무한 프롬프트 없음.
- 수정: 기능만 비활성 + 설정 이동 안내.
- 위치 특히: Apple 5.1.5는 "위치 서비스가 꺼지면 동작하지 않는" 앱, 설정으로 몰아가는 앱을 거절 — 대체 콘텐츠/수동 입력 제공. [사례](../../rejections/community-cases.md#kids-13-ip-521-regulated-entities-511ix-business-model-322-location-515-objectionable-11)

### PERM-03 안 쓰는 권한 선언 금지
- 근거: Play 권한 정책 / Apple 심사관 질문("왜 필요한가")
- 확인: 코드에서 안 쓰는 매니페스트/plist 권한. SDK 병합 권한(READ_PHONE_STATE 등)은 `tools:node="remove"`.
- 신호: 권한 목록 vs `perm.*`
- 수정: 제거; 남기면 심사 노트에 이유.

### PERM-04 사전 권한 안내("프라이밍") 화면
- 근거: Apple 5.1.1(iv) 리젝 "A custom message appears before the permission request… Use words like 'Continue' or 'Next' on the button instead" — 시스템 프롬프트 전 커스텀 화면은 시스템 알림을 흉내 내면 안 되고, 중립 문구("계속"/"다음", 절대 "허용/수락/부여/연결" 금지), 시스템 프롬프트를 회피하는 건너뛰기 금지, iOS가 재요청하지 않을 땐 "설정 열기" 경로; 한국 사례: 거부 시 종료 버튼 + 설정 이동이 유도로 판단됨
- 적용: 카메라/사진/위치/알림/ATT 프롬프트 전 온보딩 설명 화면
- 확인: 버튼 라벨; 가짜 시스템 다이얼로그 없음; 실제 프롬프트가 즉시 이어짐; 거부해도 앱 사용 가능(PERM-02).
- 신호: `perm.*`
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- 한/일 3차 규칙: CTA는 중립("다음" / "続ける"); 커스텀 프롬프트의 **취소** 버튼 자체가 위반(시스템 프롬프트를 회피 가능); 시스템 프롬프트 **전에** 설정으로 보내는 것도 위반("권한 요청을 표시하기 전에 사용자를 설정 앱으로 리디렉션"). [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

---

## PAY — 결제

### PAY-01 디지털 재화는 IAP / Play 결제
- 근거: Apple 3.1.1 "앱 내 기능·콘텐츠 해제는 IAP 필수"; 3.1.1(a) (2025-05): 외부 결제 링크·버튼은 **미국 스토어프론트에서만** 엔타이틀먼트 없이 허용; "그 외 모든 스토어프론트에서는… IAP 외 결제로 유도하는 버튼·링크·문구 금지" (지역 엔타이틀먼트: EU·한국·일본 — IOS-IAP-02) / Play **결제**: "앱 기능, 디지털 콘텐츠·재화" 는 Play 결제; 등록정보·앱 내 홍보·웹뷰·버튼·링크·광고로 유도 금지; 지역 프로그램: 한국 대체 결제(Play 결제 병행), EEA, 미국(2026-01-28까지 준수), 일본; 글로벌 수수료 변경 2026-06-30(EEA/UK/US), KR/JP 2026-12-31
- 적용: 프리미엄 해제, 구독, 코인, 테마
- 확인: Stripe/토스/아임포트 등으로 디지털 재화 판매 → FAIL. 실물·오프라인 서비스는 IAP **불가**(Apple 3.1.3(e)); 소셜 "부스트"/홍보 게시물은 IAP(3.1.3(g)). "웹에서 더 싸게" 문구 → 미국 외 FAIL.
- 신호: `pay.external`, `pay.iap`
- 수정: StoreKit/Play Billing 또는 RevenueCat. 웹 결제 안내·링크 제거 또는 승인 프로그램 하에 지역별 분기.
- Apple 2차 사례: 후원 버튼/링크(Ko-fi, GitHub Sponsors, Buy Me a Coffee)는 디지털 구매로 간주 — "Although these donations may be optional, they must use In-App Purchase" — 연결된 웹사이트에만 있어도 마찬가지; 3.1.3(a) 링크아웃은 External Link Account API 모달을 "매번" 표시; 3.1.3(c) 기업용 가격이 "개인 소비자 판매로 해석될 수 있음". [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### PAY-02 구독 고지 + 약관 링크
- 근거: Apple 3.1.2(a) "구독 기간 최소 7일, 모든 기기에서 사용 가능"; 3.1.2(c) "구독 전에 가격 대비 제공 내용을 명확히"; Schedule 2: 이용약관(EULA)·개인정보 링크를 앱 안과 메타데이터에 / Play **구독**: "구독 비용, 청구 주기, 자동 갱신 조건" 공개; 무료 체험은 "기간, 가격… 전환 방식, 해지 방법"; "계정 설정(또는 동등 페이지)에 쉬운 온라인 해지 방법"(2025-10-30 명확화)
- 확인: 페이월에 가격·기간·자동갱신 문구·약관/방침 링크·"구매 복원". 무료 체험 → 체험 후 가격·전환일. 설정에 "구독 관리"(Play 구독 센터/App Store 구독 링크).
- 신호: `pay.iap`, `legal.terms`
- 수정: 페이월 표준 문구 + 링크; ASC "라이선스 계약" 필드에 EULA URL(또는 Apple 표준 EULA); 계정 설정에 관리/해지 링크.
- 사례 교훈: 링크는 앱 **과** App Store 설명 둘 다; 청구 금액이 체험 가격보다 눈에 띄어야; "지속적 가치" 없으면 비갱신 구독으로; Play는 가격·주기·전환일·해지 경로를 단순한 페이월 한 화면에. [사례](../../rejections/community-cases.md#312-subscriptions)
- 한국 사례: EULA 링크는 App Store **설명**에 있어야; Resolution Center 답신으로는 메타데이터가 갱신되지 않음 — 빌드 재제출.
- 일본/중국 사례: Apple 표준 EULA를 써도 링크는 App 설명에 있어야; 실제 연간 청구액보다 주 단위 환산가를 크게 표시하면 거절. [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### PAY-03 구매 복원
- 근거: Apple 3.1.1 "복원 가능한 IAP는 복원 메커니즘 제공"
- 확인: 페이월/설정에 "구매 복원"; 비소모성·구독 모두.
- 신호: `pay.iap` (restorePurchases)
- 수정: 버튼 → `restorePurchases()` / `queryPurchases`.
- 사례 교훈: `restorePurchases()` 구현만으로 부족 — **버튼이 페이월에 보여야** 함. [사례](../../rejections/community-cases.md#311-in-app-purchase)

### PAY-04 심사 중 IAP 테스트 가능
- 근거: Apple 2.1(b) "IAP는 완성·최신·심사관에게 보이고 동작해야… 앱에서 찾을 수 없는 IAP 항목은 심사 노트에 이유 설명"; 첫 제출 시 IAP 상품을 앱 버전과 **함께 제출**
- 확인: ASC IAP "Ready to Submit" + 버전에 첨부. Paid Apps Agreement·은행·세금 완료. Play — 라이선스 테스터, 상품 활성.
- 수정: 콘솔 작업. IAP 미첨부는 흔한 2.1/3.1.1 리젝. IAP 프로모 코드는 2026-03-26 이후 생성 불가(오퍼 코드 사용).
- 한국 사례(2026-08): **Paid Apps Agreement 미서명** / 세금 정보 누락(2024-12부터 사업자등록번호 필수) / 은행 정보 누락이 상품 설정 문제처럼 보이는 구독 리젝 3~4회를 만듦; 구독 심사 스크린샷도 첨부. [사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### PAY-05 바이너리 밖의 IAP 배선 (계약, 상품 ID, RevenueCat, 제출 초안)
- 근거: 2026년 가장 잦은 IAP 리젝 문구 "one or more of the in-app purchase products have not been submitted for review", "Family Pack… not found", "광고 제거 버튼 오류", "Confirm you have a Paid Apps Agreement in effect" — 모두 코드 버그가 아님
- 적용: 모든 IAP / 구독
- 제출 전 확인: (1) Paid Apps Agreement **발효**(은행+세금 완료 — 이것만 완료하고 같은 빌드가 다음 날 승인된 사례); (2) 모든 IAP가 **같은** 제출 초안에 첨부("審査と一緒に提出" / 제출물(2)) — IAP의 "심사 제출"은 별도 초안을 만듦; (3) 코드·ASC·RevenueCat의 상품 ID 동일; (4) RevenueCat: App Store Connect In-App Purchase 키(.p8) 업로드, 오퍼링이 실제 상품에 매핑, 웹훅 환경 **Production + Sandbox**; (5) CI 빌드에 API 키 포함(`eas build`는 `.env`를 읽지 않음); (6) 항상 도달 가능한 복원 버튼(PAY-03).
- 신호: `pay.iap`
- 수정: 위 목록; 대부분 새 빌드 불필요 — 콘솔 쪽을 고치고 재제출.
- 사례: [일본어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### PAY-06 가격·통화·체험 문구는 코드가 아니라 스토어에서
- 근거: Apple 2.1(b) "アプリが無料トライアルを広告しているにもかかわらず、決済時にユーザーへ提供されていない"(상품에 체험이 없는데 "7일 무료" 하드코딩); Play 구독 "購入フロー内で目立つ価格の通貨が異なる"(하드코딩 ¥500 vs 현지화된 결제 통화); Apple 3.1.2 청구 금액이 소개 가격보다 덜 눈에 띔
- 적용: 가격/체험을 언급하는 모든 페이월·설정·온보딩·스크린샷·설명
- 확인: 모든 가격·통화·기간·체험 문자열은 `Product.displayPrice` / `priceString` / Play `formattedPrice`에서 렌더링; 상품 로드 전 CTA 비활성; 스크린샷·설명에 스토어프론트마다 달라지는 가격 없음.
- 신호: `price.hardcoded`
- 수정: 스토어 상품 데이터를 단일 소스로; IPA/AAB 문자열에서 고정 가격 검색.
- 사례: [일본어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- Play 3차 사례 — 체험 단계가 설정되지 않은 "Try for Free" 버튼이 구독 경고가 아니라 **멀웨어 "Billing Fraud"**(앱 정지, 계정 종료)로 처리됨. [사례](../../rejections/community-cases.md#google-play--3rd-pass-2026-08-28-thin-areas--child-safety-declarations-health-connect-form-factors-enforcement)

---

## ADS — 광고

### ADS-01 광고 ↔ 동의·라벨
- 근거: PRIV-03. 추가로 Play "광고 포함" 선언(App content > Ads).
- 확인: ASC App Privacy에 광고 데이터; Play Ads 선언 "예".

### ADS-02 방해·기만 광고 금지; 광고 신고; 아동 제한
- 근거: Apple 2.5.18 "광고는 메인 바이너리에만, 익스텐션·App Clip·위젯·알림·키보드·watchOS 금지… 앱 연령 등급에 적합… 전면 광고는 접근 쉽고 잘 보이는 닫기/건너뛰기 버튼… 부적절한 광고를 신고할 수단 포함"; 2.4.2 광고의 무관한 백그라운드 프로세스 금지 / Play **광고** — Better Ads: "예상치 못하게 뜨는 전면 광고 금지"; "레벨 시작·콘텐츠 시작 시 광고 금지"; "15초 안에 닫을 수 없는 전면 광고 금지"; 보상형은 예외; "앱 UI를 흉내 내는 광고 금지"; 잠금화면 수익화 금지 / Play Families 광고 요건
- 확인: 앱 실행/종료/레벨 시작 시 전면 광고 → FAIL(Play). 15초 내 닫기. "광고 신고" 수단(Apple). 위젯/익스텐션에 광고 없음. 광고가 콘텐츠·시스템 UI처럼 보이지 않음.
- 수정: 전면 광고를 자연스러운 구간으로; 닫기/건너뛰기; 광고 신고 메뉴(AdMob 신고 또는 mailto).
- 사례 교훈: 버튼 클릭 시 뜨는 광고 코드는 전면 광고를 제거한 뒤에도 "정상 사용 방해"로 거절됨. [사례](../../rejections/community-cases.md#ads-subscriptions-payments)
- Play 2차 사례: 설정/다운로드/연결 해제 탭 시 광고, 액티비티 시작 시 광고, 포그라운드 복귀마다 앱 오픈 광고, "뒤로 가기 버튼으로 트리거되는 광고", "백그라운드 전환 시 맥락 없는 광고 액티비티"로 거절; Families 앱은 보상형 영상도 "5초 내 닫기 불가", 내비게이션 바 뒤에 숨은 닫기 버튼으로 거절. 실제 원인은 AdMob 정책 센터에 있는 경우가 많음. 규칙: 사용자가 기대하는 곳에만(버튼에 명시), 이동/종료/백그라운드엔 절대 금지. [사례](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)
- Play 3차 사례 — 미디에이션 광고 **소재는 개발자 책임**: Unity Ads/AdMob 미디에이션으로 나간 APK 다운로드 광고가 기기·네트워크 남용 정지로 이어짐(2026-08) — AdMob 광고 검토 센터로 차단, 알 수 없는 미디에이션 소스 비활성, 증거 보관; 키즈 타깃 앱의 홍보 배너는 광고 SDK 없이도 Families 광고로 간주; PE 규칙: 원격 설정 킬스위치는 경고 후엔 괜찮지만 심사 통과용은 불가. [사례](../../rejections/community-cases.md#google-play--3rd-pass-2026-08-28-thin-areas--child-safety-declarations-health-connect-form-factors-enforcement)

### ADS-03 테스트 광고 유닛 제거
- 근거: 릴리즈에 테스트 유닛(`ca-app-pub-3940256099942544/...`) → 수익 0 + AdMob 정책; 개발 중 실광고 클릭 → 위반.
- 신호: `test.keys`
- 수정: flavor/빌드 타입 분기.

---

## PUSH — 알림

### PUSH-01 푸시 없이도 동작; 마케팅 푸시 옵트인
- 근거: Apple 4.5.4 "푸시는 앱 동작의 필수 조건이면 안 되고 민감 정보 전송 금지… 마케팅 푸시는 앱 UI의 동의 문구로 명시적 옵트인 + 앱 내 옵트아웃"; 5.1.2(i) 푸시 활성화를 기능 조건으로 금지; 4.5.3 (2026-06) 푸시 **와 Live Activity** 스팸 금지 / Play — 전체화면 인텐트 남용 금지; 스팸 알림 금지
- 확인: 첫 실행이 아니라 맥락에서 권한 요청(권장). 설정에서 알림 끄기. 마케팅은 별도 명시적 토글. 거부해도 동작.
- 신호: `perm.push`
- 수정: 알림 설정 화면; 마케팅 토글 분리; 푸시 뒤에 기능 가두지 않기.
- Apple 2차 문구: "The app does not request and obtain the user's consent before sending push notifications" · "requires push notifications in order to function" · "uses public APIs with Notification Center in a manner not prescribed by Apple". [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

---

## BG — 백그라운드

### BG-01 백그라운드 모드는 본래 목적만
- 근거: Apple 2.5.4 — `audio`는 실제 오디오 재생, `location`은 위치 기능 등. **타이머·카운트다운을 살리려고 무음 오디오를 재생하는 것은 대표적 리젝.**
- 적용: `UIBackgroundModes` 있음, 특히 타이머·집중·습관 앱
- 확인: `audio` 모드에 사용자가 듣는 소리(백색소음·음악)가 실제로 있는가. 타이머 종료는 로컬 알림으로 처리하는가.
- 신호: `bg.modes`, `bg.audio`, plist `UIBackgroundModes`
- 수정: 종료 시각 저장 + `UNUserNotificationCenter` 로컬 알림 + 복귀 시 남은 시간 재계산. 실제 사운드 기능이 있을 때만 `audio` 유지하고 심사 노트에 설명.
- 증빙: 심사 노트에 백그라운드 모드 사유 한 줄.

### BG-02 Android 포그라운드 서비스
- 근거: Android 14(targetSdk 34)+ `foregroundServiceType` + 타입별 권한 + Play Console 선언(AND-PERM-05, AND-CONSOLE-06)
- 확인: 타이머 유지용 FGS는 보통 `specialUse`(양식에 설명) 또는 `mediaPlayback`(실제 재생). `shortService`는 3분.
- 수정: 매니페스트 타입 + `FOREGROUND_SERVICE_<TYPE>` 권한 + 콘솔 양식 + 데모 영상.

---

## CONTENT — 완성도

### CONTENT-01 플레이스홀더·크래시·미완성 없음
- 근거: Apple 2.1 (플레이스홀더, 빈 화면, 깨진 링크, 크래시) / Play "손상된 기능"
- 확인: "준비 중", "coming soon", lorem ipsum, 안내 없는 빈 리스트, 죽은 버튼. 실기기(특히 **iPad**·구형 Android) 크래시. 외부 링크 200.
- 신호: `placeholder`, `todo.marks`
- 수정: 미완성 기능 숨김. 빈 상태 문구.
- 사례 교훈: 문구 없는 빈 상태는 "버튼이 빈 페이지로 이동"(Play Broken Functionality)으로 읽힘; 권한 거부·오프라인 시 무한 스피너; iPad 스플래시 멈춤. [사례](../../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)
- 한국 사례(Play): 네트워크를 끄고 테스트함 — 빈/무반응 오류 화면은 "손상된 기능"; 오류 문구 + 다시 시도 버튼.
- Play 2차 사례: 심사는 **Play 서명** 빌드로 진행(사전 출시 보고서와 서명 키가 달라 Google 로그인/App Check/일부 라이브러리 실패), 온디맨드 에셋 팩은 심사 환경에서 `AppNotOwned` 반환, 스트리밍 의존 화면은 비어 있음 — AND-REVIEW-01 참고. [사례](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### CONTENT-02 테스트·디버그 흔적 제거
- 확인: 디버그 메뉴, 스테이징 URL, 테스트 결제 키, 로그의 개인정보, `usesCleartextTraffic=true`.
- 신호: `test.keys`, `cleartext`
- 수정: 릴리즈 빌드에서 제외.
- 한국 3차 규칙: "test / 테스트 / 준비중" 문자열이 든 시드 데이터 자체가 리젝 사유; 시뮬레이터 녹화는 반려. [사례](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### CONTENT-03 최소 기능 — 웹 래퍼 금지
- 근거: Apple 4.2 (웹사이트 래퍼, 마케팅 앱, 단일 기능 앱) / Play 최소 기능
- 적용: 웹뷰가 주 UI
- 확인: 의미 있는 네이티브 기능(푸시·카메라·오프라인·위젯…).
- 신호: `webview`

### CONTENT-04 타 플랫폼 언급 금지
- 근거: Apple 2.3.10 — 앱·메타데이터에 다른 모바일 플랫폼 이름·아이콘·이미지 금지("Android에서도" ✗) / Play — 같은 취지(스크린샷의 iPhone 프레임 등)
- 확인: 현지화 문자열·스크린샷·설명의 "Android", "Google Play", "iPhone", "App Store".
- 신호: `문자열에 … 언급`
- 수정: 플랫폼 중립 표현("다른 기기에서도").

### CONTENT-05 지원 연락처
- 근거: Apple 1.5 — 앱과 지원 URL에 쉬운 연락 수단 / Play 개발자 이메일
- 확인: 설정 > 문의하기(메일 또는 폼); 지원 URL 페이지에 이메일.
- 신호: `mod.contact`
- 사례 교훈: 트위터/X 프로필이나 죽은 페이지를 지원 URL로 쓰면 거절(1.5); 이메일이 있는 실제 페이지/폼 사용. [사례](../../rejections/community-cases.md#15-developer-information-frequent-co-rejection)
- 한국 사례: 1.5에 걸린 지원 URL — GitHub 레포 페이지, Apache 기본 페이지, 이메일 없는 노션 페이지, 한글이 인코딩되지 않은 velog URL.

### CONTENT-06 평가 요청·인센티브
- 근거: Apple 5.6.1 "제공된 API로 리뷰 요청… 커스텀 리뷰 프롬프트 불허"; 3.2.2(x) "평가·리뷰·다른 앱 다운로드를 기능 사용 조건으로 강요 금지" / Play — 리뷰 보상·게이팅 금지
- 확인: 커스텀 "별 5개 주면 프리미엄" → FAIL. `SKStoreReviewController`/`requestReview`(iOS), In-App Review API(Android)만.
- 신호: `review.prompt`
- Apple 2차 문구: "prompts users to rate the app in exchange for in-app currency, points, or other incentives"(3.2.2(x)). [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### CONTENT-07 포화 카테고리 — "simple timers"는 의미 있게 다른 경험 필요
- 근거: Apple 4.3(b) (2026-06 개정): "dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling… 의미 있게 다르거나 개선된 경험을 제공하지 않으면 신규 제출을 받지 않으며… 업데이트·개선되지 않거나 고객을 끌지 못하면 삭제할 수 있음"; 4.3(a) 같은 앱의 복수 Bundle ID 금지; 4.2 "특별히 유용·독특·앱답지 않으면" / Play **기능·콘텐츠·UX**: "기능과 콘텐츠가 제한적인 앱 불허"
- 적용: 타이머/집중, 배경화면, 사운드, 손전등, 데이팅, 운세, 템플릿 생성 앱
- 확인: 무엇이 다른가(소셜 기능, 동기화, 분석, 위젯, 고유 메커니즘)? 그 차이가 첫 화면·스크린샷·설명에 보이는가?
- 신호: 앱 이름/설명 키워드(`saturated.category` 힌트)
- 수정: 스토어 설명과 심사 노트 첫 줄에 차별점; 스크린샷에 보이게; 새 번들 ID로 유사 앱 제출 금지.
- 사례 교훈: 4.3을 실제로 통과시킨 것은 **아이콘 + UI 대폭 변경** + 실제 신규 기능; 색만 바꾸기·이의 제기만으로는 실패. 이의 제기 성공 후엔 이후 모든 업데이트에 심사 노트 추가. [사례](../../rejections/community-cases.md#43-spam--duplicates--templates)
- 일본/중국 사례: 첫 제출의 4.3(a)는 **같은 빌드를 실제 심사 노트 + 녹화와 함께 재제출**해 해결(WidgetKit 스도쿠); 기계 판정 4.3("机审")은 컨셉 변경 없이는 안 풀림; 데이팅/운세 앱은 4.3(b) "99%". [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### CONTENT-08 녹화 동의·표시
- 근거: Apple 2.5.14 "사용자 활동을 녹화·기록할 때 명시적 동의 + 명확한 시각/청각 표시… 카메라·마이크·화면 녹화·기타 입력 포함" / Play 기기·네트워크 남용, 스토커웨어
- 적용: 오디오/비디오 녹화, 화면 녹화, 키 입력/사용 기록
- 확인: 녹화 전 동의 + 녹화 중 표시.
- 신호: `perm.mic`, `perm.camera`

### CONTENT-09 IPv6 전용 네트워크
- 근거: Apple 2.5.5 IPv6-only 지원(2016~); 백엔드/SDK가 IPv4 리터럴을 쓰면 "크래시/콘텐츠 로드 실패" 2.1 리젝의 숨은 원인
- 확인: 하드코딩 IPv4 없음; macOS "NAT64 네트워크 생성" 핫스팟으로 테스트.
- 수정: 호스트명 사용; API 호스트 AAAA/NAT64 호환.
- 한국 사례: 무료 동적 DNS(DuckDNS, iptime)와 IPv4 전용 EC2는 Apple의 IPv6 전용 심사망에서 접속 불가 → 2.1 "로그인 불가/데이터 로드 안 됨" 5연속. 실제 도메인 + AAAA/NAT64 호환 호스팅. [사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- 일본/중국 사례: 심사 트래픽은 미국(Apple)·마닐라 등(Play)에서 옴 — WAF 지역 차단과 "运维禁用了海外IP"가 "로그인 불가/네트워크 오류" 리젝을 만듦; 심사 기간에 해당 지역과 IPv6 개방. [사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### CONTENT-10 숨은·휴면 기능 금지; OTA 코드 푸시 신고
- 근거: Apple 2.3.1(a) "숨은·휴면·문서화되지 않은 기능 금지"; 2.5.2 기능을 바꾸는 코드 금지; Play 기만 행위 "숨은·휴면·문서화되지 않은 기능 금지"
- 적용: CodePush / Shorebird / expo-updates / 원격 기능 플래그; 디버그 메뉴; OTP·역할로만 도달하는 화면; 심사 중 달라지는 A/B 코드
- 확인: OTA는 버그 수정만 패치하고 심사 노트에 명시; 릴리즈에 디버그 오버레이·개발 메뉴 없음; 심사관/샌드박스를 감지해 동작을 바꾸는 코드(결제 브리지, 웹 게임) 없음.
- 신호: `codepush`, `todo.marks`
- 수정: 제거하거나 명확히 문서화; 심사 감지로 동작 분기 금지.
- 사례: [커뮤니티 — 2.3.1](../../rejections/community-cases.md#251--231-software-requirements-leftover-capabilities-hidden-features)

### CONTENT-11 강제 업데이트 게이트가 심사 빌드를 막지 않게
- 근거: Apple 2.1 ("업데이트 없이는 콘텐츠에 접근할 수 없음"); Play 손상된 기능
- 적용: 원격 설정/스토어 버전 대비 최소 버전 검사가 있는 앱
- 확인: 스토어보다 **새 버전**인 심사 빌드가 업데이트 화면으로 가지 않음: 버전을 세그먼트별로 비교해 local < required일 때만 안내; 스토어 조회 실패 시 탈출구.
- 신호: `force.update`
- 수정: 비교 로직 수정; 판단 로그; 스토어보다 큰 빌드 번호로 테스트.
- 사례: [커뮤니티 — 2.1](../../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)

### CONTENT-12 릴리즈 동일성 & 새 설치 테스트
- 근거: "실행/로그인 시 오류 메시지"로 읽힌 한국 2.1 리젝의 원인은 Release 전용 설정: API 호스트/포트가 Debug 스킴에만, HTTP 엔드포인트가 ATS(-1022) / AAB의 `ERR_CLEARTEXT_NOT_PERMITTED`에 막힘, 캐시된 세션에서만 되는 첫 실행 인증
- 적용: 모든 제출
- 확인: 초기화된 기기에 **Release** 빌드를 세션 없이 설치해 삭제 → 설치 → 가입 → 로그인 → 핵심 흐름 → 재실행; Release 설정에 프로덕션 호스트, 전 구간 HTTPS(`NSAllowsArbitraryLoads` / `usesCleartextTraffic` 우회 금지), 디버그 전용 플래그 없음.
- 신호: `cleartext`, `test.keys`
- 수정: 설정을 공용 위치로; 모든 엔드포인트 HTTPS; CI에 새 설치 스모크 테스트.
- 사례: [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### CONTENT-13 비한국어 로케일/리전에서 실행
- 근거: 심사관은 미국 리전에서 실행; `CFBundleDevelopmentRegion`이 `$(DEVELOPMENT_LANGUAGE)`이거나 스토리보드 현지화 테이블에 기본 언어가 없어 실행 시 크래시; 권한 다이얼로그가 다른 언어로 뜸(4.0)
- 적용: 한국어(단일 로케일)로 개발한 앱
- 확인: 기기 언어/지역을 en-US로 두고 Release 빌드 실행; `CFBundleDevelopmentRegion`이 구체 값(`ko_KR` 또는 `en`); 기본 언어 현지화 테이블 존재; `InfoPlist.strings` 현지화.
- 수정: 구체적 개발 리전; Base 현지화 완성; 두 로케일 모두 테스트.
- 사례: [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### CONTENT-14 에뮬레이터·미니앱 호스트·콘텐츠 필터 (4.7 / 2.5.1 / 2.4.5)
- 근거: Apple 4.7은 레트로 **게임 콘솔** 에뮬레이터와 앱의 주 목적이 아닌 HTML5 미니앱만 허용("offering HTML5 games appears to be the primary purpose of your app", "not emulating a retro game console specifically", "PC is not a console"); VPN/루트 인증서 콘텐츠 필터, 접근성 자동 붙여넣기, Notification Center 오용은 2.5.1 / 2.4.5; "The app installed or launched executable code. Specifically, the app uses the itms-services URL scheme"(2.5.2)
- 적용: 에뮬레이터, 미니게임 포털, 챗봇/플러그인 호스트, VPN 기반 필터, 빌드 배포 앱
- 확인: 주 목적이 자체 기능; 에뮬레이션 대상이 콘솔; itms-services/엔터프라이즈 배포 링크 없음; 공개 API 오용 없음.
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

---

## META — 스토어 메타데이터 (코드 밖)

### META-01 스크린샷은 실제 화면
- 근거: Apple 2.3.3 — 사용 중 화면, 스플래시·로그인·타이틀 불가; 프레임·문구 허용 / Play 메타데이터 — 앱을 정확히 반영
- 확인: 필수 규격(iPhone 6.9", iPad 13")과 내용. `store-screenshots` 스킬로 만든 이미지면 화면 부분이 실제 앱인지.

### META-02 설명·키워드·이름
- 근거: Apple 2.3.7 "앱 이름 30자 제한"; 메타데이터에 상표·인기 앱 이름·가격 금지; 2.3.2 설명/스크린샷에 IAP 고지; 2.3.8 메타데이터 4+ 적합; 2.3.12 중요 변경은 What's New에 / Play **메타데이터**: 제목 ≤ 30자; "이모지·이모티콘·반복 특수문자" 금지; 제목/아이콘/개발자명에 성과·순위·가격·홍보 문구 금지("App of the year", "#1", "Best of Play", "10% off", "free for limited time only", "Editor's choice", "New"); 브랜드 외 대문자 남용 금지; "출처 없는 사용자 후기" 금지; **기만 행위**: 제목/설명/아이콘/스크린샷의 허위·오도 주장 금지
- 확인: 미출시 기능 약속, 타 플랫폼 언급(CONTENT-04), 다른 앱 이름, 홍보 문구, 제목의 이모지.
- 사례 교훈: "Tutorial & Rules"(외부 콘텐츠 암시), 스페인어 "libre"("free"로 판독), 이름의 "ChatGPT", "Anonymous/匿名" 키워드, 하드웨어 브랜드명 — 모두 거절. [사례](../../rejections/community-cases.md#metadata--misleading-claims)
- Apple 2차 사례(2.3.2): 구매가 필요한 기능은 설명/스크린샷에 표시("(Pro)", "구독 필요") — "metadata refers to paid content or features, but they are not clearly identified as requiring additional purchase"; 플레이스홀더 아이콘과 Kids 카테고리 아닌 앱 이름의 "Kids"는 2.3.8; "resembles Pokemon"/스포츠 리그 유사는 4.1(a). [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### META-03 연령 등급 설문
- 근거: Apple 2.3.6 "정직하게 답변"; 새 등급 4+/9+/13+/16+/18+와 새 문항(앱 내 제어, 기능, 의료/웰니스, 폭력) — 2026-01-31까지 응답 필수; **2026-09부터 제출 시 소셜미디어 문항 필수**; "Social Media" 기능 선언 시 최소 13+(iOS 27 Time Allowances) / Play **콘텐츠 등급**(IARC): "모든 앱은 등급 필수… 등급 없는 앱은 삭제"; "허위 표기 시 삭제·정지"; "Users Interact"는 사용자 간 통신·미디어 공유
- 확인: **UGC·채팅·친구가 있으면 "사용자 상호작용/UGC/메시지" = 예**; 웹뷰로 웹 탐색이면 무제한 웹 접근; 해당 시 루트박스/도박. 기능 변경 시 설문 재제출.
- 신호: `ugc.*`, `webview`
- 사례: META-03 태그 커뮤니티 사례 참고
- 한국 사례: 웹뷰로 YouTube/외부 웹을 로드하면 등급이 12+로 상향("무제한 웹 접근") — 외부 브라우저로 열기.

### META-04 URL 동작
- 확인: 지원·마케팅·개인정보 URL 200 + 내용. 노션은 "웹에 게시" 켜짐.
- Apple 2차 사례: 링크된 페이지도 **메타데이터** — 지원 URL, README, 노트에 링크한 마케팅 사이트의 상표·타 플랫폼 언급·후원 링크·허위 주장이 심사됨. [사례](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### META-05 심사 노트
- 근거: Apple 2.3.1(a) "모든 신규 기능·변경은 App Store Connect의 Notes for Review에 **구체적으로** 기술(일반적 서술은 거절)"; App Review 페이지: "Incomplete information"(데모 계정, 특수 설정, 데모 영상/하드웨어)이 상위 리젝 사유 / Play Sign-in details(AND-CONSOLE-03)
- 확인: `templates/review-notes.md` 내용이 ASC App Review Information(노트 ≤ 4000바이트, 국제 형식 전화번호) / Play Sign-in details에 있는가. 데모 계정 + 기능 위치 + 녹화 링크 + 백그라운드 모드 사유 + IAP 위치 + 조건부(지역·시간·역할) 기능 설명.

### META-06 스토어 자산은 설치된 앱·도달 가능한 상태와 일치해야
- 근거: Apple 2.3.8 "앱 마켓플레이스에 표시되는 앱 이름과 기기에 표시되는 앱 이름이 충분히 일치하지 않아"(긴 스토어 이름 vs 짧은 `CFBundleDisplayName`); Play 혼동을 야기하는 주장/메타데이터: "the app's icon or title when installed on the device differs from what is displayed in the Play Store"(적응형/모노크롬 아이콘이 흰색으로 렌더링, 옛 테스트 트랙 아이콘), 잠긴 레벨·동적 콘텐츠 스크린샷, 존재하지 않는 화면, "Identical title and description", "Your app is improperly categorized"
- 확인: App Store/Play 제목과 런처 이름이 같은 핵심 이름(태그라인은 부제); 고해상도 아이콘과 런처 아이콘이 같은 자산(모노크롬 레이어 정리해 재생성); 모든 스크린샷이 심사관이 도달 가능한 상태(아니면 프레임 밖에 "예시" 캡션); 제목 ≠ 설명.
- 신호: plist `CFBundleDisplayName` / `android:label` vs 스토어 이름
- 수정: 이름·아이콘 통일; 스크린샷 재촬영; 설명을 기능 목록으로.
- 사례: [한국어 사례](../../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28), [Play 2차](../../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### META-07 재제출 메커닉스
- 근거: 절차 자체로 며칠을 잃은 사례들: Resolution Center 답신은 심사를 재시작하지 **않음**("However, in order for us to proceed with the review of your app, please resubmit the app for review in App Store Connect") — Apple이 버그 수정 패스를 명시적으로 제안한 경우 제외; 반대로 4.3/2.1 대화 중 심사관 답변 전에 재제출하면 스레드가 끊김; 거절된 버전 문자열은 재사용 불가(1.7.0 → 1.7.1); IAP "심사 제출"은 별도 초안 생성; Play: 재제출마다 한 이슈를 완전히 해결하지 않으면 "Repeated app rejections"로 정지
- 확인: 답신 후 Apple이 새 빌드/메타데이터를 요구하면 "심사에 재제출" 누르기; 심사관이 질문했으면 답변을 기다리기; 빌드/버전 올리기; ASC 제출 초안에 앱 + IAP가 함께 있는지 확인.
- 사례: [일본어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

---

## KR — 한국 법규·관행

### KR-01 만 14세 미만 법정대리인 동의
- 근거: 개인정보보호법 제22조의2 — 14세 미만 아동 개인정보 수집은 법정대리인 동의 필요. 대부분 "만 14세 이상입니다" 확인으로 대응.
- 적용: 회원가입 있음, 아동 대상 아님
- 확인: 가입/약관 동의 화면에 만 14세 이상 확인.
- 신호: `legal.age`
- 수정: "만 14세 이상입니다(필수)" 체크 추가.

### KR-02 약관·방침 필수 기재
- 근거: 개인정보보호법 제30조(처리방침 기재 사항), 전자상거래법(유료 서비스 청약철회·환불)
- 확인: 수집 항목·목적·보유기간·제3자 제공·처리위탁(Firebase/AWS 등 해외 이전 포함)·정보주체 권리·보호책임자 연락처. 유료면 환불 규정.

### KR-03 게임이면 등급 분류
- 근거: 게임산업진흥법 — IARC(자체등급) 인정; 청소년이용불가 게임은 GRAC 심의
- 적용: 게임 카테고리

### KR-04 한국 관련 스토어 변경(2026)
- 근거: Apple — 2026-10부터 한국에서 "경미한 비속어", "경미한 성인 주제"가 전체이용가 → 12+로(GRAC RCN 반영); 한국 기반 개발자는 2026-01-01부터 Sign in with Apple 서버 알림 엔드포인트 필수(IOS-LOGIN-03); 한국 외부 결제 엔타이틀먼트(IOS-IAP-02) / Play — 한국 대체 결제(AND-PAY-01)
- 확인: 비속어/성인 주제 문항 답변; SIWA 엔드포인트 설정.

### KR-05 토스 미니앱(앱인토스) 심사
- 근거: 고유 규칙과 빠른(수 분) 자동+수동 심사를 가진 세 번째 한국 스토어: "미니앱 접속 직후 바텀시트가 바로 노출돼요"(진입 시 바텀시트 금지), "서비스 설명 없이 즉시 토스 로그인 유도"(서비스 설명 전 로그인 유도 금지), "탭바를 사용하는 경우, 토스 미니앱 브랜딩 가이드에 적합한 플로팅 형태를 사용해야 해요"(플로팅 캡슐 탭바), 미지원 카테고리(부동산); 거절 사유는 `review_get_feedback.comments`에만(`review_get`의 `rejectMessages`는 비어 있음); 취소된 심사는 새 번들 필요
- 적용: 토스 미니앱으로 배포하는 앱
- 확인: 첫 화면이 모달/로그인 없이 서비스를 설명; 탭바가 브랜딩 가이드 준수; 스크린샷이 현재 UI와 일치; 지원 카테고리.
- 사례: [한/일 3차](../../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

---

## LAW — 지역별 연령 확인 법규 (2026)

### LAW-01 지역별 연령 확인 요구
- 근거: Apple 뉴스 2026-02-24 / 2026-06-03: 브라질·호주·싱가포르에서 18+ 앱은 성인 확인 없이 차단(2026-02-24); **텍사스 SB 2420** 2026-06-04 시행(다운로드·IAP·중요 변경에 보호자 동의 — Declared Age Range API, Significant Change API, 동의 철회 서버 알림), 유타(2026-05-06), 루이지애나(2026-07-01); 호주 16세 미만 소셜미디어법(2025-12-10) — Declared Age Range API, Age Suitability URL / Play **Age Signals API** 데이터 사용 제한(2026-01-01), 연령 제한 콘텐츠 도구
- 적용: 소셜 미디어, 데이팅, 채팅, 18+ 콘텐츠, 해당 지역에 배포되는 IAP 앱
- 확인: Declared Age Range API / Play Age Signals를 읽어 기능을 조정하는가; 중요 변경 선언; 요구 시 Age Suitability URL.
- 신호: `ugc.*`, `pay.iap`
- 수정: 연령 API 채택; 연령 적합성 페이지; 연령 등급 최신 유지(META-03).
- 증빙: 없음(플랫폼 측).
### LAW-02 규제 금융/암호화폐 스토어프론트 증빙 (3.1.5, 3.2.2(viii))
- 근거: "The storefronts you selected in App Store Connect include locations where you… have not provided supporting evidence of permissions, registrations, and/or licenses" · "facilitates trading in contracts for difference" — 암호화폐 거래/스왑/온램프, CFD/파생상품 기능은 스토어프론트별 라이선스 증빙을 App Review Information에 첨부; 없으면 기능 제거 또는 스토어프론트 제한; Play: 금융 기능 선언 + 라이선스(AND-CONSOLE-09)
- 적용: 암호화폐 지갑/거래소, 트레이딩, 대출, 보험
- 확인: 스토어프론트 목록 vs 라이선스; 증빙 첨부; 조직 계정(ACC-06).
- 사례: [Apple 2차](../../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

---

## JP — 일본

### JP-01 일본 특화 스토어·법적 요건
- 근거: **MSCA / スマホ新法**(2025-12-18 시행): Apple Japan은 외부 구매 링크/대체 결제 허용(IAP 병행 표시, Apple 고지 시트, 월별 보고; 실효 수수료 ≈ 26%/15%), Google Play Japan 외부 결제 프로그램("등록정보에 앱 외 구매 언급 금지"); **特定商取引法**(2022-06): 구독 주문 화면에 가격·기간·자동갱신·해지 조건 표시 — Apple 3.1.2 / Play 구독 리젝과 대응; **資金決済法**: 구매한 앱 내 포인트는 前払式支払手段 — 미사용 잔액 ¥10M 초과 시 공탁 의무(6개월 내 소멸하면 예외); Play: 개인사업자(開業届)는 D-U-N-S를 받아 조직 계정으로 등록해 12×14 비공개 테스트를 건너뛸 수 있음
- 확인: 페이월/지원 페이지에서 特商法表記 페이지 링크; 포인트 소멸 ≤ 6개월 또는 공탁 회계; 스토어 가격 사용(PAY-06); 심사 노트는 일본어 가능하지만 Play Sign-in details는 영어.
- 사례/출처: [일본어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28), `../../references/japan-china.md`

## CN — 중국

### CN-01 중국 특화 스토어·법적 요건
- 근거: App Store 중국 본토용 **ICP备案** 필수(2024-04부터 엄격): 미신고 앱 삭제; ASC 앱 이름이 MIIT 기록과 일치해야; 오프라인/IAP 전용 앱은 면제 신청 가능; 게임은 **版号** 필요; 대출/금융 앱은 ICP + 金融许可证 필요; Apple은 라이선스 없는 **AI 기능**을 본토 배포에서 거절("Guideline 5 - Legal" → AI 제거, 중국 본토 해제, 또는 서류 제출); 위챗/QQ 로그인은 제3자 로그인 → Sign in with Apple(4.8), 위챗 미설치 시 버튼 숨김은 면제 안 됨; iOS 앱 내 위챗 미니프로그램 홍보 → 3.2.2; 중국 SDK는 Google Play 빌드 필요(JPush `google_play` jar), DCloud/uni-app 런타임의 APK 설치 코드(Play 삭제), Umeng 코드 경로가 Apple 2.3.1 유발, Adjust의 설치 앱 읽기(Data safety); 운영팀의 해외 IP 차단은 반복되는 2.1 원인; 중국 신규 Play 계정 정지("高风险", 账号关联) — "연관 방지" VPS·계정 구매 가이드는 정책 위반이지 해결책이 아님
- 확인: ASC에 ICP 신고 번호; 라이선스 없는 AI 기능이면 중국 본토 해제; HIG 버튼의 SIWA; 미니프로그램 홍보 없음; 중국 SDK의 Google Play 변형; 심사 중 해외 IP 개방.
- 사례/출처: [중국어 사례](../../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28), `../../references/japan-china.md`

