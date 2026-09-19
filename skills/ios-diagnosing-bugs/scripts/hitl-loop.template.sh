#!/usr/bin/env bash
# 사람이 끼는 재현 루프. 실기기 화면 조작처럼 에이전트가 할 수 없는 단계를 사람에게 맡긴다.
# 이 파일을 복사해 아래 단계를 고친 뒤 실행한다. 에이전트가 스크립트를 실행하고, 사용자는 터미널의 안내를 따른다.
#
# 쓰는 법:
#   bash hitl-loop.sh
#
# 도우미 둘:
#   step "<안내>"            → 안내를 보여주고 Enter 를 기다린다
#   capture VAR "<질문>"     → 질문을 보여주고 답을 VAR 에 담는다
#
# 끝나면 받은 값을 KEY=VALUE 로 출력해 에이전트가 읽는다.
# capture 한 값은 터미널에 그대로 찍혀 에이전트가 읽으므로, 관찰한 것만 capture 하고
# 로그인처럼 비밀값이 드는 단계는 step 으로 사용자에게 맡긴다.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [끝나면 Enter] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- 아래를 고친다 -------------------------------------------------------

# (선택) 사람이 조작하는 동안 app-loop.sh 로 앱을 띄우고 출력을 받는다.
# app-loop.sh 는 --red-if 가 나오거나 --seconds 가 지날 때까지 돌므로 --seconds 를 조작 시간보다 넉넉히 준다.
LOOP_OUT="$(mktemp -d)/run.log"
bash <이 스킬 디렉토리>/scripts/app-loop.sh --device <UDID> --bundle-id <bundle id> --seconds 120 \
  --red-if '\[DEBUG-a4f2\] decode failed' --out "$LOOP_OUT" > "$LOOP_OUT.result" 2>&1 &
LOOP_PID=$!

step "기기에서 앱이 뜨면 카메라 화면으로 가서 QR 코드를 비춘다."

capture FROZE "화면이 1초 넘게 멈췄나요? (y/n)"

capture NOTE "그 밖에 본 것이 있으면 적어 주세요 (없으면 none):"

wait "$LOOP_PID" || true

# --- 위를 고친다 ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'FROZE=%s\n' "$FROZE"
printf 'NOTE=%s\n' "$NOTE"
printf 'LOOP_RESULT=%s\n' "$(head -1 "$LOOP_OUT.result")"
printf 'LOOP_OUTPUT=%s\n' "$LOOP_OUT"
