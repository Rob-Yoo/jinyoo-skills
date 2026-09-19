#!/usr/bin/env bash
# Instruments 기록: 앱을 새로 실행하고 pid 로 붙어 xctrace 로 기록한 뒤 표를 내보낸다. 시뮬레이터와 실기기 모두.
#
# 이 스크립트가 대신 처리하는 환경 함정:
# - 시뮬레이터 앱은 `xctrace --attach <이름>` 으로 찾지 못했다 → 실행 명령이 돌려준 pid 로 붙는다.
# - 실행 후 붙으므로 붙기 전 (앱 시작 직후) 의 이벤트는 기록되지 않는다.
# - 실기기 통합 로그 (Logger·os_log) 는 `log collect` 에 root 가 필요하다 → --template Logging --table os-log 로 받는다.
# - Leaks·Allocations 기록의 누수·할당 표는 xctrace export 로 나오지 않았다 → 그 기록은 Instruments 앱에서 연다.
# - xctrace export 가 같은 입력에서 간헐적으로 SIGSEGV 로 죽었다 (Xcode 26.2, os-log 표) → 최대 5번 다시 시도하고,
#   종료 코드 대신 XML 이 닫는 태그로 끝났는지로 성공을 판정한다 (죽으면서도 출력은 완결된 경우가 있었다).
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: trace.sh (--sim <UDID> | --device <UDID|이름>) --bundle-id <id> [options] [-- <app arguments>]

  --template <name>   xctrace 템플릿 (기본: 'Time Profiler'). 목록: xcrun xctrace list templates
  --seconds <n>       기록 시간 (기본: 10)
  --env NAME=VALUE    앱 환경변수. 여러 번 줄 수 있다
  --out <file.trace>  기록 파일 (기본: ./.trace/<시각>.trace)
  --table <schema>    이 표를 <out>.<schema>.xml 로 내보낸다. 여러 번 줄 수 있다.
                      없으면 기록에 든 표 목록만 출력한다. 예: potential-hangs, time-profile, os-signpost, os-log
EOF
}

SIM="" DEVICE="" BUNDLE="" TEMPLATE="Time Profiler" LIMIT=10 OUT=""
ENVS=() TABLES=() APP_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --sim) SIM="$2"; shift 2 ;;
    --device) DEVICE="$2"; shift 2 ;;
    --bundle-id) BUNDLE="$2"; shift 2 ;;
    --template) TEMPLATE="$2"; shift 2 ;;
    --seconds) LIMIT="$2"; shift 2 ;;
    --env) ENVS+=("$2"); shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    --table) TABLES+=("$2"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; APP_ARGS=("$@"); break ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
if [ -n "$SIM" ] && [ -z "$DEVICE" ]; then TARGET=sim; PREFIX=SIMCTL_CHILD_; ID="$SIM"
elif [ -n "$DEVICE" ] && [ -z "$SIM" ]; then TARGET=device; PREFIX=DEVICECTL_CHILD_; ID="$DEVICE"
else usage >&2; exit 2
fi
[ -n "$BUNDLE" ] || { usage >&2; exit 2; }
[ -n "$OUT" ] || OUT="./.trace/$(date +%Y%m%d-%H%M%S).trace"
[ -e "$OUT" ] && { echo "already exists: $OUT" >&2; exit 2; }
mkdir -p "$(dirname "$OUT")"

for kv in ${ENVS[@]+"${ENVS[@]}"}; do export "$PREFIX$kv"; done

if [ "$TARGET" = sim ]; then
  xcrun simctl boot "$SIM" 2>/dev/null
  xcrun simctl bootstatus "$SIM" -b >/dev/null 2>&1 || { echo "simulator $SIM did not boot" >&2; exit 2; }
  LAUNCHED=$(xcrun simctl launch --terminate-running-process "$SIM" "$BUNDLE" ${APP_ARGS[@]+"${APP_ARGS[@]}"}) \
    || { echo "launch failed" >&2; exit 2; }
  PID="${LAUNCHED##*: }"
else
  JSON="$OUT.launch.json"
  xcrun devicectl device process launch --device "$DEVICE" --terminate-existing --json-output "$JSON" \
    "$BUNDLE" ${APP_ARGS[@]+"${APP_ARGS[@]}"} >/dev/null 2>&1 || { echo "launch failed" >&2; exit 2; }
  PID=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["result"]["process"]["processIdentifier"])' "$JSON") \
    || { echo "no pid in $JSON" >&2; exit 2; }
fi
echo "pid: $PID"

xcrun xctrace record --template "$TEMPLATE" --device "$ID" --attach "$PID" \
  --time-limit "${LIMIT}s" --output "$OUT" --no-prompt --quiet || { echo "record failed" >&2; exit 2; }
[ "$TARGET" = sim ] && xcrun simctl terminate "$SIM" "$BUNDLE" 2>/dev/null
echo "trace: $OUT"

if [ ${#TABLES[@]} -eq 0 ]; then
  echo "tables:"
  xcrun xctrace export --input "$OUT" --toc | grep -oE 'schema="[^"]+"' | sort -u | sed 's/schema="\(.*\)"/  \1/'
  exit 0
fi
for t in "${TABLES[@]}"; do
  XML="$OUT.$t.xml"
  for attempt in 1 2 3 4 5; do
    xcrun xctrace export --input "$OUT" \
      --xpath "/trace-toc/run[@number=\"1\"]/data/table[@schema=\"$t\"]" > "$XML" 2>/dev/null
    tail -c 30 "$XML" | grep -q '</trace-query-result>' && break
    [ "$attempt" = 5 ] && { echo "export failed after 5 attempts: $t" >&2; exit 2; }
  done
  echo "$t: $XML ($(grep -c '<row' "$XML") rows)"
done
