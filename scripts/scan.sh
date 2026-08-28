#!/usr/bin/env bash
# store-review-check — 프로젝트 심사 신호 스캐너
#
# 사용:  bash scan.sh [프로젝트 경로]
# 출력:  마크다운 텍스트. Claude가 읽고 checklists/*.md 항목을 판정하는 데 쓴다.
#        스캐너가 내는 것은 "신호"일 뿐이다. 실제 기능 여부는 반드시 소스를 열어 확인한다.
# 호환:  macOS 기본 bash 3.2 / BSD grep, Linux GNU grep 모두 동작.

set -u
VERSION="1.8.0"
ROOT="${1:-.}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "경로 없음: ${1:-.}" >&2; exit 1; }

TMPD="$(mktemp -d 2>/dev/null || mktemp -d -t src)"
trap 'rm -rf "$TMPD"' EXIT
PLISTTMP="$TMPD/plist.txt"; MANTMP="$TMPD/manifest.txt"; DEPTMP="$TMPD/deps.txt"; GRADTMP="$TMPD/gradle.txt"
: > "$PLISTTMP"; : > "$MANTMP"; : > "$DEPTMP"; : > "$GRADTMP"

EXCL=(--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=Pods
      --exclude-dir=.dart_tool --exclude-dir=DerivedData --exclude-dir=.gradle --exclude-dir=dist
      --exclude-dir=.next --exclude-dir=.idea --exclude-dir=.expo --exclude-dir=vendor
      --exclude-dir=coverage --exclude-dir=.symlinks --exclude-dir=.fvm --exclude-dir=.cxx
      --exclude-dir=ephemeral --exclude-dir=__pycache__ --exclude-dir=store-screenshots)
SRC=(--include='*.dart' --include='*.swift' --include='*.m' --include='*.mm' --include='*.kt'
     --include='*.java' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx'
     --include='*.json' --include='*.xml' --include='*.plist' --include='*.strings' --include='*.arb'
     --include='*.yaml' --include='*.yml' --include='*.gradle' --include='*.kts' --include='*.properties'
     --include='*.html' --include='*.storyboard' --include='*.xib' --include='*.entitlements'
     --include='*.xcconfig' --include='*.pbxproj' --include='*.toml' --include='*.vue' --include='*.svelte')

h1(){ printf '\n# %s\n' "$*"; }
h2(){ printf '\n## %s\n' "$*"; }
h3(){ printf '\n### %s\n' "$*"; }
kv(){ printf '%s: %s\n' "$1" "$2"; }
flag(){ printf -- '- ⚠ %s\n' "$*"; }
rel(){ sed "s#^$ROOT/##"; }

# 제외 디렉토리를 prune 하는 find
ffind(){
  find "$ROOT" \( -name node_modules -o -name .git -o -name build -o -name Pods -o -name .dart_tool \
    -o -name DerivedData -o -name .gradle -o -name dist -o -name .expo -o -name .symlinks -o -name .fvm \
    -o -name .cxx -o -name ephemeral -o -name .next -o -name vendor \) -prune -o -name "$1" -print 2>/dev/null
}

# 신호 카운트 저장 (bash 3.2: 연관배열 없음)
COUNTS=""
cnt(){ local v; v="$(printf '%s\n' "$COUNTS" | grep -E "^$1=" | head -1 | cut -d= -f2)"; echo "${v:-0}"; }

# sig <id> <ERE> [i|c]   — i: 대소문자 무시(기본), c: 구분
sig(){
  local id="$1" re="$2" mode="${3:-i}" files n opt="-rIlE"
  [ "$mode" = "i" ] && opt="-rIlEi"
  files="$(grep $opt "${EXCL[@]}" "${SRC[@]}" -e "$re" "$ROOT" 2>/dev/null)"
  n="$(printf '%s' "$files" | grep -c .)"
  COUNTS="$COUNTS
$id=$n"
  if [ "$n" -gt 0 ]; then
    printf -- '- %s: %s files — ' "$id" "$n"
    printf '%s\n' "$files" | head -4 | rel | tr '\n' ' '
    printf '\n'
  else
    printf -- '- %s: 0\n' "$id"
  fi
}

# dep <label> <ERE>  — 의존성 파일 모음(DEPTMP)에서 검색
dep(){
  if grep -qiE "$2" "$DEPTMP" 2>/dev/null; then
    printf -- '- %s: yes — ' "$1"; grep -oiE "$2" "$DEPTMP" | sort -u | head -3 | tr '\n' ' '; printf '\n'
  else
    printf -- '- %s: no\n' "$1"
  fi
}

has_plist_key(){ grep -q "<key>$1</key>" "$PLISTTMP" 2>/dev/null; }
has_perm(){ grep -qE "$1" "$MANTMP" 2>/dev/null; }

# plist_val <key> <file> — 키 다음 값만 뽑는다 (string/array/bool/dict). 다음 <key>에서 멈춤.
plist_val(){
  awk -v k="<key>$1</key>" '
    found && /<key>/ { exit }
    found && /<dict>/ { printf "(dict) "; exit }
    found && /<true\/>/ { printf "true "; next }
    found && /<false\/>/ { printf "false "; next }
    found { gsub(/<[^>]*>/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); if ($0 != "") printf "%s ", $0; next }
    index($0, k) { found = 1 }
  ' "$2"
}

# ───────────────────────────────────────────────────────────────
h1 "store-review-check scan v$VERSION"
kv root "$ROOT"
kv date "$(date '+%Y-%m-%d %H:%M')"

# ───────────────────────────────────────────────────────────────
h2 "프로젝트 종류"
FOUND_ANY=0
if [ -f "$ROOT/pubspec.yaml" ]; then kv flutter "yes ($(grep -E '^(name|version):' "$ROOT/pubspec.yaml" | tr '\n' ' '))"; FOUND_ANY=1; fi
if [ -f "$ROOT/package.json" ]; then
  grep -q '"react-native"' "$ROOT/package.json" && { kv react-native yes; FOUND_ANY=1; }
  grep -q '"expo"' "$ROOT/package.json" && { kv expo "yes ($(ls "$ROOT"/app.json "$ROOT"/app.config.* 2>/dev/null | rel | tr '\n' ' '))"; FOUND_ANY=1; }
  grep -qE '"(@capacitor/core|cordova)"' "$ROOT/package.json" && { kv capacitor-or-cordova yes; FOUND_ANY=1; }
fi
XC="$(ffind '*.xcodeproj' | head -3 | rel | tr '\n' ' ')"; [ -n "$XC" ] && { kv xcode-project "$XC"; FOUND_ANY=1; }
XW="$(ffind '*.xcworkspace' | grep -v 'project.xcworkspace' | head -2 | rel | tr '\n' ' ')"; [ -n "$XW" ] && kv xcode-workspace "$XW"
GR="$(ffind 'build.gradle' ; ffind 'build.gradle.kts')"; [ -n "$GR" ] && { kv gradle "yes ($(printf '%s\n' "$GR" | grep -c .) files)"; FOUND_ANY=1; }
[ -f "$ROOT/Package.swift" ] && kv swift-package yes
[ -f "$ROOT/Podfile" ] || [ -f "$ROOT/ios/Podfile" ] && kv cocoapods yes
[ "$FOUND_ANY" -eq 0 ] && echo "(모바일 프로젝트 마커를 찾지 못함 — 경로를 확인하거나 앱 루트에서 다시 실행)"

