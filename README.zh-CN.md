<p align="center">
  <img src="docs/report-sample.png" width="860" alt="store-review-check HTML 报告">
</p>

<h1 align="center">store-review-check</h1>

<p align="center"><b>在提交<i>之前</i>发现 App Store 和 Google Play 的被拒风险。</b><br>
面向 Claude Code、Codex CLI 及任何兼容 SKILL.md 的智能体的 <a href="https://agentskills.io">Agent Skill</a>。</p>

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

## 为什么做这个

这是我们一款"和朋友一起专注的计时器"应用真实收到的被拒通知:

> **Guideline 1.2 – Safety – User-Generated Content**
> 我们发现应用包含用户生成内容，但未具备全部必要的防护措施… *要求用户同意条款(EULA)… 过滤不当内容的方法… 用户举报不当内容的机制… 用户屏蔽恶意用户的机制…* 请提供预填充数据的演示账号(Google 或 Kakao)… 请在回复中附上真机录制的屏幕视频…

仅仅一个显示昵称的好友列表就让它成了"UGC 应用"。上述每一项要求都可以在**提交前从代码中**得知。这个 skill 就是做这件事——如果仍然被拒，它会把通知保存为案例，供下次检查复用。

## 功能

| 模式 | 你说 | 你得到 |
|---|---|---|
| **提交前预检** | `帮我检查应用审核` / `/store-review-check ~/dev/app` | 扫描 → 功能画像 → 逐项判定 🔴 FAIL / 🟠 WARN / ⚪ UNKNOWN / 🟢 PASS，附 `文件:行` 依据、修复方法和所需证明 → **HTML 报告(浏览器打开)或聊天输出** → 控制台清单 → 审核备注草稿 |
| **被拒处理** | 粘贴被拒邮件 | 解析 → 保存案例 → 映射到清单 ID → **并发被拒预测**(如仅有 Google/Kakao 登录 → Sign in with Apple 4.8) → 修复计划 → 证明视频录制脚本 → 英文回复 → 审核备注 |
| **提交信息** | `写审核备注` | App Store Connect *App Review Information* 备注与 Play Console *应用访问权限* 文案: 演示账号、绕过验证方式、举报/屏蔽/条款位置 |

skill 提出的所有问题都是**选择题**(必要时可多选): 平台、范围、HTML 还是聊天、下一步做什么。没有开放式来回追问。

## 安装

**Claude Code**
```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.claude/skills/store-review-check
```
**Codex CLI**
```bash
git clone https://github.com/LeeHueeng/store-review-check.git ~/.codex/skills/store-review-check
```
**其他 Agent Skills 运行时** — 克隆到该运行时的 skills 目录(文件夹名保持 `store-review-check`)。

重启智能体后:

```
> 帮我检查应用审核                    # 当前目录预检
> /store-review-check ~/dev/app     # Claude Code，指定路径
> $store-review-check                # Codex CLI
> 被拒了: <粘贴邮件>                  # 被拒处理
> 写审核备注                          # 提交信息
```

单独运行扫描器:
```bash
bash ~/.claude/skills/store-review-check/scripts/scan.sh ~/dev/app
```
识别 Flutter、React Native、Expo、iOS/Android 原生项目。输出的是"信号"，判定前智能体会打开文件核实。

## 示例

```
## 审核预检 — Focus Together (iOS, Android) 2026-08-28
🔴 FAIL 9 · 🟠 WARN 3 · ⚪ UNKNOWN 1 · 🟢 PASS 1   (复发风险: 2026-08-27-ios-1.2-ugc)

### 🔴 提交前必须修复
1. UGC-01 登录前无条款同意 — Apple 1.2 / Play UGC (lib/auth/login_screen.dart:41)
2. UGC-03 无举报机制 — Apple 1.2 / Play UGC
3. UGC-04 无屏蔽机制 — Apple 1.2 / Play UGC
4. IOS-LOGIN-01 仅 Google/Kakao 登录，无 Sign in with Apple — Apple 4.8
5. ACC-02 无应用内账号删除 — Apple 5.1.1(v) / Play
6. ACC-03 无可绕过两步验证的审核演示账号 — Apple 2.1 / Play 应用访问权限
7. AND-PERM-05 FOREGROUND_SERVICE 缺少 foregroundServiceType — Android 14
8. IOS-PRIV-03 缺少 PrivacyInfo.xcprivacy — ITMS-91053
…
报告: store-review/report-2026-08-28.html
```

## 检查内容

