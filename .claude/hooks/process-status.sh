#!/usr/bin/env bash
# process-status.sh — 하이브리드 자율 판단(UserPromptSubmit, 매처 없음 = 매 턴).
# 방식: 물리 조건(싸게 감지) 충족 → "스스로에게 질문"을 주입한다 — "툴박스에 a,b,c,d가 있는데 지금 쓸 게 있나?"
#   특정 명령을 강제하지 않으므로, 편집 카운터 proxy의 오차(안티테제 260701 문제 B/G)가
#   '틀린 명령'이 아니라 '검토할 후보'로 완화된다. 어느 툴이 맞는지는 에이전트가 판단(자율).
# 판단은 매 턴, 출력은 후보 있을 때만(clean이면 침묵 → 의례화·토큰 완화, 문제 D).
#
# 물리 트리거(구체화 260701):
#   antithesis  : pending(=마지막 검토 이후 편집) ≥3   (Task 실행 시 track-tools가 baseline 리셋)
#   clemini 하달: 조사(WebSearch/WebFetch) ≥4 & agy 하달 0   (Cohort는 웹조사도 가능 → 통째 하달)
#   RPW 생성    : RPW 없음 & 누적편집 ≥2
#   Datavault   : 누적편집 ≥5 & 노트 0
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

# 물리 조건 → 후보 툴 목록(판단은 에이전트). 우선순위 상위 최대 2개만(과부하 방지, skill_activation 원칙 일치 — 안티테제 1-C).
# 순위: antithesis > clemini하달 > RPW > Datavault.
paper=0; [ -f "$dir/${sid}.paper" ] && paper=1
cand=""; n=0
addc(){ [ "$n" -lt 2 ] && { cand="${cand} · $1"; n=$((n+1)); }; }
[ "$pending" -ge 2 ] && addc "verify(수정 동작 확인했나?)"
[ "$pending" -ge 3 ] && addc "antithesis(미검토편집 ${pending} — 독립검토?)"
[ "$paper" = "1" ] && [ "$pending" -ge 2 ] && addc "paper(논문 파일 편집 — 컴파일·리뷰?)"
[ "$research" -ge 4 ] && [ "$agy" -eq 0 ] && addc "clemini하달(조사 ${research}회 직접 — 웹조사까지 Cohort로?)"
[ "$rpw" = "없음" ] && [ "$edits" -ge 2 ] && addc "RPW생성(상태 스냅샷 없음)"
[ "$edits" -ge 5 ] && [ "$dv" -eq 0 ] && addc "Datavault(결정·패턴을 원자 노트로?)"

# 후보 있을 때만 '자문' 1줄 주입. 없으면 침묵.
[ -n "$cand" ] && printf '[하네스 자문] 툴박스에 지금 쓸 것 있나?%s — 해당되면 실행(묻지 말고), 없으면 넘어가라.\n' "$cand"
exit 0
