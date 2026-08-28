# Android checklist — Google Play policies

Google Play-only items. Feature-conditional items (UGC, account, payments…) live in `common.md`.
Written as of 2026-08-28 against the Policy Center (https://support.google.com/googleplay/android-developer/topic/9858052) and Play Console Help. Korean: `ko/android.md`. Sources: `../references/google-play.md`.

---

## SDK & build

### AND-SDK-01 Target API level
- Basis: **Target API level requirement** (verbatim, 2026): "New apps and app updates must target Android 16 (API level 36) or higher to be submitted to Google Play; except for Wear OS, and Android Automotive OS apps, which must target Android 15" — deadline **2026-08-31**; "Existing apps must target Android 15 (API level 35) or higher to remain available to new users"; "You will be able to request an extension to November 1, 2026". The bar moves every August 31.
- Verify: the `targetSdk` number. Flutter's `flutter.targetSdkVersion` depends on the Flutter SDK (3.27+ → 35, 3.35+ → 36; confirm) → `flutter --version` + `flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`. Expo SDK 52+ → 35, SDK 54+ → 36 (confirm).
- Signals: `Android Gradle` section, auto-hints
- Fix: raise `targetSdk` and handle that version's behavior changes (FGS types and start restrictions, photo permissions, notification permission, edge-to-edge (35+), 16 KB pages).

### AND-SDK-02 16 KB page size
- Basis: "Starting November 1st, 2025, all new apps and updates to existing apps submitted to Google Play and targeting Android 15+ devices must support 16 KB page sizes"; "Starting February 1, 2027, if your app updates don't support 16 KB memory page sizes, you won't be able to release these updates"; technical quality: "Apps that contain native code must support devices with 16 KB memory page sizes. Java/Kotlin only apps are compatible by default." (TV 2026-08-01, Wear 2026-09-15)
- Verify: apps with `.so` files (Flutter, RN, SQLite…) build with AGP 8.5.1+ / NDK r28+; Play Console App bundle explorer shows a warning otherwise.

### AND-BUILD-01 Signing & bundle
- Verify: AAB upload (required for new apps since 2021-08), signed with the upload key (no `signingConfigs.debug` in release; upload key "Must be an RSA key of 2048 bits or more"), Play App Signing enrolled, `debuggable false`, `minifyEnabled` (25% code optimization becomes a quality requirement 2027-02), arm64-v8a included ("Apps that contain native code must support 64-bit only architectures").
- Signals: Gradle section
- Korean cases: `versionCode` must strictly increase across versionName bumps (`1.0.1+0` after `1.0.0+7` was refused as "앱 업데이트가 거부되었습니다"); an AAB built on another machine with a different upload key fails re-review.

### AND-BUILD-02 Manifest essentials
- Verify: explicit `android:exported` (API 31+, components with intent filters), remove `usesCleartextTraffic="true"` or restrict via network_security_config, intentional `allowBackup`.
- Signals: Manifest section

---

## Permissions (Play permissions policy + declaration forms)

### AND-PERM-01 SMS & Call Log
- Basis: "Apps must be actively registered as the default SMS, Phone, or Assistant handler before prompting users to accept any of SMS or Call Log permissions." OTP → SMS Retriever API / User Consent API. From **2027-01-27** READ_CALL_LOG is no longer permitted for "account verification via phone call" (use Digital Credentials API / SMS Retriever).
- Signals: auto-hints
- Fix: remove; switch to SMS Retriever.

### AND-PERM-02 QUERY_ALL_PACKAGES
- Basis: only when the core feature needs the installed-app list (launchers, security, app managers). Otherwise `<queries>` for specific packages. Requires the Play Console declaration form.
- Applies: focus apps that want to show "apps to block" — replace with category-intent `<queries>` or explain core use in the form.

### AND-PERM-03 MANAGE_EXTERNAL_STORAGE (All files access)
- Basis: file managers / backup only. Declaration form + video. Most apps use Scoped Storage / SAF / Photo Picker instead.

### AND-PERM-04 Background & precise location
- Basis: "Background location may only be used when it provides a significant benefit to users and is relevant to the core functionality of the app"; "never request location permissions… for the sole purpose of advertising or analytics". Declaration: one feature needing background, why foreground is insufficient, **video ≤ 30 s** showing the disclosure + runtime prompt. Prominent disclosure format: "[This app] collects location data to enable [feature]… even when the app is closed or not in use." 2026-04-15: the **location button** is "the recommended minimum scope for precise location"; Location policy update effective **2027-01-27** (`onlyForLocationButton` on Android 17+).
- Verify: `ACCESS_BACKGROUND_LOCATION` only with a core feature; disclosure before the prompt (PRIV-04); precise location only if needed.

### AND-PERM-05 Foreground service types
- Basis: targetSdk 34+ requires `<service android:foregroundServiceType="…">` plus the matching `FOREGROUND_SERVICE_<TYPE>` permission; missing → runtime exception. Play Console **Foreground service permissions** declaration per type: "Provide a description of the app functionality that is using each foreground service type", "Describe the user impact if the task is deferred… and/or interrupted", "Include a link to a video demonstrating each foreground service feature". Types: camera, connectedDevice, dataSync, health, location, mediaPlayback, mediaProcessing, mediaProjection, microphone, phoneCall, remoteMessaging, shortService, specialUse, systemExempted. Android 15+: dataSync/mediaPlayback etc. cannot start from BOOT_COMPLETED; mediaProcessing limited to 6 h per 24 h; `specialUse` requires `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` which is "reviewed when you submit your app". Geofencing removed as an FGS use case from 2027-01-27.
- Type guide: keeping a timer notification alive → `specialUse` (subtype property + form) or `shortService` (3 min). White-noise playback → `mediaPlayback`. Tracking → `location`. Uploads → `dataSync` (restricted).
- Signals: auto-hint (`FOREGROUND_SERVICE` without a type)
- Fix: manifest type + permission + `startForeground(id, notification, type)` + console form + demo video.
- Play 2nd-pass cases: SDKs (Zoom Meeting SDK, background-geolocation, expo-video) declare FGS types you don't use — remove the matching `FOREGROUND_SERVICE_*` permissions and `tools:replace="android:foregroundServiceType"` on the SDK service; Organic Maps was refused `specialUse` ("when it is not required to do so") until it used typed services with per-feature videos; `FOREGROUND_SERVICE_SPECIAL_USE` in the manifest alone triggers the declaration gate on upload.

### AND-PERM-06 Accessibility services
- Basis: `BIND_ACCESSIBILITY_SERVICE` only for assisting users with disabilities. Other uses (app blocking, automation) must be declared as "non-accessibility" in the form + prominent disclosure + consent. High rejection rate.
- Applies: focus apps blocking other apps — UsageStats (AND-PERM-07) + overlay passes more often.
- From cases: after removing the accessibility service you must also delete the Accessibility declaration in Play Console (App content), or the app keeps getting rejected. Disclosure in the store description does not count — it must be in-app before enabling.

### AND-PERM-07 Usage stats (PACKAGE_USAGE_STATS)
- Basis: a signature permission granted by the user in Settings. Must be a core feature, with prior disclosure. Declare "App activity > Installed apps" etc. in Data safety.
- Applies: focus apps measuring app usage time
- Verify: a disclosure screen before sending the user to Settings.

### AND-PERM-08 Photo & video permissions
- Basis: **Photo and Video Permissions policy** — apps targeting API 33+ may request `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` only if "system pickers (like the Android Photo Picker), are not sufficient for your app to provide core functionality" (gallery-type apps); custom pickers "must still submit a declaration". Phase 1 2025-01-22; "May 28, 2025: Full policy compliance is mandatory for all developers". Picking one profile photo → **Photo Picker**.
- Verify: `image_picker` (Flutter 0.8.9+ uses the Photo Picker, no permission needed) etc. leaving the permission in the manifest → remove with `tools:node="remove"`. Answer the "Photo and video permissions" declaration in the console.
- Signals: auto-hint
- Cases: community cases tagged AND-PERM-08

### AND-PERM-09 Overlay (SYSTEM_ALERT_WINDOW)
- Basis: policy relaxed, but a malware indicator. Needs a reason and a user-grant flow. Focus apps' blocking screens have passed.

### AND-PERM-10 Exact alarms & full-screen intents
- Basis: `USE_EXACT_ALARM` only when "core, user-facing functionality requires precisely-timed actions, such as: The app is an alarm or timer app. The app is a calendar app that shows event notifications." Others use `SCHEDULE_EXACT_ALARM` (user-granted) or inexact alarms. `USE_FULL_SCREEN_INTENT`: "Only apps whose core functionality is a high-priority use case of setting an alarm or receiving phone or video calls will be automatically granted"; others must request the user permission and "gracefully degrade" (declaration since 2024-05-31; default-off for others since 2025-01-22). Device & Network Abuse bans "Apps that use the full-screen intent permission to force user interaction with disruptive ads or notifications."
- Applies: timer-end alerts
- Verify: a timer app justifies `USE_EXACT_ALARM` (declare it). Notification channel importance; full-screen intent usage.
- From cases: `USE_FULL_SCREEN_INTENT` often arrives from notification libraries — remove with `tools:node="remove"` if not an alarm/call app; check `canScheduleExactAlarms()` before scheduling on Android 14+ (Play flags apps that don't).
- Play 2nd-pass cases: Notifee < 9 adds `USE_FULL_SCREEN_INTENT`; ML Kit's datatransport telemetry uses `AlarmManager.setExact` → exact-alarm warnings; the Play Developer API refuses uploads with "You must let us know whether your app uses any exact alarm permissions" until the declaration exists. A non-alarm app that auto-dismissed its full-screen intent after a few minutes passed.

### AND-PERM-11 POST_NOTIFICATIONS (13+)
- Verify: targetSdk 33+ requires the runtime notification permission. Denied → timer-end notifications won't show, so request in context + explain on denial.

### AND-PERM-12 Contacts (Android 17 / API 37)
- Basis: apps targeting Android 17 (API 37)+ may request `READ_CONTACTS` only if "the Android Contact Picker is not sufficient for your app to provide core functionality"; declaration form ~2026-09, mandatory **2027-01-27**
- Applies: friend-finding from contacts, invitations
- Verify: use the contact picker for "invite a friend"; broad access only for contact-manager-type apps + declaration + prominent disclosure (PRIV-04).

### AND-PERM-13 Merged-manifest audit — permissions injected by libraries
- Basis: the single most common Play rejection root cause in community cases: `READ_MEDIA_IMAGES/VIDEO`, `READ_EXTERNAL_STORAGE`, `FOREGROUND_SERVICE_*` types, `QUERY_ALL_PACKAGES`, `USE_FULL_SCREEN_INTENT`, `ACCESS_BACKGROUND_LOCATION`, `AD_ID` arrive through manifest merging from image_picker, file_picker, permission_handler, expo-image-picker, expo-video, Agora, upload/download libraries, notification plugins…
- Applies: every app (check on each dependency upgrade)
- Verify: inspect the **merged** manifest (`build/intermediates/merged_manifests/release/AndroidManifest.xml`, Android Studio "Merged Manifest" tab, or `bundletool dump manifest`). Compare with what the app actually uses.
- Signals: dependency list (`camera/media`, `background`, `push`), auto-hint
- Fix: `<uses-permission android:name="…" tools:node="remove"/>` in the app manifest (Expo: `android.blockedPermissions` in app.json); then re-check the merged manifest. Note that Play may still cite an older build — see AND-CONSOLE-11.
- Cases: [community — Photo & Video](../rejections/community-cases.md#photo-and-video-permissions-read_media_images--video), [foreground services](../rejections/community-cases.md#foreground-service-declarations)

### AND-PERM-14 VpnService
- Basis: VpnService only for core VPN plus parental control/enterprise, app-usage tracking, device security, network tools, browsers, carrier apps; never "Collect personal and sensitive user data without prominent disclosure and consent" or "Redirect or manipulate user traffic… for monetization". Rejection text: "We are unable to confirm your app's declared use of VpnService as a permitted use case… should be removed from the app manifest across all release tracks."
- Applies: `perm.vpn` > 0
- Verify: use case matches the list; declaration form submitted; VpnService removed if not core.

### AND-PERM-15 REQUEST_INSTALL_PACKAGES
- Basis: "Permission use is not directly related to your app's core purpose. We found that your app is not compliant with how REQUEST_INSTALL_PACKAGES permission is allowed to be used… Please remove the use of REQUEST_INSTALL_PACKAGES permission from your app." Allowed only for apps whose core purpose delivers packages (browsers, file sharing/transfer, enterprise device management, backup/restore).
- Applies: injected by `open_file` (Flutter), in-app updater plugins, file managers
- Verify: not in the merged manifest unless the app installs packages; declaration submitted if it does.
- Fix: switch plugin (`open_filex`) or `tools:node="remove"`.
- Cases: [Play 2nd pass](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### AND-SEC-01 App-security scanner flags
- Basis: Play's security review rejects builds for "Leaked AWS credentials / Your app contains Exposed Amazon Web Services Credentials", "intent scheme hijacking" (`Intent.parseUri` from web content in `shouldOverrideUrlLoading`), "Your app(s) are using a WebView that is vulnerable to cross-app scripting" (unvalidated `loadUrl` from intents/push), and warns on "Authentication via WebView"
- Applies: any app with a WebView, embedded cloud keys, or WebView-based OAuth
- Verify: no client-side secrets (use pre-signed URLs / a backend); validate every URL before `loadUrl` (`Patterns.WEB_URL`, allow-list hosts); never parse `intent://` URIs from web content; OAuth via Custom Tabs / AppAuth, not a WebView.
- Fix: as above; resubmit — the scanner re-checks the new AAB.
- Cases: [Play 2nd pass](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

---

## Play Console declarations (outside the code)

### AND-CONSOLE-01 Privacy policy URL
- Basis: required for all apps (2024~). Store listing + in-app link. `common.md` PRIV-01.

### AND-CONSOLE-02 Data safety
- Basis: declare collection, sharing and security practices accurately, including SDKs. Includes the account-deletion URL (AND-CONSOLE-08). Mismatch → policy notice / update rejection.
- Verify: compare with the `common.md` PRIV-02 SDK table. "Encrypted in transit", "deletion request method".

### AND-CONSOLE-03 Sign-in details (formerly "App access")
- Basis: Play Console > Policy and programs > App content > **Sign-in details** ("up to five sets of instructions"; "Any other instructions" for OTP/MFA). Requirements: "Your sign-in details must be accessible at all times, reusable, and valid regardless of user location… If your app typically requires a 2-Step verification code or One-time password, make sure to provide reusable login credentials that can bypass these requirements… must be provided in English… If the provided password expires, we may not be able to review your app and, therefore, the app may be rejected." Paywalled content needs access instructions too. Rejections show up as "Broken Functionality" / could not verify.
- Verify: `templates/review-notes.md` Android part; social-login-only → email reviewer account (ACC-03); credentials tested from a foreign IP.
- Korean cases: Play does **not** accept demo videos instead of credentials; QR/hardware-gated apps must provide long-lived codes; Hangul IDs and admin accounts are refused; Kakao/Naver/Google-only login is not accepted — add ID/password login (ACC-05).

### AND-CONSOLE-04 Advertising ID & "contains ads"
- Basis: `AD_ID` permission declaration (targetSdk 33+, merged by ad SDKs) + Data safety advertising ID + "Contains ads" declaration. Not using the ad ID → `tools:node="remove"` and answer "No".
- Signals: auto-hint
- Play 2nd-pass cases: with Firebase Analytics and no ads, answer the Advertising ID declaration **Yes** (analytics use case) rather than stripping the permission — Google support's own advice; contradictory errors in both directions usually mean an older active bundle differs (AND-CONSOLE-11).

### AND-CONSOLE-05 Content rating (IARC)
- Basis: unfinished questionnaire blocks publishing. **UGC / chat / friends → answer "users interact / share information" = Yes.** False answers are a suspension reason.
- Verify: `common.md` META-03.

### AND-CONSOLE-06 Sensitive-permission declaration forms
- Basis: foreground services, exact alarms, full-screen intents, photo/video, background location, All files access, QUERY_ALL_PACKAGES, accessibility, SMS… require the App content > Sensitive app permissions / Foreground service forms. Each: core-feature explanation + demo video (unlisted YouTube link OK).
- Verify: manifest permissions ↔ submitted forms.
- From cases: CI/CD uploads (Fastlane / Play API) skip the Console prompt that surfaces new declaration forms — upload the AAB **once through the Console UI** when a new sensitive permission appears; the demo video must show the permission/FGS feature itself, not generic gameplay; declared types must match what the code actually starts.

### AND-CONSOLE-07 Target audience & children
- Basis: Target audience and content questionnaire (age groups 5 and under / 6–8 / 9–12 / 13–15 / 16–17 / 18+). Including children triggers the **Families policy**: "Only use Google Play Families Self-Certified Ads SDKs" (the program is "currently not accepting new applicants"; AdMob ≥19, Unity Ads, ironSource… listed; AppLovin exited), no interest-based ads, child-only apps must not transmit AAID/IMEI etc., AR safety warning, social apps "an in-app reminder to be safe online"; mixed audience → "a neutral age screen must be implemented"; "Google Play may reject your app" if assets appeal to children unintentionally; review "up to 7 days or longer". Since 2026-07-15 social apps focused on chatting with strangers or anonymously must not target children.
- Verify: store copy ("students", "kids") ↔ target audience; ad SDK is on the self-certified list if children are included.
- Play 2nd-pass cases: "non-certified ad SDKs" fired for Stripe (not an ad SDK), Adjust, Amplitude, AdMob without child-directed tagging; the fix is `tagForChildDirectedTreatment` / removing the SDK / `AD_ID tools:node="remove"`. A **neutral age screen** must let users freely enter month/day/year — three age buttons are not neutral — and nothing (Play Games auto sign-in, analytics) may send the AAID before it. "App stability" rejections under Families came from on-demand asset packs failing in the review environment (AND-REVIEW-01).

### AND-CONSOLE-08 Account-deletion URL
- Basis: apps with account creation must provide Data safety > "Account deletion request URL" + in-app deletion. `common.md` ACC-02.

### AND-CONSOLE-09 Mandatory declarations — even when the answer is "none"
- Basis: **Health apps declaration**: "All developers that have an app published on Google Play must complete the Health apps declaration, including apps on closed testing, open testing, or production tracks" (required after 2024-08-31). **Financial features declaration**: mandatory for every app ("My app doesn't provide any financial features" option); since 2025-10-30 "you will not be able to make any updates to your app(s) until you complete this declaration". **News & Magazines** self-declaration (removal for non-compliance, 2026-05-27 reminder). **Government apps** declaration (since 2023-01-31). Also: COVID-19, Blockchain (via Financial features), VPN.
- Verify: App content page shows every declaration completed. A focus timer using "mental health" wording may be a Health app (Health Content and Services policy).
- From cases: Health Connect and Financial declarations are judged from the **full store description** — list each data type and why it is needed; loan/SIP calculators declared "no financial features" got rejected; keep policy URLs public.

### AND-CONSOLE-10 Child Safety Standards self-certification
- Basis: Social & Dating apps (since 2025-01-22) and anonymous/random chat apps (since 2026-07-15) must "Have published standards against child sexual abuse and exploitation (CSAE)" at a globally accessible URL, "Provide an in-app mechanism for user feedback", address CSAM, comply with child-safety laws, "Provide a child safety point of contact", and self-certify in Play Console before publishing. Dating / random / anonymous-chat / gambling apps must use Play Console tools to block minors (Age-Restricted Content policy).
- Applies: Social/Dating category, chat with strangers, anonymous chat (see common UGC-07)
- Verify: the CSAE standards page URL; contact; Play Console App content > Child safety standards completed.

### AND-CONSOLE-11 Deactivate old builds in every track before resubmitting
- Basis: rejections repeatedly cite an **older version code** (e.g. "Remove the use of … permission from all version codes within the submission") because internal/closed/open tracks still carry a build with the offending permission, target API or crash.
- Applies: every resubmission after a permission/targetSdk/crash fix
- Verify: Play Console > Releases: every active track's latest release is the fixed build (or the track is paused/deactivated); App bundle explorer shows no older bundles with the permission.
- Fix: promote the fixed build to all tracks or deactivate them; then resubmit; still submit any required declaration form even if the permission is now gone.
- Cases: [community](../rejections/community-cases.md#photo-and-video-permissions-read_media_images--video)
- Korean case: the violation cited version code 3 in the **open-testing** track after VC 6 was fixed — create a release in that track from the fixed bundle so the old one deactivates; test-track bundles cannot be deleted, only overlaid.

### AND-CONSOLE-12 Government-information apps
- Basis: Misleading Claims rejections "Your app doesn't provide a clear source of government information or its description lacks an easy-to-see disclaimer stating that the app doesn't represent a government entity" / "Identify a clear source of government information"; disclaimers alone rarely pass — cases passed only with the Government apps declaration + written authorization, an in-app about/disclaimer page, and fully-formed source URLs in the description (reviewers copy them verbatim)
- Applies: apps republishing or embedding government/public-sector content (also see AND-META-04 for Korean cases)
- Verify: Government apps declaration answered; authorization letter if claiming affiliation; disclaimer in the listing **and** in-app; every source URL complete and reachable; no embedded government websites without permission.
- Cases: [Play 2nd pass](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

---

## Store listing

### AND-META-01 Metadata policy
- Basis: app title "30 characters or less"; no "emojis, emoticons, or repeated special characters"; no text or image "that indicate store performance or ranking, price or promotional information" in title, icon or developer name ("App of the year", "#1", "Best of Play", "10% off", "free for limited time only", "Editor's choice", "New"); no all caps unless brand; no misleading symbols in icons; no "unattributed or anonymous user testimonials"; **Deceptive Behavior**: no "false or misleading information or claims, including in the description, title, icon, and screenshots"; **Impersonation**: no titles like "<celebrity> Official" without rights.
- Verify: title, short description (80), full description, icon.

### AND-META-02 Screenshots & graphics
- Basis: store listing assets — icon 512×512 32-bit PNG with alpha ≤ 1024 KB; feature graphic 1024×500 JPEG/24-bit PNG (no alpha) required; screenshots min 2 (for featuring: ≥4 at ≥1080 px, 16:9 or 9:16), 320–3840 px; tablet screenshots ≥4 at 1080–7680 px; promo video = public/unlisted YouTube URL, ads disabled, embeddable. Must accurately represent the app.

### AND-META-03 Developer information
- Basis: email required; organizations need D-U-N-S + public address/phone (2024~); individuals show name + email; address public for paid/IAP apps.

### AND-META-04 Source citations & non-affiliation for public-information apps
- Basis: Play "Misleading claims" rejection "제공된 출처가 불충분함": government/public-information apps must cite every source with a working official URL and must not imply government affiliation ("공식", "정부 제공", "국가 인증")
- Applies: apps republishing government, medical, legal or financial information
- Verify: each content item links to its official source; a disclaimer such as "This app is not affiliated with or endorsed by any government agency" in the listing and in-app.
- Cases: [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

---

## Testing & account

### AND-TEST-01 Closed testing for new personal accounts
- Basis: **personal** accounts created after 2023-11-13 must run a closed test with **12+ testers opted in for 14 consecutive days** before applying for production access (questionnaire).
- Verify: account creation date and type. If it applies, plan at least two weeks.
- From cases: Google rejects production access when "testers did not engage" — 12 opted-in accounts that never open the app fail; give testers free rein, then answer the production-access questions with ≥ 3 substantive lines each (crash-free statement, concrete feedback, planned changes).
- Korean cases (2024–2026): keep ≥ 12 opted-in testers **until the end** (recruit 30+; 품앗이 / paid testers drop out), require real sessions, ship 2–3 updates during the test, answer each questionnaire item in detail; a stalled application was approved the day after the closed track was updated.

### AND-ACCOUNT-01 Account verification
- Basis: identity verification (ID, phone, email); organizations need D-U-N-S. Publishing is blocked until complete.
- Korean cases: 주민등록등본 (정부24) passes fastest, but the payments-profile address must match the document character-for-character (지번 vs 도로명); mask ID digits; statements without an address fail.

### AND-ACCOUNT-02 App registration (2026) & organization requirement
- Basis: Play Console requires **app registration by 2026-09-30** — unregistered apps face "global removal from Google Play"; financial, health, VPN and government apps "must register as an Organization" (D-U-N-S). Developer details (legal name/address/email/phone) are shown publicly; monetizing accounts must show their full address.
- Verify: every published app registered; account type matches the app category.
- Play 2nd-pass cases: "Some types of apps can only be distributed by organizations" (Play Console Requirements policy) fires for healthcare and "earn money"/rewards apps even after converting to an organization with D-U-N-S — a support ticket was needed for the Console to recognize the change; a company publishing from an individual account since 2016 had all apps removed until a new organization account + app transfer.

### AND-QUALITY-01 Technical quality thresholds
- Basis: Play technical quality requirements — user-perceived crash rate ≤ 1.09% and ANR rate ≤ 0.47% (bad-behavior thresholds affect visibility/warnings); native code 64-bit + 16 KB; from 2027-02 apps must apply ≥25% code optimization (R8) and memory limits; Zero-Tap Sign-In from 2027-04 (announced). Suspensions count as strikes (enforcement policy).
- Verify: Android vitals before submission; `minifyEnabled true`, R8 enabled.

### AND-QUALITY-02 Malware / "Deceptive Behavior" false-positive hygiene
- Basis: account terminations under "MALWARE, BEHAVIOR TRANSPARENCY AND MOBILE UNWANTED SOFTWARE" and "changing device settings without user consent" have hit apps for: a Firebase endpoint IP on a threat feed, an ads-lite SDK, a Unity plugin, a `PowerManager.WakeLock` that keeps the screen on. Re-uploading the same build after a ban led to permanent termination.
- Verify: no wake locks / brightness / settings changes without a visible user action; no dynamic code loading; scan the release AAB with VirusTotal before upload; keep the dependency list minimal and current.
- Signals: `wakelock`
- Fix: replace `WakeLock` with `FLAG_KEEP_SCREEN_ON` on the activity; if flagged, do **not** re-upload — appeal with VirusTotal report, source excerpts and a gameplay/feature video, and get the AV vendor to clear the detection first.
- Cases: [community](../rejections/community-cases.md#closed-testing-malware-false-positives-verification-target-api-16-kb)

### AND-ENFORCE-01 Rejection strikes, suspensions and account association
- Basis: "Violation of Enforcement Process policy… Suspension can occur as the result of egregious or multiple policy violations, as well as repeated app rejections or removals… you can submit an updated, policy compliant app using a new package name and a new app name"; suspended apps cannot be updated; resubmitting under a near-identical package/app name after a suspension is read as review evasion (「危険性の高いパターンまたは不正使用のパターンが検出された」); inviting a Console user tied to a terminated account suspends the whole account ("prior violation of associated, previously terminated account")
- Applies: every developer
- Verify/Rules: stop after the **second** rejection of the same build — self-test from the internal track and appeal instead of re-uploading; never re-upload the same or near-identical package after a suspension; vet every invited Console user; keep a written appeal that names the exact change made.
- Cases: [Play 2nd pass](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

### AND-REVIEW-01 The review environment is not the Play Store
- Basis: reviewers install the **Play-signed** build (different key than the pre-launch report → Google/Firebase sign-in, App Check and some libraries fail), Play Asset Delivery on-demand packs return `AppNotOwned` / `AppUnavailable` / `InternalError`, networking may be off, live/stream-dependent screens are empty, older credentials in other releases are used
- Applies: every submission
- Verify: both upload and app-signing SHA-1/256 registered everywhere (Firebase, Google Cloud OAuth, Kakao/Naver key hashes); first-session asset packs are install-time; explicit offline/empty-state messages; install the internal-track build yourself before submitting; Sign-in details updated in the same submission as the build.
- Cases: [Play 2nd pass](../rejections/community-cases.md#google-play--additional-cases-2nd-pass-2026-08-28-stack-exchange-api-play-community-github-issues-hn)

---

## UGC & payments (Play-specific additions)

### AND-UGC-01 Play UGC policy — verbatim requirements
- "Apps that contain or feature UGC must:" "Requires users accept the app's terms of use and/or user policy before users can create or upload UGC" (UGC-01) · "Defines objectionable content and behaviors… and prohibits them" (UGC-01) · "Conducts UGC moderation, as is reasonable and consistent with the type of UGC hosted by the app" (UGC-02/05) · "Provides an in-app system for reporting and blocking objectionable UGC and users, and taking action against UGC or users where appropriate" (UGC-03/04) · "Provides safeguards to prevent in-app monetization from encouraging objectionable user behavior".
- Incidental sexual UGC must be "hidden by default behind filters that require at least two user actions in order to completely disable"; minors excluded via a neutral age screen; "Apps whose primary purpose is featuring objectionable UGC will be removed"; "continually failing to address user complaints" is a violation.
- Also: Child Safety Standards (AND-CONSOLE-10), Age-Restricted Content tools for dating/random/anonymous chat, AI-generated content must have in-app reporting (common AI-01), content rating "Users Interact" = Yes (AND-CONSOLE-05).

### AND-PAY-01 Play Billing & regional programs
- `common.md` PAY-01. **Korea**: Play billing must be offered alongside; "If a user pays through an alternative billing system, the Google Play service fee will be reduced by 4%"; alternative billing APIs mandatory since 2023-08-02; report transactions within 24 h. **EEA**: alternative billing with/without user choice, External offers program (business account, EEA-only). **US**: external content links + alternative billing programs since 2025-12-09 (comply by 2026-01-28; fee reporting from 2026-10-01). **Japan**: external payments program; "Play store listings must not mention out-of-app purchases". **Global fee model**: from 2026-06-30 (EEA/UK/US) 5% billing fee for Play Billing, 20% IAP, 10% subscriptions; AU 2026-09-30, KR/JP 2026-12-31, rest 2027-09-30. External-link payments outside these programs remain prohibited.