# ───────────────────────────────────────────────────────────────
h2 "iOS Info.plist"
PLISTS="$(ffind 'Info.plist' | grep -vE '(Tests|UITests|/Pods/|\.framework/|/Carthage/)')"
if [ -z "$PLISTS" ]; then
  echo "(Info.plist 없음)"
else
  printf '%s\n' "$PLISTS" | while read -r f; do
    [ -f "$f" ] || continue
    cat "$f" >> "$PLISTTMP"
    h3 "$(printf '%s' "$f" | rel)"
    echo "- 권한 문구(UsageDescription):"
    grep -oE '<key>NS[A-Za-z]+UsageDescription</key>' "$f" | sed 's/<[^>]*>//g' | sort -u | while read -r k; do
      v="$(grep -A1 "<key>$k</key>" "$f" | tail -1 | sed 's/<[^>]*>//g; s/^[[:space:]]*//')"
      echo "    - $k = \"$v\""
    done
    for k in ITSAppUsesNonExemptEncryption UIBackgroundModes LSApplicationQueriesSchemes UIRequiresFullScreen \
             'UISupportedInterfaceOrientations~ipad' NSAppTransportSecurity CFBundleDisplayName \
             CFBundleShortVersionString CFBundleVersion NSUserTrackingUsageDescription; do
      if grep -q "<key>$k</key>" "$f"; then
        v="$(plist_val "$k" "$f")"
        echo "- $k: ${v:-(값 없음)}"
      else
        echo "- $k: (없음)"
      fi
    done
  done
fi
# Expo: app.json 의 ios.infoPlist
for f in "$ROOT/app.json" "$ROOT"/app.config.js "$ROOT"/app.config.ts; do
  [ -f "$f" ] || continue
  if grep -q 'infoPlist' "$f"; then
    h3 "$(printf '%s' "$f" | rel) (expo infoPlist)"
    grep -nE 'NS[A-Za-z]+UsageDescription|ITSAppUsesNonExemptEncryption|UIBackgroundModes|usesAppleSignIn|supportsTablet|googleServicesFile|permissions' "$f" | head -30 | sed 's/^/    /'
    cat "$f" >> "$PLISTTMP"
  fi
done

# ───────────────────────────────────────────────────────────────
h2 "iOS Entitlements / Privacy Manifest / pbxproj"
ENTS="$(ffind '*.entitlements')"
if [ -z "$ENTS" ]; then echo "- entitlements: (없음)"; else
  printf '%s\n' "$ENTS" | while read -r f; do
    printf -- '- %s: ' "$(printf '%s' "$f" | rel)"
    grep -oE '<key>[^<]+</key>' "$f" | sed 's/<[^>]*>//g' | tr '\n' ' '; printf '\n'
  done
fi
PM_COUNT="$(ffind 'PrivacyInfo.xcprivacy' | grep -c .)"
kv "PrivacyInfo.xcprivacy 파일 수" "$PM_COUNT"
ffind 'PrivacyInfo.xcprivacy' | head -3 | while read -r f; do
  printf -- '- %s: ' "$(printf '%s' "$f" | rel)"
  grep -oE 'NSPrivacyAccessedAPICategory[A-Za-z]+|NSPrivacyTracking|NSPrivacyCollectedDataType[A-Za-z]*' "$f" | sort -u | tr '\n' ' '; printf '\n'
done
ffind 'project.pbxproj' | grep -v '/Pods/' | while read -r f; do
  h3 "$(printf '%s' "$f" | rel)"
  for k in TARGETED_DEVICE_FAMILY IPHONEOS_DEPLOYMENT_TARGET MARKETING_VERSION CURRENT_PROJECT_VERSION PRODUCT_BUNDLE_IDENTIFIER CODE_SIGN_ENTITLEMENTS SUPPORTS_MACCATALYST; do
    v="$(grep -oE "$k = [^;]+" "$f" | sed "s/$k = //" | sort -u | tr '\n' ' ')"
    echo "- $k: ${v:-(없음)}"
  done
done

# ───────────────────────────────────────────────────────────────
h2 "Android Manifest"
MANS="$(ffind 'AndroidManifest.xml' | grep '/src/main/')"
if [ -z "$MANS" ]; then echo "(src/main/AndroidManifest.xml 없음)"; else
  printf '%s\n' "$MANS" | while read -r f; do
    cat "$f" >> "$MANTMP"
    h3 "$(printf '%s' "$f" | rel)"
    echo "- uses-permission:"
    grep -oE '<uses-permission[^>]*android:name="[^"]+"' "$f" | grep -oE 'name="[^"]+"' | sed 's/name=//; s/"//g; s/^/    - /'
    grep -q 'android:debuggable="true"' "$f" && flag 'android:debuggable="true"'
    grep -oE 'usesCleartextTraffic="[^"]+"' "$f" | sed 's/^/- /'
    grep -oE 'foregroundServiceType="[^"]+"' "$f" | sort -u | sed 's/^/- /'
    grep -oE 'android:allowBackup="[^"]+"' "$f" | sed 's/^/- /'
    echo "- <service> 수: $(grep -c '<service' "$f")"
    grep -q 'com.google.android.gms.ads.APPLICATION_ID' "$f" && echo "- AdMob APPLICATION_ID meta-data 있음"
    grep -q 'android.permission.RECEIVE_BOOT_COMPLETED' "$f" && echo "- RECEIVE_BOOT_COMPLETED 있음(부팅 자동 실행)"
  done
fi

h2 "Android Gradle"
printf '%s\n' "$GR" | while read -r f; do
  [ -f "$f" ] || continue
  grep -qE 'applicationId|targetSdk' "$f" || continue
  cat "$f" >> "$GRADTMP"
  h3 "$(printf '%s' "$f" | rel)"
  grep -nE 'applicationId|minSdk|targetSdk|compileSdk|versionCode|versionName|abiFilters|signingConfig|minifyEnabled|debuggable' "$f" | sed 's/^[[:space:]]*/- /' | head -25
done
[ -f "$ROOT/android/gradle.properties" ] && grep -nE 'android\.|flutter\.' "$ROOT/android/gradle.properties" | sed 's/^/- gradle.properties: /' | head -10
for f in "$ROOT/app.json" "$ROOT"/app.config.js "$ROOT"/app.config.ts; do
  [ -f "$f" ] || continue
  grep -q '"android"' "$f" && { echo "- expo android 설정:"; grep -nE 'permissions|package|versionCode|googleServicesFile|blockedPermissions' "$f" | head -15 | sed 's/^/    /'; }
done

# ───────────────────────────────────────────────────────────────
h2 "SDK / 의존성"
for n in pubspec.yaml package.json Podfile Podfile.lock build.gradle build.gradle.kts settings.gradle settings.gradle.kts Package.swift Package.resolved app.json app.config.js app.config.ts libs.versions.toml Cartfile; do
  ffind "$n" | while read -r f; do cat "$f" >> "$DEPTMP"; done
