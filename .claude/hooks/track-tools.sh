#!/usr/bin/env bash
# track-tools.sh — 카운터 갱신 + antithesis baseline 리셋. PostToolUse "Bash|Task|WebSearch|WebFetch". 항상 exit 0.
# baseline = 마지막 '검토 ack' 시점의 편집수. Task(서브에이전트=antithesis 등) 실행 시 baseline←현재편집 → pending 리셋(작업 묶음 종료).
# 한계(안티테제 260701 문제 G): Task=antithesis라는 proxy — 다른 목적 Task도 리셋시키고, 서브에이전트 없는 antithesis 경로는 못 잡음.
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
tool="$(printf '%s' "$input" | (jq -r '.tool_name // empty' 2>/dev/null || echo ''))"
dir="${HOME}/.claude/.harness_state"; mkdir -p "$dir" 2>/dev/null
rd(){ v=$(cat "$dir/${sid}.$1" 2>/dev/null || echo 0); case "$v" in ''|*[!0-9]*) v=0 ;; esac; echo "$v"; }
inc(){ echo $(( $(rd "$1") + 1 )) > "$dir/${sid}.$1" 2>/dev/null; }
case "$tool" in
  Task)
    inc review
    echo "$(rd edits)" > "$dir/${sid}.baseline" 2>/dev/null   # 검토 ack → pending 리셋
    ;;
  WebSearch|WebFetch) inc research ;;
  Bash)
    cmd="$(printf '%s' "$input" | (jq -r '.tool_input.command // empty' 2>/dev/null || echo ''))"
    printf '%s' "$cmd" | grep -Eq '(agy|delegate\.sh|delegate-fanout\.sh)' && inc agy
    ;;
esac
exit 0
