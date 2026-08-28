---
name: store-review-check
description: Pre-flight check for App Store (iOS) and Google Play (Android) review. Scans a mobile project (Flutter, React Native, Expo, native) for rejection risks — UGC safeguards (EULA, report, block, filter), account deletion, Sign in with Apple, reviewer demo account, permission strings, privacy manifest/ATT, payments, background modes, iPad layout, targetSdk, Play Console declarations — and writes a graded report (HTML or chat). Paste a rejection email and it parses it, saves the case, maps it to the checklist, predicts co-rejections, and drafts the fix plan, evidence recording script, reviewer reply and review notes. Use for "check my app before submitting", "app review pre-check", "we got rejected", "write App Review notes", "demo account for reviewers", 심사 체크, 리젝 미리 확인, 앱스토어 심사 준비, 플레이스토어 정책 점검, 리젝 왔어, 심사 노트, 審査チェック, リジェクト, 审核预检, 被拒.
argument-hint: [project path | pasted rejection email | notes]
---

# Store Review Pre-Check & Rejection Manager

Catch App Store / Google Play rejection reasons **before** submitting, and turn every rejection you do get into a knowledge-base case that the next pre-check re-uses.

## Hard rules

1. **Reply in the user's language.** Detect it from their message (Korean → Korean, Japanese → Japanese, …). Reports, case analysis and chat output follow the user; replies addressed to Apple/Google reviewers are always written in English. Checklists in this skill are English (`checklists/`) with translations under `checklists/<lang>/` that may lag — English is canonical.
2. **Every question is a multiple-choice question.** Never ask open-ended questions. In Claude Code use `AskUserQuestion` (with `multiSelect: true` whenever several answers can apply, and the recommended option first with "(Recommended)"). In runtimes without that tool (Codex CLI, others) print the options as a numbered list, mark the recommended one, and end the turn to wait for the answer; accept a number or free text. If something needs free text (a path, an email), still offer options plus "Other" for typing. Don't ask what the code or the scanner can tell you. Question sets are defined per mode below.
3. **No PASS without evidence.** Only mark PASS when you verified it in code/config/resources and can cite `file:line`. Otherwise UNKNOWN with "how to verify". Scanner counts alone never decide a grade — open the file: is `report` a crash reporter or a report-content feature? Is `friend` a feature or a variable name?
4. **Reviewer-eyed priority.** 🔴 FAIL (a guideline explicitly requires it and it's missing) → 🟠 WARN (frequently rejected / reviewer discretion / console-side) → ⚪ UNKNOWN → 🟢 PASS → N/A. Every FAIL/WARN carries the guideline number, the fix, and the evidence to submit.
5. **Feature-conditional.** Items for features the app doesn't have are N/A — but "doesn't have" requires that you actually read the routes/screens. UGC is broad: nicknames, profile photos, status messages, friend invites, group names — **any user input visible to another user** makes it a UGC app.
6. **Every rejection becomes a case** in `rejections/`. New pattern → add a checklist item and consider a scanner signal. This is how the skill learns.
7. **Change code only when asked.** Default deliverables are the report, plan and drafts. When the user picks "fix now", implement exactly what the report prescribes.
8. **Never store secrets.** Demo passwords / API keys never go into reports or case files — use `<DEMO_PASSWORD>` placeholders; the user types them into the console.
9. **Date-sensitive numbers** (targetSdk, minimum Xcode/SDK) are judged against today's date; checklist values carry their "as of" date — recommend checking the official page when in doubt.

## Layout

| Path | Purpose |
|---|---|
| `scripts/scan.sh` | Project signal scanner. `bash scan.sh <root>` → markdown (plist, entitlements, pbxproj, manifest, gradle, dependencies, feature/moderation/login/payment/permission/background greps, auto-hints) |
| `scripts/render_report.py` | JSON → standalone HTML report (filters, dark mode, console checkboxes, copyable review notes). `python3 render_report.py report.json report.html --open` |
| `checklists/common.md` | Feature-conditional items: UGC, account, privacy, permissions, payments, ads, push, background, content, metadata, Korea law |
| `checklists/ios.md` / `checklists/android.md` | Platform items: Sign in with Apple, iPad, Info.plist, privacy manifest, ATT, FamilyControls / targetSdk, permission declarations, Play Console forms, closed testing … |
| `checklists/<lang>/` | Translations (may lag behind English) |
| `references/` | Links + summaries of the official guideline sources the checklists were verified against |
| `rejections/` | Case KB. Own cases: `YYYY-MM-DD-<platform>-<guideline>-<app>.md`. Community cases: `community-cases.md` |
| `templates/` | report JSON/markdown, case, review notes, reviewer reply, UGC EULA clause, evidence recording script |

`$SKILL` below = the directory containing this file (Claude Code `~/.claude/skills/store-review-check`, Codex `~/.codex/skills/store-review-check`).

## Mode detection

| Input | Mode |
|---|---|
| A path / nothing / "check my app", "심사 체크" | **A. Pre-check** |
| Rejection text (`Guideline x.x`, `Submission ID`, `Issue Description`, `Your app has been rejected`, `Policy status`, `does not comply with`, `정책 위반`, `거부되었습니다`, `リジェクト`) | **B. Rejection intake** |
| "review notes", "demo account", "App access", "reply to reviewer", "심사 노트" | **C. Submission info** |

In B, if the project path is known also run A focused on the affected items.

## A. Pre-check

1. **Scan first, ask second.** `bash "$SKILL/scripts/scan.sh" "<root>" > "$SCRATCH/scan.md"` and read it. Root unknown → current directory; monorepo → the app root (where `pubspec.yaml` / `ios/` / `android/` live).
2. **Question set A1** (one `AskUserQuestion` call, two questions):
   - *Platforms to check?* (multiSelect) — `iOS (App Store)`, `Android (Google Play)`, `Other / not a mobile app`. Mark the platforms the scanner detected "(detected, Recommended)". If only "Other" → explain the skill covers iOS/Android and stop.
   - *Scope?* (multiSelect) — `Full check (Recommended)`, `UGC & moderation`, `Login / account / demo account`, `Privacy & permissions`, `Payments & ads`, `Store metadata & console only`.
3. **Feature profile.** From the scan build the "what this app has" table: login methods (Google/Kakao/Naver/Apple/email/phone/guest), UGC surfaces, payments, ads, permissions, background, webview, push. Open files for ambiguous signals. Read the router/navigation (`lib/router.dart`, `app/_layout.tsx`, `AppDelegate`/`MainActivity`, main Navigator) to establish the **login wall** and the screen list.
4. **Judge.** Walk `checklists/common.md` sections that the profile activates + every item of `ios.md` / `android.md` for the chosen platforms. Follow each item's "Verify" steps; record `file:line`.
5. **Recurrence check.** Read `checklist_ids` from every `rejections/*.md` frontmatter; any overlap with FAIL/WARN items goes to the top of the report as "Recurrence risk" with the case link. Also skim `rejections/community-cases.md` for the same IDs and cite the closest community case in the item's detail.
6. **Write the JSON** (`templates/report.schema.json` documents the shape; `docs/sample-report.json` is a filled example) to `<root>/store-review/report-YYYY-MM-DD.json`. `lang` = the user's language code (`en`/`ko`/`ja`/`zh`).
7. **Question set A2** — *How do you want the report?* — `Open HTML report in browser (Recommended)`, `Show in chat`, `Both`.
   - HTML: `python3 "$SKILL/scripts/render_report.py" "<root>/store-review/report-YYYY-MM-DD.json" "<root>/store-review/report-YYYY-MM-DD.html" --open` (`--open` uses `open`/`xdg-open`; if that fails, print the path). In chat show only the one-line summary + FAIL list.
   - Chat: print the format in "Chat output" below, and also write `<root>/store-review/report-YYYY-MM-DD.md` from `templates/report.md`.
8. **Question set A3** — *Next?* (multiSelect) — `Fix the FAIL items now`, `Draft review notes (demo account, feature locations)`, `Plan the evidence recording`, `Nothing else`.

### Grades

- 🔴 **FAIL** — explicitly required by a guideline/policy and missing. Submitting = rejection.
- 🟠 **WARN** — often rejected but passable depending on implementation/explanation, or must be verified in the console.
- ⚪ **UNKNOWN** — not decidable from code; say how to verify.
- 🟢 **PASS** — evidence found.
- **N/A** — feature absent (with evidence).

## B. Rejection intake

1. **Parse**: platform, review date, app name, version (build), Submission ID / case number, review devices, guideline numbers + titles (may be several), requirement bullets, required evidence (recording, demo account), reply channel. Then match the reviewer's sentences against the **Reviewer phrasings index** at the end of `rejections/community-cases.md` — it maps verbatim fragments to checklist IDs and to cases with confirmed fixes. Quote the guideline text from `references/apple.md` / `references/google-play.md` in the analysis.
2. **Question set B1** (only if the project path is unknown): *Where is the project?* — `Current directory (Recommended)`, `Other → type the path`, `No project here — analysis only`.
3. **Save the case** from `templates/rejection-case.md` to `$SKILL/rejections/YYYY-MM-DD-<ios|android>-<guideline>-<app-slug>.md` (full original text; secrets → `<REDACTED>`). Add a row to `rejections/README.md`.
4. **Map** every requirement bullet to a checklist ID. Missing ID → create the item (ID = section abbreviation + 2-digit number, appended after existing ones) and, if the scanner can catch it, add a `sig` line to `scan.sh` (then `bash -n scripts/scan.sh`).
5. **Root cause** with file evidence (run A for the affected items). No project → mark the analysis "assumed" and continue; never block on it.
6. **Predict co-rejections** with the table below; warn about them so the resubmission isn't rejected for a *new* reason.
7. **Question set B2** — *What do you want now?* (multiSelect) — `Fix plan only (Recommended)`, `Implement the fixes now`, `Draft the reply to the reviewer`, `Update review notes`, `Evidence recording script`. Then, if a report is produced, question set A2 (HTML / chat / both).
8. Deliver: root cause, per-requirement fix plan (how, which files, effort), evidence plan (`templates/evidence-recording.md`), reply draft (`templates/reply.md`, English for Apple), review notes (`templates/review-notes.md`). After implementing, update the case's action table and `status`.

### Co-rejections (when one hits, check the others)

| Rejected for | Also verify |
|---|---|
| Apple 1.2 UGC / Play UGC | ACC-03 demo account (reviewer can't log in → rejected again), IOS-LOGIN-01 Sign in with Apple (social-only login), ACC-02 account deletion, META-03 age rating "users interact", KR-01, AND-CONSOLE-05 |
| Apple 4.8 Sign in with Apple | ACC-02, ACC-03, PRIV-01 |
| Apple 2.1 completeness / demo account | ACC-01 login wall, CONTENT-01, IOS-IPAD-01 (iPad crash/layout) |
| Apple 5.1.1 privacy | PRIV-01~04, PERM-01, ACC-02, IOS-PRIV-02 ATT |
| Apple 3.1.1 IAP | PAY-01~04, remove external payment links |
| Apple 2.5.4 background | IOS-BG-01, AND-PERM-05 |
| Play permissions | matching AND-PERM-*, AND-CONSOLE-06 declaration forms, AND-CONSOLE-02 Data safety |
| Play User Data | PRIV-01~04, AND-CONSOLE-01/02/08 |
| Play Photo & Video / FGS / any permission | AND-PERM-13 merged manifest, AND-CONSOLE-11 old builds in other tracks, AND-CONSOLE-06 declaration via Console UI |
| Apple 4.3 spam / 4.3(b) saturated category | CONTENT-07, META-02, META-05 (note the differentiator in review notes) |
| Apple 2.5.1 leftover framework | IOS-ENT-04 (Xcode capability **and** App ID) |
| Apple 2.1 "cannot log in / data not loading" (Korean apps) | CONTENT-09 IPv6, CONTENT-12 release parity, CONTENT-13 locale, ACC-05 Kakao 2-step, IOS-IPAD-02 PASS on iPad |
| Play Sign-in details / closed testing (Korea) | ACC-05, AND-CONSOLE-03, AND-TEST-01, AND-ACCOUNT-01 (등본 address match) |
| Play Deceptive Behavior / Misleading Claims / icon-title mismatch | META-02, META-06, AND-META-01, AND-CONSOLE-12 (government info), CONTENT-10 |
| Play Families | AND-CONSOLE-07 (neutral age screen, certified ad SDKs), ADS-02, PRIV-02, AND-REVIEW-01 |
| Apple 2.1(b) IAP "not found / not submitted / agreement" | PAY-05, PAY-04, PAY-06, IOS-META-07 (promoted images), META-07 |
| Apple 5.1.2 ATT | PRIV-05, PRIV-03, IOS-PRIV-04, PRIV-02 (labels) |
| Apple 5.1.1(ix) / 3.1.5 / 3.2.2 regulated | ACC-06, LAW-02, AND-ACCOUNT-02 |

## C. Submission info

1. **Question set C1**: *Platforms?* (multiSelect: iOS / Android) · *Login methods the app offers?* (multiSelect: Email+password, Sign in with Apple, Google, Kakao, Naver, Phone OTP, Guest, None) · *What must the notes explain?* (multiSelect: UGC safeguards, background mode reason, IAP/subscription, sensitive permissions, account deletion, foreground service).
2. Fill `templates/review-notes.md`: demo account IDs (passwords as placeholders), how to bypass verification (2FA off, fixed OTP, reviewer-only email login), where report/block/terms live, recording link, contact. Kakao/Google-only demo accounts frequently fail from foreign IPs / 2-step verification — recommend an **email/password reviewer account or Sign in with Apple** as well, and **pre-populate** the demo accounts with friends/chats/posts.

## Signal → item quick map

| scan.sh signal | Items |
|---|---|
| `ugc.*` > 0 | UGC-01~06, META-03, AND-UGC-01 |
| `mod.report/block/filter` = 0 with UGC | UGC-02/03/04 FAIL candidates |
| `auth.google/kakao/naver` > 0 and `auth.apple` = 0 | IOS-LOGIN-01 |
| `auth.login` > 0 and `account.delete` = 0 | ACC-02, AND-CONSOLE-08 |
| `auth.login` > 0 and `auth.guest` = 0 | ACC-01, ACC-03 |
| `legal.privacy` = 0 | PRIV-01 |
| `legal.terms` = 0 | UGC-01, PAY-02 |
| `ads.sdk` > 0 | PRIV-03, ADS-*, IOS-PRIV-02, AND-CONSOLE-04 |
| `pay.iap` > 0 | PAY-02~04, IOS-IAP-01 |
| `pay.external` > 0 | PAY-01, AND-PAY-01 |
| `bg.*` > 0 | BG-01/02, IOS-BG-01, AND-PERM-05 |
| `perm.screentime` > 0 | IOS-ENT-02, AND-PERM-07 |
| `perm.alarm` > 0 | AND-PERM-10 |
| `perm.*` > 0 without the matching UsageDescription | IOS-PLIST-01 |
| `PrivacyInfo.xcprivacy` = 0 | IOS-PRIV-03 |
| `ITSAppUsesNonExemptEncryption` missing | IOS-META-03 |
| Android restricted permissions | AND-PERM-01~11 |
| `targetSdk` < requirement | AND-SDK-01 |
| `placeholder / todo / test.keys` | CONTENT-01/02 |
| other-platform strings | CONTENT-04 |
| `TARGETED_DEVICE_FAMILY` 1,2 | IOS-IPAD-01 |
| app name/description matches a saturated category (timer, wallpaper, flashlight, sounds, fortune, dating) | CONTENT-07 (Apple 4.3(b)) |
| `ai.sdk` > 0 | AI-01 |
| `ugc.anonymous` > 0 | UGC-07, AND-CONSOLE-10 |
| `codepush` > 0 | CONTENT-10 |
| `force.update` > 0 | CONTENT-11 |
| `wakelock` > 0 | AND-QUALITY-02 |
| `perm.vpn` > 0 | AND-PERM-14, IOS-UI-02 |
| `record.activity` > 0 | CONTENT-08 |
| permission-injecting libraries in dependencies | AND-PERM-13 (merged-manifest audit) |
| leftover entitlements / framework refs (`perm.health`, `track.att`, `perm.screentime` without a feature) | IOS-ENT-04 |
| `carrier.auth` > 0 (PASS / 본인인증) | IOS-IPAD-02 |
| `dyn.dns` > 0 (DuckDNS, ngrok, iptime…) | CONTENT-09, CONTENT-12 |
| `auth.kakao` / `auth.naver` > 0 | ACC-05 (reviewer login playbook) + IOS-LOGIN-01 |
| `CFBundleDevelopmentRegion = $(DEVELOPMENT_LANGUAGE)` | CONTENT-13 |
| `CFBundleDisplayName` ≠ store name | META-06 |
| `sec.aws` / `sec.webview` / `sec.webauth` > 0 | AND-SEC-01 (Play security scanner: leaked credentials, intent hijacking, WebView XSS, WebView OAuth) |
| any Play resubmission after a rejection | AND-ENFORCE-01 (stop after the 2nd rejection), AND-CONSOLE-11 (old builds), AND-REVIEW-01 (Play-signed build, asset packs, offline) |
| `price.hardcoded` > 0 | PAY-06 (store-fetched price/trial text) |
| `donation` > 0 | PAY-01 (donations must use IAP) |
| `applepay` > 0 | IOS-IAP-03 (4.9 prominence) |
| `icloud.sync` > 0 with `pay.iap` | IOS-IAP-04 (4.10) |
| `emulator` > 0 | CONTENT-14 (4.7) |
| `pay.iap` > 0 (always) | PAY-05 (agreement, submission draft, product IDs, RevenueCat wiring) |
| `track.att` > 0 (always) | PRIV-05 (ATT reachable on a fresh device, label consistency), IOS-PRIV-04 (ITMS-91064) |
| any Apple resubmission | META-07 (reply vs resubmit, don't resubmit mid-dialogue, version reuse) |
| storefronts include Japan / China | JP-01 / CN-01 (`references/japan-china.md`) |
| `form.factor` > 0 (Auto / Wear / TV / XR opt-in or library-merged services) | AND-FORM-01 |
| `plist.default.purpose` > 0 | IOS-PLIST-05 (plugin default purpose strings) |
| `toss.miniapp` > 0 | KR-05 (Toss mini-app review) |
| `media.thirdparty` > 0 | LAW-03 (5.2.3 rights evidence) |
| `mac.entitlements` > 0 | IOS-ENT-05 (Mac sandbox entitlement scan) |
| app name contains an Apple trademark (Mac, iOS, Apple Watch…) | IOS-META-09 |
| plugin-heavy app / extension targets | IOS-ENT-06 (frameworks linked via plugins/extensions), IOS-BIN-01 (SDK signatures, beta toolchain) |
| production login can't be completed by a foreign reviewer (Kakao KR phone, SIWA + SMS) | ACC-07 documented reviewer path (never hidden behaviour) |

## Learning rules (keeping the KB alive)

- New rejection → case file + `rejections/README.md` row + link from the related checklist item's `Cases:` line.
- Unknown reason → new checklist item in the same shape (Basis / Applies / Verify / Signals / Fix / Evidence / Cases). Add to English first, translations when possible.
- Scanner-detectable → add a `sig` or auto-hint to `scan.sh`, then `bash -n`.
- Resolved → frontmatter `status: resolved` and record what actually got it approved.
- Show `git -C "$SKILL" status` afterwards; commit/push only when the user asks.

## Chat output (mode A)

```
## Review pre-check — <app> (<platforms>) <date>
🔴 FAIL n · 🟠 WARN n · ⚪ UNKNOWN n · 🟢 PASS n   (recurrence: <case> or none)

### 🔴 Must fix before submitting
1. UGC-03 No report mechanism — Apple 1.2 / Play UGC. Add Report to chat & profile menus (`lib/chat/room.dart`)
2. IOS-LOGIN-01 Social login only — Apple 4.8. Add Sign in with Apple (`lib/auth/login_screen.dart`)

### 🟠 Verify / strengthen
…

Report: store-review/report-2026-08-28.html (or .md)
Next: (1) fix 2 FAILs (2) create + seed demo accounts (3) record evidence
```