done
if [ ! -s "$DEPTMP" ]; then echo "(의존성 파일 없음)"; else
  dep "auth.google"        "google_sign_in|GoogleSignIn|react-native-google-signin|play-services-auth|googleid|expo-auth-session"
  dep "auth.kakao"         "kakao"
  dep "auth.apple"         "sign_in_with_apple|AuthenticationServices|react-native-apple-authentication|expo-apple-authentication|usesAppleSignIn"
  dep "auth.naver"         "naver_login|naveridlogin|NaverThirdPartyLogin|react-native-naver-login"
  dep "auth.facebook"      "facebook_auth|FBSDKLoginKit|react-native-fbsdk"
  dep "auth.firebase"      "firebase_auth|FirebaseAuth|react-native-firebase/auth"
  dep "backend.supabase"   "supabase"
  dep "backend.firebase"   "firebase_core|firebase-core|Firebase/Core|react-native-firebase/app|firebase-bom"
  dep "iap"                "in_app_purchase|purchases_flutter|react-native-purchases|react-native-iap|expo-in-app-purchases|StoreKit|billing-ktx|billingclient|com\.android\.billingclient|flutter_inapp_purchase|Glassfy|Adapty|Qonversion"
  dep "ads"                "google_mobile_ads|Google-Mobile-Ads-SDK|react-native-google-mobile-ads|play-services-ads|admob|applovin|ironsource|unity-ads|unityads|pangle|vungle|inmobi|facebook-audience"
  dep "tracking(ATT)"      "app_tracking_transparency|react-native-tracking-transparency|expo-tracking-transparency|AppTrackingTransparency"
  dep "analytics"          "firebase_analytics|amplitude|mixpanel|segment|appsflyer|adjust|branch\.io|react-native-branch|posthog"
  dep "crash"              "firebase_crashlytics|sentry|bugsnag|datadog"
  dep "push"               "firebase_messaging|onesignal|expo-notifications|react-native-firebase/messaging|flutter_local_notifications|react-native-push-notification|notifee"
  dep "location"           "geolocator|expo-location|react-native-geolocation|CoreLocation|play-services-location|flutter_background_geolocation|^ *location:"
  dep "camera/media"       "image_picker|expo-image-picker|react-native-image-picker|photo_manager|expo-camera|vision-camera|^ *camera:|image_cropper"
  dep "webview"            "webview_flutter|flutter_inappwebview|react-native-webview|expo-web-browser|url_launcher"
  dep "health"             "^ *health:|health_connect|HealthKit|react-native-health"
  dep "background"         "workmanager|background_fetch|flutter_background_service|expo-background-fetch|expo-task-manager|flutter_foreground_task|audio_service|just_audio_background"
  dep "contacts"           "contacts_service|flutter_contacts|expo-contacts|react-native-contacts"
  dep "bluetooth"          "flutter_blue|flutter_reactive_ble|react-native-ble|CoreBluetooth"
  dep "payment.external"   "stripe|paypal|tosspayments|toss_payments|iamport|portone|bootpay|paymentwidget|nicepay|kcp"
  dep "maps"               "google_maps|mapbox|naver_map|kakao_map|react-native-maps"
  dep "screentime/usage"   "FamilyControls|DeviceActivity|ManagedSettings|usage_stats|app_usage|UsageStatsManager|flutter_screen_time|screen_time"
  dep "sms/otp"            "sms_autofill|otp_autofill|SmsRetriever|telephony"
  dep "ai.sdk"             "openai|dart_openai|google_generative_ai|generativeai|anthropic|claude|gemini|langchain|firebase_vertexai|vertexai|ml_kit|mlkit"
  dep "codepush/ota"       "code-push|codepush|shorebird|expo-updates|hot_update|appcenter"
  dep "wakelock"           "wakelock|keep_screen_on|keepawake|expo-keep-awake"
  dep "vpn"                "VpnService|openvpn|wireguard|flutter_vpn|react-native-vpn"
  dep "perm-injecting libs (check merged manifest)" "image_picker|file_picker|permission_handler|expo-image-picker|expo-video|agora|uploadservice|background_downloader|flutter_foreground_task|background_geolocation|react-native-background-actions|inappbrowser|awesome_notifications|flutter_local_notifications"
fi