| 领域 | 示例 | 依据 |
|---|---|---|
| **UGC 与内容审核** | 含零容忍条款的 EULA 同意、内容过滤、举报、屏蔽(即时移除+通知开发者)、24 小时处理、真机录屏、预填充演示账号 | Apple 1.2 · Play UGC |
| **账号与登录** | 登录墙、应用内账号删除(+Play 网页链接)、海外 IP 可用的演示账号、有社交登录时的 Sign in with Apple、Kakao/Google 控制台配置 | Apple 5.1.1(iv)(v), 4.8, 2.1 · Play 账号删除、应用访问权限 |
| **隐私** | 应用内+商店隐私政策、App Privacy / 数据安全标签与 SDK 一致、ATT / AD_ID、显著披露、Privacy Manifest | Apple 5.1.1, 5.1.2 · Play 用户数据 |
| **权限** | 每个 API 的用途说明、拒绝后仍可用、未使用权限、Android 受限权限与声明表单(照片/视频、FGS 类型、精确闹钟、无障碍、QUERY_ALL_PACKAGES…) | Apple 5.1.1(ii) · Play 权限 |
| **支付与广告** | 数字商品走 IAP / Play 结算、订阅披露+条款链接、恢复购买、IAP 随版本提交、测试广告 ID、干扰性广告 | Apple 3.1.1, 3.1.2 · Play 付款、广告 |
| **后台与计时器** | 用静音音频保活计时器(2.5.4)、FGS 类型+Play 声明、改用本地通知 | Apple 2.5.4 · Android 14 FGS |
| **完成度与元数据** | 占位内容、iPad 崩溃、提及其他平台、截图、年龄分级"用户互动"、标题规则、支持 URL | Apple 2.1, 2.3.x, 2.4.1, 4.0 · Play 元数据 |
| **平台要求** | targetSdk 截止日期、16KB 页面、AAB/64 位、出口合规、最低 Xcode、新 Play 账号封闭测试、FamilyControls 授权 | — |
| **韩国** | 14 岁以下法定代理人同意、政策必备内容、IARC/GRAC | 个人信息保护法 |

**154 个检查项**，每项包含 *依据 / 适用条件 / 核实方法 / 扫描信号 / 修复 / 证明 / 案例*。全部对照 2026-08-28 的官方原文(2026-06-08 版 App Store Review Guidelines、Play 政策中心)核实 — 原文引用、URL 及 2025–2026 变更记录见 [`references/`](references/)。

## 真实被拒案例

[`rejections/community-cases.md`](rejections/community-cases.md) 收集了 **1270 条真实被拒案例**(2022–2026)，来自 Apple Developer Forums、Play 开发者社区、Stack Overflow、GitHub issues/PR、Hacker News、Kakao DevTalk、Habr、Fabapp、OKKY、Qiita/Zenn、掘金及开发者博客(英、韩、日、中、俄、西、葡、越、印尼、土、德、法文来源)的真实被拒案例，含审核员原话、根本原因、通过审核的修复以及来源链接。每个案例映射到清单 ID，预检时可以指出 *"有人正是因此被拒，这样修复后通过了"*。

## 让它学习你的被拒记录

1. 粘贴邮件 → 保存为 `rejections/YYYY-MM-DD-<platform>-<guideline>-<app>.md`，附 `checklist_ids`。
2. 清单里没有的原因 → 新增检查项；若可检测则新增扫描信号。
3. 下次预检 → 有重叠则置顶标记为**复发风险**。

## 仓库结构

```
SKILL.md                     skill 本体(规则、选择式流程、各模式工作流、信号→检查项映射)
scripts/scan.sh              项目信号扫描器(兼容 bash 3.2 / BSD grep)
scripts/render_report.py     JSON → 单文件 HTML 报告(筛选、深色模式、清单状态保存、复制备注)
checklists/common.md         功能条件项
checklists/ios.md            App Store 检查项
checklists/android.md        Google Play 检查项
checklists/ko/               翻译(以英文为准)
references/                  官方来源(Apple、Google Play)+ 韩国 / 日本 / 中国特有陷阱及来源
templates/                   报告 schema、案例、审核备注、回复、UGC 条款、录制脚本
rejections/                  案例库 — 你的案例 + community-cases.md
docs/                        示例报告 JSON + 截图
```

## 兼容性

- **Claude Code** — 通过 `AskUserQuestion`(多选)提问，生成并打开 HTML 报告。
- **Codex CLI** — 同一份 SKILL.md；问题以聊天中的编号选项呈现。
- 任何遵循 [Agent Skills 规范](https://agentskills.io/specification)(`name` + `description` frontmatter)的运行时。

## 贡献

欢迎 PR — 尤其是**真实被拒案例**(审核员原话+修复方法)和**指南更新**。在 `rejections/community-cases.md` 加一行，并从对应检查项的 `Cases:` 链接过去。

## 免责声明

指南会变化。日期相关数值(targetSdk 截止、最低 Xcode、封闭测试人数)均标注"截至日期"，提交前请以官方页面为准。本工具能减少被拒，但不保证通过。

## 许可证

MIT
