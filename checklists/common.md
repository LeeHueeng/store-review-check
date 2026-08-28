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

### ACC-03 Reviewer demo account (the social-login-only trap)
- Basis: Apple 2.1(a) "include demo account info (and turn on your back-end service!) if your app includes a login. If you are unable to provide a demo account due to legal or security obligations, you may include a built-in demo mode in lieu of a demo account with prior approval by Apple"; ASC help: the demo account "must not expire" / Play **Sign-in details** (formerly App access): "Your sign-in details must be accessible at all times, reusable, and valid regardless of user location… If your app typically requires a 2-Step verification code or One-time password, make sure to provide reusable login credentials that can bypass these requirements… must be provided in English… If the provided password expires… the app may be rejected"
- Applies: any login
- Verify: the review notes carry an account. That account logs in **from the reviewer's location (US etc.) without 2-step verification, device confirmation or foreign-login blocks**, and never expires. Kakao and Google accounts frequently fail here.
- Signals: `auth.google/kakao/naver` > 0 and `auth.email` = 0 and `auth.apple` = 0
- Fix (preferred order): (1) add Sign in with Apple (solves IOS-LOGIN-01 too; reviewers use their own Apple ID — consider auto-seeding demo data for empty accounts); (2) enable email/password in Firebase etc. and create a **reviewer-only account** (exposing the button is safer than a hidden entry); (3) if you do hand over Kakao/Google demo accounts: 2-step off, recovery email set, be ready to approve login alerts. Provide a second account so reviewers can see both sides of chats/friend requests.
- Evidence: review notes via `templates/review-notes.md` (Apple Notes ≤ 4000 bytes; Play up to five sets of instructions + "Any other instructions" for OTP/MFA).
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — "Please provide a pre-populated demo account (Google or Kakao)"; see also community cases tagged ACC-03
- [community cases](../rejections/community-cases.md#21-app-completeness--information-needed-demo-account-crashes-hidden-gates)

### ACC-04 Social-login console configuration
- Basis: not a guideline, but a broken login during review becomes a 2.1 rejection
- Verify: Kakao — iOS bundle ID / Android key hash (the **release** key!) registered, consent items (nickname, profile, email) configured, business app if email is required. Google — OAuth consent screen in "production", iOS client ID and Android SHA-1 (upload key **and** Play App Signing key) registered. Firebase Auth providers enabled.
- Fix: check the above. Copy the Play App Signing SHA-1 from Play Console > App integrity.

---

## PRIV — privacy

### PRIV-01 Privacy policy — in app and in the store listing
- Basis: Apple 5.1.1(i) "All apps must include a link to their privacy policy in the App Store Connect metadata field and within the app in an easily accessible manner" / Play **User Data**: linked in Play Console **and** accessible within the app; must include "Developer information and a privacy point of contact", the types of personal data accessed/collected/used/shared, "Secure data handling procedures", retention/deletion policy, be clearly labeled as a privacy policy, and "The entity named in the app's Google Play store listing must appear in the privacy policy or the app must be named in the privacy policy"
- Verify: a link in Settings / sign-up that actually opens (no 404). Content covers the items above, third parties (Firebase, ad SDKs, AI providers…), deletion, contact, and names the developer entity. The URL field is filled in ASC and Play Console. Apple's App Review page also lists "Broken links… a link to your privacy policy is required for all apps" among top rejection reasons.
- Signals: `legal.privacy`, URL candidates
- Fix: publish the policy (Notion/static page) → link in Settings + sign-up → register the URL in both consoles.
- Evidence: console screenshots.
- Hosting defects that got apps rejected on Play: GitHub Markdown, Blogspot, PDF, JavaScript-only pages, editable blog posts, private/geofenced URLs. Host a plain, public, fixed HTML page on your own domain. [cases](../rejections/community-cases.md#user-data-privacy-policy-data-safety-prominent-disclosure)

### PRIV-02 Privacy labels match reality (App Privacy / Data safety)
- Basis: Apple App Privacy Details / Play Data safety — mismatch with actual collection is a rejection / policy violation
- Verify: derive collection from the SDK list: Firebase Auth (email, name, ID), Analytics (usage data, device ID), Crashlytics (diagnostics), AdMob (advertising ID, coarse location), Kakao (nickname, profile, email). Compare with the console declarations.
- Signals: `SDK / dependencies` section
- Fix: update the console declarations from the SDK list. For Firebase use the per-SDK table in Firebase's privacy docs.

### PRIV-03 Tracking / advertising-ID consent
- Basis: Apple 5.1.2(i) "You must receive explicit permission from users via the App Tracking Transparency APIs to track their activity… Your app may not require users to enable system functionalities (e.g. push notifications, location services, tracking) in order to access functionality, content, use the app, or receive monetary or other compensation"; fingerprinting is prohibited ("you may not derive data from a device for the purpose of uniquely identifying it") / Play **Ads**: "The Android advertising identifier (AAID) must only be used for advertising and user analytics"; **Advertising ID**: apps targeting Android 13+ must declare `com.google.android.gms.permission.AD_ID`; declare "advertising identifier" under Device or other IDs in Data safety; Android ID is no longer treated as a persistent identifier (2025-04)
- Applies: ad SDKs, attribution (AppsFlyer/Adjust), analytics used for advertising
- Verify: iOS — ATT request code + `NSUserTrackingUsageDescription` + "Tracking" in App Privacy; an SDK that combines data across apps counts as tracking "even if you don't use the SDK for these purposes". No feature or reward gated on accepting. Android — AD_ID in the manifest (ad SDKs merge it), Data safety advertising ID, respect opt-out/reset.
- Signals: `ads.sdk`, `track.att`, `track.adid`
- Fix: show the ATT prompt **before** initializing ads (after onboarding). App must work when denied. IDFV for same-vendor analytics doesn't need ATT.
- Evidence: none (code).

### PRIV-04 Prominent disclosure & data minimization
- Basis: Apple 5.1.1(iii) "Where possible, use the out-of-process picker or a share sheet rather than requesting full access to protected resources like Photos or Contacts" / Play **Prominent disclosure and consent** — required when access "may not be within the reasonable expectation of the user" (location for ads, contacts upload, background collection): "Must be within the app itself… displayed in the normal usage of the app and not require the user to navigate into a menu… Must describe the data being accessed or collected… Must explain how the data will be used and/or shared"; consent "Must require affirmative user action (for example, tap to accept, tick a check-box)", "Must not interpret navigation away from the disclosure as consent", "Must not use auto-dismissing or expiring messages", and must come before the runtime permission
- Verify: location used for ads/analytics? contacts uploaded? background collection? → an in-app disclosure screen in Google's format: **"[This app] collects/transmits/syncs/stores [type of data] to enable ['feature'], [scenario]."**
- Signals: `perm.*`, `ads.sdk`
- Fix: a dialog immediately before the permission request with an explicit Accept action; prefer pickers (Photo Picker, contact picker, share sheet) over broad permissions.

### AI-01 AI features (third-party AI sharing, AI-generated content)
- Basis: Apple 5.1.2(i) (2025-11) "You must clearly disclose where personal data will be shared with third parties, including with third-party AI, and obtain explicit permission before doing so" / Play **AI-Generated Content**: "Apps that generate content using AI must contain in-app user reporting or flagging features that allow users to report or flag offensive content to developers without needing to exit the app"; Play User Data requirements "apply to third-party AI integrations" (2026-07)
- Applies: any call to OpenAI/Gemini/Claude/etc. with user data; AI chat, summaries, image generation
- Verify: a disclosure (privacy policy + in-app, before the first AI call) that user content is sent to <provider>; an explicit permission step; a report/flag control on AI output; AI output subject to the same UGC filter/report rules.
- Signals: `ai.sdk`
- Fix: consent screen before first AI use; "Report this response" on AI output; list the AI provider in the privacy policy and Data safety (shared data).

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

### PERM-03 No unused permissions
- Basis: Play permissions policy / Apple reviewers ask "why do you need this?"
- Verify: manifest/plist permissions not used in code. SDK-merged ones (READ_PHONE_STATE etc.) removed via `tools:node="remove"`.
- Signals: permission list vs `perm.*`
- Fix: remove; if kept, justify in review notes.

---

## PAY — payments

### PAY-01 Digital goods through IAP / Play Billing
- Basis: Apple 3.1.1 "If you want to unlock features or functionality within your app… you must use in-app purchase"; 3.1.1(a) (2025-05): buttons/external links to other purchase methods are allowed **only on the United States storefront** without an entitlement; "In all other storefronts… apps and their metadata may not include buttons, external links, or other calls to action that direct customers to purchasing mechanisms other than in-app purchase" (regional entitlement programs: EU, Korea, Japan — see IOS-IAP-02) / Play **Payments**: Play billing required for "in-app features or services, including any app functionality, digital content or goods"; must not steer users to alternatives via the listing, in-app promotions, webviews, buttons, links or ads; regional programs: Korea alternative billing (alongside Play billing), EEA alternative billing/external offers, US external content links + alternative billing (comply since 2026-01-28), Japan external payments; global fee changes from 2026-06-30 (EEA/UK/US), KR/JP 2026-12-31
- Applies: premium unlock, subscriptions, coins, themes
- Verify: selling digital goods via Stripe/Toss/iamport etc. → FAIL. Physical goods and offline services must **not** use IAP (Apple 3.1.3(e)); social "boosts"/promoted posts must use IAP (3.1.3(g)). "Cheaper on the web" copy → FAIL outside the US.
- Signals: `pay.external`, `pay.iap`
- Fix: switch to StoreKit / Play Billing or RevenueCat. Remove web-payment prompts/links, or gate them by storefront/region under an approved program.

### PAY-02 Subscription disclosure + terms links
- Basis: Apple 3.1.2(a) "the subscription period must last at least seven days and be available across all of the user's devices"; 3.1.2(c) "Before asking a customer to subscribe, you should clearly describe what the user will get for the price"; Schedule 2 requires Terms of Use (EULA) and privacy-policy links in the app and in metadata / Play **Subscriptions**: disclose "the cost of your subscription, the frequency of your billing cycle, the automatic renewal terms"; trials must "clearly and accurately describe the terms of your offer, including the duration, pricing… how it converts, how to cancel"; and the app must "clearly disclose how a user can manage or cancel their subscription" with an easy online method in "your app's account settings (or equivalent page)" (clarified 2025-10-30)
- Verify: paywall shows price, period, auto-renew wording, terms/privacy links, "Restore purchases". Free trial → post-trial price and conversion date. Settings has "Manage subscription" (link to Play Subscription Center / App Store subscriptions).
- Signals: `pay.iap`, `legal.terms`
- Fix: standard footer text + links on the paywall; EULA URL in the ASC "License Agreement" field (or Apple's standard EULA); a manage/cancel link in account settings.
- From cases: links must be in the app **and** in the App Store description; the billed amount must be more prominent than the intro price; no "ongoing value" → use non-renewing subscriptions; Play wants price, cycle, conversion date and cancel path on one simple paywall. [cases](../rejections/community-cases.md#312-subscriptions)

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

### CONTENT-02 No test/debug leftovers
- Verify: debug menus, staging URLs, test payment keys, personal data in logs, `usesCleartextTraffic=true`.
- Signals: `test.keys`, `cleartext`
- Fix: exclude from release builds.

### CONTENT-03 Minimum functionality — no web wrappers
- Basis: Apple 4.2 (websites wrapped in an app, marketing-only apps, single-feature apps) / Play Minimum functionality
- Applies: WebView is the main UI
- Verify: meaningful native functionality (push, camera, offline, widgets…).
- Signals: `webview`

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

### CONTENT-06 Ratings prompts & incentives
- Basis: Apple 5.6.1 "Use the provided API to prompt users to review your app… we will disallow custom review prompts"; 3.2.2(x) "Apps must not force users to rate the app, review the app, download other apps, or other store-related actions in order to access functionality, content, or use of the app" / Play — no rewards or gating for reviews
- Verify: custom "rate 5 stars for premium" → FAIL. Only `SKStoreReviewController` / `requestReview` (iOS) and the In-App Review API (Android).
- Signals: `review.prompt`

### CONTENT-07 Saturated categories — "simple timers" need a meaningfully different experience
- Basis: Apple 4.3(b) (2026-06 wording): "Certain kinds of apps, such as dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling, are well established on the App Store and we will not accept new submissions unless they offer a meaningfully different or improved experience. We may remove these apps from the App Store going forward if they are not updated, improved, or do not attract customers"; 4.3(a) no multiple Bundle IDs of the same app; 4.2 "not particularly useful, unique, or 'app-like'" / Play **Functionality, Content, and User Experience**: "We do not allow apps that only have limited functionality and content"
- Applies: timer/focus, wallpaper, sound, flashlight, dating, fortune-telling, template-generated apps
- Verify: what makes the app different (social features, sync, analytics, widgets, unique mechanic)? Is that difference visible on the first screen, in screenshots and in the description?
- Signals: app name / description keywords (`saturated.category` hint)
- Fix: lead the store description and Notes for Review with the differentiator; make it visible in screenshots; don't submit near-duplicates under new bundle IDs.
- From cases: what actually cleared 4.3 was a **significantly different icon + UI** plus a real new feature; color-only changes and appeals alone did not. After an appeal succeeds, add a reviewer note on every later update. [cases](../rejections/community-cases.md#43-spam--duplicates--templates)

### CONTENT-08 Recording consent & indicator
- Basis: Apple 2.5.14 "Apps must request explicit user consent and provide a clear visual and/or audible indication when recording, logging, or otherwise making a record of user activity. This includes any use of the device camera, microphone, screen recordings, or other user inputs" / Play Device & Network Abuse, Stalkerware
- Applies: audio/video recording, screen recording, keystroke/usage logging
- Verify: consent before recording + a visible indicator while recording.
- Signals: `perm.mic`, `perm.camera`

### CONTENT-09 IPv6-only networking
- Basis: Apple 2.5.5 "IPv6-only network" support required since 2016; a frequent hidden cause of "the app crashed / could not load content" 2.1 rejections when the backend or SDK uses IPv4 literals
- Verify: no hard-coded IPv4 addresses; test with macOS "Create NAT64 Network" hotspot.
- Fix: use hostnames; ensure the API host has AAAA/NAT64 compatibility.

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

---

## META — store metadata (outside the code)

### META-01 Screenshots show the app in use
- Basis: Apple 2.3.3 — screenshots show the app in use, not splash/login/title art; device frames and captions allowed / Play Metadata policy — accurately reflect the app
- Verify: required sizes (iPhone 6.9", iPad 13") and content. If made with the `store-screenshots` skill, the framed screen must be the real app.

### META-02 Description, keywords, name
- Basis: Apple 2.3.7 "App names must be limited to 30 characters"; no trademarked terms, popular app names or pricing in metadata; 2.3.2 IAP disclosure in description/screenshots; 2.3.8 metadata suitable for 4+; 2.3.12 meaningful "What's New" for significant changes / Play **Metadata**: title ≤ 30 chars; no "emojis, emoticons, or repeated special characters"; no store-performance, ranking, price or promotional text in title/icon/developer name ("App of the year", "#1", "Best of Play", "10% off", "free for limited time only", "Editor's choice", "New"); no all caps unless brand; no "unattributed or anonymous user testimonials"; **Deceptive Behavior**: no false or misleading claims in title/description/icon/screenshots
- Verify: promises of unreleased features, other-platform mentions (CONTENT-04), other apps' names, promo words, emojis in the title.
- From cases: "Tutorial & Rules" (implied external content), Spanish "libre" (read as "free"), "ChatGPT" in a name, "Anonymous/匿名" keywords, brand names of hardware — all rejected. [cases](../rejections/community-cases.md#metadata--misleading-claims)

### META-03 Age-rating questionnaire
- Basis: Apple 2.3.6 "Answer the age rating questions in App Store Connect honestly"; new tiers 4+/9+/13+/16+/18+ with new questions (in-app controls, capabilities, medical/wellness, violence) — responses were required by 2026-01-31; **social-media questions required for submissions from 2026-09**; declaring the "Social Media" capability sets a minimum 13+ rating (iOS 27 Time Allowances) / Play **Content Ratings** (IARC): "All apps must have a content rating… Apps without a content rating will be removed"; "Misrepresentation of your app's content may result in removal or suspension"; interactive element "Users Interact" covers user-to-user communication and media sharing
- Verify: **with UGC, chat or friends, answer "users interact / UGC / messaging" = Yes**; unrestricted web access if a WebView browses the web; loot boxes/gambling questions if applicable. Re-submit the questionnaire when features change.
- Signals: `ugc.*`, `webview`
- Cases: see community cases tagged META-03

### META-04 URLs work
- Verify: support, marketing and privacy URLs return 200 with content. Notion pages: "publish to web" on.

### META-05 Review notes
- Basis: Apple 2.3.1(a) "All new features, functionality, and product changes must be described with specificity in the Notes for Review section of App Store Connect (generic descriptions will be rejected) and accessible for review"; App Review page: "Incomplete information" (demo account, special configurations, demo video/hardware) is a top rejection reason / Play Sign-in details (AND-CONSOLE-03)
- Verify: `templates/review-notes.md` content is in ASC App Review Information (Notes ≤ 4000 bytes, contact phone in international format) / Play Sign-in details. Demo account + feature locations + recording link + background-mode reason + IAP location + anything hidden behind conditions (region, time, role).

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

---

## LAW — regional age-assurance laws (2026)

### LAW-01 Age-assurance requirements by region
- Basis: Apple news 2026-02-24 / 2026-06-03: apps rated 18+ are blocked in Brazil, Australia and Singapore without adult confirmation (2026-02-24); **Texas SB 2420** in force 2026-06-04 (parental consent for downloads, IAP and significant changes — Declared Age Range API, Significant Change API, consent-revocation server notifications), Utah (2026-05-06), Louisiana (2026-07-01); Australia under-16 social-media law (2025-12-10) — Declared Age Range API, Age Suitability URL / Play **Age Signals API** data-use restrictions (2026-01-01) and Age-Restricted Content tools
- Applies: social media, dating, chat, 18+ content, apps with IAP distributed in those regions
- Verify: whether the app reads the Declared Age Range API / Play Age Signals and adjusts features; whether significant changes are declared; an Age Suitability URL where required.
- Signals: `ugc.*`, `pay.iap`
- Fix: adopt the age APIs; provide an age-suitability page; keep the age rating current (META-03).
- Evidence: none (platform-side).

