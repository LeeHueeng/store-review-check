# 답신 템플릿

## Apple — App Store Connect > 앱 심사 메시지 답장 (영어)

구조: 감사 → 요구사항별 "구현했음 + 어디서 보는지" → 데모 계정 → 첨부 → 재심사 요청. 변명·긴 설명 금지. 새 빌드를 올렸으면 빌드 번호 명시.

```
Hello,

Thank you for the review. We have addressed Guideline {{1.2}} as follows and uploaded a new build ({{1.0 (11)}}).

1. Terms of Use (EULA) — Users must accept our Terms of Use and Privacy Policy before signing up or logging in. The terms state that there is no tolerance for objectionable content or abusive users, and that reported content is removed and offending users are ejected within 24 hours. ({{Login screen → consent checkbox}}; also Settings > Terms of Use)

2. Filtering objectionable content — Nicknames, status messages and chat messages are checked against a profanity/objectionable-word filter on the client and on the server before they are stored or shown.

3. Flagging content — Every message, post and profile can be reported via {{long-press / "⋯" menu}} > Report, with a reason. Reports are sent to our moderation queue and notify us immediately.

4. Blocking users — Any user can be blocked from {{their profile / chat / friends list}} > Block. Blocking immediately removes that user's content from the blocker's feed and chats, notifies us with the related content, and can be managed in Settings > Blocked users.

5. Moderation — We review all reports within 24 hours, remove violating content and eject the user who posted it. Contact: {{support@example.com}}.

Demo account (pre-populated, no verification step): {{reviewer@example.com}} / {{see App Review Information}}. A second account ({{reviewer2@example.com}}) is provided to view both sides of chats.

Attached is a screen recording captured on a physical {{iPhone 15}} showing: EULA consent before login → reporting a message → blocking a user (content removed instantly). The same link is in the App Review Information notes.

Please let us know if anything else is needed.

Best regards,
{{Name}}
```

## Google Play — 정책 위반 이의 제기 / 재제출 메모 (Play Console 양식 또는 한국어 가능)

Play는 대체로 "수정 후 재제출"이 답신이다. 이의 제기(appeal)는 오판일 때만.

```
[재제출 메모 — App access "기타 정보"에 기입]
정책 {{사용자 제작 콘텐츠}} 관련 수정 사항:
- 약관 동의 화면 추가 (가입/로그인 전), 약관에 부적절 콘텐츠 무관용·24시간 내 조치 명시
- 메시지/프로필 신고 기능 ({{경로}})
- 사용자 차단 기능 ({{경로}}), 차단 즉시 콘텐츠 숨김
- 금칙어 필터 (입력 시)
- 리뷰어 계정: {{reviewer@example.com}} / (비밀번호는 App access에 입력)
- 시연 영상: {{링크}}
```