# ───────────────────────────────────────────────────────────────
h2 "기능 신호 (소스 grep — 파일 수, 대표 파일)"
echo "인증/계정:"
sig auth.login      '(signIn|sign_in|logIn|login|로그인|회원가입|signUp|sign_up)'
sig auth.google     '(GoogleSignIn|google_sign_in|signInWithGoogle|GoogleAuthProvider|GIDSignIn)'
sig auth.kakao      '(KakaoSdk|kakao_flutter_sdk|UserApi\.instance|KakaoLogin|kakaotalk|kakaolink|카카오 ?로그인|loginWithKakao)'
sig auth.apple      '(SignInWithApple|sign_in_with_apple|ASAuthorizationAppleID|AppleAuthProvider|OAuthProvider\("apple|signInWithApple)'
sig auth.naver      '(NaverLogin|naver_login|네이버 ?로그인|NaverThirdPartyLogin)'
sig auth.email      '(createUserWithEmailAndPassword|signInWithEmailAndPassword|signInWithPassword|이메일 ?로그인|signUpWithEmail)'
sig auth.phone      '(verifyPhoneNumber|signInWithPhoneNumber|PhoneAuthProvider|휴대폰 ?인증|SMS ?인증|signInWithOtp)'
sig auth.guest      '(signInAnonymously|anonymous|guest|게스트|비회원|둘러보기|skipLogin)'
sig account.delete  '(deleteAccount|delete_account|deleteUser|withdraw|withdrawal|회원 ?탈퇴|계정 ?삭제|account ?deletion|탈퇴)'
sig account.logout  '(signOut|logout|로그아웃)'
echo "UGC(사용자 생성 콘텐츠):"
sig ugc.chat        '(ChatRoom|chatRoom|chat_room|sendMessage|send_message|메시지 ?보내기|채팅|ChatScreen|chat_screen)'
sig ugc.comment     '(comment|댓글)'
sig ugc.post        '(createPost|create_post|newPost|피드|게시글|게시물|FeedScreen|feed_screen|timeline)'
sig ugc.profile     '(nickname|nick_name|displayName|display_name|프로필|닉네임|avatar|profileImage|profile_image)'
sig ugc.friend      '(friend|follow|팔로우|친구|buddy)'
sig ugc.group       '(GroupScreen|group_screen|createGroup|create_group|joinRoom|join_room|createRoom|모임|그룹 ?만들기|스터디 ?그룹|studyRoom|study_room)'
sig ugc.upload      '(uploadImage|upload_image|uploadFile|putFile|putData|storage\.ref|이미지 ?업로드|사진 ?업로드|FirebaseStorage)'
sig ugc.review      '(writeReview|write_review|리뷰 ?작성|후기|rating|별점)'
sig ugc.status      '(statusMessage|status_message|상태 ?메시지|한 ?줄 ?소개|introduce|bio)'
echo "모더레이션:"
sig mod.report      '(reportUser|reportPost|reportContent|report_user|report_post|reportMessage|report_message|신고)'
sig mod.block       '(blockUser|block_user|blockedUsers|blocked_users|unblock|차단)'
sig mod.filter      '(profanity|badword|bad_word|banned_word|bannedWords|금칙어|비속어|욕설|wordFilter|word_filter|contentFilter|moderation|moderator)'
sig mod.hide        '(hidePost|hide_post|hideContent|hideUser|숨기기|removeFromFeed|mute)'
sig mod.contact     '(support@|help@|contact@|문의하기|고객센터|support ?email|1:1 ?문의)'
echo "약관/법무:"
sig legal.terms     '(EULA|이용약관|terms ?of ?(service|use)|termsOfService|terms_of_service|termsAgree|terms_agree|약관 ?동의|서비스 ?약관)'
sig legal.privacy   '(개인정보 ?처리방침|개인정보 ?수집|privacy ?policy|privacyPolicy|privacy_policy)'
sig legal.age       '(만 ?14세|만 ?13세|under ?13|age ?gate|ageGate|생년월일|birthdate|birthday|COPPA|법정 ?대리인)'
echo "결제/광고/추적:"
sig pay.iap         '(StoreKit|SKProduct|SKPaymentQueue|in_app_purchase|purchases_flutter|Purchases\.|BillingClient|react-native-iap|expo-in-app-purchases|구독|subscription|premium|프리미엄|restorePurchases|restore_purchases|구매 ?복원)'
sig pay.external    '(Stripe|PayPal|TossPayments|iamport|portone|bootpay|카드 ?결제|계좌 ?이체|무통장)'
sig ads.sdk         '(AdMob|google_mobile_ads|GADBannerView|BannerAd|MobileAds|AppLovin|ironSource|UnityAds|RewardedAd|InterstitialAd|AppOpenAd)'
sig track.att       '(AppTrackingTransparency|ATTrackingManager|NSUserTrackingUsageDescription|app_tracking_transparency|requestTrackingAuthorization|TrackingStatus)'
sig track.adid      '(advertisingIdentifier|ASIdentifierManager|AdvertisingIdClient|permission\.AD_ID|IDFA|GAID)'
echo "권한/하드웨어:"
sig perm.location   '(CLLocationManager|geolocator|ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|ACCESS_BACKGROUND_LOCATION|expo-location|Geolocation|NSLocation)'
sig perm.camera     '(image_picker|UIImagePickerController|PHPicker|permission\.CAMERA|READ_MEDIA_IMAGES|READ_EXTERNAL_STORAGE|expo-image-picker|react-native-image-picker|NSCameraUsageDescription|NSPhotoLibrary|AVCaptureSession)'
sig perm.mic        '(AVAudioSession|RECORD_AUDIO|NSMicrophoneUsageDescription|speech_to_text|AVAudioRecorder|MediaRecorder)'
sig perm.contacts   '(CNContactStore|READ_CONTACTS|NSContactsUsageDescription|contacts_service|flutter_contacts)'
sig perm.push       '(firebase_messaging|UNUserNotificationCenter|POST_NOTIFICATIONS|expo-notifications|OneSignal|FirebaseMessaging|registerForRemoteNotifications|getToken\(\))'
sig perm.health     '(HealthKit|HKHealthStore|health_connect|HealthConnect)'
sig perm.bluetooth  '(CoreBluetooth|BLUETOOTH_CONNECT|BLUETOOTH_SCAN|NSBluetooth)'
sig perm.calendar   '(EKEventStore|READ_CALENDAR|WRITE_CALENDAR|NSCalendarsUsageDescription|NSCalendarsFullAccessUsageDescription)'
sig perm.screentime '(FamilyControls|DeviceActivity|ManagedSettings|UsageStatsManager|PACKAGE_USAGE_STATS|앱 ?차단|앱 ?제한|AppBlocker)'
sig perm.overlay    '(SYSTEM_ALERT_WINDOW|canDrawOverlays|TYPE_APPLICATION_OVERLAY)'
sig perm.alarm      '(SCHEDULE_EXACT_ALARM|USE_EXACT_ALARM|setExactAndAllowWhileIdle|USE_FULL_SCREEN_INTENT|AlarmManager)'
echo "백그라운드/기타:"
sig bg.modes        '(UIBackgroundModes|BGTaskScheduler|beginBackgroundTask|FOREGROUND_SERVICE|workmanager|background_fetch|flutter_background_service|flutter_foreground_task|audio_service|백그라운드)'
sig bg.audio        '(AVAudioSessionCategoryPlayback|\.playback|silent\.mp3|silence\.mp3|keepAlive|keep_alive|백그라운드 ?재생)'
sig webview         '(WKWebView|webview_flutter|InAppWebView|react-native-webview|WebView\(|WebViewController)'
sig deeplink        '(applinks:|CFBundleURLSchemes|android:scheme|uni_links|app_links|firebase_dynamic_links|deep_link|deeplink|kakaolink)'
sig share.invite    '(Share\.share|share_plus|inviteFriend|invite_friend|초대 ?코드|inviteCode|invite_code|referral)'
sig review.prompt   '(SKStoreReviewController|requestReview|in_app_review|InAppReview|ReviewManager|리뷰 ?요청|평가 ?요청)'
echo "기타 리스크:"
sig ai.sdk          '(openai|OpenAI|gpt-4|gpt-3|dart_openai|GenerativeModel|google_generative_ai|anthropic|claude-|gemini|vertexai|chatCompletion|completions)'
sig ugc.anonymous   '(anonymous ?chat|random ?chat|익명 ?채팅|랜덤 ?채팅|匿名|stranger|모르는 ?사람)'
sig codepush        '(CodePush|codePush|shorebird|expo-updates|Updates\.checkForUpdate|hotUpdate|hot_update)'
sig force.update    '(forceUpdate|force_update|forcedUpdate|mustUpdate|minimumVersion|minimum_version|minAppVersion|min_app_version|강제 ?업데이트|업데이트가 ?필요)'
sig wakelock        '(WakeLock|wakelock|WakelockPlus|keepScreenOn|FLAG_KEEP_SCREEN_ON|isIdleTimerDisabled|keepAwake)'
sig perm.vpn        '(VpnService|NEVPNManager|NETunnelProvider|BIND_VPN_SERVICE)'
sig record.activity '(ReplayKit|RPScreenRecorder|MediaProjection|screenRecord|screen_record|화면 ?녹화)'
sig carrier.auth    '(본인 ?인증|본인확인|PASS ?인증|(^|[^a-z])pass_?auth|NiceID|nice_id|kmcert|kmcis|다날|(^|[^a-z])danal|휴대폰 ?본인|carrierAuth|mobileok|kcb_)'
sig dyn.dns         '(duckdns|no-ip\.|noip\.com|iptime\.org|ddns\.net|dynu\.com|ngrok\.io|ngrok-free|localtunnel|serveo)'
sig sec.aws         '(AKIA[0-9A-Z]{16}|aws_secret_access_key|AWS_SECRET|BasicAWSCredentials|AWSStaticCredentialsProvider)' c
sig price.hardcoded '(₩ ?[0-9][0-9,]*|[0-9][0-9,]* ?원|¥ ?[0-9][0-9,]*|[0-9][0-9,]* ?円|\$ ?[0-9]+(\.[0-9]{2})?( ?/ ?(mo|month|yr|year|week))|[0-9]+ ?(日間|days?|일) ?(無料|free|무료)|무료 ?체험|free ?trial|無料トライアル)'
sig donation        '(ko-fi\.com|buymeacoffee|github\.com/sponsors|patreon\.com|paypal\.me|후원하기|寄付|donate)'
sig applepay        '(PKPaymentButton|PKPaymentAuthorization|ApplePayButton|apple_pay|applePay|isApplePaySupported)'
sig icloud.sync     '(NSUbiquitousKeyValueStore|CKContainer|CloudKit|iCloud ?(sync|동기화|同期)|NSPersistentCloudKitContainer)'
sig emulator        '(emulator|エミュレータ|에뮬레이터|romPath|\.rom\b|mini ?game ?platform|H5 ?游戏)'
sig form.factor     '(CarAppService|androidx\.car\.app|android\.hardware\.type\.automotive|WearableListenerService|android\.hardware\.type\.watch|LEANBACK_LAUNCHER|android\.software\.leanback|WatchKit|WKExtension|xr\.|visionos)'
sig plist.default.purpose '(Allow \$\(PRODUCT_NAME\) to access|\$\(PRODUCT_NAME\) needs access|This app needs access to|이 앱은 .* 권한이 필요합니다\.?$|needs to access your (camera|microphone|photos|location)$)'
sig toss.miniapp    '(apps-in-toss|@apps-in-toss|appsInToss|토스 ?미니앱|앱인토스)'
sig region.markers  '(yandex|vk\.com|Сбер|ЮMoney|mir_pay|MirPay|CPF|CNPJ|pix_key|PIX ?QR|MoMo|ZaloPay|VNPay|Midtrans|GoPay|OVO ?Pay|DANA|iyzico|Impressum|Datenschutzerklärung|PSE ?Kominfo|Komdigi)'
sig media.thirdparty '(youtube_player|react-native-youtube|youtube-iframe|YTPlayerView|themoviedb|TMDB|jellyfin|peertube|radio ?stream|icecast|shoutcast|plex|emby|torrent)'
sig mac.entitlements '(ENABLE_INCOMING_NETWORK_CONNECTIONS|ENABLE_OUTGOING_NETWORK_CONNECTIONS|ENABLE_FILE_ACCESS_DOWNLOADS_FOLDER|ENABLE_RESOURCE_ACCESS_CAMERA|ENABLE_RESOURCE_ACCESS_MICROPHONE|ENABLE_USER_SELECTED_FILES|SUPPORTS_MACCATALYST = YES)'
sig sec.webview     '(Intent\.parseUri|parseUri\(|shouldOverrideUrlLoading|addJavascriptInterface|setJavaScriptEnabled\(true\)|setAllowFileAccess\(true\))'
sig sec.webauth     '(WebView.*(oauth|login|authorize)|(oauth|authorize).*WebView|webview_flutter.*(oauth|login))'

