<p align="center">
  <img src="docs/report-sample.png" width="860" alt="store-review-check HTML レポート">
</p>

<h1 align="center">store-review-check</h1>

<p align="center"><b>App Store・Google Play のリジェクトを<i>提出前に</i>見つける。</b><br>
Claude Code、Codex CLI、その他 SKILL.md 対応エージェント向けの <a href="https://agentskills.io">Agent Skill</a>。</p>

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
</p>

---

## なぜ作ったか

「友達と一緒に集中するタイマー」アプリで実際に受け取ったリジェクトです:

> **Guideline 1.2 – Safety – User-Generated Content**
> アプリにユーザー生成コンテンツが含まれていますが、必要な対策がすべて実装されていません… *利用規約(EULA)への同意を必須に… 不適切なコンテンツのフィルタ… 通報機能… ユーザーのブロック機能…* データが入ったデモアカウント(Google または Kakao)を提供してください… 実機で撮影した画面録画を添えて返信してください…

ニックネームが見える友達リストだけで「UGC アプリ」になりました。これらの要件はすべて **提出前にコードを見れば分かる**ものです。このスキルはそれを行い、それでもリジェクトされたらケースとして保存し、次のチェックで再利用します。

## できること

| モード | こう言うと | こうなる |
|---|---|---|
| **事前チェック** | `審査チェックして` / `/store-review-check ~/dev/app` | スキャン → 機能プロファイル → チェックリスト全項目を 🔴 FAIL / 🟠 WARN / ⚪ UNKNOWN / 🟢 PASS で判定 + `ファイル:行` の根拠 + 修正方法 + 必要な証跡 → **HTML レポート(ブラウザで開く)またはチャット** → コンソールチェックリスト → 審査ノート下書き |
| **リジェクト対応** | リジェクトメールを貼り付け | 解析 → ケース保存 → チェックリストへマッピング → **併発リジェクト予測**(例: Google/Kakao ログインのみ → Sign in with Apple 4.8) → 修正計画 → 証跡録画の手順 → 英語の返信 → 審査ノート |
| **提出情報** | `審査ノートを書いて` | App Store Connect の *App Review Information* と Play Console の *アプリのアクセス* 文面: デモアカウント、認証の回避方法、通報・ブロック・規約の場所 |

スキルからの質問はすべて**選択式**(必要に応じて複数選択): プラットフォーム、範囲、HTML かチャットか、次の作業。自由記述のやり取りはありません。

## インストール

**Claude Code**
```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.claude/skills/store-review-check
```
**Codex CLI**
```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.codex/skills/store-review-check
```
**その他の Agent Skills ランタイム** — そのランタイムの skills ディレクトリにクローン(フォルダ名は `store-review-check` のまま)。

エージェントを再起動して:

```
> 審査チェックして                    # カレントディレクトリを事前チェック
> /store-review-check ~/dev/app      # Claude Code、パス指定
> $store-review-check                 # Codex CLI
> リジェクトされた: <メールを貼り付け>  # リジェクト対応
> 審査ノートを書いて                   # 提出情報
```

スキャナー単体:
```bash
bash ~/.claude/skills/store-review-check/scripts/scan.sh ~/dev/app
```
Flutter、React Native、Expo、iOS/Android ネイティブを認識します。出力は「シグナル」であり、判定前にエージェントがファイルを開いて確認します。

## 例

```
## 審査事前チェック — Focus Together (iOS, Android) 2026-08-28
🔴 FAIL 9 · 🟠 WARN 3 · ⚪ UNKNOWN 1 · 🟢 PASS 1   (再発リスク: 2026-08-27-ios-1.2-ugc)

### 🔴 提出前に必ず修正
1. UGC-01 ログイン前の規約同意なし — Apple 1.2 / Play UGC (lib/auth/login_screen.dart:41)
2. UGC-03 通報機能なし — Apple 1.2 / Play UGC
3. UGC-04 ブロック機能なし — Apple 1.2 / Play UGC
4. IOS-LOGIN-01 Google/Kakao ログインのみで Sign in with Apple なし — Apple 4.8
5. ACC-02 アプリ内アカウント削除なし — Apple 5.1.1(v) / Play
6. ACC-03 2段階認証なしでログインできる審査用アカウントなし — Apple 2.1 / Play アプリのアクセス
7. AND-PERM-05 FOREGROUND_SERVICE に foregroundServiceType なし — Android 14
8. IOS-PRIV-03 PrivacyInfo.xcprivacy なし — ITMS-91053
…
レポート: store-review/report-2026-08-28.html
```

## チェック内容

