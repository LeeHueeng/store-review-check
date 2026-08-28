# Common checklist — feature-conditional items

Items that apply depending on what the app does. Each cites both Apple and Google Play.
Shape of every item: **Basis** (guideline) → **Applies** (when) → **Verify** (what to look at) → **Signals** (scan.sh) → **Fix** → **Evidence** → **Cases**.
Grades are defined in SKILL.md. Written as of 2026-08-28 against the App Store Review Guidelines last updated 2026-06-08 and the Play Policy Center as of 2026-08. Korean translation: `ko/common.md`. Official sources with quotes: `../references/apple.md`, `../references/google-play.md`.

---

## UGC — user-generated content

> Apple **1.2 Safety – User-Generated Content** / Google Play **User Generated Content policy**
>
> **Applies**: if *anything* a user types or uploads is visible to another user. Not just chat, comments and posts — **nicknames, profile photos, status messages, one-line bios, friend invites, group/room names, shared timer labels** are UGC. Any "with friends" social feature triggers all of this (case 2026-08-27).
> "Friend requests must be accepted" is not a substitute for report + block.
> Since 2026-02 Apple applies 1.2 explicitly to **random or anonymous chat**; since 2026-06 the guideline adds: "It is your responsibility to remove content that violates this guideline… If we find such content, we will ask you to remove it, and provide a plan to improve your compliance… Egregious or repeated behavior is grounds for immediate removal." Play additionally requires **Child Safety Standards self-certification** for Social/Dating apps (2025-01-22) and anonymous/random chat apps (2026-07-15) — see UGC-07 / AND-CONSOLE-10.

### UGC-01 Terms (EULA) consent with a zero-tolerance clause
- Basis: Apple 1.2 (rejection wording: "Require that users agree to terms (EULA) and these terms must make it clear that there is no tolerance for objectionable content or abusive users") / Play UGC ("require users to accept the app's terms of use and/or user policy before users can create or upload UGC"; "define objectionable content and behaviors … and prohibit them")
- Verify:
  1. A consent UI (required checkbox or "Agree and continue") **before or right after sign-up/login, before any UGC can be created**. Social-login-only apps still need a consent screen right after the first login.
  2. The terms contain (a) a definition of prohibited content, (b) an explicit **no-tolerance** sentence, (c) the right to remove content, block, suspend and eject users, (d) action within 24 hours.
  3. The terms can be re-opened from Settings.
- Signals: `legal.terms`, `auth.login`
- Fix: required consent on the sign-up/login screen → cannot proceed unchecked. Insert the clause from `templates/eula-ugc.md`. Store the consent timestamp (re-consent when the terms version changes).
- Evidence: the first scene of the screen recording must be the consent screen.
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-02 Objectionable-content filter
- Basis: Apple 1.2 "A method for filtering objectionable content" / Play UGC "robust, effective and ongoing UGC moderation"
- Applies: any text input (nickname, message, bio…) or image upload
- Verify: text — a profanity/banned-word filter runs at input time or at server write time (client list, server function or external API all count). Images — at minimum a report → human review process; ideally automatic detection (Cloud Vision SafeSearch, Rekognition…).
- Signals: `mod.filter`
- Fix: minimum = Korean + English profanity list applied before nickname/message writes with a user-facing message. Images: SafeSearch on upload or "visible after review".
- Evidence: optional but strong — recording of a blocked word → warning.

### UGC-03 Report content and users
- Basis: Apple 1.2 "A mechanism for users to flag objectionable content" / Play UGC "an in-app system for reporting objectionable UGC and users"
- Verify: every UGC surface (chat message, post, comment, profile, friends list) can be reported within **two taps**. Reason picker + confirmation. Reports actually reach the developer (DB collection, email, Slack…).
- Signals: `mod.report` (0 → FAIL candidate; >0 → open the file: crash reporting is a false positive)
- Fix: long-press / ⋯ menu → Report → reason (spam, abuse, sexual, other) → save (`reports`: reporterId, targetUserId, contentId, reason, createdAt) → notify the developer.
- Evidence: the full report flow in the recording.
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)
- Cases: [community — 1.2 / Play UGC](../rejections/community-cases.md#12-user-generated-content) (report **users** as well as content; Discourse case needed both)

### UGC-04 Block users — instant removal + developer notification
- Basis: Apple 1.2 "A mechanism for users to block abusive users (blocking should also notify the developer of the inappropriate content and should remove it from the user's feed instantly)" / Play UGC "an in-app system for blocking UGC and users"
- Verify: block is available from profile / chat / friends list. On block, that user's content (messages, posts, friend entry, invites) disappears **without a refresh**. A blocked-users list in Settings with unblock. The block event is recorded/notified to the developer.
- Signals: `mod.block`, `mod.hide`
- Fix: persist `blockedUsers` → filter every UGC query/render (client immediately + server rules) → auto-write a `reports` entry with reason "blocked" → Settings > Blocked users.
- Evidence: recording of block → content vanishes instantly.
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md)

### UGC-05 24-hour action process + published contact
- Basis: Apple 1.2 rejection wording "act on objectionable content reports within 24 hours by removing the content and ejecting the user" + guideline text "Published contact information so users can easily reach you" and (2026-06) "It is your responsibility to remove content that violates this guideline… provide a plan to improve your compliance" / Play UGC "taking action against UGC or users where appropriate"; listed violation: "continually failing to address user complaints about objectionable material"
- Verify: an **operational** process exists to see and act on reports within 24 h (notification channel; an admin tool or console procedure to delete content and suspend accounts). A contact email in the terms, in the app and on the support URL (Apple 1.5).
- Signals: `mod.contact`
- Fix: email/Slack alert on report + a documented delete/suspend runbook (even a Firebase console procedure). Contact in Settings and on the store support URL. Keep a short written moderation plan — Apple may ask for one.
- Evidence: state in the reply: "we review reports within 24 hours and remove content / suspend accounts".

### UGC-06 Evidence — physical-device recording + pre-populated demo account
- Basis: rejection wording ("screen recording captured on a physical device", "pre-populated demo account")
- Verify: a recording exists (simulator recordings are refused). Logging in with the demo account shows friends/chats/posts already present. Reviewers can log in without 2-step verification.
- Fix: shoot per `templates/evidence-recording.md`. Create two demo accounts (A, B), make them friends, seed a few messages. See ACC-03.
- Evidence: recording link in the review notes; file attached to the reply.

