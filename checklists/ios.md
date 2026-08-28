# iOS checklist — Apple App Store Review Guidelines

Apple-only items. Feature-conditional items (UGC, account, payments…) live in `common.md` and are only referenced here.
Written as of 2026-08-28 against the guidelines last updated 2026-06-08 (https://developer.apple.com/app-store/review/guidelines/). Korean: `ko/ios.md`. Sources: `../references/apple.md`.

---

## Login

### IOS-LOGIN-01 Sign in with Apple (4.8 Login Services)
- Basis: 4.8 "Apps that use a third-party or social login service (such as Facebook Login, Google Sign-In, Log in with X, Sign In with LinkedIn, Login with Amazon, or WeChat Login) to set up or authenticate the user's primary account with the app must also offer as an equivalent option another login service with the following features: the login service limits data collection to the user's name and email address; the login service allows users to keep their email address private as part of setting up their account; and the login service does not collect interactions with your app for advertising purposes without consent." Kakao/Naver/LINE logins count. Sign in with Apple satisfies this.
- Exemptions (verbatim categories): the app exclusively uses your company's own account setup and sign-in systems; login via an alternative app marketplace account; education/enterprise apps requiring an existing education or enterprise account; government or industry-backed citizen identification / eID; a client for a specific third-party service where users must sign in to that service directly.
- Applies: `auth.google/kakao/naver/facebook` > 0
- Verify: the Apple button is on the **same screen, same size** as the social buttons (hidden or smaller → 4.8 rejection). `sign_in_with_apple` / `AuthenticationServices` used. Xcode capability "Sign in with Apple" + entitlement `com.apple.developer.applesignin`. Firebase: Apple provider enabled + Services ID (for Android/web).
- Signals: `auth.apple`, entitlements
- Fix: add the button (HIG: black/white Apple-logo button; "Delay sign-in as long as possible") → Firebase/Supabase Apple provider → decide the account-merge policy (same email, different provider). Accept the new relay domain `private.icloud.com` as well as `privaterelay.appleid.com` (2026-08).
- Evidence: none (reviewers check). One line in the review notes: "Sign in with Apple available".
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — not in the email, but Google/Kakao-only login makes this a co-rejection risk; community cases tagged IOS-LOGIN-01

### IOS-LOGIN-02 Revoke Apple tokens on account deletion
- Basis: 5.1.1(v) + Apple notice (2022) — when a Sign in with Apple user deletes their account, call the `revoke tokens` REST API
- Verify: the account-deletion server function revokes the Apple token.

### IOS-LOGIN-03 Korea: Sign in with Apple server-to-server notifications
- Basis: Apple news 2025-10-09 — developers based in Korea must provide a server-to-server notification endpoint on the Services ID used for Sign in with Apple from 2026-01-01 (account changes/deletions are pushed to your server)
- Applies: Korea-based developer account + Sign in with Apple
- Verify: Certificates, Identifiers & Profiles > Services ID > Sign in with Apple > server-to-server notification endpoint is set and the endpoint handles `consent-revoked` / `account-delete` events.

### IOS-LOGIN-04 After Sign in with Apple: don't ask for name/email again; accept relay addresses
- Basis: 4.0 Design rejection text — "Your app requires users to provide their name and/or email address after using Sign in with Apple. This information is already provided by the Authentication Services framework."
- Applies: any Sign in with Apple flow that shows a profile form afterwards
- Verify: name/email are taken from `ASAuthorizationAppleIDCredential` on the **first** authorization (Apple only sends them once — persist immediately); `@privaterelay.appleid.com` / `@private.icloud.com` addresses are accepted by validation and by the backend; Firebase `displayName == null` is handled without re-prompting; the button uses the official wording ("Sign in with Apple" / "Apple로 로그인").
- Signals: `auth.apple`
- Fix: pre-fill from the credential, make the form optional, allow relay emails.
- Cases: [community — 4.0 / SIWA](../rejections/community-cases.md#40-design--sign-in-with-apple-ux)

---

## Devices & UI

### IOS-IPAD-01 Works on iPad (2.4.1 / 4.0 / 2.1)
- Basis: reviewers **test on iPad too** (cases: iPad Air 11-inch M3, iPad Air 5). With `TARGETED_DEVICE_FAMILY = 1,2` (universal) a broken iPad layout is a 4.0 Design / 2.1 rejection. With `1` (iPhone-only) the app still runs in compatibility mode and must not crash — "'Create PIN' button was not responsive" and splash hangs were rejected on iPad Air.
- Verify: pbxproj `TARGETED_DEVICE_FAMILY`. Universal → run every screen on the 13" and 11" iPad simulators: stretched layouts, modal sizes, tap targets, landscape (`UISupportedInterfaceOrientations~ipad` with all four orientations → check landscape; portrait-only requires `UIRequiresFullScreen = YES` + portrait only). iPhone-only → still launch and tap through on an iPad simulator. iPad 13" screenshots must be real iPad captures, not stretched iPhone images.
- Signals: pbxproj, plist orientations
- Fix: a width-constrained container (max 600 pt, centered) as minimum effort. Or go iPhone-only (`TARGETED_DEVICE_FAMILY = 1`) — still must not crash on iPad.
- Cases: [2026-08-27 iOS 1.2 UGC](../rejections/2026-08-27-ios-1.2-ugc-jomhae.md) — review devices included an iPad; [community](../rejections/community-cases.md#40-design--sign-in-with-apple-ux)

### IOS-IPAD-02 Carrier (PASS/SMS) authentication cannot run on iPad
- Basis: Korean 2.1 rejections on iPad Air: "Unable to proceed with PASS authentication after selecting a carrier option" — iPad has no SMS; Apple reviews iPhone-only apps on iPad anyway. `TARGETED_DEVICE_FAMILY = 1`, removing iPad screenshots/orientations and "Supported Destinations" did **not** stop the iPad review; only `UIRequiredDeviceCapabilities = [telephony]` made the app uninstallable on iPad → approved.
- Applies: apps whose sign-up requires PASS / carrier SMS verification (본인인증) or phone-only flows
- Verify: a non-SMS fallback exists (email OTP, Sign in with Apple), or `UIRequiredDeviceCapabilities` includes `telephony` (accepting that the app won't install on iPad / Wi-Fi-only devices).
- Signals: `auth.phone`, `carrier.auth`
- Fix: add a fallback path, or declare `telephony`.
- Cases: [Korean sources](../rejections/community-cases.md#cases-from-korean-language-sources-2nd-pass-2026-08-28)

### IOS-UI-01 Basic polish (4.0 Design)
- Verify: dark-mode breakage (force light with `UIUserInterfaceStyle = Light` if needed), safe area / notch / Dynamic Island overlap, keyboard covering inputs, empty states, clipping with large Dynamic Type.
- Korean case: opening Safari for sign-up or account deletion is a 4.0 rejection ("taken to the default web browser… poor user experience") — use `SFSafariViewController` / `ASWebAuthenticationSession`.

### IOS-UI-02 No private APIs or downloaded code (2.5.1 / 2.5.2)
- Verify: plugins using private APIs (shows up as ITMS warnings on upload). Code push (CodePush/Shorebird…) allowed only when it doesn't change the app's primary purpose.

### IOS-UI-03 External links & app steering (3.1.1(a) / 2.3.10)
- Verify: outside the US storefront, no "subscribe cheaper on the web" links, buttons or copy (3.1.1(a): only the United States storefront may include them without an entitlement; EU/Japan/Korea via their programs — IOS-IAP-02). Minimal prompting to install other apps; never force downloads/reviews (3.2.2(x)).

---

## Info.plist

### IOS-PLIST-01 Missing or vague purpose strings (5.1.1(ii))
- Basis: calling a permission API without its `NS*UsageDescription` **crashes** → 2.1. Present but vague → 5.1.1 rejection.
- Verify: keys required per `perm.*` signal:
  | Signal | Key |
  |---|---|
  | perm.camera | NSCameraUsageDescription, NSPhotoLibraryUsageDescription (+ NSPhotoLibraryAddUsageDescription when saving) |
  | perm.location | NSLocationWhenInUseUsageDescription (+ NSLocationAlwaysAndWhenInUseUsageDescription) |
  | perm.mic | NSMicrophoneUsageDescription (+ NSSpeechRecognitionUsageDescription) |
  | perm.contacts | NSContactsUsageDescription |
  | perm.calendar | NSCalendarsFullAccessUsageDescription (iOS 17+) |
  | perm.bluetooth | NSBluetoothAlwaysUsageDescription |
  | perm.health | NSHealthShareUsageDescription, NSHealthUpdateUsageDescription |
  | track.att | NSUserTrackingUsageDescription |
  | Face ID | NSFaceIDUsageDescription |
  | local network | NSLocalNetworkUsageDescription |
  Include what plugins use internally (image_picker → camera + photos). Wording: "to do X, we use Y".
- Signals: `iOS Info.plist` section vs `perm.*`
- Fix: add keys + localize via `InfoPlist.strings` (ko/en).

### IOS-PLIST-02 UIBackgroundModes justification (2.5.4)
- See `common.md` BG-01. `audio`, `location`, `voip`, `fetch`, `processing` each need a real feature.

### IOS-PLIST-03 URL schemes & LSApplicationQueriesSchemes
- Verify: Kakao login → `kakao{APP_KEY}` URL scheme + `LSApplicationQueriesSchemes` with `kakaokompassauth`, `kakaolink`, `kakaoplus`. Naver → `naversearchapp`, `naversearchthirdlogin`. Missing → KakaoTalk app login fails during review.
- Signals: `LSApplicationQueriesSchemes`, `auth.kakao`

### IOS-PLIST-04 ATS (App Transport Security)
- Verify: `NSAllowsArbitraryLoads = true` needs a justification in the review notes. Prefer per-domain exceptions.

---

## Privacy & manifests

### IOS-PRIV-01 App Privacy labels (ASC)
- See `common.md` PRIV-02. Fill "App Privacy" from the SDK list before submitting.

### IOS-PRIV-02 ATT (5.1.2(i))
- See `common.md` PRIV-03. Ad/attribution SDKs → ATT request + `NSUserTrackingUsageDescription`. Denying ATT must not limit functionality.

### IOS-PRIV-03 Privacy manifest — Required Reason APIs & SDK manifests
- Basis: "Starting May 1, 2024, apps that don't describe their use of required reason API in their privacy manifest file aren't accepted by App Store Connect." `PrivacyInfo.xcprivacy` keys: `NSPrivacyTracking`, `NSPrivacyTrackingDomains` (requests to these domains fail without ATT consent), `NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes` with reason codes. Apple-listed third-party SDKs (Firebase*, GoogleSignIn, FBSDK*, Alamofire, Flutter, Kingfisher, SDWebImage, RxSwift, OneSignal, Lottie, Realm…) must ship their own manifest and signature — https://developer.apple.com/support/third-party-SDK-requirements/
- Error codes: **ITMS-91053 "Missing API declaration"** = your binary (or an SDK in it) calls a required-reason API without a matching `NSPrivacyAccessedAPITypes` entry. **ITMS-91061 "Missing privacy manifest"** = a listed SDK has no privacy manifest (blocking for new apps / updates adding such an SDK since ~2025-02).
- Verify: `PrivacyInfo.xcprivacy` in the app target + in Copy Bundle Resources. Categories: FileTimestamp (DDA9.1, C617.1…), SystemBootTime (35F9.1…), DiskSpace (E174.1, 7D6E.1…), ActiveKeyboards (54BD.1), UserDefaults (CA92.1 for app-container use).
- Signals: `PrivacyInfo.xcprivacy file count`
- Fix: Xcode > New File > App Privacy. Flutter/RN: `ios/Runner/PrivacyInfo.xcprivacy` + add to the Xcode project. Update SDKs to versions that ship manifests.

---

## Metadata & submission

### IOS-META-01 Screenshot specs
- Basis: ASC screenshot specifications — 1–10 per device class, JPG/PNG without alpha. iPhone 6.9" **1320×2868** (or 2868×1320) required if the app runs on iPhone (6.5" 1284×2778 is accepted and scaled when 6.9" is missing). iPad 13" **2064×2752 or 2048×2732** (or landscape) required if the app runs on iPad. Screenshots show the real app in use (2.3.3), no other-platform imagery (2.3.10), suitable for 4+ (2.3.8). New fall-2026 creative assets (product page header, search result asset) are optional.

### IOS-META-02 App Review Information
- Basis: 2.3.1(a) new features must be described "with specificity in the Notes for Review… (generic descriptions will be rejected)"; 2.1(a)/(b) demo account and IAP visibility; App Review page lists "Incomplete information" among the top rejection reasons ("over 40% of unresolved issues are related to guideline 2.1: App Completeness")
- Verify: "Sign-in required" + demo account that "must not expire" (extra accounts in Notes), Notes ≤ 4000 bytes in any language (`templates/review-notes.md`), contact name/email/phone (international format with "+"), attachments/links (recording). UGC apps: recording link **required** (case). Explain anything behind conditions (region, role, time, hardware).

### IOS-META-03 Export compliance
- Verify: `ITSAppUsesNonExemptEncryption` key. HTTPS only → `false` skips the question on every upload. Custom crypto (E2EE…) → `true` + annual self-classification report (US).
- Signals: plist

### IOS-META-04 Minimum Xcode / SDK
- Basis: https://developer.apple.com/news/upcoming-requirements/ — "Apps uploaded to App Store Connect must be built with Xcode 26 or later using an SDK for iOS 26, iPadOS 26, tvOS 26, visionOS 26, or watchOS 26", effective **2026-04-28** (watchOS apps also 64-bit). Apple moves this every April.
- Verify: `xcodebuild -version` ≥ 26; Flutter/RN/Expo version supports the iOS 26 SDK. CI images updated.
- Korean case (2026-03): a vendor SDK bundling binaries built with a newer SDK than your Xcode (Realm inside Kakao Navi KNSDK-UI 1.12.16) fails upload with ITMS-90512 "Invalid SDK value" / ITMS-91065 "Missing signature"; re-signing breaks the signature — downgrade or update the SDK.

### IOS-META-05 Version & build numbers
- Verify: bump `CFBundleVersion` (build) on resubmission. `MARKETING_VERSION` matches the store version.

### IOS-META-06 Age rating questionnaire (2025–2026 system)
- Basis: tiers 4+/9+/13+/16+/18+ with new questions (in-app controls incl. parental controls & age assurance; capabilities: unrestricted web access, UGC, social media, messaging & chat, advertising; medical/wellness; violence; chance-based: gambling, simulated gambling, contests, loot boxes). Responses were required by 2026-01-31; **social-media questions required for submissions from 2026-09**; the "Social Media" capability implies minimum 13+ (iOS 27 Time Allowances); loot boxes → 18+ in Brazil; Korea profanity/mature themes → 12+ from 2026-10. 2.3.6: answer honestly.
- Verify: the questionnaire in ASC reflects UGC/messaging/social features and any web browsing; the resulting tier matches marketing (no "for kids" wording outside the Kids category — 5.1.4(b)).
- Signals: `ugc.*`, `webview`, `pay.iap` (loot boxes)

---

## Entitlements & special features

### IOS-ENT-01 Capabilities ↔ code
- Verify: push → `aps-environment` entitlement + Push enabled on the App ID in ASC (otherwise no token → feature dead during review). Associated Domains (universal links), App Groups (widgets), etc. match what the code uses.
- Signals: entitlements list vs `perm.push`, `deeplink`

### IOS-ENT-02 Screen Time API (FamilyControls) — separate approval
- Basis: `com.apple.developer.family-controls` must be **requested from and approved by Apple** (weeks). Submitting without it fails the build or gets rejected. Common in focus / app-blocker apps.
- Applies: `perm.screentime` > 0
- Verify: the approved entitlement is in the distribution provisioning profile (distribution approval is separate from development).
- Fix: request at https://developer.apple.com/contact/request/family-controls-distribution and wait. Hide the feature until approved.

### IOS-ENT-03 Sign in with Apple entitlement
- See IOS-LOGIN-01. `com.apple.developer.applesignin` array `Default`.

### IOS-ENT-04 No leftover capabilities or framework references
- Basis: 2.5.1 rejections quote "binary includes references to HealthKit components, but the app does not appear to include any primary features that require health or fitness data", "still includes ScreenTime API without ScreenTime features", "binary contains references to App Tracking Transparency, but you have indicated you do not intend to ask users for permission to track"; Kids apps: ATT references are a 1.3 rejection
- Applies: any capability toggled once in Xcode or on the App ID; SDKs that link HealthKit/ATT/FamilyControls; removed features
- Verify: Signing & Capabilities has only capabilities with visible features; the **App ID in the developer portal** matches (a capability left enabled there alone caused a rejection); `otool -L` / `strings` on the binary for `HealthKit`, `ATTrackingManager`, `FamilyControls`, `DeviceActivity` when the feature is gone; no `NSUserTrackingUsageDescription` if you don't track.
- Signals: entitlements list, `perm.health`, `track.att`, `perm.screentime`
- Fix: remove the capability in Xcode **and** on the App ID; drop the SDK/module; strip the plist keys.
- Cases: [community — 2.5.1](../rejections/community-cases.md#251--231-software-requirements-leftover-capabilities-hidden-features)

---

## Background & timers (focus/timer apps)

### IOS-BG-01 How the timer survives in background (2.5.4)
- Basis: silent audio or fake location updates to keep the app alive get rejected. Timer apps are safest with **end time + local notification + Live Activity/widget**, no background execution.
- Verify: `bg.audio` signal (silence.mp3, AVAudioSession playback with no audible feature); is `audio_service` / `just_audio_background` used for real sound?
- Fix: `common.md` BG-01. If there is a real ambient-sound feature, state it in the review notes ("Background audio is used for the ambient sound feature; the timer itself uses local notifications").

### IOS-BG-02 Live Activity / widgets
- Verify: `NSSupportsLiveActivities = true`, App Group for the widget extension. Not a review item per se, but a crash source.

---

## Payments

### IOS-IAP-01 IAP submission state
- `common.md` PAY-01~04. First submission: attach IAPs to the version, Paid Apps Agreement done, paywall has terms/privacy links and restore.

### IOS-IAP-02 Regional external-purchase programs
- Basis: **Korea** — StoreKit External Purchase entitlement (Korea-only binary; approved PSPs KCP, Inicis, Toss, NICE; "Apple will charge a 26% commission on the price paid by the user"; mandatory modal disclosure before each payment flow; monthly sales reports). **US** — 3.1.1(a): links/buttons allowed without entitlement, IAP must still be offered; commission litigation ongoing (2026-08). **EU** — unified terms from 2026-10-01 (Core Technology Commission 5%, alternative payments alongside IAP). **Japan** — MSCA: iOS 26.2+ alternative payments/marketplaces, IAP must be presented alongside.
- Applies: `pay.external` > 0 and digital goods
- Verify: the entitlement is approved and the binary is region-scoped; disclosures shown; otherwise 3.1.1 rejection.

