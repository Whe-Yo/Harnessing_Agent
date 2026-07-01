#!/usr/bin/env bash
# stop-antithesis.sh — antithesis 게이트(Stop). 미검토 편집 pending(=edits-baseline) ≥3이면 턴 종료를 차단·환기.
# 작업 묶음당 1회: baseline으로 pending 계산 → 구 .nudged '세션 영구 1회' 버그(안티테제 260701 문제 F) 제거.
#   Task(서브에이전트=antithesis) 실행 시 track-tools가 baseline 리셋 → 다음 묶음에서 다시 발동.
# 무한루프 차단: stop_hook_active + stopped_baseline(이 묶음에서 이미 막았으면 통과). bash 3.2 호환. jq 없어도 폴백.
set -u
input="$(cat)"
active="$(printf '%s' "$input" | (jq -r '.stop_hook_active // false' 2>/dev/null || echo false))"
[ "$active" = "true" ] && exit 0
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
dir="${HOME}/.claude/.harness_state"
rd(){ v=$(cat "$dir/${sid}.$1" 2>/dev/null || echo 0); case "$v" in ''|*[!0-9]*) v=0 ;; esac; echo "$v"; }
edits=$(rd edits); baseline=$(rd baseline); stopped=$(rd stopped_baseline)
pending=$(( edits - baseline )); [ "$pending" -lt 0 ] && pending=0

[ "$pending" -ge 3 ] || exit 0
# 이 작업 묶음(현 baseline)에서 이미 막았으면 통과 — 묶음당 1회
[ -f "$dir/${sid}.stopped_baseline" ] && [ "$stopped" = "$baseline" ] && exit 0
echo "$baseline" > "$dir/${sid}.stopped_baseline" 2>/dev/null

reason="이번 작업 묶음에 미검토 편집 ${pending}회. 끝내기 전 §6 antithesis를 처리하라 — 독립 인스턴스(Agent 툴)로 1회 반론 검토를 '묻지 말고' 실행(그러면 자동 해제), 또는 사소하면 생략 사유 한 줄. (작업 묶음당 1회.)"
jq -n --arg r "$reason" '{decision:"block", reason:$r}' 2>/dev/null \
  || printf '{"decision":"block","reason":"미검토 편집이 쌓였다 — antithesis를 실행하거나 생략 사유를 남겨라."}\n'
exit 0
