# Feedback — 260701_1121 / claude

## 유형
bug (A) + friction/enhancement (B, C)

## 요약
비-하네스 프로젝트(2dtomesh) 다시간 실무 세션에서 하네스는 정상 장착(훅 전 이벤트 설정, agy 인증)됐으나 RPW·antithesis·clemini가 전 세션 0회 실동작. 원인은 (A) guard-secrets 과차단(구체 버그) + (B) 넛지형 소프트규칙이 실무 몰입에 밀리고 저시야성이라 실효 없음(설계).

## 무슨 일이

### A. guard-secrets.sh 과차단 (bug)
- 하려던 것: 사용자의 2계정 SSH 셋업 지원(공개키 `*.pub` 조회, `~/.ssh/config` 작성).
- 일어난 것: `~/.ssh` 경로면 읽기·쓰기·복사 전부 차단 → 공개키(비밀 아님) 조회 불가, config 작성 불가. 단 `ssh-keygen -f ~/.ssh/...`(생성)는 통과됨.
- 기대한 것: 개인키만 차단, 공개키 읽기·config 쓰기는 허용.
- 제안: `BEGIN OPENSSH PRIVATE KEY`/`id_*`(비-.pub) 개인키만 차단, `*.pub` 읽기·`~/.ssh/config` 쓰기 허용으로 세분화.

### B. 소프트 규칙이 실무 몰입에 밀림 (friction/enhancement) — 핵심
- 일어난 것: 설치·디버깅·실험에 몰두하는 동안 boost/RPW/antithesis/clemini를 자발 호출하지 않음.
- 증거: `rule_plan_work.md` 미생성, antithesis 0회, Gemini 위임 0회(web_search 15+회 전부 에이전트 자체 수행).
- B2: `stop-antithesis.sh`는 Stop 훅으로 연결돼 있으나 "작업묶음당 1회 + 에이전트향 + 저시야성"이라 수십 회 편집·대량 설계에도 실동작 안 함.
- B3: RPW 미부트스트랩 — 프로젝트에 rule_plan_work.md 부재 → SessionStart의 boost가 로드할 상태 없음.
- B4: clemini 위임 미트리거 — agy 인증됨(`agy models` 정상)인데 "조사→Gemini" 라우팅이 넛지/강제 없이 방치, 토큰절약 동기 미실현.
- 제안: 주요 작업단위마다 antithesis 넛지 재무장(누적 편집 임계치), RPW 자동 생성(스켈레톤), 조사 N회 누적 시 위임 넛지.

### C. 프로세스 가시성 부재 (enhancement)
- 일어난 것: 차단형 가드훅(secrets/git)만 사용자에게 보이고, 넛지형(RPW·antithesis·clemini)은 전부 에이전트 내부 → 사용자가 "돌고 있는지" 알 수 없음(사용자가 직접 "왜 안 도냐" 질문한 것이 증상).
- 제안: 턴당 "프로세스 상태" 1줄(RPW 최신여부 / antithesis 실행여부 / 위임 사용여부) 노출 옵션.

## 환경
- 에이전트: claude (Claude Code, Opus 4.8)
- OS: Linux
- 도구: settings.json 훅 전 이벤트 설정됨(PreToolUse/SessionStart/Stop/PostToolUse/UserPromptSubmit/Notification/SubagentStop), guard-secrets·guard-git 작동 확인, agy 인증됨.
- 프로젝트: /workspace/Project/2dtomesh (비-하네스)

## 재현
1. 비-하네스 프로젝트에서 다시간 실무(설치·디버깅·실험) 진행.
2. 세션 종료까지 boost/RPW/antithesis/clemini 자발 호출 안 됨 확인 (rule_plan_work.md 부재, antithesis 0회, agy 위임 0회).
3. guard-secrets: `cat ~/.ssh/*.pub` 또는 `cat > ~/.ssh/config` 시도 → §9 차단.

## 관련 스킬·규칙
- please-work-claude: RPW(7절), antithesis(6절), boost(7절), 훅(stop-antithesis.sh, guard-secrets.sh)
- clemini: 라우팅(조사→Gemini), delegate.sh, agy