### UGC-07 Minors, age gating and child-safety obligations
- Basis: Apple 1.2.1(a) / 4.7.5 (creator and mini-app content above the app's age rating needs an age-restriction mechanism based on verified or declared age); Apple 5.1.4 (kids apps: no third-party ads/analytics); Play **Child Safety Standards** (Social & Dating since 2025-01-22, anonymous/random chat since 2026-07-15): published CSAE standards at a public URL, in-app feedback mechanism, CSAM handling, child-safety point of contact, self-certification in Play Console; Play **Age-Restricted Content**: dating, random/anonymous chat and real-money gambling apps "are required to use the Play Console functionality and tools to block minors" (2025-10-30)
- Applies: social, dating, chat (especially anonymous/random), creator/UGC feeds, apps rated 18+
- Verify: category in the store; age screen (neutral age gate) or Declared Age Range API usage; a public child-safety standards page and a named contact (Play); Play Console self-certification done.
- Signals: `ugc.chat`, `ugc.anonymous`, category
- Fix: neutral age screen at sign-up; publish a child-safety standards page (can be a section of the terms); Play Console App content > Child safety standards; Apple: Age Suitability URL, Declared Age Range API where regional laws apply (see LAW-01).
- Evidence: URL of the standards page; console screenshot.
- Apple 3rd-pass Kids rule: Kids Category builds must not *reference* `ASIdentifierManager` or ATT — Branch, Firebase Analytics (GoogleAppMeasurement) and React Native core are flagged; Apple wants the code removed, not toggled off; the parental gate must be non-disableable before every outbound link and purchase (share sheet included). [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)
- International 3rd-pass rule: **prohibited app classes are not fixable by moderation** — appearance-rating / "hot-or-not", random/anonymous chat and Chatroulette-style mechanics are rejected under 1.2 regardless of safeguards (removable without notice since 2026-02); Play tolerates them with rating + moderation. Decide before building; EU alternative marketplaces / PWA are the fallback, not re-skins. [cases](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

---

## ACC — account & login

### ACC-01 Login wall
- Basis: Apple 5.1.1(iv) "don't require personal information unless directly relevant to core functionality" / 5.1.1(v) "if your app doesn't include significant account-based features, let people use it without a login" / Play: no explicit rule (but App access instructions are mandatory)
- Applies: the first screen is a login screen
- Verify: is there core functionality usable without login (e.g. a solo timer)? Login gating only social features passes. If everything is behind login, the reason must be core (sync, friends).
- Signals: `auth.login` > 0 and `auth.guest` = 0
- Fix: a "continue without login" path, or explain in the review notes why login is essential + demo account.
- Evidence: review notes.

### ACC-02 In-app account deletion
- Basis: Apple 5.1.1(v) "If your app supports account creation, you must also offer account deletion within the app… The app must also include a mechanism to revoke social network credentials and disable data access between the app and social network from within the app. An app may not store credentials or tokens to social networks off of the device" (mandatory since 2022-06-30; support page: "only offering to temporarily deactivate or disable an account is insufficient"; "should not require people to make a phone call, send an email, or go through other support flows") / Play **Account deletion** requirement: "it must also allow users to request for their account to be deleted" in-app **and** "a web link resource where users can request app account deletion" entered in Data safety (enforced 2024-05-31); "Temporary account deactivation, disabling, or 'freezing' the app account does not qualify"
- Applies: sign-up or social login exists
- Verify: Settings > Delete account is easy to find and really deletes server data and the auth account (not logout, not deactivate). Social links are severed from within the app (Kakao unlink, Google revoke, Apple `revoke tokens` REST API). A public web page to request deletion exists and is registered in Play Data safety. A direct in-app link is acceptable if the final step happens on the web.
- Signals: `account.delete`
- Fix: Settings > Delete account → confirm → server function deletes user doc, storage, auth → unlink providers → back to login. Web page (Notion/static) "request account deletion" → Play Console Data safety.
- Evidence: optional recording; Play Data safety URL.
- From cases: the Play deletion URL is checked by a non-browser client — plain HTTPS, no client-specific TLS; Kakao users must be unlinked via the Kakao Unlink API; a generic settings page is not accepted, link straight to the deletion step; reviewers who can't find the entry reject — mention its path in the notes or attach a video. [cases](../rejections/community-cases.md#account-deletion)
- Korean cases: after deletion, **re-signing up with the same Apple/Google identity must work** (write the server user doc before redirecting; clear phone-verification / single-device locks); a Play deletion page must name the app and developer and list the steps — "contact support" or login-gated pages fail. [cases](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- Apple 2nd-pass case: an app with **no accounts** was rejected under 5.1.1(v) because a local profile/name step looked like sign-up — state "no accounts, local profile only, delete path: …" in the standing review notes. [case](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- Korean/Japanese 3rd-pass cases: deletion must be reachable and visible from the state a **fresh reviewer account lands in** (pending-approval screens, iPad layout where the button sat below the fold, grey low-contrast text). [cases](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### ACC-03 Reviewer demo account (the social-login-only trap)
- Basis: Apple 2.1(a) "include demo account info (and turn on your back-end service!) if your app includes a login. If you are unable to provide a demo account due to legal or security obligations, you may include a built-in demo mode in lieu of a demo account with prior approval by Apple"; ASC help: the demo account "must not expire" / Play **Sign-in details** (formerly App access): "Your sign-in details must be accessible at all times, reusable, and valid regardless of user location… If your app typically requires a 2-Step verification code or One-time password, make sure to provide reusable login credentials that can bypass these requirements… must be provided in English… If the provided password expires… the app may be rejected"
- Applies: any login
- Verify: the review notes carry an account. That account logs in **from the reviewer's location (US etc.) without 2-step verification, device confirmation or foreign-login blocks**, and never expires. Kakao and Google accounts frequently fail here.
- Signals: `auth.google/kakao/naver` > 0 and `auth.email` = 0 and `auth.apple` = 0
- Fix (preferred order): (1) add Sign in with Apple (solves IOS-LOGIN-01 too; reviewers use their own Apple ID — consider auto-seeding demo data for empty accounts); (2) enable email/password in Firebase etc. and create a **reviewer-only account** (exposing the button is safer than a hidden entry); (3) if you do hand over Kakao/Google demo accounts: 2-step off, recovery email set, be ready to approve login alerts. Provide a second account so reviewers can see both sides of chats/friend requests.
- Evidence: review notes via `templates/review-notes.md` (Apple Notes ≤ 4000 bytes; Play up to five sets of instructions + "Any other instructions" for OTP/MFA).
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — "Please provide a pre-populated demo account (Google or Kakao)"; see also community cases tagged ACC-03
- [community cases](../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)
- Korean cases: the demo account must be loginable repeatedly on new devices — no stale push-token/device binding, no single-use phone verification, fixed OTP; GitHub/Google demo logins need 2FA off **and** no new-device challenge; Play refuses Hangul IDs, admin accounts and demo videos in place of credentials; QR/hardware-gated apps must supply long-lived codes. A Korean-language phone call with App Review resolved one stuck case. [cases](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- Japanese case: Google's "Verify it's you" on a demo Google account was solved without code by enabling 2FA and listing **backup codes** in the reply. [case](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- Apple 3rd-pass cases: the backend must be awake — free-tier backends (Supabase pauses after 7 idle days) and expired review API keys produce 2.1(a) "error during login"; add a keep-alive and a review-period key with a budget cap. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### ACC-04 Social-login console configuration
- Basis: not a guideline, but a broken login during review becomes a 2.1 rejection
- Verify: Kakao — iOS bundle ID / Android key hash (the **release** key!) registered, consent items (nickname, profile, email) configured, business app if email is required. Google — OAuth consent screen in "production", iOS client ID and Android SHA-1 (upload key **and** Play App Signing key) registered. Firebase Auth providers enabled.
- Fix: check the above. Copy the Play App Signing SHA-1 from Play Console > App integrity.
- Korean cases: with Play App Signing, register the **legacy** app-signing key hash as well as the upload key hash (Play Console > App integrity, filter "legacy") — a Flutter team's Kakao login only worked after that.

### ACC-05 Kakao / Naver login review playbook (Korea)
- Basis: Kakao DevTalk staff answers + repeated Korean cases: reviewer devices trigger Kakao's 2-step verification (unknown device / overseas IP) even with 2FA and overseas-login block turned off; cancelling the KakaoTalk app-switch shows an "install KakaoTalk" page that reviewers screenshot as a bug; Play rejects Kakao/Naver/Google-only logins outright in Sign-in details
- Applies: any Kakao / Naver / LINE login
- Verify: the review notes include (a) a Kakao account **not linked to KakaoTalk** (non-Kakao email) or an email inbox the reviewer can open to read the 8-digit code, (b) a sentence telling reviewers to log in via the web/account flow (or delete KakaoTalk / clear Safari website data) if the "install KakaoTalk" page appears, (c) an ID/password or Sign in with Apple path as well.
- Signals: `auth.kakao`, `auth.naver`
- Fix: create the reviewer Kakao account without KakaoTalk; test from a foreign IP; add SIWA (IOS-LOGIN-01) and an email/password reviewer login (ACC-03).
- Cases: [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28) — DevTalk 135699 / 135723 / 139785
- 3rd-pass detail: Kakao accounts need a Korean phone number, and Sign in with Apple always creates a *new* user that then hits SMS verification — hence teams add a documented reviewer login + fixed OTP (ACC-07). [cases](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### ACC-06 Organization enrollment for regulated or sensitive-data apps (5.1.1(ix))
- Basis: "The account that submits the app must be enrolled in the Apple Developer Program as an organization, and not as an individual" — health/body data, insurance, loans, gambling, crypto exchanges; documentation from an individual cannot substitute (Apple 5.1.1(ix)); Play: "Some types of apps can only be distributed by organizations" (AND-ACCOUNT-02)
- Applies: apps in highly regulated fields or handling health/financial data
- Verify: the submitting Apple developer account is an organization (D-U-N-S); Play account type matches.
- Fix: enroll as an organization before submitting; individuals must remove the regulated feature.
- Cases: [Apple 2nd pass](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### ACC-07 Review-mode backend: documented reviewer path, not hidden behaviour
- Basis: Korean teams whose only logins are Kakao (needs a KR phone number) or Sign in with Apple (always creates a new user → SMS verification) built a **reviewer-only path**: an email/password or hidden entry (logo long-press) login with a fixed bypass OTP, and server-side "review mode" accounts pre-seeded with fake friends/posts so report/block can be tested. This is acceptable only when it is **declared in the review notes** and changes nothing else — undocumented review detection is Apple 2.3.1 / Play Deceptive Behavior (CONTENT-10)
- Applies: apps whose production logins can't be completed from a foreign reviewer device
- Verify: the reviewer path is described step-by-step in App Review Information / Play Sign-in details (entry gesture, credentials, fixed OTP); the reviewer account sees the same features as a normal user; seeded data has no "test/테스트/준비중" strings (CONTENT-02); the path stays valid after launch (Google re-tests).
- Fix: implement as a normal, documented login option; never key behaviour on reviewer IP/device.
- Cases: [Korean/Japanese 3rd pass](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)
- International 3rd-pass detail: the review environment **cannot receive SMS, calls or push and denies push permission on purpose**; e-mail OTP with test@test.com-style addresses is treated as a placeholder — ship a reviewer bypass code or a pre-verified demo account, never depend on push. [cases](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

---

## PRIV — privacy

### PRIV-01 Privacy policy — in app and in the store listing
- Basis: Apple 5.1.1(i) "All apps must include a link to their privacy policy in the App Store Connect metadata field and within the app in an easily accessible manner" / Play **User Data**: linked in Play Console **and** accessible within the app; must include "Developer information and a privacy point of contact", the types of personal data accessed/collected/used/shared, "Secure data handling procedures", retention/deletion policy, be clearly labeled as a privacy policy, and "The entity named in the app's Google Play store listing must appear in the privacy policy or the app must be named in the privacy policy"
- Verify: a link in Settings / sign-up that actually opens (no 404). Content covers the items above, third parties (Firebase, ad SDKs, AI providers…), deletion, contact, and names the developer entity. The URL field is filled in ASC and Play Console. Apple's App Review page also lists "Broken links… a link to your privacy policy is required for all apps" among top rejection reasons.
- Signals: `legal.privacy`, URL candidates
- Fix: publish the policy (Notion/static page) → link in Settings + sign-up → register the URL in both consoles.
- Evidence: console screenshots.
- Hosting defects that got apps rejected on Play: GitHub Markdown, Blogspot, PDF, JavaScript-only pages, editable blog posts, private/geofenced URLs. Host a plain, public, fixed HTML page on your own domain. [cases](../rejections/community-cases.md#user-data-privacy-policy-data-safety-prominent-disclosure)
- International 3rd-pass cases: the policy must name each **framework by name** ("Health Connect" not only "Apple Health"; Firebase/AdMob identifiers) with data types, purpose, sharing, retention — omissions were the rejection cause. [cases](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

### PRIV-02 Privacy labels match reality (App Privacy / Data safety)
- Basis: Apple App Privacy Details / Play Data safety — mismatch with actual collection is a rejection / policy violation
- Verify: derive collection from the SDK list: Firebase Auth (email, name, ID), Analytics (usage data, device ID), Crashlytics (diagnostics), AdMob (advertising ID, coarse location), Kakao (nickname, profile, email). Compare with the console declarations.
- Signals: `SDK / dependencies` section
- Fix: update the console declarations from the SDK list. For Firebase use the per-SDK table in Firebase's privacy docs.
- Play 2nd-pass cases: "Invalid Data safety form" is usually an SDK you didn't think of — play-services-ads (phone number), analytics/Adjust/Amplitude/AppLovin/Segment (Device or other IDs), an OSM login (email), yandex ads in a kids app. Declare what the SDK collects (vendors publish tables) or remove the SDK; update the form on every SDK bump. [cases](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### PRIV-03 Tracking / advertising-ID consent
- Basis: Apple 5.1.2(i) "You must receive explicit permission from users via the App Tracking Transparency APIs to track their activity… Your app may not require users to enable system functionalities (e.g. push notifications, location services, tracking) in order to access functionality, content, use the app, or receive monetary or other compensation"; fingerprinting is prohibited ("you may not derive data from a device for the purpose of uniquely identifying it") / Play **Ads**: "The Android advertising identifier (AAID) must only be used for advertising and user analytics"; **Advertising ID**: apps targeting Android 13+ must declare `com.google.android.gms.permission.AD_ID`; declare "advertising identifier" under Device or other IDs in Data safety; Android ID is no longer treated as a persistent identifier (2025-04)
- Applies: ad SDKs, attribution (AppsFlyer/Adjust), analytics used for advertising
- Verify: iOS — ATT request code + `NSUserTrackingUsageDescription` + "Tracking" in App Privacy; an SDK that combines data across apps counts as tracking "even if you don't use the SDK for these purposes". No feature or reward gated on accepting. Android — AD_ID in the manifest (ad SDKs merge it), Data safety advertising ID, respect opt-out/reset.
- Signals: `ads.sdk`, `track.att`, `track.adid`
- Fix: show the ATT prompt **before** initializing ads (after onboarding). App must work when denied. IDFV for same-vendor analytics doesn't need ATT.
- Evidence: none (code).
- Korean cases: ATT must be the **first** system prompt and shown at launch (not after sign-up, not 4th in a chain); Flutter needs a ~1 s delay before requesting; unused purpose keys left in the plist get flagged together with it.

### PRIV-04 Prominent disclosure & data minimization
- Basis: Apple 5.1.1(iii) "Where possible, use the out-of-process picker or a share sheet rather than requesting full access to protected resources like Photos or Contacts" / Play **Prominent disclosure and consent** — required when access "may not be within the reasonable expectation of the user" (location for ads, contacts upload, background collection): "Must be within the app itself… displayed in the normal usage of the app and not require the user to navigate into a menu… Must describe the data being accessed or collected… Must explain how the data will be used and/or shared"; consent "Must require affirmative user action (for example, tap to accept, tick a check-box)", "Must not interpret navigation away from the disclosure as consent", "Must not use auto-dismissing or expiring messages", and must come before the runtime permission
- Verify: location used for ads/analytics? contacts uploaded? background collection? → an in-app disclosure screen in Google's format: **"[This app] collects/transmits/syncs/stores [type of data] to enable ['feature'], [scenario]."**
- Signals: `perm.*`, `ads.sdk`
- Fix: a dialog immediately before the permission request with an explicit Accept action; prefer pickers (Photo Picker, contact picker, share sheet) over broad permissions.
- Play 3rd-pass wording — "Requests for in-app user consent and runtime permission are not immediately preceded by an in-app disclosure"; "A toggle button will not meet the threshold for explicit consent… Apps must have two buttons clearly displaying consent options". [cases](../rejections/community-cases.md#google-play--3rd-pass-2026-08-28-thin-areas--child-safety-declarations-health-connect-form-factors-enforcement)

### PRIV-05 ATT prompt must be reachable on a fresh review device
- Basis: 2026 rejections "We were unable to locate the App Tracking Transparency permission request when reviewed on iOS/iPadOS" for apps whose ATT call existed but never fired: requested before the app was active (`undetermined` returned silently, never retried), tied to an ad banner that never mounted, gated on ad inventory (AdMob serves nothing to unpublished apps) or on deep progress (6 game-overs), shown 4th in a permission chain, or 24 h after install
- Applies: any app that links ATT (ad/analytics SDKs do)
- Verify: request when `applicationState == .active` (SwiftUI: `scenePhase`, Flutter/RN: after first frame + lifecycle active), retry while `notDetermined`, request **before** initializing ad SDKs, no dependency on ad inventory or progress, a manual entry in Settings, localized `NSUserTrackingUsageDescription`, and a screen recording + location in the review notes. If ATT is in the binary, App Privacy must declare tracking (ASC blocks otherwise).
- Signals: `track.att`, `ads.sdk`
- Fix: move the request to the first active foreground after onboarding.
- Cases: [Japanese sources](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28), [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- Apple 2nd-pass cases: the App Privacy "Used to Track You" label, `NSUserTrackingUsageDescription` and bundled SDK privacy manifests (Meta, TikTok, ad SDKs) must all agree with whether ATT is actually requested — "App Privacy information… indicates tracking… but the app never shows an ATT prompt" and the reverse ("the app still does not use App Tracking Transparency"). [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- Korean/Japanese 3rd-pass cases (iPadOS 26, 4 independent apps): never persist your own "already asked" flag (Keychain survives reinstall — use the system `notDetermined`), request after the window is active and within the first screen, never gate behind a deep trigger; attach a ~20-second fresh-install recording to the reply. [cases](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)
- Apple 3rd-pass detail: `requestTrackingAuthorization` resolves silently as `notDetermined` when the app isn't active **or another system sheet (Game Center login…) is on top**; request after active, before ads init, retry until a real answer; iPadOS 26 review devices are slower than dev phones. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### AI-01 AI features (third-party AI sharing, AI-generated content)
- Basis: Apple 5.1.2(i) (2025-11) "You must clearly disclose where personal data will be shared with third parties, including with third-party AI, and obtain explicit permission before doing so" / Play **AI-Generated Content**: "Apps that generate content using AI must contain in-app user reporting or flagging features that allow users to report or flag offensive content to developers without needing to exit the app"; Play User Data requirements "apply to third-party AI integrations" (2026-07)
- Applies: any call to OpenAI/Gemini/Claude/etc. with user data; AI chat, summaries, image generation
- Verify: a disclosure (privacy policy + in-app, before the first AI call) that user content is sent to <provider>; an explicit permission step; a report/flag control on AI output; AI output subject to the same UGC filter/report rules.
- Signals: `ai.sdk`
- Fix: consent screen before first AI use; "Report this response" on AI output; list the AI provider in the privacy policy and Data safety (shared data).
- Apple 2nd-pass cases (2025-11 rule): a consent step naming each AI provider must appear **before the first AI call**; "Note that only including this information in the app's Terms of Service or Privacy Policy is not sufficient"; purpose strings must say audio/text leaves the device. [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- Korean/Japanese 3rd-pass cases: the consent gate must list each recipient by **legal entity** (e.g. Anthropic, OpenAI) before the first AI call; a privacy-policy line alone was rejected twice. [cases](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)
- Apple 3rd-pass rule: name **one** company per data flow — a provider list ("OpenAI, Anthropic or xAI") fails; enumerate the data sent; consent before the first send; re-consent when the provider changes; Apple's 2.1 question set now includes third-party-AI items. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

---

## PERM — permissions

### PERM-01 Purpose strings
- Basis: Apple 5.1.1(ii) — purpose strings must be "specific and complete" ("Access photos" ✗ → "to set your profile photo" ✓) / Android — rationale before runtime requests recommended
- Verify: see `IOS-PLIST-01`. Android: rationale shown on re-request after denial.
- Signals: `perm.*` vs plist keys
- Fix: every NS*UsageDescription says "to do X". Localize (`InfoPlist.strings`).
- Watch-outs from cases: the message shown **after "Don't Allow"** is judged too; strings must be localized for the device language; libraries (share sheets, FlutterFlow) can require `NSPhotoLibraryUsageDescription` even if you never touch photos (ITMS-90683). [cases](../rejections/community-cases.md#511ii-purpose-strings)

### PERM-02 Works when denied
- Basis: Apple 5.1.1(iv) "don't manipulate, trick or force people to consent" / Play permissions: usable without non-core permissions
- Verify: denying push/camera/location doesn't block the app or loop prompts.
- Fix: disable only the feature + link to Settings.
- Location specifically: Apple 5.1.5 rejects apps that are "not functional when Location Services are disabled" or that push users to Settings — provide fallback content / manual entry. [cases](../rejections/community-cases.md#kids-13-ip-521-regulated-entities-511ix-business-model-322-location-515-objectionable-11)
- Apple 3rd-pass case: review iPads have no Face ID/Touch ID enrolled — `SecItemAdd` with `.biometryCurrentSet` returns `errSecAuthFailed (-25293)`; check `LAContext.canEvaluatePolicy` and fall back. [case](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### PERM-03 No unused permissions
- Basis: Play permissions policy / Apple reviewers ask "why do you need this?"
- Verify: manifest/plist permissions not used in code. SDK-merged ones (READ_PHONE_STATE etc.) removed via `tools:node="remove"`.
- Signals: permission list vs `perm.*`
- Fix: remove; if kept, justify in review notes.

### PERM-04 Pre-permission ("priming") screens
- Basis: Apple 5.1.1(iv) rejections "A custom message appears before the permission request… Use words like 'Continue' or 'Next' on the button instead" — custom screens must not mimic the system alert, must use neutral wording (never "Allow / Accept / Grant / Connect"), must not offer a skip that avoids the system prompt, and must provide an "Open Settings" path when iOS won't re-prompt; Korean case: an exit button + Settings redirect on denial was read as steering
- Applies: any onboarding explainer shown before camera/photos/location/notifications/ATT prompts
- Verify: button labels; no fake system dialog; the real prompt follows immediately; denial leaves the app usable (PERM-02).
- Signals: `perm.*`
- Cases: [Apple 2nd pass](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- Korean/Japanese 3rd-pass rules: the CTA must be neutral ("다음" / "続ける"); a **Cancel** button on the custom prompt is itself a violation (it lets users avoid the system prompt); redirecting to Settings **before** the system prompt is a violation ("권한 요청을 표시하기 전에 사용자를 설정 앱으로 리디렉션"). [cases](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)
- Apple 3rd-pass mechanics: one neutral button ("Continue"/"Next" — never "Allow", "Enable", "Grant Permission"), no Cancel/Not Now/Back, non-dismissible, and the tap must immediately trigger the system prompt; emoji or visual bias toward Allow is rejected. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

---

## PAY — payments

### PAY-01 Digital goods through IAP / Play Billing
- Basis: Apple 3.1.1 "If you want to unlock features or functionality within your app… you must use in-app purchase"; 3.1.1(a) (2025-05): buttons/external links to other purchase methods are allowed **only on the United States storefront** without an entitlement; "In all other storefronts… apps and their metadata may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase" (regional entitlement programs: EU, Korea, Japan — see IOS-IAP-02) / Play **Payments**: Play billing required for "in-app features or services, including any app functionality, digital content or goods"; must not steer users to alternatives via the listing, in-app promotions, webviews, buttons, links or ads; regional programs: Korea alternative billing (alongside Play billing), EEA alternative billing/external offers, US external content links + alternative billing (comply since 2026-01-28), Japan external payments; global fee changes from 2026-06-30 (EEA/UK/US), KR/JP 2026-12-31
- Applies: premium unlock, subscriptions, coins, themes
- Verify: selling digital goods via Stripe/Toss/iamport etc. → FAIL. Physical goods and offline services must **not** use IAP (Apple 3.1.3(e)); social "boosts"/promoted posts must use IAP (3.1.3(g)). "Cheaper on the web" copy → FAIL outside the US.
- Signals: `pay.external`, `pay.iap`
- Fix: switch to StoreKit / Play Billing or RevenueCat. Remove web-payment prompts/links, or gate them by storefront/region under an approved program.
- Apple 2nd-pass cases: donation buttons/links (Ko-fi, GitHub Sponsors, Buy Me a Coffee) count as digital purchases — "Although these donations may be optional, they must use In-App Purchase" — even when they only live on the linked website; 3.1.3(a) link-outs must use the External Link Account API modal "before every instance of linking out"; 3.1.3(c) enterprise pricing "could be interpreted as being sold to individual consumers". [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- International 3rd-pass cases: Apple judged 3.1.1 from the **marketing website and store description** (plan names/features that existed only there) — audit pricing page, FAQ, terms and listing for sentences tying mobile features to a paid plan or external purchase. [cases](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

### PAY-02 Subscription disclosure + terms links
- Basis: Apple 3.1.2(a) "the subscription period must last at least seven days and be available across all of the user's devices"; 3.1.2(c) "Before asking a customer to subscribe, you should clearly describe what the user will get for the price"; Schedule 2 requires Terms of Use (EULA) and privacy-policy links in the app and in metadata / Play **Subscriptions**: disclose "the cost of your subscription, the frequency of your billing cycle, the automatic renewal terms"; trials must "clearly and accurately describe the terms of your offer, including the duration, pricing… how it converts, how to cancel"; and the app must "clearly disclose how a user can manage or cancel their subscription" with an easy online method in "your app's account settings (or equivalent page)" (clarified 2025-10-30)
- Verify: paywall shows price, period, auto-renew wording, terms/privacy links, "Restore purchases". Free trial → post-trial price and conversion date. Settings has "Manage subscription" (link to Play Subscription Center / App Store subscriptions).
- Signals: `pay.iap`, `legal.terms`
- Fix: standard footer text + links on the paywall; EULA URL in the ASC "License Agreement" field (or Apple's standard EULA); a manage/cancel link in account settings.
- From cases: links must be in the app **and** in the App Store description; the billed amount must be more prominent than the intro price; no "ongoing value" → use non-renewing subscriptions; Play wants price, cycle, conversion date and cancel path on one simple paywall. [cases](../rejections/community-cases.md#312-subscriptions)
- Korean case: the EULA link must be in the App Store **description**; replying in Resolution Center does not update metadata — resubmit a build.
- Japanese/Chinese cases: with Apple's standard EULA the link must still be in the App Description; a weekly-equivalent price shown larger than the actual annual charge was rejected. [cases](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### PAY-03 Restore purchases
- Basis: Apple 3.1.1 "make sure you have a restore mechanism for any restorable in-app purchases"
- Verify: a "Restore purchases" control on the paywall/settings; non-consumables and subscriptions.
- Signals: `pay.iap` (restorePurchases)
- Fix: button → `restorePurchases()` / `queryPurchases`.
- From cases: implementing `restorePurchases()` is not enough — the **button must be visible** on the paywall. [case](../rejections/community-cases.md#311-in-app-purchase)

### PAY-04 IAP testable during review
- Basis: Apple 2.1(b) "If you offer in-app purchases in your app, make sure they are complete, up-to-date, visible to the reviewer and functional. If any configured in-app purchase items cannot be found or reviewed in your app, explain the reason in your review notes"; on the first submission, submit the IAP products **with** the app version
- Verify: ASC IAP status "Ready to Submit" and attached to the version. Paid Apps Agreement signed, banking and tax done. Play — license testers, products active.
- Fix: console work. Un-attached IAP is a frequent 2.1 / 3.1.1 rejection. IAP promo codes can no longer be created after 2026-03-26 (use offer codes).
- Korean case (2026-08): an unsigned **Paid Apps Agreement** / missing tax info (사업자등록번호 required since 2024-12) / missing bank details produced 3–4 subscription rejections that looked like product-configuration problems; also attach the subscription review screenshot. [case](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### PAY-05 IAP wiring outside the binary (agreements, product IDs, RevenueCat, submission draft)
- Basis: the most frequent 2026 IAP rejections read "one or more of the in-app purchase products have not been submitted for review", "Family Pack… not found", "Remove ads button errors", "Confirm you have a Paid Apps Agreement in effect" — and none of them are code bugs
- Applies: any IAP / subscription
- Verify before submitting: (1) Paid Apps Agreement **in effect** (bank + tax complete — the same build was approved the next day after this alone); (2) every IAP attached to the **same** submission draft ("審査と一緒に提出" / 提出物(2)) — "Submit for review" on an IAP creates a separate draft; (3) product IDs identical in code, ASC and RevenueCat; (4) RevenueCat: the App Store Connect In-App Purchase key (.p8) uploaded, offerings mapped to real products, webhook environment **Production + Sandbox**; (5) CI builds carry the API keys (`eas build` does not read `.env`); (6) a restore control reachable at all times (PAY-03).
- Signals: `pay.iap`
- Fix: as listed; most need no new build — resubmit after fixing the console side.
- Cases: [Japanese sources](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### PAY-06 Price, currency and trial text come from the store, never from code
- Basis: Apple 2.1(b) "アプリが無料トライアルを広告しているにもかかわらず、決済時にユーザーへ提供されていない" (hard-coded "7-day free trial" while the product had none); Play subscriptions "購入フロー内で目立つ価格の通貨が異なる" (hard-coded ¥500 vs localized cart currency); Apple 3.1.2 billed amount less prominent than an intro price
- Applies: any paywall, settings, onboarding, screenshots or description mentioning price/trial
- Verify: every price, currency, period and trial string is rendered from `Product.displayPrice` / `priceString` / Play `formattedPrice`; the CTA is disabled until the product loads; screenshots and the description don't state prices that differ by storefront.
- Signals: `price.hardcoded`
- Fix: single source of truth from the store product; scan the IPA/AAB strings for fixed prices.
- Cases: [Japanese sources](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- Play 3rd-pass case — a "Try for Free" button without a configured trial phase was treated as **Malware "Billing Fraud"** (app suspended, account terminated), not a subscriptions warning. [case](../rejections/community-cases.md#google-play--3rd-pass-2026-08-28-thin-areas--child-safety-declarations-health-connect-form-factors-enforcement)

---

## ADS — advertising

### ADS-01 Ads ↔ consent & labels
- Basis: see PRIV-03. Plus Play "Contains ads" declaration (App content > Ads).
- Verify: ASC App Privacy includes ad data; Play Ads declaration "Yes".

### ADS-02 No disruptive or deceptive ads; ad reporting; children restrictions
- Basis: Apple 2.5.18 "Display advertising should be limited to your main app binary, and should not be included in extensions, App Clips, widgets, notifications, keyboards, watchOS apps… Ads displayed in an app must be appropriate for the app's age rating… Interstitial ads… must provide easily accessible and visible close/skip buttons… Apps that contain ads must also include the ability for users to report any inappropriate or age-inappropriate ads"; 2.4.2 no unrelated background processes from ads / Play **Ads** — Better Ads Experiences: "Full screen interstitial ads of all formats… that show unexpectedly… are not allowed"; "Ads that appear during game play at the beginning of a level or during the beginning of a content segment are not allowed"; "not closeable after 15 seconds are not allowed"; rewarded ads exempt; "Ads must not simulate or impersonate the user interface of any app feature"; lockscreen monetization banned / Play Families Ads & Monetization for children
- Verify: interstitial at launch / exit / level start → FAIL (Play). Close button within 15 s. A "report ad" affordance (Apple). Ads never in widgets/extensions. Ads don't look like content or system UI.
- Fix: move interstitials to natural breaks; add close/skip; add an ad-report menu (AdMob "report ad" or a mailto).
- From cases: ads triggered on button clicks were rejected as "interferes with the normal use of the application" even after interstitials were removed. [case](../rejections/community-cases.md#ads-subscriptions-payments)
- Play 2nd-pass cases: rejections for ads on Settings/Download/Disconnect taps, on activity start, App Open ads on every foreground, "ads triggered by the back button", "out of context activities with ads… if the app is sent to the background"; Families apps additionally get "can't be closed after 5 seconds" for rewarded videos and close buttons hidden behind the navigation bar. Often the real reason sits in the AdMob policy center. Rule: ads only where the user expects them (label the button), never on navigation/exit/background. [cases](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)
- Play 3rd-pass cases — mediated ad **creatives are your liability**: APK-download ads served through Unity Ads / AdMob mediation produced Device and Network Abuse suspensions (2026-08) — use the AdMob Ad Review Center, disable unknown mediation sources, keep evidence; promotional banners in a kids-audience app count as ads under Families even without an ad SDK; PE rule: remote-config kill switches are fine after a warning but not to pass review. [cases](../rejections/community-cases.md#google-play--3rd-pass-2026-08-28-thin-areas--child-safety-declarations-health-connect-form-factors-enforcement)

### ADS-03 Remove test ad units
- Basis: leaving test units (`ca-app-pub-3940256099942544/...`) in release → zero revenue + AdMob policy; clicking live ads during development → violation.
- Signals: `test.keys`
- Fix: switch by flavor/build type.

---

## PUSH — notifications

### PUSH-01 Works without push; marketing push is opt-in
- Basis: Apple 4.5.4 "Push Notifications must not be required for the app to function, and should not be used to send sensitive personal or confidential information. Push Notifications should not be used for promotions or direct marketing purposes unless customers have explicitly opted in to receive them via consent language displayed in your app's UI, and you provide a method in your app for a user to opt out"; 5.1.2(i) no gating functionality on enabling push; 4.5.3 (2026-06) push **and Live Activities** must not be used for spam / Play — Device & Network Abuse bans full-screen-intent abuse; no spammy notifications
- Verify: permission is requested in context, not at first launch (recommended). Notifications can be disabled in Settings. Marketing has a separate explicit opt-in toggle. App works when denied.
- Signals: `perm.push`
- Fix: notification settings screen; separate marketing toggle; never block a feature behind push.
- Apple 2nd-pass wording: "The app does not request and obtain the user's consent before sending push notifications" · "requires push notifications in order to function" · "uses public APIs with Notification Center in a manner not prescribed by Apple". [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

---

## BG — background

### BG-01 Background modes only for their intended purpose
- Basis: Apple 2.5.4 — `audio` for real audio playback, `location` for location features, etc. **Playing silent audio to keep a timer/countdown alive is a classic rejection.**
- Applies: `UIBackgroundModes` present, especially timer/focus/habit apps
- Verify: with `audio` mode, is there audible content (white noise, music)? Is the timer-end handled with a local notification?
- Signals: `bg.modes`, `bg.audio`, plist `UIBackgroundModes`
- Fix: store the end time + schedule a `UNUserNotificationCenter` local notification + recompute remaining time on resume. Keep `audio` only with a real sound feature and explain it in the review notes.
- Evidence: one line in the review notes explaining the background mode.

### BG-02 Android foreground services
- Basis: Android 14 (targetSdk 34)+ requires `foregroundServiceType` + per-type permission + Play Console declaration (AND-PERM-05, AND-CONSOLE-06)
- Verify: a timer-keeping FGS is usually `specialUse` (explain in the form) or `mediaPlayback` (real playback). `shortService` is limited to 3 minutes.
- Fix: manifest type + `FOREGROUND_SERVICE_<TYPE>` permission + console form + demo video.

---

## CONTENT — completeness

### CONTENT-01 No placeholders, crashes or unfinished features
- Basis: Apple 2.1 (placeholder text, empty screens, broken links, crashes) / Play "Broken functionality"
- Verify: "coming soon", lorem ipsum, empty lists without a message, dead buttons. Crashes on real devices (especially **iPad** and older Android). Every external link returns 200.
- Signals: `placeholder`, `todo.marks`
- Fix: hide unfinished features. Add empty-state copy.
- From cases: empty states without a message are read as "button leads to a blank page" (Play Broken Functionality); infinite spinners when a permission is denied or the network is off; splash hangs on iPad. [cases](../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)
- Korean case (Play): tests run with the network off — a blank or unresponsive error screen is "Broken Functionality"; show an error message + retry button.
- Play 2nd-pass cases: the review runs the **Play-signed** build (different signing key than the pre-launch report → Google sign-in / App Check / third-party libs can fail), on-demand asset packs return `AppNotOwned` in the review environment, and stream-dependent screens are empty — see AND-REVIEW-01. [cases](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### CONTENT-02 No test/debug leftovers
- Verify: debug menus, staging URLs, test payment keys, personal data in logs, `usesCleartextTraffic=true`.
- Signals: `test.keys`, `cleartext`
- Fix: exclude from release builds.
- Korean 3rd-pass rule: seeded demo data containing "test / 테스트 / 준비중" strings is itself a rejection reason; simulator recordings are refused. [cases](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

### CONTENT-03 Minimum functionality — no web wrappers
- Basis: Apple 4.2 (websites wrapped in an app, marketing-only apps, single-feature apps) / Play Minimum functionality
- Applies: WebView is the main UI
- Verify: meaningful native functionality (push, camera, offline, widgets…).
- Signals: `webview`
- International 3rd-pass cases: **live aggregator apps are re-reviewed as new** on routine updates — price-comparison/travel/cashback apps got 4.1 (third-party logos) then 4.2.2 "not different from a web browser"; keep a ready dossier (number of sources, native aggregation/ranking/dedup, iOS features, comparison with approved category peers) and attach it to every update's notes. [cases](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

### CONTENT-04 No other-platform mentions
- Basis: Apple 2.3.10 — no names, icons or imagery of other mobile platforms in the app or metadata ("also on Android" ✗) / Play — same spirit (iPhone frames in screenshots…)
- Verify: localization strings, screenshots and descriptions for "Android", "Google Play", "iPhone", "App Store".
- Signals: `strings mentioning …`
- Fix: platform-neutral wording ("on your other devices").

### CONTENT-05 Support contact
- Basis: Apple 1.5 — an easy way to contact you in the app and on the support URL / Play developer email
- Verify: Settings > Contact (mail or form); the support URL page shows an email.
- Signals: `mod.contact`
- From cases: a Twitter/X profile or a dead page as Support URL is rejected (1.5); use a real page or a form with an email. [cases](../rejections/community-cases.md#15-developer-information-frequent-co-rejection)
- Korean cases: support URLs that failed 1.5 — a GitHub repo page, a default Apache page, a Notion page without an email, a velog URL with unencoded Korean characters.

### CONTENT-06 Ratings prompts & incentives
- Basis: Apple 5.6.1 "Use the provided API to prompt users to review your app… we will disallow custom review prompts"; 3.2.2(x) "Apps must not force users to rate the app, review the app, download other apps, or other store-related actions in order to access functionality, content, or use of the app" / Play — no rewards or gating for reviews
- Verify: custom "rate 5 stars for premium" → FAIL. Only `SKStoreReviewController` / `requestReview` (iOS) and the In-App Review API (Android).
- Signals: `review.prompt`
- Apple 2nd-pass wording: "prompts users to rate the app in exchange for in-app currency, points, or other incentives" (3.2.2(x)). [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- Apple 3rd-pass rule (5.6.3): no `requestReview` during onboarding/first launch; no fabricated testimonials or star ratings in-app; gate on real engagement. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### CONTENT-07 Saturated categories — "simple timers" need a meaningfully different experience
- Basis: Apple 4.3(b) (2026-06 wording): "Certain kinds of apps, such as dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling, are well established on the App Store and we will not accept new submissions unless they offer a meaningfully different or improved experience. We may remove these apps from the App Store going forward if they are not updated, improved, or do not attract customers"; 4.3(a) no multiple Bundle IDs of the same app; 4.2 "not particularly useful, unique, or 'app-like'" / Play **Functionality, Content, and User Experience**: "We do not allow apps that only have limited functionality and content"
- Applies: timer/focus, wallpaper, sound, flashlight, dating, fortune-telling, template-generated apps
- Verify: what makes the app different (social features, sync, analytics, widgets, unique mechanic)? Is that difference visible on the first screen, in screenshots and in the description?
- Signals: app name / description keywords (`saturated.category` hint)
- Fix: lead the store description and Notes for Review with the differentiator; make it visible in screenshots; don't submit near-duplicates under new bundle IDs.
- From cases: what actually cleared 4.3 was a **significantly different icon + UI** plus a real new feature; color-only changes and appeals alone did not. After an appeal succeeds, add a reviewer note on every later update. [cases](../rejections/community-cases.md#43-spam--duplicates--templates)
- Japanese/Chinese cases: 4.3(a) on a first submission was cleared by resubmitting the **same build with real review notes + a recording** (WidgetKit Sudoku); machine-flagged 4.3 ("机审") never clears without a concept change; dating/fortune-telling apps hit 4.3(b) "99%". [cases](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)

### CONTENT-08 Recording consent & indicator
- Basis: Apple 2.5.14 "Apps must request explicit user consent and provide a clear visual and/or audible indication when recording, logging, or otherwise making a record of user activity. This includes any use of the device camera, microphone, screen recordings, or other user inputs" / Play Device & Network Abuse, Stalkerware
- Applies: audio/video recording, screen recording, keystroke/usage logging
- Verify: consent before recording + a visible indicator while recording.
- Signals: `perm.mic`, `perm.camera`

### CONTENT-09 IPv6-only networking
- Basis: Apple 2.5.5 "IPv6-only network" support required since 2016; a frequent hidden cause of "the app crashed / could not load content" 2.1 rejections when the backend or SDK uses IPv4 literals
- Verify: no hard-coded IPv4 addresses; test with macOS "Create NAT64 Network" hotspot.
- Fix: use hostnames; ensure the API host has AAAA/NAT64 compatibility.
- Korean cases: free dynamic-DNS domains (DuckDNS, iptime) and IPv4-only EC2 instances are unreachable from Apple's IPv6-only review network → 2.1 "cannot login / data not loading" ×5. Use a real domain with AAAA or NAT64-compatible hosting. [cases](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)
- Japanese/Chinese cases: reviewer traffic comes from the US (Apple) and e.g. Manila (Play) — WAF geo-blocks and "运维禁用了海外IP" produce "cannot log in / network error" rejections; open those regions and IPv6 for the review window. [cases](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- Apple 3rd-pass cases: verbatim 2016-era IPv6 rejection text still appears ("…could not be loaded when reviewed on an IPv6 network"); Meteor/Reachability/SAP SDK cases; an Irish mobile-network geoblock produced a 2.3.1 "behaves differently" suspicion. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### CONTENT-10 No hidden or dormant features; declare OTA code push
- Basis: Apple 2.3.1(a) "Don't include any hidden, dormant, or undocumented features in your app"; 2.5.2 no code that changes features; Play Deceptive Behavior "don't include any hidden, dormant, or undocumented features"
- Applies: CodePush / Shorebird / expo-updates / remote feature flags; debug menus; screens reachable only by OTP or role; A/B code paths that differ during review
- Verify: any OTA mechanism only patches bug fixes and is declared in the Notes for Review; no debug overlays or dev menus in release; no code that detects the reviewer/sandbox and changes behavior (payment bridges, web games).
- Signals: `codepush`, `todo.marks`
- Fix: remove or clearly document; never gate behavior on review detection.
- Cases: [community — 2.3.1](../rejections/community-cases.md#251--231-software-requirements-leftover-capabilities-hidden-features)

### CONTENT-11 Forced-update gate must not block the review build
- Basis: Apple 2.1 ("we are unable to access content without updating the app"); Play Broken Functionality
- Applies: apps with a minimum-version / force-update check against a remote config or the store version
- Verify: the review build (a version **newer** than the store) is not sent to the update screen: compare versions segment-by-segment and only prompt when local < required; keep an escape hatch when the store lookup fails.
- Signals: `force.update`
- Fix: correct comparison; log the decision; test with a build number above the store's.
- Cases: [community — 2.1](../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)

### CONTENT-12 Release-parity & fresh-install test
- Basis: Korean 2.1 rejections that read "error message on launch/login" were caused by Release-only configuration: API host/port only set in the Debug scheme, HTTP endpoints blocked by ATS (-1022) / `ERR_CLEARTEXT_NOT_PERMITTED` in the AAB, first-run auth that only worked with a cached session
- Applies: every submission
- Verify: install the **Release** build on a wiped device with no saved session and run delete → install → sign-up → login → core flow → relaunch; Release config has the production host, HTTPS everywhere (no `NSAllowsArbitraryLoads` / `usesCleartextTraffic` workarounds), no debug-only feature flags.
- Signals: `cleartext`, `test.keys`
- Fix: move config to a shared place; HTTPS for every endpoint; automate the fresh-install smoke test in CI.
- Cases: [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### CONTENT-13 Run the app in a non-Korean locale / region
- Basis: reviewers run in a US region; Korean apps crashed on launch because `CFBundleDevelopmentRegion` was `$(DEVELOPMENT_LANGUAGE)` or the storyboard localization table lacked the base language; permission dialogs appeared in the wrong language (4.0)
- Applies: apps developed in Korean (or any single locale)
- Verify: set the device language/region to en-US and launch the Release build; `CFBundleDevelopmentRegion` is a concrete locale (`ko_KR` or `en`); all localization tables exist for the base language; `InfoPlist.strings` localized.
- Fix: concrete development region; complete Base localization; test both locales.
- Cases: [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### CONTENT-14 Emulators, mini-app hosts, content filters (4.7 / 2.5.1 / 2.4.5)
- Basis: Apple 4.7 allows retro **game-console** emulators and HTML5 mini-apps only when they are not the app's primary purpose ("offering HTML5 games appears to be the primary purpose of your app", "not emulating a retro game console specifically", "PC is not a console"); VPN/root-certificate content filters, accessibility auto-paste and Notification Center misuse fall under 2.5.1 / 2.4.5; "The app installed or launched executable code. Specifically, the app uses the itms-services URL scheme" (2.5.2)
- Applies: emulators, mini-game portals, chatbot/plug-in hosts, VPN-based filters, apps distributing builds
- Verify: the primary purpose is your own functionality; emulated systems are consoles; no itms-services / enterprise-distribution links; no public-API misuse.
- Cases: [Apple 2nd pass](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

---

## META — store metadata (outside the code)

### META-01 Screenshots show the app in use
- Basis: Apple 2.3.3 — screenshots show the app in use, not splash/login/title art; device frames and captions allowed / Play Metadata policy — accurately reflect the app
- Verify: required sizes (iPhone 6.9", iPad 13") and content. If made with the `store-screenshots` skill, the framed screen must be the real app.
- Apple 3rd-pass cases: "$4.99", "free", "すべて無料", "All of it free" in screenshots are 2.3.7 price references; device frames are allowed in screenshots but **not** in App Preview videos (2.3.4); previews need an audio track (silent is fine). [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### META-02 Description, keywords, name
- Basis: Apple 2.3.7 "App names must be limited to 30 characters"; no trademarked terms, popular app names or pricing in metadata; 2.3.2 IAP disclosure in description/screenshots; 2.3.8 metadata suitable for 4+; 2.3.12 meaningful "What's New" for significant changes / Play **Metadata**: title ≤ 30 chars; no "emojis, emoticons, or repeated special characters"; no store-performance, ranking, price or promotional text in title/icon/developer name ("App of the year", "#1", "Best of Play", "10% off", "free for limited time only", "Editor's choice", "New"); no all caps unless brand; no "unattributed or anonymous user testimonials"; **Deceptive Behavior**: no false or misleading claims in title/description/icon/screenshots
- Verify: promises of unreleased features, other-platform mentions (CONTENT-04), other apps' names, promo words, emojis in the title.
- From cases: "Tutorial & Rules" (implied external content), Spanish "libre" (read as "free"), "ChatGPT" in a name, "Anonymous/匿名" keywords, brand names of hardware — all rejected. [cases](../rejections/community-cases.md#metadata--misleading-claims)
- Apple 2nd-pass cases (2.3.2): features that need a purchase must be labelled in the description/screenshots ("(Pro)", "subscription required") — "metadata refers to paid content or features, but they are not clearly identified as requiring additional purchase"; placeholder icons and the word "Kids" in a non-Kids app name are 2.3.8; "resembles Pokemon" / sports-league likeness is 4.1(a). [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- International 3rd-pass case: **machine-translated localized titles** are policy-checked per locale ("vrij" read as "free"); keep every locale's title ≤ 30 chars and free of price/superlative words. [case](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

### META-03 Age-rating questionnaire
- Basis: Apple 2.3.6 "Answer the age rating questions in App Store Connect honestly"; new tiers 4+/9+/13+/16+/18+ with new questions (in-app controls, capabilities, medical/wellness, violence) — responses were required by 2026-01-31; **social-media questions required for submissions from 2026-09**; declaring the "Social Media" capability sets a minimum 13+ rating (iOS 27 Time Allowances) / Play **Content Ratings** (IARC): "All apps must have a content rating… Apps without a content rating will be removed"; "Misrepresentation of your app's content may result in removal or suspension"; interactive element "Users Interact" covers user-to-user communication and media sharing
- Verify: **with UGC, chat or friends, answer "users interact / UGC / messaging" = Yes**; unrestricted web access if a WebView browses the web; loot boxes/gambling questions if applicable. Re-submit the questionnaire when features change.
- Signals: `ugc.*`, `webview`
- Cases: see community cases tagged META-03
- Korean case: a WebView loading YouTube/open web content raised the rating to 12+ ("unrestricted web access") — open such links externally instead.
- Apple 3rd-pass cases (2025-09 → 2026): "Parental Controls", "Age Assurance", "In-App Controls", "Advertising" and "User-Generated Content" answers are verified against the binary — unimplemented parental controls → answer None; kids-targeted naming ("…4Kids") without the Kids Category → 2.3.8. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### META-04 URLs work
- Verify: support, marketing and privacy URLs return 200 with content. Notion pages: "publish to web" on.
- Apple 2nd-pass cases: linked pages **are** metadata — the support URL, README and marketing site linked from notes are reviewed for trademarks, other-platform mentions, donation links and false claims. [cases](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)
- International 3rd-pass cases: legal/support/deletion URLs on repo branches, unmerged pages or `rsync --delete` deploys produced 404s at review time on both stores — host on a stable domain, per locale, and gate submission on a live HTTP 200 check of the URLs stored in the consoles. [cases](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

### META-05 Review notes
- Basis: Apple 2.3.1(a) "All new features, functionality, and product changes must be described with specificity in the Notes for Review section of App Store Connect (generic descriptions will be rejected) and accessible for review"; App Review page: "Incomplete information" (demo account, special configurations, demo video/hardware) is a top rejection reason / Play Sign-in details (AND-CONSOLE-03)
- Verify: `templates/review-notes.md` content is in ASC App Review Information (Notes ≤ 4000 bytes, contact phone in international format) / Play Sign-in details. Demo account + feature locations + recording link + background-mode reason + IAP location + anything hidden behind conditions (region, time, role).

### META-06 Store assets must match the installed app and reachable states
- Basis: Apple 2.3.8 "앱 마켓플레이스에 표시되는 앱 이름과 기기에 표시되는 앱 이름이 충분히 일치하지 않아" (long store name vs short `CFBundleDisplayName`); Play Misleading Claims / Metadata: "the app's icon or title when installed on the device differs from what is displayed in the Play Store" (adaptive/monochrome icon rendering white, an old test-track icon), screenshots of locked levels or dynamic content, screens that don't exist, "Identical title and description", "Your app is improperly categorized"
- Verify: the App Store / Play title and the launcher name share the same core name (tagline in the subtitle); the hi-res icon and the launcher icon are the same asset (regenerate adaptive icons without stray monochrome layers); every screenshot shows a state the reviewer can reach (caption "representative" outside the device frame otherwise); title ≠ description.
- Signals: plist `CFBundleDisplayName` / `android:label` vs store name
- Fix: align names and icons; retake screenshots; rewrite the description as a feature list.
- Cases: [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28), [Play 2nd pass](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### META-07 Resubmission mechanics
- Basis: cases lost days to the process itself: a Resolution Center reply does **not** restart review ("However, in order for us to proceed with the review of your app, please resubmit the app for review in App Store Connect") unless Apple explicitly offers a bug-fix pass; conversely, resubmitting during a 4.3 / 2.1 dialogue before the reviewer answers kills the thread; a rejected version string can't be reused (1.7.0 → 1.7.1); IAP "Submit for review" creates a separate draft; Play: one issue fully fixed per resubmission or "Repeated app rejections" suspends the app
- Verify: after replying, press "Resubmit for review" when Apple asks for a new build/metadata; wait for the reviewer's reply when they asked a question; bump build/version; check the ASC submission draft lists app + IAPs together.
- Cases: [Japanese sources](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28)
- Apple 3rd-pass escalation ladder (4.3(a), 2.4.5): reply in Resolution Center and *wait* — resubmitting before the reviewer answers ends the thread and strengthens the spam flag; ask for a call ("I'd like to talk"); Meet with Apple (Tue/Thu, Japanese available) can reach the appeal team; Board appeals can be upheld without engagement; name your sibling apps and the differentiation up front in notes. [cases](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

---

## KR — Korea law & practice

### KR-01 Under-14 parental consent
- Basis: 개인정보보호법 §22-2 — collecting personal data of children under 14 requires legal-guardian consent. Most services handle it with an "I am 14 or older" confirmation at sign-up.
- Applies: sign-up exists; app not aimed at children
- Verify: an age-14 confirmation on the sign-up / consent screen.
- Signals: `legal.age`
- Fix: add "I am 14 or older (required)" to the consent checkboxes.

### KR-02 Mandatory policy contents
- Basis: 개인정보보호법 §30 (privacy-policy contents), 전자상거래법 (refund/withdrawal for paid services)
- Verify: the policy lists items collected, purposes, retention, third parties, processors (including overseas transfer — Firebase/AWS), data-subject rights, privacy officer contact. Paid → refund terms.

### KR-03 Game rating
- Basis: 게임산업진흥법 — IARC (Apple/Google self-rating) is accepted; adult-only games need GRAC review
- Applies: Games category
### KR-04 Korea-specific store changes (2026)
- Basis: Apple — from 2026-10 "infrequent profanity" and "infrequent mature themes" move from All to 12+ in Korea (GRAC RCN override); Korea-based developers must provide a Sign in with Apple server-to-server notification endpoint on their Services ID since 2026-01-01 (IOS-LOGIN-03); Korea external-purchase entitlement (IOS-IAP-02) / Play — Korea alternative billing (AND-PAY-01)
- Verify: age rating answers on profanity/mature themes; SIWA endpoint configured.

### KR-05 Toss mini-app (앱인토스) review
- Basis: a third Korean store with its own rules and fast (minutes) automated-plus-manual review: "미니앱 접속 직후 바텀시트가 바로 노출돼요" (no bottom sheet on entry), "서비스 설명 없이 즉시 토스 로그인 유도" (no login prompt before the service is explained), "탭바를 사용하는 경우, 토스 미니앱 브랜딩 가이드에 적합한 플로팅 형태를 사용해야 해요" (floating capsule tab bar), unsupported categories (real estate); rejection reasons appear only in `review_get_feedback.comments` (`review_get` returns empty `rejectMessages`); a cancelled review needs a new bundle
- Applies: apps shipped as Toss mini-apps
- Verify: first screen explains the service with no modal/login; tab bar follows the branding guide; screenshots match the current UI; category supported.
- Cases: [Korean/Japanese 3rd pass](../rejections/community-cases.md#korean-and-japanese-sources--3rd-pass-2026-08-28-github-issues-okky-brunch-damoang-teratail-hatena-toss-mini-app)

---

## LAW — regional age-assurance laws (2026)

### LAW-01 Age-assurance requirements by region
- Basis: Apple news 2026-02-24 / 2026-06-03: apps rated 18+ are blocked in Brazil, Australia and Singapore without adult confirmation (2026-02-24); **Texas SB 2420** in force 2026-06-04 (parental consent for downloads, IAP and significant changes — Declared Age Range API, Significant Change API, consent-revocation server notifications), Utah (2026-05-06), Louisiana (2026-07-01); Australia under-16 social-media law (2025-12-10) — Declared Age Range API, Age Suitability URL / Play **Age Signals API** data-use restrictions (2026-01-01) and Age-Restricted Content tools
- Applies: social media, dating, chat, 18+ content, apps with IAP distributed in those regions
- Verify: whether the app reads the Declared Age Range API / Play Age Signals and adjusts features; whether significant changes are declared; an Age Suitability URL where required.
- Signals: `ugc.*`, `pay.iap`
- Fix: adopt the age APIs; provide an age-suitability page; keep the age rating current (META-03).
- Evidence: none (platform-side).

### LAW-02 Regulated finance / crypto storefront evidence (3.1.5, 3.2.2(viii))
- Basis: "The storefronts you selected in App Store Connect include locations where you… have not provided supporting evidence of permissions, registrations, and/or licenses" · "facilitates trading in contracts for difference" — crypto exchange/swap/on-ramp and CFD/derivatives features need licence evidence per storefront attached in App Review Information; otherwise remove the feature or restrict storefronts; Play: Financial features declaration + licences (AND-CONSOLE-09)
- Applies: crypto wallets/exchanges, trading, lending, insurance
- Verify: storefront list vs licences; evidence attached; organization account (ACC-06).
- Cases: [Apple 2nd pass](../rejections/community-cases.md#apple--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-github-issuesprs-hn-zennvelog)

### LAW-03 Rights evidence for third-party media and catalogs (5.2.3)
- Basis: 9 cases — a Jellyfin client rejected 3× until downloads were removed, TMDB catalog "documentary evidence", PeerTube clients ×4, react-native-youtube-iframe, radio streams: any app that streams, downloads or indexes third-party audio/video needs rights/licence evidence attached in App Review Information *before* review; the YouTube API ToS alone is rejected; offline download of third-party media is unfixable — remove it and scrub "download/offline" from metadata
- Applies: media players, radio/podcast aggregators, YouTube embeds, catalog apps
- Verify: evidence attached; no third-party download feature; metadata free of "download".
- Signals: `media.thirdparty`
- Cases: [Apple 3rd pass](../rejections/community-cases.md#apple--3rd-pass-2026-08-28-thin-areas--ipv6-523-media-rights-525-apple-trademarks-mac-entitlement-scans-widgetswatchos-age-assurance-ai-disclosure-reader-apps-frameworks)

### LAW-04 Regional distribution gotchas — Russia/Belarus, Brazil, Vietnam, Indonesia, Turkey, Germany, France
- Basis (details and sources in [`references/regions.md`](../references/regions.md)): **Russia/Belarus** — sanction blocks on developer accounts, Apple Pay/card payments off since 2022-03, no RF Play Console registration, VPN removals on Roskomnadzor demand, bank "clone" apps = 2.3.1 by design; **Brazil** — ECA Digital (2026-03-17: age assurance, parental linkage <16, **loot boxes banned** for minors, no profiling/ads on minors), ANPD makes the stores the first enforcement line, CADE settlement (alternative stores/payments incl. PIX), CPF/CNPJ identity; **Vietnam** — Decree 147: games need a Vietnamese G1 licence via a local publisher, fintech/pawn apps need the business licence + Vietnam-only availability; **Indonesia** — Komdigi PSE registration (unregistered platforms blocked), top-up shops rejected under Payments; **Turkey** — KVKK mobile-app guide (in-app notice/consent, child notices), Play age verification since 2025-10, association terminations; **Germany** — Impressum reachable in-app and in the listing, DSGVO consent taken literally (no Firebase token before notification consent), "(inoffiziell)" for official-sounding names; **France** — under-15 social ban with age verification (2026-07), Declared Age Range API, 180-day Play appeal window
- Applies: any storefront/country in the list; games; fintech; social
- Verify: storefront list vs licences/registrations; region-specific legal pages (Impressum, PSE, game licence numbers); age-assurance APIs where required; payment method availability.
- Cases: [international sources](../rejections/community-cases.md#cases-from-russian-spanish-portuguese-vietnamese-indonesian-turkish-german-and-french-sources-3rd-pass-2026-08-28)

---

## JP — Japan

### JP-01 Japan-specific store and legal requirements
- Basis: **MSCA / スマホ新法** (in force 2025-12-18): Apple Japan permits external purchase links / alternative payments (IAP must be shown alongside, Apple disclosure sheet, monthly reporting; effective commission ≈ 26%/15%), Google Play Japan external payments program ("Play store listings must not mention out-of-app purchases"); **特定商取引法** (2022-06): subscription order screens must show price, period, auto-renewal and cancellation terms — mirrors Apple 3.1.2 / Play subscription rejections; **資金決済法**: purchased in-app points are 前払式支払手段 — unused balance over ¥10M triggers deposit obligations unless points expire within 6 months; Play: sole proprietors (開業届) can obtain a D-U-N-S and register an organization account, skipping the 12×14 closed test
- Verify: 特商法表記 page linked from the paywall/support page; point expiry ≤ 6 months or accounting for deposits; store-fetched prices (PAY-06); review notes in Japanese are fine but Play Sign-in details must be English.
- Cases / sources: [Japanese sources](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28), `../references/japan-china.md`

## CN — China

### CN-01 China-specific store and legal requirements
- Basis: **ICP备案** required for App Store China mainland (strict since 2024-04): unfiled apps are removed; the ASC app name must match the MIIT record; offline/IAP-only apps may request an exemption; games need a **版号**; loan/finance apps need ICP + 金融许可证; Apple rejects **AI features** for mainland distribution without a licence ("Guideline 5 - Legal" → remove AI, deselect China mainland, or provide documentation); WeChat/QQ login is a third-party login → Sign in with Apple (4.8), hiding the WeChat button when WeChat isn't installed does not exempt; promoting a WeChat mini-program inside an iOS app → 3.2.2; Chinese SDKs need Google-Play builds (JPush `google_play` jars), DCloud/uni-app runtime carries APK-install code (Play removal), Umeng code paths triggered Apple 2.3.1, Adjust reads installed apps (Data safety); ops blocking overseas IPs is a recurring 2.1 cause; Play account bans for new Chinese accounts ("高风险", 账号关联) — "anti-association" VPS and account-buying guides are policy violations, not fixes
- Verify: ICP filing number in ASC; China mainland deselected if AI features are unlicensed; SIWA present with HIG button; no mini-program promotion; Google-Play variants of Chinese SDKs; overseas IPs open during review.
- Cases / sources: [Chinese sources](../rejections/community-cases.md#cases-from-japanese-and-chinese-sources-2nd-pass-2026-08-28), `../references/japan-china.md`

