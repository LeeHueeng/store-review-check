# 심사 노트 템플릿

비밀번호는 콘솔에 직접 입력한다. 이 파일·리포트·케이스에는 `<DEMO_PASSWORD>`로 둔다.

---

## App Store Connect — App Review Information > Notes (영어)

```
DEMO ACCOUNT (pre-populated with friends, chats and posts)
  Login method: {{Email/Password | Sign in with Apple | Google | Kakao}}
  ID: {{reviewer@example.com}}
  Password: <DEMO_PASSWORD>
  {{2-step verification is disabled on this account. If a verification code is requested, use the fixed code 000000.}}
  Second account (to see the other side of chats/friend requests): {{reviewer2@example.com}} / <DEMO_PASSWORD>

HOW TO LOG IN
  1. Launch app → tap "{{Continue with Email}}"
  2. Accept the Terms of Use (EULA) and Privacy Policy on the consent screen
  3. Enter the credentials above

USER-GENERATED CONTENT SAFEGUARDS (Guideline 1.2)
  - EULA with zero-tolerance policy: shown before sign-up/login; also Settings > Terms of Use
  - Content filter: profanity/objectionable words are blocked on nicknames and messages ({{client + server}})
  - Report: {{Friends list / Chat}} > long-press or "⋯" > Report > choose reason
  - Block: {{Profile}} > "⋯" > Block → the user's content disappears immediately; Settings > Blocked users to manage
  - Reports and blocks notify us ({{email/Slack}}); we act within 24 hours (remove content, suspend/eject user)
  - Contact: {{support@example.com}}

SCREEN RECORDING (physical {{iPhone model}}, iOS {{ver}}): {{https://… (Drive/Dropbox/YouTube unlisted)}}
  Shows: EULA consent → login → report a message → block a user (content removed instantly)

OTHER NOTES
  - {{Background audio mode is used for the ambient/white-noise feature; the timer itself uses local notifications.}}
  - {{Sign in with Apple is available on the login screen alongside Google/Kakao.}}
  - {{The app is designed for iPhone; on iPad it runs in compatibility mode / has an adaptive layout.}}
  - Account deletion: Settings > Account > Delete account

CONTACT: {{name}}, {{email}}, {{+82-10-…}}
```

체크:
- [ ] "Sign-in required" 체크박스 켜고 계정 입력
- [ ] 데모 계정 2개가 서로 친구이고 대화·게시물이 있음
- [ ] 계정이 해외 IP에서 로그인됨 (VPN으로 한 번 테스트)
- [ ] 녹화 링크가 로그인 없이 열림
- [ ] 백엔드(Firebase 등)가 심사 기간 내내 켜져 있음

---

## Google Play Console — App content > App access (한국어 UI 기준)

"전체 또는 일부 기능이 제한됨" 선택 → 안내 추가:

```
Name: Reviewer account
Username: {{reviewer@example.com}}
Password: <DEMO_PASSWORD>
Other info:
  - Login: tap "{{Continue with Email}}" → accept Terms → enter credentials. 2-step verification is off.
  - Second account for chat/friends: {{reviewer2@example.com}} / <DEMO_PASSWORD>
  - UGC safeguards: Report ({{path}}), Block ({{path}}), Terms ({{path}}), profanity filter on input.
  - Account deletion: Settings > Account > Delete account. Web: {{https://…/delete-account}}
  - Foreground service ({{type}}): used for {{keeping the focus timer running with a persistent notification}}. Demo: {{video link}}
```

체크:
- [ ] Data safety에 계정 삭제 URL
- [ ] 민감 권한/포그라운드 서비스 선언 양식에 영상 링크
- [ ] 콘텐츠 등급 설문 "사용자 상호작용" 예
