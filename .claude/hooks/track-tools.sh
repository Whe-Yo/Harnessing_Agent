#!/usr/bin/env bash
# track-tools.sh — 카운터 갱신 + antithesis baseline 리셋. PostToolUse "Bash|Task|WebSearch|WebFetch". 항상 exit 0.
# baseline = 마지막 antithesis(검토 ack) 시점의 편집수. antithesis Task 실행 시만 리셋(안티테제 1-A: 아무 Task나 리셋하던 것 수정).
# research는 하달(agy) 발생 시 리셋(안티테제 1-B: clemini 넛지 만성 재발 방지 — 하달하면 조사 needs 해소).
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
    # antithesis Task일 때만 baseline 리셋(=검토 ack). 다른 서브에이전트(Explore·구현 위임)는 리셋 안 함.
    tp="$(printf '%s' "$input" | (jq -r '.tool_input.prompt // .tool_input.description // empty' 2>/dev/null || echo ''))"
    printf '%s' "$tp" | grep -Eqi 'antithesis|안티테제|반론 검토|독립 검토자|독립 인스턴스' && echo "$(rd edits)" > "$dir/${sid}.baseline" 2>/dev/null
    ;;
  WebSearch|WebFetch) inc research ;;
  Bash)
    cmd="$(printf '%s' "$input" | (jq -r '.tool_input.command // empty' 2>/dev/null || echo ''))"
    if printf '%s' "$cmd" | grep -Eq '(agy|delegate\.sh|delegate-fanout\.sh)'; then inc agy; echo 0 > "$dir/${sid}.research" 2>/dev/null; fi
    ;;
esac
exit 0
