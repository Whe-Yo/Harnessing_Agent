---
title: 계측(카운터) 훅은 PostToolUse에 둔다 — 성공한 도구만 측정
type: decision
date: 260702_1126
tags: [hooks, counters, measurement]
links: [260702_1126_install-doc-drift]
---

**WHAT**: 편집 카운터(mark-work)를 PreToolUse에서 PostToolUse로 이동.

**WHY**: PreToolUse는 '시도'를 세고 PostToolUse는 '성공'을 센다. 카운터가 게이트(Stop·자문)의 근거라면 거부·실패한 편집까지 +1되는 순간 게이트가 허수로 발동한다. 차단 훅은 PreToolUse(막아야 하니 실행 전), 계측 훅은 PostToolUse(사실만 세야 하니 실행 후) — 역할별 이벤트 분리.

**REJECTED**: PreToolUse 유지 + 거부 감지 보정 — PreToolUse 시점엔 거부 여부를 알 수 없어 원리적으로 불가. 이벤트를 옮기는 게 유일한 정확한 해.

관련: [[260702_1126_install-doc-drift]] — 같은 260702 안티테제 라운드의 발견.
