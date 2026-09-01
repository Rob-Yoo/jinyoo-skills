#!/usr/bin/env bash
# 상대 에이전트 CLI 를 읽기 전용으로 실행한다.
#   bash ask.sh <codex|claude> <<'EOF'
#   <프롬프트>
#   EOF
# 성공: stdout 에 결과 파일 경로 한 줄. 실패(CLI 오류·빈 결과): stderr 메시지 + exit 1.
set -euo pipefail

case "${1:-}" in
  codex)
    # -s read-only 는 셸 쓰기만 막는다. MCP·커넥터 도구는 사용자 설정과 apps 를 꺼서 뺀다.
    # 사용자 설정을 끄면 모델 설정도 빠지므로, config.toml 최상위의 model·model_reasoning_effort 만 되살린다.
    MODEL_ARGS=()
    CFG="${CODEX_HOME:-$HOME/.codex}/config.toml"
    if [ -f "$CFG" ]; then
      while IFS= read -r kv; do MODEL_ARGS+=(-c "$kv"); done < <(
        awk '/^[[:space:]]*\[/ { exit }
             /^[[:space:]]*(model|model_reasoning_effort)[[:space:]]*=/ { sub(/[[:space:]]*=[[:space:]]*/, "="); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print }' "$CFG")
    fi
    run() { codex exec -s read-only --ignore-user-config -c features.apps=false ${MODEL_ARGS[@]+"${MODEL_ARGS[@]}"} \
              --skip-git-repo-check -o "$OUT" - >/dev/null 2>"$LOG"; } ;;
  claude)
    # --tools 는 기본 도구만 제한한다. MCP 도구는 --strict-mcp-config 로 뺀다.
    run() { env -u CLAUDECODE claude -p --tools Read,Grep,Glob --strict-mcp-config - \
              >"$OUT" 2>"$LOG"; } ;;
  *)
    echo "usage: ask.sh <codex|claude> < prompt" >&2
    exit 2 ;;
esac

# 상대가 같은 이름의 스킬(second-opinion 등)을 스스로 발동해 되부르거나 범위 확인만 돌려주지 않게,
# 프롬프트 맨 앞에 고정 지시를 붙인다. SKILL.md 가 아니라 여기 두어 빠뜨릴 수 없게 한다.
PREFIX="다른 스킬·위임 절차를 쓰지 말고, 범위 확인 질문도 하지 말고, 읽기 전용으로 직접 답하라."

OUT="$(mktemp -t second-opinion)"
LOG="$OUT.log"
if ! { printf '%s\n\n' "$PREFIX"; cat; } | run; then
  echo "error: $1 실행 실패 — 로그: $LOG" >&2
  exit 1
fi
if [ ! -s "$OUT" ]; then
  echo "error: $1 결과가 비어 있음 — 로그: $LOG" >&2
  exit 1
fi
echo "$OUT"
