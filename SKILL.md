---
name: store-review-check
description: 앱스토어(iOS)·플레이스토어(Android) 심사 리젝 사전 방지와 리젝 관리. 프로젝트를 스캔해 UGC(약관·신고·차단·필터), 계정 삭제, 소셜 로그인(Sign in with Apple), 심사용 데모 계정, 권한 문구, 개인정보, 결제, 백그라운드, iPad 대응, targetSdk 등 가이드라인 위반 소지를 판정한 리포트를 만들고, 리젝 메일을 붙여넣으면 분석→케이스 저장→수정 계획→증빙 녹화 순서→답신 초안까지 만든다. "심사 체크", "리젝 미리 확인", "앱스토어 심사 준비", "플레이스토어 정책 점검", "리젝 왔어", "심사 노트 써줘", "데모 계정 안내" 같은 요청에 사용.
argument-hint: [프로젝트 경로 | 리젝 메일 붙여넣기 | notes]
---

# 스토어 심사 사전 체크 & 리젝 관리

앱스토어(iOS)·플레이스토어(Android) 제출 전에 리젝 사유를 미리 찾아 없애고, 리젝이 오면 케이스로 축적해 다음 심사에 반영한다.

## 절대 규칙

1. **근거 없는 PASS 금지.** 코드·설정·리소스에서 `파일:라인` 근거를 확인한 항목만 PASS. 확인할 수 없으면 UNKNOWN으로 두고 "어떻게 확인할지"를 적는다. 스캐너 카운트만으로 판정하지 않는다 — `report`가 크래시 리포트인지 신고 기능인지, `friend`가 친구 기능인지 변수명인지 반드시 소스를 열어 본다.
2. **리포트는 심사관 관점의 우선순위.** 🔴 FAIL(가이드라인이 명시적으로 요구하는데 없음) → 🟠 WARN(자주 걸리거나 심사관 재량) → ⚪ UNKNOWN → 🟢 PASS 순. 모든 FAIL/WARN에는 가이드라인 번호 + 수정 방법 + 증빙 방법이 붙는다.
3. **기능 조건부 판정.** 앱에 없는 기능의 항목은 N/A. 단 "없다"고 판단하려면 라우트/화면 목록을 실제로 읽었어야 한다. 특히 UGC는 범위가 넓다: 닉네임·프로필 사진·상태 메시지·친구 초대·그룹 이름처럼 **다른 사용자에게 보이는 사용자 입력**이 하나라도 있으면 UGC 앱이다.
4. **리젝 메일은 반드시 케이스로 저장한다** (`rejections/`). 새 패턴이면 `checklists/`에 항목을 추가하고 `scripts/scan.sh`에 신호를 추가할지 검토한다. 스킬은 이렇게 학습한다.
5. **코드 수정은 사용자가 요청할 때만.** 기본 산출물은 리포트·계획·초안. "고쳐줘"가 오면 리포트의 수정 방법을 그대로 구현한다.
6. **비밀은 저장하지 않는다.** 데모 계정 비밀번호·API 키는 리포트/케이스 파일에 평문으로 쓰지 않는다. 심사 노트 템플릿엔 `<DEMO_PASSWORD>` 플레이스홀더를 두고 사용자가 콘솔에서 직접 채우게 한다.
7. **날짜에 민감한 요구치(targetSdk, 최소 Xcode/SDK)는 오늘 날짜 기준으로 판단**하고, 확신이 없으면 공식 페이지 확인을 권한다. 체크리스트에 적힌 숫자는 작성 시점(2026-08) 기준이다.

## 스킬 구성