# ───────────────────────────────────────────────────────────────
h2 "콘텐츠/메타데이터 신호"
sig placeholder     '(lorem ipsum|coming soon|준비 ?중입니다|테스트용|dummy text|placeholder text|샘플 텍스트|개발 ?중)'
sig todo.marks      '(TODO|FIXME|HACK|XXX)' c
sig test.keys       '(sk_test_|pk_test_|test_key|TEST_KEY|sandbox_|isTestDevice|testDeviceIds|ca-app-pub-3940256099942544)'
CT="$(grep -rIhoE "${EXCL[@]}" "${SRC[@]}" -e 'http://[A-Za-z0-9./_?=&%-]+' "$ROOT" 2>/dev/null \
  | grep -vE 'localhost|127\.0\.0\.1|10\.0\.2\.2|schemas\.|w3\.org|apple\.com/DTDs|xmlns|example\.com|android\.com|json-schema|ocsp|crl\.|purl\.org|ns\.adobe' | sort -u | head -8 | tr '\n' ' ')"
echo "- cleartext http:// (소스 내, 예외 제외): ${CT:-없음}"
LU="$(grep -rIhoE "${EXCL[@]}" "${SRC[@]}" -e 'https?://[A-Za-z0-9./_?=&%-]+' "$ROOT" 2>/dev/null \
  | grep -iE 'privacy|terms|policy|약관|eula|support|help|contact|notion\.site|notion\.so' | sort -u | head -8 | tr '\n' ' ')"
echo "- 약관/개인정보/지원 URL 후보: ${LU:-없음}"

# 다른 플랫폼 언급 (현지화 문자열 위주)
OTHER_IOS=0; OTHER_AND=0
L10N="$( { ffind '*.arb'; ffind '*.strings'; ffind 'strings.xml'; ffind '*.json' | grep -iE '(i18n|locale|l10n|lang|translation)'; } 2>/dev/null )"
if [ -n "$L10N" ]; then
  printf '%s\n' "$L10N" | while read -r f; do
    [ -f "$f" ] || continue
    grep -qE '안드로이드|Android|Google Play|플레이 ?스토어' "$f" && echo "- 문자열에 Android/Google Play 언급: $(printf '%s' "$f" | rel)"
    grep -qE 'iPhone|App Store|앱스토어|아이폰' "$f" && echo "- 문자열에 iPhone/App Store 언급: $(printf '%s' "$f" | rel)"
  done
else
  echo "- 현지화 파일(.arb/.strings/strings.xml) 없음 — 하드코딩 문자열이면 소스에서 직접 확인"
fi

# 스토어 메타데이터 파일
h2 "스토어 메타데이터 파일"
META="$( { ffind 'metadata' ; ffind 'fastlane'; ffind 'store'; ffind 'store_listing'; ffind 'PRIVACY*'; ffind 'privacy*.html'; ffind 'terms*.html'; ffind 'privacy*.md'; ffind 'terms*.md'; } 2>/dev/null | sort -u )"
if [ -z "$META" ]; then echo "(fastlane/metadata·privacy·terms 파일 없음)"; else
  printf '%s\n' "$META" | head -15 | rel | sed 's/^/- /'
  ffind 'privacy_url.txt' | while read -r f; do echo "- $(printf '%s' "$f" | rel): $(cat "$f")"; done
  ffind 'support_url.txt' | while read -r f; do echo "- $(printf '%s' "$f" | rel): $(cat "$f")"; done
  ffind 'marketing_url.txt' | while read -r f; do echo "- $(printf '%s' "$f" | rel): $(cat "$f")"; done
fi

