#!/usr/bin/env bash
# process-status.sh — 매 턴 하네스 판단(UserPromptSubmit, 매처 없음 = 매 턴). 판단은 항상, 출력은 넛지 있을 때만(clean이면 침묵 → 의례화·토큰 완화, 안티테제 260701 문제 D).
#
# 발동 조건(구체화 260701 — 안티테제 반영):
#   · antithesis  : pending(=마지막 검토 이후 편집) ≥ 3      [최우선]. Task(서브에이전트) 실행 시 baseline 리셋(=검토 ack) → pending 0.
#   · RPW 생성    : RPW 없음 & 누적편집 ≥ 2
#   · Datavault   : 누적편집 ≥ 5 & datavault 노트 0
#   · clemini 하달: 조사(WebSearch/WebFetch) ≥ 4 & agy 하달 0
#   넛지는 우선순위 최상 1개만 출력(antithesis > RPW > Datavault > 하달) — 정보 과부하 방지(문제 C).
#   임계치는 휴리스틱(편집 '횟수' proxy의 한계는 문제 B — 크기 가중은 백로그).
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
cwd="$(printf '%s' "$input" | (jq -r '.cwd // empty' 2>/dev/null || echo ''))"
[ -n "$cwd" ] || cwd="$PWD"
dir="${HOME}/.claude/.harness_state"
rd(){ v=$(cat "$dir/${sid}.$1" 2>/dev/null || echo 0); case "$v" in ''|*[!0-9]*) v=0 ;; esac; echo "$v"; }
edits=$(rd edits); baseline=$(rd baseline); agy=$(rd agy); research=$(rd research)
pending=$(( edits - baseline )); [ "$pending" -lt 0 ] && pending=0

if   [ -f "$cwd/rule_plan_work.md" ]; then rpw="있음";
elif [ -f "$cwd/work.md" ];          then rpw="있음(work.md)";
else rpw="없음"; fi
dv=$(find "$cwd/datavault" -maxdepth 1 -name '*.md' ! -name 'INDEX.md' 2>/dev/null | wc -l | tr -d ' '); case "$dv" in ''|*[!0-9]*) dv=0 ;; esac

rem=""
if   [ "$pending" -ge 3 ]; then rem="주요 작업(미검토 편집 ${pending}회) → antithesis 독립검토를 '묻지 말고' 실행(서브에이전트 실행 시 자동 해제) 또는 생략 사유 한 줄."
elif [ "$rpw" = "없음" ] && [ "$edits" -ge 2 ]; then rem="RPW 미생성 → rule_plan_work.md 스켈레톤 생성 권장."
elif [ "$edits" -ge 5 ] && [ "$dv" -eq 0 ]; then rem="아키텍처 결정·패턴·안티패턴이 나왔다면 Datavault 원자 노트로(현재 ${dv}개, '나중에'는 유실)."
elif [ "$research" -ge 4 ] && [ "$agy" -eq 0 ]; then rem="조사 ${research}회·하달 0 → clemini delegate.sh로 Gemini 하달 고려(Claude 토큰 절약)."
fi

# clean(넛지 없음)이면 침묵 — 판단은 매 턴 수행되나 출력 안 함. 넛지 있을 때만 1줄.
[ -n "$rem" ] && printf '[하네스] RPW:%s·미검토편집:%s·하달:%s·조사:%s·DV:%s — %s\n' "$rpw" "$pending" "$agy" "$research" "$dv" "$rem"
exit 0