| 경로 | 용도 |
|---|---|
| `scripts/scan.sh` | 프로젝트 신호 스캐너. `bash scan.sh <루트>` → 마크다운 출력 |
| `checklists/common.md` | 기능 조건부 항목 (UGC, 계정, 개인정보, 권한, 결제, 광고, 푸시, 백그라운드, 콘텐츠, 메타데이터, 한국 법규) |
| `checklists/ios.md` | Apple 전용 (Sign in with Apple, iPad, Info.plist, Privacy Manifest, ATT, 심사 노트 …) |
| `checklists/android.md` | Google Play 전용 (targetSdk, 권한 선언, 콘솔 양식, 비공개 테스트 …) |
| `rejections/` | 리젝 케이스 KB. 파일명 `YYYY-MM-DD-<platform>-<guideline>-<app>.md` |
| `templates/` | 리포트, 케이스, 심사 노트, 답신, UGC 약관 조항, 증빙 녹화 순서 |

스킬 폴더 = 이 SKILL.md가 있는 디렉토리(보통 `~/.claude/skills/store-review-check`). 아래에서 `$SKILL`로 표기.

## 모드 판별

| 입력 | 모드 |
|---|---|
| 경로 / 인자 없음 / "심사 체크해줘" | **A. 사전 점검** |
| 리젝 메일 텍스트 (`Guideline x.x`, `Submission ID`, `Issue Description`, `정책 위반`, `Your app has been rejected`, `Policy status`, `앱이 거부되었습니다`) | **B. 리젝 처리** |
| "심사 노트", "review notes", "데모 계정", "App access", "답신" | **C. 심사 제출 정보** |

B 모드에서 프로젝트 경로를 알면 A를 해당 항목 중심으로 함께 수행한다.

## A. 사전 점검

1. **스캔.** `bash "$SKILL/scripts/scan.sh" "<프로젝트 루트>" > "$SCRATCH/scan.md"` 후 읽는다. 루트를 모르면 현재 디렉토리. 모노레포면 앱 루트를 찾아 지정한다(`pubspec.yaml`·`ios/`·`android/`가 있는 곳).
2. **기능 프로필 확정.** 스캔 결과로 "이 앱이 가진 기능" 표를 만든다: 로그인 방식(구글/카카오/네이버/애플/이메일/게스트), UGC 종류, 결제, 광고, 권한, 백그라운드, 웹뷰, 푸시. 신호가 애매한 것은 해당 파일을 열어 확정한다. 라우트/네비게이션 파일(예: `lib/router.dart`, `app/_layout.tsx`, `AppDelegate`/`MainActivity`, 메인 Navigator)을 읽어 **로그인 벽 여부**와 주요 화면 목록을 파악한다.
3. **체크리스트 판정.** `checklists/common.md`에서 프로필에 해당하는 섹션 + `ios.md`/`android.md` 전 항목을 하나씩 판정한다. 각 항목의 "확인" 절차를 따르고 근거 `파일:라인`을 적는다. 등급 정의는 아래.
4. **과거 케이스 대조.** `rejections/*.md`의 frontmatter `checklist_ids`를 읽어, 이번 리포트에서 FAIL/WARN인 ID와 겹치면 리포트 최상단 "재발 위험"에 케이스 링크와 함께 표시한다.
5. **리포트 작성.** `templates/report.md` 형식으로 `<프로젝트 루트>/store-review/report-YYYY-MM-DD.md`에 쓴다(사용자가 다른 위치를 말했으면 그곳). 채팅에는 요약 표 + FAIL 목록 + 다음 행동만 보여준다.
6. **심사 노트 초안**(C 모드 산출물)을 리포트 7절에 포함한다. 데모 계정이 필요한데 없으면 "만들어야 함"으로 FAIL(ACC-03).

### 판정 등급

- 🔴 **FAIL** — 가이드라인/정책이 명시적으로 요구하는 것이 없음. 제출하면 리젝 확정 수준.
- 🟠 **WARN** — 자주 리젝되지만 구현·설명에 따라 통과 가능. 또는 코드 밖(콘솔 설정)에서 확인해야 하는 것.
- ⚪ **UNKNOWN** — 코드에서 판단 불가. 확인 방법을 적는다.
- 🟢 **PASS** — 근거 확인됨.
- **N/A** — 기능 없음(근거 필요).

## B. 리젝 처리

