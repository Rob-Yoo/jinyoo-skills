#!/usr/bin/env bash
# 녹화를 시작하고 Maestro 흐름을 돌린 뒤 녹화를 끝내고 마지막 화면을 찍는다.
#   rec.sh <UDID> <출력 디렉토리> <이름> <flow.yaml> [끝난 뒤 대기 초=2.5]
# 산출: <출력>/<이름>.mp4, <출력>/<이름>-end.png. 마지막 줄에 영상 크기(바이트)를 출력한다.
# 녹화는 화면이 바뀔 때만 프레임을 쓰므로(VFR) 크기로 화면 변화를 가늠한다. 같은 화면에서 입력 없이 찍은 기준 녹화와 비교한다.
set -euo pipefail
[ $# -ge 4 ] || { echo "usage: rec.sh <UDID> <out-dir> <name> <flow.yaml> [tail-seconds]" >&2; exit 2; }
U="$1"; OUT="$2"; NAME="$3"; FLOW="$4"; TAIL="${5:-2.5}"
mkdir -p "$OUT"
xcrun simctl io "$U" recordVideo --codec=h264 --force "$OUT/$NAME.mp4" >/dev/null 2>&1 &
P=$!
sleep 1.5
maestro --device "$U" test "$FLOW" 2>&1 | grep -E "COMPLETED|FAILED|WARNED" || true
sleep "$TAIL"
kill -INT "$P"; wait "$P" 2>/dev/null || true
xcrun simctl io "$U" screenshot "$OUT/$NAME-end.png" >/dev/null 2>&1
wc -c < "$OUT/$NAME.mp4" | tr -d ' '
