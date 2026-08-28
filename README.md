# store-review-check

앱스토어(iOS)·플레이스토어(Android) **심사 리젝을 제출 전에 잡아내고**, 리젝이 오면 케이스로 축적해 다음 심사에 반영하는 Claude Code 스킬.

"좀 해!" 1.0 심사에서 받은 **Guideline 1.2 (UGC)** 리젝 — 약관 동의·신고·차단·필터·24시간 조치·데모 계정 — 같은 것을 코드 스캔 단계에서 미리 경고하는 것이 목적이다.

## 하는 일

| 모드 | 입력 | 산출물 |
|---|---|---|
| **A. 사전 점검** | 프로젝트 경로 | `store-review/report-YYYY-MM-DD.md` — 항목별 FAIL/WARN/UNKNOWN/PASS + 근거 파일:라인 + 수정 방법 + 콘솔 체크리스트 + 심사 노트 초안 |
| **B. 리젝 처리** | 리젝 메일 붙여넣기 | `rejections/` 케이스 저장, 원인 분석, 수정 계획, 증빙 녹화 순서, 답신 초안, **동반 리젝 예측**(예: Google/Kakao 로그인만 → Sign in with Apple 4.8) |
| **C. 심사 제출 정보** | "심사 노트 써줘" | App Store Connect Notes / Play App access 문구 |

## 설치

```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.claude/skills/store-review-check
```

Claude Code를 재시작하면 `/store-review-check`로 호출되거나 "심사 체크해줘", "리젝 왔어" 같은 말에 자동으로 뜬다.

업데이트: `git -C ~/.claude/skills/store-review-check pull`

## 사용 예

```
/store-review-check ~/dev/my-app          # 사전 점검
심사 체크해줘                               # 현재 디렉토리
리젝 왔어: (메일 전문 붙여넣기)              # 리젝 처리
심사 노트 써줘                               # 데모 계정·기능 위치 안내문
```

스캐너만 따로 돌리기:

```bash
bash ~/.claude/skills/store-review-check/scripts/scan.sh ~/dev/my-app
```

Flutter / React Native / Expo / iOS·Android 네이티브를 인식한다. 출력은 "신호"이고 최종 판정은 Claude가 소스를 열어 확인한다.

## 구성

```
SKILL.md                 스킬 본문 (규칙·워크플로·신호→항목 매핑)
scripts/scan.sh          프로젝트 신호 스캐너 (bash 3.2 / BSD grep 호환)
checklists/common.md     기능 조건부: UGC, 계정, 개인정보, 권한, 결제, 광고, 푸시, 백그라운드, 콘텐츠, 메타데이터, 한국 법규
checklists/ios.md        Apple 전용: Sign in with Apple, iPad, Info.plist, Privacy Manifest, ATT, 심사 노트, FamilyControls …
checklists/android.md    Play 전용: targetSdk, 권한 선언 양식, 콘솔 항목, 비공개 테스트 …
templates/report.md      점검 리포트
templates/rejection-case.md  리젝 케이스
templates/review-notes.md    심사 노트 (ASC Notes / Play App access)
templates/reply.md           답신 (Apple 영어 / Play)
templates/eula-ugc.md        UGC 무관용 약관 조항 (한/영)
templates/evidence-recording.md  실기기 녹화 순서
rejections/              리젝 케이스 KB (README.md에 인덱스)
```

## 스킬이 학습하는 방식

1. 리젝 메일 → `rejections/YYYY-MM-DD-<platform>-<guideline>-<app>.md` 저장, frontmatter `checklist_ids`에 관련 항목 기록.
2. 체크리스트에 없던 사유면 `checklists/`에 항목 추가, 스캐너로 잡을 수 있으면 `scan.sh`에 신호 추가.
3. 다음 사전 점검 때 케이스의 `checklist_ids`와 대조해 "재발 위험"으로 최상단에 표시.

## 주의

- 체크리스트의 날짜 의존 수치(targetSdk 요구치, 최소 Xcode 등)는 작성 시점(2026-08) 기준. 제출 전 공식 페이지에서 확인.
- 데모 계정 비밀번호·API 키는 리포트·케이스에 저장하지 않는다(플레이스홀더).
- 스캐너는 정규식 기반이라 오탐·미탐이 있다. PASS 판정은 항상 소스 근거가 있어야 한다.

## 라이선스

MIT