1. **파싱.** 플랫폼, 심사일, 앱 이름, 버전(빌드), Submission ID, 심사 기기, 가이드라인 번호·제목(복수 가능), 요구사항 bullet, 요구 증빙(녹화·데모 계정 등), 답신 채널.
2. **케이스 저장.** `templates/rejection-case.md`로 `$SKILL/rejections/YYYY-MM-DD-<ios|android>-<가이드라인번호>-<앱slug>.md` 생성. 원문 전문 포함(비밀은 `<REDACTED>`). `rejections/README.md` 표에 한 줄 추가.
3. **체크리스트 매핑.** 요구사항 하나하나를 `checklists/` ID에 연결한다. 해당 ID가 없으면 새 항목을 만든다(ID 규칙: 섹션약어-2자리 순번, 기존 항목 뒤에). `scan.sh`로 잡을 수 있는 신호면 `sig` 한 줄을 추가한다.
4. **원인 확인.** 프로젝트 경로를 알면 A 모드를 해당 항목 중심으로 수행해 "정확히 무엇이 없는지"를 파일 근거로 밝힌다. 경로를 모르면 케이스에 "추정"으로 기록하고 계속 진행한다(막지 않는다).
5. **숨은 리스크 예측.** 메일에 없어도 같은 심사에서 흔히 함께 걸리는 항목을 아래 "동반 리젝" 표로 확인해 경고한다. 재제출 때 새 사유로 또 리젝되는 것을 막는 게 목적이다.
6. **산출물** (채팅 + 케이스 파일):
   - 원인 분석 (무엇이 왜 걸렸나)
   - 수정 계획 — 요구사항별 구현 방법·예상 파일·난이도
   - 증빙 계획 — `templates/evidence-recording.md` 기반 녹화 순서
   - 답신 초안 — `templates/reply.md` (Apple은 영어)
   - 심사 노트 업데이트 — `templates/review-notes.md`
7. 사용자가 "고쳐줘"라고 하면 수정 계획을 구현한다. 구현 후 케이스 파일의 조치 표와 상태를 갱신한다.

### 동반 리젝 (하나 걸리면 같이 보는 것)

| 걸린 항목 | 같이 확인 |
|---|---|
| Apple 1.2 UGC / Play UGC | ACC-03 데모 계정(심사관이 로그인 못 하면 다시 리젝), IOS-LOGIN-01 Sign in with Apple(소셜 로그인만 있을 때), ACC-02 계정 삭제, META-03 연령 등급 "사용자 상호작용", KR-01, AND-CONSOLE-05 |
| Apple 4.8 Sign in with Apple | ACC-02 계정 삭제, ACC-03 데모 계정, PRIV-01 |
| Apple 2.1 데모 계정/완성도 | ACC-01 로그인 벽, CONTENT-01, IOS-IPAD-01 (iPad에서 크래시·레이아웃) |
| Apple 5.1.1 개인정보 | PRIV-01~04, PERM-01, ACC-02, IOS-PRIV-02 ATT |
| Apple 3.1.1 IAP | PAY-01~04, 외부 결제 링크 제거 |
| Apple 2.5.4 백그라운드 | IOS-BG-01, AND-PERM-05 |
| Play 권한 정책 | 해당 AND-PERM-* + AND-CONSOLE-06 선언 양식 + AND-CONSOLE-02 Data safety |
| Play 사용자 데이터 | PRIV-01~04, AND-CONSOLE-01/02/08 |

## C. 심사 제출 정보

`templates/review-notes.md`를 채워 출력한다. iOS는 App Review Information 노트(영어), Android는 App access 안내. 반드시 포함: 데모 계정 ID(비밀번호는 플레이스홀더), 인증 우회 방법(2단계 인증 끔·고정 OTP·리뷰어 전용 이메일 로그인), UGC 기능 위치(신고·차단·약관 경로), 녹화 링크, 연락처.