# ───────────────────────────────────────────────────────────────
h2 "자동 힌트 (스캐너 추정 — 반드시 소스로 검증)"
HINTS=0
UGC=$(( $(cnt ugc.chat) + $(cnt ugc.comment) + $(cnt ugc.post) + $(cnt ugc.friend) + $(cnt ugc.upload) + $(cnt ugc.review) + $(cnt ugc.group) + $(cnt ugc.status) ))
if [ "$UGC" -gt 0 ]; then
  flag "UGC 신호 있음 (chat=$(cnt ugc.chat) comment=$(cnt ugc.comment) post=$(cnt ugc.post) friend=$(cnt ugc.friend) group=$(cnt ugc.group) upload=$(cnt ugc.upload) profile=$(cnt ugc.profile)) → common.md UGC-01~UGC-06 전부 점검"
  echo "    모더레이션 신호: report=$(cnt mod.report) block=$(cnt mod.block) filter=$(cnt mod.filter) hide=$(cnt mod.hide) terms=$(cnt legal.terms) contact=$(cnt mod.contact)"
  [ "$(cnt mod.report)" -eq 0 ] && flag "신고(report) 신호 없음 → UGC-03 FAIL 가능성"
  [ "$(cnt mod.block)" -eq 0 ]  && flag "차단(block) 신호 없음 → UGC-04 FAIL 가능성"
  [ "$(cnt mod.filter)" -eq 0 ] && flag "필터(profanity/금칙어) 신호 없음 → UGC-02 FAIL 가능성"
  [ "$(cnt legal.terms)" -eq 0 ] && flag "약관(EULA) 신호 없음 → UGC-01 FAIL 가능성"
  HINTS=1
fi
SOCIAL=$(( $(cnt auth.google) + $(cnt auth.kakao) + $(cnt auth.naver) ))
if [ "$SOCIAL" -gt 0 ] && [ "$(cnt auth.apple)" -eq 0 ]; then
  flag "소셜 로그인(google=$(cnt auth.google) kakao=$(cnt auth.kakao) naver=$(cnt auth.naver)) 있으나 Sign in with Apple 신호 없음 → ios.md IOS-LOGIN-01 (4.8)"; HINTS=1
fi
if [ "$(cnt auth.login)" -gt 0 ] && [ "$(cnt account.delete)" -eq 0 ]; then
  flag "로그인 있으나 계정 삭제 신호 없음 → common.md ACC-02 (Apple 5.1.1(v) / Play 계정 삭제 정책)"; HINTS=1
fi
if [ "$(cnt auth.login)" -gt 0 ] && [ "$(cnt auth.guest)" -eq 0 ]; then
  flag "로그인 있고 게스트/둘러보기 신호 없음 → 로그인 벽 여부 확인 (common.md ACC-01, Apple 5.1.1(iv)) + 심사용 데모 계정 필수 (ACC-03)"; HINTS=1
fi
if [ "$(cnt ads.sdk)" -gt 0 ] && [ "$(cnt track.att)" -eq 0 ]; then
  flag "광고 SDK 있으나 ATT 신호 없음 → ios.md IOS-PRIV-02 (5.1.2)"; HINTS=1
fi
if [ "$(cnt pay.external)" -gt 0 ]; then flag "외부 결제 신호 → common.md PAY-01 (Apple 3.1.1 / Play 결제 정책) — 디지털 재화면 IAP 필수"; HINTS=1; fi
if [ "$(cnt pay.iap)" -gt 0 ]; then flag "IAP/구독 신호 → common.md PAY-02~04 (구독 고지, 구매 복원, 약관 링크)"; HINTS=1; fi
if [ "$(cnt perm.screentime)" -gt 0 ]; then flag "Screen Time/UsageStats 신호 → ios.md IOS-ENT-02 (FamilyControls 승인) / android.md AND-PERM-07"; HINTS=1; fi
if [ "$(cnt bg.audio)" -gt 0 ] || [ "$(cnt bg.modes)" -gt 0 ]; then flag "백그라운드 실행 신호 → ios.md IOS-BG-01 (2.5.4: 타이머 유지용 무음 오디오는 리젝 사유) / android.md AND-PERM-05 (FGS 타입 선언)"; HINTS=1; fi
if [ "$(cnt perm.push)" -gt 0 ]; then flag "푸시 신호 → common.md PUSH-01 (마케팅 푸시 옵트인, 푸시 없이도 동작)"; HINTS=1; fi
if [ "$(cnt webview)" -gt 0 ]; then flag "WebView 신호 → common.md CONTENT-03 (4.2 최소 기능: 웹 래퍼 금지)"; HINTS=1; fi
if [ "$(cnt legal.privacy)" -eq 0 ]; then flag "앱 내 개인정보처리방침 신호 없음 → common.md PRIV-01 (앱 내 링크 필수)"; HINTS=1; fi
if [ "$(cnt legal.age)" -eq 0 ] && [ "$(cnt auth.login)" -gt 0 ]; then flag "연령 확인 신호 없음 → common.md KR-01 (만 14세 미만 법정대리인 동의) 검토"; HINTS=1; fi
if [ "$(cnt placeholder)" -gt 0 ]; then flag "플레이스홀더/준비중 문구 신호 → common.md CONTENT-01 (2.1)"; HINTS=1; fi
if [ "$(cnt test.keys)" -gt 0 ]; then flag "테스트 키/테스트 광고 ID 신호 → 릴리즈 빌드에서 제거 (CONTENT-02)"; HINTS=1; fi

