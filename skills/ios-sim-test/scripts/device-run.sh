#!/usr/bin/env bash
# 실기기에서 Maestro flow 하나를 실행한다.
# Maestro iOS 드라이버는 기기 안 127.0.0.1:<port> 에 열리고 맥에서 닿지 않으므로,
# maestro.log 에서 포트를 읽어 iproxy 로 같은 포트를 USB 포워딩한다. 끝나면 그 iproxy 를 닫는다.
#   device-run.sh <UDID> <flow.yaml 절대경로>
#   SHOTS=<dir> device-run.sh ...   # 실행 중 드라이버 /screenshot 을 반복 호출해 프레임 저장 (녹화 대용, 파일명은 ms 시각)
#   SHOT_ROOT=<dir>                 # takeScreenshot 절대경로의 공통 접두사 (옮기기용, 기본: 현재 디렉토리)
# 출력: "port <N>", flow 결과 끝 15줄, 옮긴 takeScreenshot 경로 ("shot <경로>"). 종료 코드는 maestro 의 것.
# 포트는 maestro.log 의 "Selected device <UDID> using port N" 문구로 읽는다 (Maestro 2.7.0). 버전이 바뀌면 문구부터 확인한다.
set -u
[ $# -eq 2 ] || { echo "usage: device-run.sh <UDID> <flow.yaml 절대경로>" >&2; exit 2; }
U="$1"; FLOW="$2"; SHOT_ROOT="${SHOT_ROOT:-$PWD}"
case "$FLOW" in /*) ;; *) echo "flow 는 절대경로로 준다: $FLOW" >&2; exit 2;; esac
START=$(date +%H:%M:%S)   # ponytail: 자정을 넘겨 실행하면 이 시각 비교가 어긋난다. 다시 실행한다.
cd /tmp   # maestro 는 작업 디렉토리에 로그·임시파일을 만들 수 있어 레포 밖에서 실행
maestro --device "$U" test "$FLOW" > "$FLOW.out" 2>&1 &
MP=$!; IP=""
for i in $(seq 1 120); do
  PORT=$(cat $(ls -td ~/.maestro/tests/*/ | head -4 | sed 's|$|maestro.log|') 2>/dev/null \
    | grep "Selected device $U using port" | awk -v s="$START" 'substr($1,1,8)>=s' \
    | grep -o "using port [0-9]*" | tail -1 | grep -o "[0-9]*$")
  if [ -n "$PORT" ]; then
    iproxy "$PORT:$PORT" -u "$U" >/dev/null 2>&1 & IP=$!; echo "port $PORT"
    if [ -n "${SHOTS:-}" ]; then
      mkdir -p "$SHOTS"
      ( while kill -0 $MP 2>/dev/null; do
          curl -s -m 3 -o "$SHOTS/f-$(python3 -c 'import time;print(int(time.time()*1000))').jpg" \
            "http://127.0.0.1:$PORT/screenshot?compressed=true"
        done ) &
    fi
    break
  fi
  kill -0 $MP 2>/dev/null || break
  sleep 0.5
done
# 드라이버 예외가 나면 maestro 가 끝나지 않고 멈춰 있으므로 감시해서 끝낸다.
while kill -0 $MP 2>/dev/null; do grep -q "Exception in thread" "$FLOW.out" && { sleep 1; kill $MP; }; sleep 0.5; done
wait $MP; RC=$?
[ -n "$IP" ] && kill $IP 2>/dev/null
grep -v WARNING "$FLOW.out" | grep -v "^\s*at " | grep -v "^Detected\|^Running on" | tail -15
# 실기기에서 takeScreenshot 은 ~/.maestro/tests/<시각>/<flow>/takeScreenshot/<절대경로> 에 저장된다 → 원래 경로로 옮긴다.
find ~/.maestro/tests -newer "$FLOW" -path "*takeScreenshot${SHOT_ROOT}/*" -name "*.png" 2>/dev/null | while read f; do
  d="/${f#*takeScreenshot/}"; mkdir -p "$(dirname "$d")"; mv "$f" "$d"; echo "shot $d"
done
exit $RC
