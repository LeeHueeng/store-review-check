---
date: {{YYYY-MM-DD}}
platform: {{ios | android}}
app: {{앱 이름}}
bundle_id: {{번들 ID / 패키지명 (모르면 비움)}}
version: {{1.0 (10)}}
submission_id: {{Submission ID / Play 사례 번호}}
guidelines:
  - {{"1.2 Safety - User-Generated Content"}}
review_device: {{iPad Air 11-inch (M3), iPhone 17 Pro Max}}
status: {{open | resolved}}
resolved_on: {{YYYY-MM-DD 또는 비움}}
checklist_ids: [{{UGC-01, UGC-02, …}}]
---

# {{YYYY-MM-DD}} {{플랫폼}} {{가이드라인 번호}} — {{앱 이름}}

## 원문

```
{{리젝 메일 전문. 데모 계정·비밀번호 등 비밀은 <REDACTED>}}
```

## 요구사항 (메일에서 추출)

- [ ] {{요구 1}} → {{체크리스트 ID}}
- [ ] {{요구 2}} → {{체크리스트 ID}}
- [ ] 증빙: {{녹화 / 데모 계정 / 문서}}

## 원인 분석

{{앱의 어떤 기능이 왜 걸렸는지. 프로젝트를 스캔해 확인했으면 파일:라인, 아니면 "추정" 표시.}}

## 숨은 리스크 (같은 심사에서 함께 걸리기 쉬운 것)

- {{ID}}: {{이유}}

## 조치

| 요구 | 구현 | 파일 | 상태 |
|---|---|---|---|
| {{약관 동의}} | {{가입 화면 필수 체크 + 약관 조항}} | `{{…}}` | {{예정 / 완료}} |

## 증빙

- 녹화: {{링크 또는 파일명 — 촬영 순서는 templates/evidence-recording.md}}
- 데모 계정: 심사 노트에 기재 (이 파일엔 ID만, 비밀번호 없음)

## 답신

{{보낸 답신 요약 (전문은 templates/reply.md 형식)}}

## 교훈 → 체크리스트 반영

- {{checklists/xxx.md ID}}: {{무엇을 추가/수정했는지}}
- scan.sh: {{추가한 신호 또는 "변경 없음"}}
