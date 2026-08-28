<p align="center">
  <img src="docs/report-sample.png" width="860" alt="store-review-check HTML report">
</p>

<h1 align="center">store-review-check</h1>

<p align="center"><b>Catch App Store &amp; Google Play rejections <i>before</i> you submit.</b><br>
An <a href="https://agentskills.io">Agent Skill</a> for Claude Code, Codex CLI and any SKILL.md-compatible agent.</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.ko.md">한국어</a> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <img alt="License MIT" src="https://img.shields.io/badge/license-MIT-blue.svg">
  <img alt="Agent Skills" src="https://img.shields.io/badge/Agent%20Skills-SKILL.md-8A2BE2">
  <img alt="Claude Code" src="https://img.shields.io/badge/Claude%20Code-supported-D97757">
  <img alt="Codex CLI" src="https://img.shields.io/badge/Codex%20CLI-supported-000000">
  <img alt="iOS Android" src="https://img.shields.io/badge/iOS-App%20Store-lightgrey"> <img alt="Android" src="https://img.shields.io/badge/Android-Google%20Play-3DDC84">
</p>

---

## Why

This is a real rejection we got for a "focus timer with friends" app:

> **Guideline 1.2 – Safety – User-Generated Content**
> We found in our review that the app includes user-generated content but does not have all the required precautions… *Require that users agree to terms (EULA)… A method for filtering objectionable content… A mechanism for users to flag objectionable content… A mechanism for users to block abusive users…* Please provide a pre-populated demo account (Google or Kakao)… reply with a screen recording captured on a physical device…

A friends list with nicknames was enough to make it a "UGC app". Every one of those requirements is knowable from the code **before** the 24-hour review round-trip. That is what this skill does — and when a rejection still lands, it turns it into a case the next check will remember.

Bonus we only learned from the official text: since June 2026 Apple lists **"simple timers"** among saturated categories (4.3(b)) — a timer app now needs a "meaningfully different or improved experience" spelled out in its listing and review notes. The checklist flags that too.

## What it does

| Mode | You say | You get |
|---|---|---|
| **Pre-check** | `check my app for review` / `/store-review-check ~/dev/app` | Scan → feature profile → every checklist item graded 🔴 FAIL / 🟠 WARN / ⚪ UNKNOWN / 🟢 PASS with `file:line` evidence, fix and required proof → **HTML report (opens in browser) or chat** → console checklist → review-notes draft |
| **Rejection intake** | paste the rejection email | Parsed, saved as a case, mapped to checklist IDs, **co-rejection prediction** (e.g. Google/Kakao-only login → Sign in with Apple 4.8), fix plan, evidence-recording script, reviewer reply (English), review notes |
| **Submission info** | `write the review notes` | App Store Connect *App Review Information* notes and Play Console *App access* text: demo accounts, verification bypass, where report/block/terms live |

Everything the skill needs from you is asked as **multiple-choice questions** (multi-select where it makes sense): platforms, scope, HTML vs chat, what to do next. No open-ended back-and-forth.

## Quick start

**Claude Code**
```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.claude/skills/store-review-check
```
**Codex CLI**
```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.codex/skills/store-review-check
```
**Other Agent-Skills runtimes** — clone into that runtime's skills directory (the folder name must stay `store-review-check`).

Restart the agent, then:

```
> check my app for review          # pre-check (current directory)
> /store-review-check ~/dev/app    # Claude Code, explicit path
> $store-review-check               # Codex CLI
> we got rejected: <paste email>   # rejection intake
> write the App Review notes        # submission info
```

Standalone scanner (no agent needed):
```bash
bash ~/.claude/skills/store-review-check/scripts/scan.sh ~/dev/app
```
Understands Flutter, React Native, Expo, iOS and Android native. Output is *signals*; the agent opens the files before grading.

## Example

```
## Review pre-check — Focus Together (iOS, Android) 2026-08-28
🔴 FAIL 9 · 🟠 WARN 3 · ⚪ UNKNOWN 1 · 🟢 PASS 1   (recurrence: 2026-08-27-ios-1.2-ugc)

### 🔴 Must fix before submitting
1. UGC-01 No EULA consent before login — Apple 1.2 / Play UGC (lib/auth/login_screen.dart:41)
2. UGC-03 No report mechanism — Apple 1.2 / Play UGC
3. UGC-04 No block mechanism — Apple 1.2 / Play UGC
4. IOS-LOGIN-01 Google/Kakao login without Sign in with Apple — Apple 4.8
5. ACC-02 No in-app account deletion — Apple 5.1.1(v) / Play
6. ACC-03 No reviewer demo account that bypasses 2-step verification — Apple 2.1 / Play App access
7. AND-PERM-05 FOREGROUND_SERVICE without foregroundServiceType — Android 14
8. IOS-PRIV-03 No PrivacyInfo.xcprivacy — ITMS-91053
…
Report: store-review/report-2026-08-28.html
```

