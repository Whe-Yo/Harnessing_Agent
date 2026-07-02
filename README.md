# Please-Work Claude

Claude(Claude Code)를 위한 하네스. 규칙·스킬·훅을 Claude에 주입해 사고·검증·보고 절차를 일관되게 만든다.

> 가족: **claude**(Claude 하네스) · [gemini](https://github.com/Whe-Yo/please-work-gemini)(Gemini/Cohort 하네스) · [clemini](https://github.com/Whe-Yo/please-work-clemini)(Claude×Gemini 오케스트레이션)

> [!CAUTION]
> **이 저장소는 도구함이다. 도구함 안에서 작업하지 않는다.**
> Claude는 여기서 재료를 읽고 복사해 자기 환경(`~/.claude/`)에 주입한다. 프로젝트 작업의 일환으로 이 저장소를 수정·기록·설정하지 않는다.
> 예외는 [`log_for_test/`](log_for_test/) 하나 — `feedback` 절차로만 md를 추가한다. 나머지 경로는 성역이다.

## [ 핵심 세 축 ]

- **적응형 하네싱** — 고정 묶음이 아니라 프로젝트에 맞는 스킬만 골라 장착한다. `setup`이 [`SKILL_INDEX.md`](skills/SKILL_INDEX.md)를 읽고 `~/.claude/commands/`에 설치하고, `manage`가 갱신한다.
- **RPW (Rule · Plan · Work)** — 세션이 바뀌어도 끊기지 않는 현재 상태 스냅샷. 덮어쓰는 문서이고 히스토리는 git이 담당한다. 템플릿: [`rules/rule_plan_work_template.md`](rules/rule_plan_work_template.md). 에피그래프: *"Knowledge is power, guard it well."*
- **N회 안티테제** — 이전 대화를 모르는 독립 인스턴스(Agent 툴로 소환)가 RPW + 검토 대상만 받아 반론 검토한다. 최소 1회, 발산하면 사용자 중재.

## [ 세 겹의 기억 ]

역할이 겹치지 않는 세 저장소를 쓴다. 상세는 [`rules/datavault.md`](rules/datavault.md).

| | 담는 것 | 수명 |
|---|---|---|
| **RPW** | 현재 세션의 상태·계획 | 덮어씀 |
| **Datavault** (`datavault/`) | 세션 초월 지식 — 결정·패턴·안티패턴의 원자 노트 그래프 | 누적 |
| **git** | 변경 사실 | 영구 |

## [ 두 층 — 효력의 경계 ]

| 층 | 구성 | 효력 |
|---|---|---|
| **지시 층** | CLAUDE.md · 스킬 · RPW | 소프트 — 대체로 따름 |
| **강제·가시성 층** | Hooks·permissions ([`.claude/`](.claude/)) | 하드 차단 + 조건부 자문 — 가드레일(셸 우회까지 막진 못함) |

훅 7종. 차단: `guard-secrets`(.env·자격증명 읽기)·`guard-git`(force-push·`reset --hard`·history rewrite)를 PreToolUse가 exit 2로 끊는다. 게이트: `stop-antithesis`가 주요 작업 후 검토 미실행 시 턴 종료를 1회 막는다. 가시성: `mark-work`·`track-tools`가 카운터를 갱신하고, `process-status`가 매 턴 **하이브리드 자문**을 준다 — 물리 조건이 차면 "툴박스에 지금 쓸 것 있나?"를 한 줄 주입하고, 아니면 침묵한다. 기능별 발동 기준은 [`rules/skill_activation.md`](rules/skill_activation.md).

## [ 구성 요소 ]

- [`rules/CLAUDE.md`](rules/CLAUDE.md) — 행동 원칙. `~/.claude/CLAUDE.md`에 병합.
- [`skills/`](skills/) — 스킬 12종. 목록은 [`SKILL_INDEX.md`](skills/SKILL_INDEX.md).
- [`mcp/mcp_template.json`](mcp/mcp_template.json) — MCP 서버 명세(context7, sequential-thinking, exa, memory).
- [`.claude/`](.claude/) — 강제·가시성 층 실물(settings.json + 훅 7종). `setup`이 설치·검증한다.

## [ 적용 ]

1. [`rules/CLAUDE.md`](rules/CLAUDE.md) 내용을 `~/.claude/CLAUDE.md`(또는 프로젝트 CLAUDE.md)에 직접 병합한다. `@경로` import는 환경에 따라 전개되지 않는다(실증).
2. Claude에게 `setup`을 지시한다 — 스킬 장착·MCP 등록·강제층 설치에 더해 **검증 게이트**(가드 차단 + 가시성층 기능 테스트)를 통과해야 설치 완료다.
3. RPW는 프로젝트별로 그 루트에 생성된다.

## [ 피드백 로그 ]

실사용 마찰·안티테제 기록은 [`log_for_test/`](log_for_test/)에 남긴다(`YYMMDD_HHMM_claude.md`). 버전 이력은 [CHANGELOG.md](CHANGELOG.md).

---

# Please-Work Claude (English)

A harness for Claude (Claude Code). It injects rules, skills, and hooks so that reasoning, verification, and reporting stay consistent.

> Family: **claude** (Claude harness) · [gemini](https://github.com/Whe-Yo/please-work-gemini) (Gemini/Cohort harness) · [clemini](https://github.com/Whe-Yo/please-work-clemini) (Claude×Gemini orchestration)

> [!CAUTION]
> **This repository is a toolbox. Do not work inside the toolbox.**
> Claude reads and copies materials from here into its own environment (`~/.claude/`). Modifying this repository as part of project work is prohibited.
> The single exception is [`log_for_test/`](log_for_test/) — md files are added only through the `feedback` procedure. Everything else is a sanctuary.

## [ Three Pillars ]

- **Adaptive harnessing** — not a fixed bundle; `setup` reads [`SKILL_INDEX.md`](skills/SKILL_INDEX.md) and installs only the skills the project needs into `~/.claude/commands/`.
- **RPW (Rule · Plan · Work)** — a current-state snapshot that survives session boundaries. It is overwritten in place; history belongs to git. Template: [`rules/rule_plan_work_template.md`](rules/rule_plan_work_template.md). Epigraph: *"Knowledge is power, guard it well."*
- **N-times antithesis** — an independent instance with no knowledge of the prior conversation receives only the RPW and the review target, and argues against it. At least once; the user arbitrates on divergence.

## [ Three Layers of Memory ]

Three stores with non-overlapping roles. Details: [`rules/datavault.md`](rules/datavault.md).

| | Holds | Lifetime |
|---|---|---|
| **RPW** | Current session state and plan | Overwritten |
| **Datavault** (`datavault/`) | Cross-session knowledge — atomic notes of decisions, patterns, anti-patterns | Accumulates |
| **git** | What changed | Permanent |

## [ Two Layers of Enforcement ]

| Layer | Made of | Force |
|---|---|---|
| **Instruction** | CLAUDE.md · skills · RPW | Soft — mostly followed |
| **Enforcement & visibility** | Hooks·permissions ([`.claude/`](.claude/)) | Hard blocks + conditional advisory — a guardrail, not shell-proof |

Seven hooks. Blocking: `guard-secrets` (.env/credential reads) and `guard-git` (force-push, `reset --hard`, history rewrites) exit 2 at PreToolUse. Gate: `stop-antithesis` blocks turn end once after major work without review. Visibility: `mark-work` and `track-tools` keep counters, and `process-status` injects a one-line **hybrid advisory** ("anything in the toolbox worth using now?") only when physical conditions are met — silence otherwise. Activation criteria: [`rules/skill_activation.md`](rules/skill_activation.md).

## [ Components ]

- [`rules/CLAUDE.md`](rules/CLAUDE.md) — behavioral principles, merged into `~/.claude/CLAUDE.md`.
- [`skills/`](skills/) — 12 skills; see [`SKILL_INDEX.md`](skills/SKILL_INDEX.md).
- [`mcp/mcp_template.json`](mcp/mcp_template.json) — MCP server specs (context7, sequential-thinking, exa, memory).
- [`.claude/`](.claude/) — the enforcement/visibility layer itself (settings.json + 7 hooks). Installed and verified by `setup`.

## [ Setup ]

1. Merge the contents of [`rules/CLAUDE.md`](rules/CLAUDE.md) directly into `~/.claude/CLAUDE.md` (path imports may silently fail to expand — verified).
2. Tell Claude to run `setup` — skill installation, MCP registration, enforcement layer install, plus a mandatory **verification gate** (guard blocking + visibility-layer functional test).
3. The RPW document is created per project, at its root.

## [ Feedback Log ]

Real-use friction and antithesis records go to [`log_for_test/`](log_for_test/) (`YYMMDD_HHMM_claude.md`). Version history: [CHANGELOG.md](CHANGELOG.md).