| 領域 | 例 | 根拠 |
|---|---|---|
| **UGC・モデレーション** | ゼロトレランス条項付き規約同意、コンテンツフィルタ、通報、ブロック(即時削除+開発者通知)、24時間以内の対応、実機録画、データ入りデモアカウント | Apple 1.2 · Play UGC |
| **アカウント・ログイン** | ログインウォール、アプリ内アカウント削除(+Play 用 Web リンク)、海外 IP から使えるデモアカウント、ソーシャルログイン時の Sign in with Apple、Kakao/Google コンソール設定 | Apple 5.1.1(iv)(v), 4.8, 2.1 · Play アカウント削除、アプリのアクセス |
| **プライバシー** | アプリ内+ストアのプライバシーポリシー、App Privacy / データセーフティと SDK の整合、ATT / AD_ID、事前開示、Privacy Manifest | Apple 5.1.1, 5.1.2 · Play ユーザーデータ |
| **権限** | 使用 API ごとの目的文字列、拒否時の動作、未使用権限、Android 制限付き権限と申告フォーム(写真/動画、FGS タイプ、正確なアラーム、ユーザー補助、QUERY_ALL_PACKAGES…) | Apple 5.1.1(ii) · Play 権限 |
| **決済・広告** | デジタル商品は IAP / Play 課金、サブスク表示+規約リンク、購入の復元、IAP の添付、テスト広告 ID、妨害広告 | Apple 3.1.1, 3.1.2 · Play 決済、広告 |
| **バックグラウンド・タイマー** | 無音オーディオでタイマー維持(2.5.4)、FGS タイプ+Play 申告、ローカル通知への置き換え | Apple 2.5.4 · Android 14 FGS |
| **完成度・メタデータ** | プレースホルダー、iPad でのクラッシュ、他プラットフォームへの言及、スクリーンショット、年齢レーティング「ユーザー同士の交流」、タイトル規則、サポート URL | Apple 2.1, 2.3.x, 2.4.1, 4.0 · Play メタデータ |
| **プラットフォーム要件** | targetSdk 期限、16KB ページ、AAB/64bit、輸出コンプライアンス、最小 Xcode、新規 Play アカウントのクローズドテスト、FamilyControls 承認 | — |
| **韓国** | 14歳未満の法定代理人同意、ポリシー必須記載、IARC/GRAC | 個人情報保護法 |

**118 項目**、それぞれに *根拠 / 適用条件 / 確認 / スキャナーシグナル / 修正 / 証跡 / 事例*。全項目を 2026-08-28 時点の公式原文(App Store Review Guidelines 2026-06-08 改訂版、Play ポリシーセンター)と照合しています — 原文引用・URL・2025〜2026 の変更履歴は [`references/`](references/)。

## 実際のリジェクト事例

[`rejections/community-cases.md`](rejections/community-cases.md) に、**100 件以上の実際のリジェクト事例**(2022〜2026)を開発者フォーラム・Reddit・Apple Developer Forums・Play コミュニティ・ブログ(英・韓・日・中)から集めた実際のリジェクト事例を、審査官の文言、原因、承認された修正、出典リンクとともにまとめています。各事例はチェックリスト ID に紐づいており、事前チェックで *「これで実際にリジェクトされた人がいて、こう直して通った」* と示せます。

## 自分のリジェクトを学習させる

1. メールを貼り付け → `rejections/YYYY-MM-DD-<platform>-<guideline>-<app>.md` に `checklist_ids` 付きで保存。
2. チェックリストにない理由 → 項目を追加、検出可能ならスキャナーにシグナル追加。
3. 次回の事前チェック → 重複があれば最上部に **再発リスク** として表示。

## 構成

```
SKILL.md                     スキル本体(ルール、選択式フロー、モード別ワークフロー、シグナル→項目マップ)
scripts/scan.sh              プロジェクトのシグナルスキャナー(bash 3.2 / BSD grep 互換)
scripts/render_report.py     JSON → 単一 HTML レポート(フィルタ、ダークモード、チェック状態保存、ノートコピー)
checklists/common.md         機能条件付き項目
checklists/ios.md            App Store 項目
checklists/android.md        Google Play 項目
checklists/ko/               翻訳(英語が正)
references/                  チェックリストを照合した公式ソース
templates/                   レポートスキーマ、ケース、審査ノート、返信、UGC 規約条項、録画手順
rejections/                  ケース KB — 自分のケース + community-cases.md
docs/                        サンプルレポート JSON + スクリーンショット
```

## 互換性

- **Claude Code** — `AskUserQuestion`(複数選択)で質問し、HTML レポートを生成して開きます。
- **Codex CLI** — 同じ SKILL.md。質問はチャット内の番号付き選択肢になります。
- [Agent Skills 仕様](https://agentskills.io/specification)(`name` + `description` frontmatter)に従うすべてのランタイム。

## コントリビュート

PR 歓迎 — 特に**実際のリジェクト事例**(審査官の文言+修正方法)と**ガイドラインの更新**。`rejections/community-cases.md` に一行追加し、該当チェックリスト項目の `Cases:` からリンクしてください。

## 注意

ガイドラインは変わります。日付依存の値(targetSdk 期限、最小 Xcode、クローズドテストの人数)には「基準日」が付いています。提出前に公式ページで確認してください。このツールはリジェクトを減らしますが、承認を保証するものではありません。

## ライセンス

MIT
