#!/usr/bin/env bash
# 녹화에서 멈춘 구간을 짧게 줄여 보고서용 클립을 만든다. 움직이는 구간은 프레임을 하나도 지우지 않는다.
#   trim-still.sh <입력.mp4> <출력.mp4> [남길 초=0.3] [멈춤으로 볼 최소 초=0.5]
#   멈춘 구간을 줄이지 않으려면: trim-still.sh <입력> <출력> 0 100000
# 마지막 줄에 "원본초 -> 결과초" 를 출력한다.
# mpdecimate 는 느린 움직임의 프레임까지 지워 애니메이션이 빨라 보여서 쓰지 않는다 (실측: 2초 움직임이 1초로).
# freezedetect 잡음 기준 n=0.0001 은 화면 일부의 1px 이동을 움직임으로 보고, 인코더 잡음은 멈춤으로 보는 값이다 (합성 영상 실측).
set -euo pipefail
[ $# -ge 2 ] || { echo "usage: trim-still.sh <in.mp4> <out.mp4> [hold-seconds] [min-freeze-seconds]" >&2; exit 2; }
IN="$1"; OUT="$2"; HOLD="${3:-0.3}"; MIN="${4:-0.5}"

dur() { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"; }

# freeze_start/freeze_end 를 짝지어 "각 멈춤의 처음 HOLD 초 뒤부터 끝까지" 를 지울 구간으로 만든다.
# 끝까지 멈춘 채 끝나면 freeze_end 가 없으므로 아주 큰 값으로 닫는다.
EXPR=$(ffmpeg -hide_banner -i "$IN" -vf "fps=30,freezedetect=n=0.0001:d=$MIN" -f null - 2>&1 \
  | { grep -oE "freeze_(start|end): [0-9.]+" || true; } \
  | awk -v h="$HOLD" '
      /start/ { s = $2; open = 1 }
      /end/   { e = e (e ? "+" : "") "between(t," s + h "," $2 ")"; open = 0 }
      END     { if (open) e = e (e ? "+" : "") "between(t," s + h ",1e9)"; print (e ? e : "0") }')

ffmpeg -loglevel error -y -i "$IN" \
  -vf "fps=30,select='not($EXPR)',setpts=N/FRAME_RATE/TB,scale=360:-2" \
  -c:v libx264 -crf 26 -pix_fmt yuv420p -an -movflags +faststart "$OUT"
echo "$(dur "$IN") -> $(dur "$OUT")"