## What it checks

| Area | Examples | Guidelines |
|---|---|---|
| **UGC & moderation** | EULA with zero-tolerance clause, content filter, report, block (instant removal + developer notice), 24-hour action, physical-device recording, pre-populated demo account | Apple 1.2 · Play UGC |
| **Account & login** | Login wall, in-app account deletion (+ web link for Play), demo account that works from a foreign IP, Sign in with Apple when social login exists, Kakao/Google console setup | Apple 5.1.1(iv)(v), 4.8, 2.1 · Play Account deletion, App access |
| **Privacy** | Privacy policy in app + store, App Privacy / Data safety labels vs SDKs, ATT / AD_ID, prominent disclosure, privacy manifest (Required Reason API) | Apple 5.1.1, 5.1.2 · Play User Data |
| **Permissions** | Purpose strings per used API, graceful denial, unused permissions, Android restricted permissions & declaration forms (photo/video, FGS types, exact alarm, accessibility, QUERY_ALL_PACKAGES…) | Apple 5.1.1(ii) · Play Permissions |
| **Payments & ads** | Digital goods via IAP / Play Billing, subscription disclosure + terms links, restore purchases, IAP attached to the submission, test ad IDs, intrusive ads | Apple 3.1.1, 3.1.2 · Play Payments, Ads |
| **Background & timers** | Silent-audio timer keepers (2.5.4), FGS types + Play declaration, local notifications instead | Apple 2.5.4 · Android 14 FGS |
| **Completeness & metadata** | Placeholders, crashes on iPad, other-platform mentions, screenshots, age rating "users interact", title rules, support URL | Apple 2.1, 2.3.x, 2.4.1, 4.0 · Play Metadata |
| **Platform requirements** | targetSdk deadline, 16 KB pages, AAB/64-bit, export compliance, minimum Xcode, closed testing for new Play accounts, FamilyControls entitlement | — |
| **Korea** | Under-14 parental consent, mandatory policy contents, IARC/GRAC | 개인정보보호법 |

**118 items**, each with *Basis / Applies when / Verify / Scanner signals / Fix / Evidence / Cases*. Every item was checked against the official guideline text on 2026-08-28 (App Store Review Guidelines of 2026-06-08, Play Policy Center) — see [`references/`](references/) for the verbatim quotes, URLs and the 2025–2026 change log.

## Real-world rejection cases

[`rejections/community-cases.md`](rejections/community-cases.md) collects **100+ real rejection stories** (2022–2026) from developer forums, Reddit, Apple Developer Forums, Play developer communities and blogs (English, Korean, Japanese, Chinese sources) with the guideline quoted, root cause, the fix that got approved and the source link. Each case is mapped to checklist IDs, so a pre-check can say *"this exact thing got someone rejected — here's what fixed it"*.

## Teach it your rejections

1. Paste the email → the skill saves `rejections/YYYY-MM-DD-<platform>-<guideline>-<app>.md` with `checklist_ids`.
2. A reason the checklist doesn't know → it adds an item and, if detectable, a scanner signal.
3. Next pre-check → any overlap is flagged at the top as **Recurrence risk**.

## Repository layout

```
SKILL.md                     the skill (rules, question flows, mode workflows, signal→item map)
scripts/scan.sh              project signal scanner (bash 3.2 / BSD grep compatible)
scripts/render_report.py     JSON → standalone HTML report (filters, dark mode, checklist state, copy notes)
checklists/common.md         feature-conditional items
checklists/ios.md            App Store items
checklists/android.md        Google Play items
checklists/ko/               translations (English is canonical)
references/                  official sources the checklists were verified against
templates/                   report schema, case, review notes, reviewer reply, UGC EULA clause, recording script
rejections/                  case KB — your cases + community-cases.md
docs/                        sample report JSON + screenshot
```

## Compatibility

- **Claude Code** — asks with `AskUserQuestion` (multi-select), renders and opens the HTML report.
- **Codex CLI** — same SKILL.md; questions become numbered options in chat.
- Any runtime following the [Agent Skills spec](https://agentskills.io/specification) (`name` + `description` frontmatter).

## Contributing

PRs welcome — especially **real rejection cases** (with the reviewer's wording and the fix) and **guideline updates**. Add a row to `rejections/community-cases.md` and link it from the checklist item's `Cases:` line.

## Disclaimer

Guidelines change. Date-sensitive values (targetSdk deadlines, minimum Xcode, closed-testing numbers) carry an "as of" date; verify on the official page before submitting. This tool reduces rejections; it does not guarantee approval.

## License

MIT