# 포화 카테고리 (Apple 4.3(b): dating, flashlight, sound effects, wallpaper, simple timers, fortune telling)
NAMES="$( { grep -hE '^(name|description):' "$ROOT/pubspec.yaml" 2>/dev/null; grep -hE '"(name|description|displayName|slug)"' "$ROOT/app.json" "$ROOT/package.json" 2>/dev/null; grep -h -A1 'CFBundleDisplayName' "$PLISTTMP" 2>/dev/null; grep -hoE 'android:label="[^"]+"' "$MANTMP" 2>/dev/null; } | tr 'A-Z' 'a-z' )"
if printf '%s' "$NAMES" | grep -qE 'timer|타이머|pomodoro|뽀모도로|wallpaper|배경 ?화면|flashlight|손전등|sound ?effect|효과음|fortune|운세|타로|tarot|dating|소개팅|데이팅|white ?noise|백색 ?소음'; then
  flag "앱 이름/설명이 포화 카테고리(타이머·배경화면·손전등·효과음·운세·데이팅)와 일치 → common.md CONTENT-07 (Apple 4.3(b) 2026-06: 'simple timers'는 의미 있게 다른 경험 없으면 거절)"; HINTS=1
fi
if [ "$(cnt ai.sdk)" -gt 0 ]; then flag "AI SDK/API 신호 → common.md AI-01 (Apple 5.1.2(i) 제3자 AI 공유 고지·동의 / Play AI 콘텐츠 앱 내 신고)"; HINTS=1; fi
if [ "$(cnt ugc.anonymous)" -gt 0 ]; then flag "익명/랜덤 채팅 신호 → UGC-07, AND-CONSOLE-10 (Apple 1.2 2026-02 명시 적용 / Play Child Safety Standards·미성년자 차단 도구)"; HINTS=1; fi
if [ "$(cnt codepush)" -gt 0 ]; then flag "OTA 코드 푸시 신호 → common.md CONTENT-10 (Apple 2.3.1 hidden features — 심사 노트에 명시, 버그 수정 범위만)"; HINTS=1; fi
if [ "$(cnt force.update)" -gt 0 ]; then flag "강제 업데이트 게이트 신호 → common.md CONTENT-11 (심사 빌드가 스토어보다 새 버전이라 업데이트 화면에 갇히는 리젝)"; HINTS=1; fi
if [ "$(cnt wakelock)" -gt 0 ]; then flag "WakeLock/화면 켜짐 유지 신호 → android.md AND-QUALITY-02 (기기 설정 변경으로 오탐된 사례; FLAG_KEEP_SCREEN_ON 권장)"; HINTS=1; fi
if [ "$(cnt perm.vpn)" -gt 0 ]; then flag "VpnService 신호 → android.md AND-PERM-14 / ios.md IOS-UI-02 (허용 용도·선언 필요)"; HINTS=1; fi
if [ "$(cnt record.activity)" -gt 0 ]; then flag "화면/활동 녹화 신호 → common.md CONTENT-08 (Apple 2.5.14 동의 + 표시)"; HINTS=1; fi
if grep -qiE 'image_picker|file_picker|permission_handler|expo-image-picker|expo-video|agora|uploadservice|flutter_foreground_task|background_geolocation|background-actions|inappbrowser' "$DEPTMP" 2>/dev/null; then
  flag "권한을 병합 매니페스트에 주입하는 라이브러리 사용 → android.md AND-PERM-13 (build/intermediates/merged_manifests 확인, tools:node=\"remove\")"; HINTS=1
fi
if [ "$(cnt price.hardcoded)" -gt 0 ]; then flag "하드코딩된 가격/무료체험 문구 신호 → common.md PAY-06 (스토어 상품 데이터에서 가격·통화·체험 기간을 가져와야 — 2026 Apple 2.1(b)/Play 구독 리젝)"; HINTS=1; fi
if [ "$(cnt donation)" -gt 0 ]; then flag "후원/도네이션 링크 신호 → common.md PAY-01 (Apple: 'donations… must use In-App Purchase' — 연결된 웹사이트의 링크도 검사)"; HINTS=1; fi
if [ "$(cnt applepay)" -gt 0 ]; then flag "Apple Pay 신호 → ios.md IOS-IAP-03 (4.9: 다른 결제 버튼과 동등하게 노출; PassKit만 링크하고 미사용이면 IOS-ENT-04)"; HINTS=1; fi
if [ "$(cnt icloud.sync)" -gt 0 ] && [ "$(cnt pay.iap)" -gt 0 ]; then flag "iCloud 동기화 + IAP 신호 → ios.md IOS-IAP-04 (4.10: iCloud 동기화 등 내장 기능을 유료화 금지)"; HINTS=1; fi
if [ "$(cnt region.markers)" -gt 0 ]; then flag "지역 결제/법규 마커(러·브라질·베트남·인니·터키·독일) 신호 → common.md LAW-04 + references/regions.md (라이선스·등록·연령 확인·Impressum)"; HINTS=1; fi
if [ "$(cnt media.thirdparty)" -gt 0 ]; then flag "제3자 미디어/카탈로그 신호 → common.md LAW-03 (5.2.3: 권리 증빙을 심사 노트에 첨부; 제3자 미디어 오프라인 다운로드는 제거)"; HINTS=1; fi
if [ "$(cnt mac.entitlements)" -gt 0 ]; then flag "macOS/Catalyst 샌드박스 엔타이틀먼트 신호 → ios.md IOS-ENT-05 (2.4.5(i): 서명된 바이너리별 codesign -d --entitlements 확인, 기능 없는 키 제거)"; HINTS=1; fi
if printf '%s' "$NAMES" | grep -qE '(^|[^a-z])(mac|macos|ios|ipados|apple ?watch|watchos|sidecar|inkwell|airpods|iphone|ipad)([^a-z]|$)'; then flag "앱 이름/표시명에 Apple 상표 신호 → ios.md IOS-META-09 (5.2.5: 이름·부제·키워드·CFBundleName에서 제거; 설명의 'for macOS'는 허용)"; HINTS=1; fi
if [ "$(cnt plist.default.purpose)" -gt 0 ]; then flag "플러그인 기본 목적 문구(Allow \$(PRODUCT_NAME) to access…) 신호 → ios.md IOS-PLIST-05 (Apple 자동 분석이 플레이스홀더로 지적; 구체 문구 + 미사용 권한 제거)"; HINTS=1; fi
if [ "$(cnt toss.miniapp)" -gt 0 ]; then flag "토스 미니앱(앱인토스) 신호 → common.md KR-05 (진입 시 바텀시트/로그인 금지, 플로팅 탭바, review_get_feedback 확인)"; HINTS=1; fi
if [ "$(cnt form.factor)" -gt 0 ]; then flag "Auto/Wear/TV/XR 폼팩터 신호 → android.md AND-FORM-01 (별도 품질 심사; 라이브러리가 병합한 CarAppService는 tools:node=remove) / iOS watchOS·visionOS 심사 기기 확인"; HINTS=1; fi
if [ "$(cnt emulator)" -gt 0 ]; then flag "에뮬레이터/미니게임 플랫폼 신호 → common.md CONTENT-14 (Apple 4.7: 레트로 콘솔·비주목적 HTML5만 허용)"; HINTS=1; fi
if [ "$(cnt sec.aws)" -gt 0 ]; then flag "AWS 자격 증명 패턴(AKIA…/secret key) 신호 → android.md AND-SEC-01 (Play 'Leaked AWS credentials' 리젝; 사전 서명 URL/백엔드로 이동)"; HINTS=1; fi
if [ "$(cnt sec.webview)" -gt 0 ]; then flag "WebView intent/JS 인터페이스 신호 → android.md AND-SEC-01 ('intent scheme hijacking', 'cross-app scripting' — loadUrl 전 URL 검증, intent:// 파싱 금지)"; HINTS=1; fi
if [ "$(cnt sec.webauth)" -gt 0 ]; then flag "WebView 기반 OAuth 신호 → AND-SEC-01 'Authentication via WebView' 경고 + Apple 4.0 (Custom Tabs / ASWebAuthenticationSession 사용)"; HINTS=1; fi
if [ "$(cnt carrier.auth)" -gt 0 ]; then flag "휴대폰 본인인증(PASS/NICE/KMC) 신호 → ios.md IOS-IPAD-02 (iPad Air에서 심사 시 SMS 불가 — 대체 경로 또는 UIRequiredDeviceCapabilities=telephony)"; HINTS=1; fi
if [ "$(cnt dyn.dns)" -gt 0 ]; then flag "동적 DNS/터널 도메인 신호 → common.md CONTENT-09 (Apple IPv6-only 심사망에서 접속 불가로 2.1 리젝 사례) + CONTENT-12"; HINTS=1; fi
if [ "$(cnt auth.kakao)" -gt 0 ] || [ "$(cnt auth.naver)" -gt 0 ]; then flag "카카오/네이버 로그인 → common.md ACC-05 (심사관 2단계 인증·카카오톡 설치 페이지 문제: 카톡 미연동 계정 + 이메일함 제공, ID/PW 또는 Apple 로그인 병행)"; HINTS=1; fi
if [ -s "$PLISTTMP" ]; then
  grep -q 'CFBundleDevelopmentRegion' "$PLISTTMP" && grep -A1 'CFBundleDevelopmentRegion' "$PLISTTMP" | grep -q 'DEVELOPMENT_LANGUAGE' && { flag "CFBundleDevelopmentRegion = \$(DEVELOPMENT_LANGUAGE) → common.md CONTENT-13 (미국 리전 심사 기기에서 실행 시 크래시 사례 — ko_KR/en 등 구체 값으로)"; HINTS=1; }
  [ "$(cnt perm.camera)" -gt 0 ] && ! has_plist_key NSCameraUsageDescription && ! has_plist_key NSPhotoLibraryUsageDescription && { flag "카메라/사진 신호 있으나 NSCamera/NSPhotoLibraryUsageDescription 없음 → ios.md IOS-PLIST-01"; HINTS=1; }
  [ "$(cnt perm.location)" -gt 0 ] && ! has_plist_key NSLocationWhenInUseUsageDescription && { flag "위치 신호 있으나 NSLocationWhenInUseUsageDescription 없음 → IOS-PLIST-01"; HINTS=1; }
  [ "$(cnt perm.mic)" -gt 0 ] && ! has_plist_key NSMicrophoneUsageDescription && { flag "마이크 신호 있으나 NSMicrophoneUsageDescription 없음 → IOS-PLIST-01"; HINTS=1; }
  [ "$(cnt perm.contacts)" -gt 0 ] && ! has_plist_key NSContactsUsageDescription && { flag "연락처 신호 있으나 NSContactsUsageDescription 없음 → IOS-PLIST-01"; HINTS=1; }
  [ "$(cnt track.att)" -gt 0 ] && ! has_plist_key NSUserTrackingUsageDescription && { flag "ATT 호출 있으나 NSUserTrackingUsageDescription 없음 → IOS-PLIST-01"; HINTS=1; }
  has_plist_key ITSAppUsesNonExemptEncryption || { flag "ITSAppUsesNonExemptEncryption 없음 → 업로드마다 수출 규정 질문 (ios.md IOS-META-03)"; HINTS=1; }
  [ "$PM_COUNT" -eq 0 ] && { flag "PrivacyInfo.xcprivacy 없음 → ios.md IOS-PRIV-03 (Required Reason API 매니페스트)"; HINTS=1; }
  if [ "$(cnt auth.kakao)" -gt 0 ] && ! grep -q 'kakao' "$PLISTTMP"; then flag "카카오 로그인 있으나 Info.plist에 kakao URL scheme/LSApplicationQueriesSchemes 없음"; HINTS=1; fi
fi
if [ -s "$MANTMP" ]; then
  has_perm 'READ_SMS|RECEIVE_SMS|SEND_SMS|READ_CALL_LOG|WRITE_CALL_LOG|PROCESS_OUTGOING_CALLS' && { flag "SMS/통화기록 권한 → android.md AND-PERM-01 (제한 권한, 기본 앱 아니면 거부)"; HINTS=1; }
  has_perm 'QUERY_ALL_PACKAGES' && { flag "QUERY_ALL_PACKAGES → AND-PERM-02 (선언 양식 필수)"; HINTS=1; }
  has_perm 'MANAGE_EXTERNAL_STORAGE' && { flag "MANAGE_EXTERNAL_STORAGE(모든 파일 접근) → AND-PERM-03"; HINTS=1; }
  has_perm 'ACCESS_BACKGROUND_LOCATION' && { flag "백그라운드 위치 → AND-PERM-04 (양식+영상+사전 고지)"; HINTS=1; }
  has_perm 'READ_MEDIA_IMAGES|READ_MEDIA_VIDEO|READ_EXTERNAL_STORAGE' && { flag "사진/동영상 권한 → AND-PERM-08 (Photo Picker 권고, 광범위 접근은 선언 필요)"; HINTS=1; }
  has_perm 'FOREGROUND_SERVICE' && ! grep -q 'foregroundServiceType' "$MANTMP" && { flag "FOREGROUND_SERVICE 있으나 foregroundServiceType 미선언 → AND-PERM-05 (targetSdk 34+ 필수)"; HINTS=1; }
  has_perm 'FOREGROUND_SERVICE' && { flag "포그라운드 서비스 → Play Console 'Foreground service permissions' 선언 + 영상 (AND-CONSOLE-06)"; HINTS=1; }
  has_perm 'BIND_ACCESSIBILITY_SERVICE' && { flag "접근성 서비스 → AND-PERM-06 (접근성 목적 아니면 거부)"; HINTS=1; }
  has_perm 'REQUEST_INSTALL_PACKAGES' && { flag "REQUEST_INSTALL_PACKAGES → 선언 양식"; HINTS=1; }
  has_perm 'SYSTEM_ALERT_WINDOW' && { flag "SYSTEM_ALERT_WINDOW(오버레이) → AND-PERM-09"; HINTS=1; }
  has_perm 'USE_EXACT_ALARM|SCHEDULE_EXACT_ALARM' && { flag "정확한 알람 권한 → AND-PERM-10 (알람/타이머/캘린더 핵심 기능일 때만)"; HINTS=1; }
  has_perm 'USE_FULL_SCREEN_INTENT' && { flag "USE_FULL_SCREEN_INTENT → AND-PERM-10 (알람/통화 앱만, Console 선언)"; HINTS=1; }
  [ "$(cnt ads.sdk)" -gt 0 ] && ! has_perm 'com.google.android.gms.permission.AD_ID' && { flag "광고 SDK 있으나 AD_ID 권한 미선언 → AND-CONSOLE-04"; HINTS=1; }
  has_perm 'android:name="android.permission.INTERNET"' || { flag "INTERNET 권한 없음 — 네트워크 앱이면 확인"; HINTS=1; }
fi
if [ -s "$GRADTMP" ]; then
  TS="$(grep -oE 'targetSdk(Version)?[ =]+[0-9]+' "$GRADTMP" | grep -oE '[0-9]+$' | sort -n | head -1)"
  if [ -n "$TS" ]; then
    [ "$TS" -lt 35 ] && { flag "targetSdk=$TS → android.md AND-SDK-01 (2025-08-31부터 35, 2026-08-31부터 36 요구)"; HINTS=1; }
    [ "$TS" -eq 35 ] && { flag "targetSdk=35 → 2026-08-31 이후 신규/업데이트는 36 요구 (AND-SDK-01) — 제출 시점 확인"; HINTS=1; }
  elif grep -q 'flutter.targetSdkVersion' "$GRADTMP"; then
    flag "targetSdk = flutter.targetSdkVersion (Flutter SDK 기본값) → 'flutter --version' 으로 실제 값 확인 (AND-SDK-01)"; HINTS=1
  fi
  grep -q 'signingConfigs.debug' "$GRADTMP" && grep -qE 'release[^}]*signingConfig signingConfigs\.debug' "$GRADTMP" && { flag "release 빌드가 debug 서명 사용 → AND-BUILD-01"; HINTS=1; }
fi
[ "$HINTS" -eq 0 ] && echo "(자동 힌트 없음 — 그래도 체크리스트 전 항목은 수동 판정)"

printf '\n(끝) 신호 카운트는 파일 수 기준. 0이어도 하드코딩·네이티브 구현으로 존재할 수 있고, >0이어도 무관한 매치일 수 있다.\n'
