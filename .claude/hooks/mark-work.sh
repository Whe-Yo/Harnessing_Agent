#!/usr/bin/env bash
# mark-work.sh — 편집 카운터(작업량 신호). PreToolUse "Edit|Write|NotebookEdit". 차단 안 함(항상 exit 0).
# 한계(안티테제 260701 문제 B): 편집 '횟수'라 1글자 수정과 대규모 리팩터가 동일 +1 — 크기 가중은 백로그.
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
dir="${HOME}/.claude/.harness_state"
mkdir -p "$dir" 2>/dev/null
find "$dir" -type f -mtime +7 -delete 2>/dev/null  # 오래된 세션 상태 정리
ef="$dir/${sid}.edits"; ec=$(cat "$ef" 2>/dev/null || echo 0); case "$ec" in ''|*[!0-9]*) ec=0 ;; esac
echo $((ec+1)) > "$ef" 2>/dev/null
exit 0