카카오/구글 계정만 있으면 해외 IP·2단계 인증 때문에 심사관이 로그인 못 하는 경우가 잦다. **이메일/비밀번호 리뷰어 계정 또는 Sign in with Apple** 경로를 함께 제공하라고 권한다. 데모 계정에는 친구·채팅·게시물 같은 **UGC 데이터를 미리 채워둔다**(pre-populated).

## 신호 → 항목 빠른 매핑

| scan.sh 신호 | 항목 |
|---|---|
| `ugc.*` > 0 | UGC-01~06, META-03, AND-UGC-01 |
| `mod.report/block/filter` = 0 (UGC 있을 때) | UGC-02/03/04 FAIL 후보 |
| `auth.google/kakao/naver` > 0, `auth.apple` = 0 | IOS-LOGIN-01 |
| `auth.login` > 0, `account.delete` = 0 | ACC-02, AND-CONSOLE-08 |
| `auth.login` > 0, `auth.guest` = 0 | ACC-01, ACC-03 |
| `legal.privacy` = 0 | PRIV-01 |
| `legal.terms` = 0 | UGC-01, PAY-02 |
| `ads.sdk` > 0 | PRIV-03, ADS-*, IOS-PRIV-02, AND-CONSOLE-04 |
| `pay.iap` > 0 | PAY-02~04, IOS-IAP-01 |
| `pay.external` > 0 | PAY-01, AND-PAY-01 |
| `bg.*` > 0 | BG-01/02, IOS-BG-01, AND-PERM-05 |
| `perm.screentime` > 0 | IOS-ENT-02, AND-PERM-07 |
| `perm.alarm` > 0 | AND-PERM-10 |
| `perm.*` > 0, 해당 UsageDescription 없음 | IOS-PLIST-01 |
| `PrivacyInfo.xcprivacy` 0개 | IOS-PRIV-03 |
| `ITSAppUsesNonExemptEncryption` 없음 | IOS-META-03 |
| Android 제한 권한 | AND-PERM-01~11 |
| `targetSdk` < 요구치 | AND-SDK-01 |
| `placeholder/todo/test.keys` | CONTENT-01/02 |
| 문자열에 타 플랫폼 언급 | CONTENT-04 |
| `TARGETED_DEVICE_FAMILY` 1,2 | IOS-IPAD-01 (iPad 레이아웃 실제 확인) |

## 학습 규칙 (KB 유지)

- 새 리젝 케이스 → `rejections/` 저장 + `rejections/README.md` 표 갱신 + 관련 체크리스트 항목의 `사례:` 줄에 링크 추가.
- 체크리스트에 없는 사유 → 항목 신설. 형식은 기존 항목과 동일(근거/적용/확인/신호/수정/증빙/사례).
- 스캐너로 잡을 수 있는 것 → `scan.sh`에 `sig` 또는 자동 힌트 추가 후 `bash -n scripts/scan.sh`로 문법 확인.
- 해결된 케이스 → frontmatter `status: resolved`, 무엇이 통과를 만들었는지 "조치" 표에 남긴다.
- 변경 후 `git -C "$SKILL" status`를 보여주고, 커밋/푸시는 사용자가 요청할 때 한다.

## 채팅 출력 형식 (A 모드)

```
## 심사 사전 점검 — <앱> (<플랫폼>) <날짜>
🔴 FAIL n · 🟠 WARN n · ⚪ UNKNOWN n · 🟢 PASS n   (재발 위험: <케이스> 또는 없음)

### 🔴 지금 고쳐야 제출 가능
1. UGC-03 신고 기능 없음 — Apple 1.2 / Play UGC. 채팅·프로필에 신고 메뉴 추가 (`lib/chat/room.dart`)
2. IOS-LOGIN-01 소셜 로그인만 있음 — Apple 4.8. Sign in with Apple 추가 (`lib/auth/login_screen.dart`)

### 🟠 확인·보강
…

리포트: store-review/report-2026-08-28.md
다음: (1) FAIL 2건 수정 (2) 데모 계정 생성·데이터 채우기 (3) 증빙 녹화
```
