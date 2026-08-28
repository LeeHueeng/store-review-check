# Store review pre-check report

Write this file in the user's language. The JSON (`report.schema.json`) is the source of truth; this markdown is the chat/markdown rendering.

- App: {{name}} ({{bundle id / package}})
- Version: {{version (build)}}
- Platforms: {{iOS / Android / both}}
- Checked on: {{YYYY-MM-DD}}
- Project: `{{path}}` ({{Flutter / React Native / Expo / iOS native / Android native}})
- Scanner: scan.sh v{{version}} — {{n}} auto-hints

## 1. At a glance

| Grade | Count |
|---|---|
| 🔴 FAIL (will be rejected) | {{n}} |
| 🟠 WARN (often rejected / console check) | {{n}} |
| ⚪ UNKNOWN (needs verification) | {{n}} |
| 🟢 PASS | {{n}} |
| N/A | {{n}} |

**Recurrence risk**: {{"same as [case](link) UGC-03" or "no past rejection pattern"}}

## 2. Feature profile (basis for judgments)

| Feature | Found | Evidence |
|---|---|---|
| Login | {{Google · Kakao · Apple · email · guest}} | `{{file:line}}` |
| UGC | {{chat · friends · nickname · profile photo …}} | |
| Payments | | |
| Ads | | |
| Permissions | | |
| Background | | |
| Push | | |
| WebView | | |

## 3. Findings

| ID | Grade | Guideline | Summary | Evidence |
|---|---|---|---|---|
| UGC-01 | 🔴 | Apple 1.2 / Play UGC | No consent screen | `lib/auth/login.dart:40` social login → home |
| … | | | | |

## 4. Details (FAIL / WARN / UNKNOWN only)

### {{ID}} {{title}} — {{grade}}
- Guideline: {{number · name}}
- Current state: {{what exists / what is missing}}
- Evidence: `{{file:line}}`
- Fix: {{concrete — which screen, what to add, data model, server}}
- Evidence to submit: {{recording · review notes · console setting}}
- Closest community case: {{link from rejections/community-cases.md, if any}}

## 5. Fix priority

1. {{FAILs first; prefer work that clears several items at once (e.g. Sign in with Apple = IOS-LOGIN-01 + ACC-03)}}
2. …

## 6. Console checklist (outside the code)

**App Store Connect**
- [ ] Privacy policy URL / support URL respond
- [ ] App Privacy labels = SDK collection
- [ ] Age rating questionnaire (UGC → users interact = Yes)
- [ ] App Review Information: demo account, notes, recording link, contact
- [ ] Screenshots iPhone 6.9" / iPad 13" (universal)
- [ ] Export compliance (ITSAppUsesNonExemptEncryption)
- [ ] IAP attached + Paid Apps Agreement (if any)

**Google Play Console**
- [ ] Privacy policy URL
- [ ] Data safety (SDKs, account-deletion URL)
- [ ] App access (credentials)
- [ ] Content rating questionnaire
- [ ] Target audience / Ads / Advertising ID
- [ ] Sensitive-permission & foreground-service declarations + video
- [ ] targetSdk requirement
- [ ] (new personal account) closed testing 12 testers · 14 days

## 7. Review notes draft

{{filled templates/review-notes.md}}
