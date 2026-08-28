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
    run() { codex exec -s read-only --ignore-user-config -c features.apps=false \
              --skip-git-repo-check -o "$OUT" - >/dev/null 2>"$LOG"; } ;;
  claude)
    # --tools 는 기본 도구만 제한한다. MCP 도구는 --strict-mcp-config 로 뺀다.
    run() { env -u CLAUDECODE claude -p --tools Read,Grep,Glob --strict-mcp-config - \
              >"$OUT" 2>"$LOG"; } ;;
  *)
    echo "usage: ask.sh <codex|claude> < prompt" >&2
    exit 2 ;;
esac

OUT="$(mktemp -t second-opinion)"
LOG="$OUT.log"
if ! run; then
  echo "error: $1 실행 실패 — 로그: $LOG" >&2
  exit 1
fi
if [ ! -s "$OUT" ]; then
  echo "error: $1 결과가 비어 있음 — 로그: $LOG" >&2
  exit 1
fi
echo "$OUT"
