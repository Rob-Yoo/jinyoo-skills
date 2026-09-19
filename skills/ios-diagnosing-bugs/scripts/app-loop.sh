#!/usr/bin/env bash
# 앱 실행 루프: (선택) 빌드 → 설치 → 실행 → 출력 캡처 → 패턴으로 red/green 판정. 시뮬레이터와 실기기 모두.
# 종료 코드: 0 green, 1 red, 2 준비 실패.
# 앱이 제한 시간 전에 끝나면 (크래시 등) 패턴이 판정하지 않은 한 red 다.
#
# 이 스크립트가 대신 처리하는 환경 함정:
# - macOS 에는 timeout 이 없다 → 실행 시간 상한을 직접 관리한다.
# - `simctl launch --stdout=<path>` 로는 파일이 생기지 않았다 → 콘솔 출력 (--console-pty / --console) 을 파일로 받는다.
# - print 는 stdout 으로, Logger·os_log 는 통합 로그로 간다 → 시뮬레이터는 --log-predicate 로 함께 받는다.
#   log stream 은 준비 신호 없이 늦게 붙어 시작 직후 로그를 놓쳤다 → 실행 중엔 stream 으로 조기 판정만 하고,
#   끝난 뒤 `log show --start <실행 시각>` 으로 다시 받아 최종 판정한다.
#   실기기 통합 로그는 `log collect` 에 root 가 필요하다 → trace.sh --template Logging --table os-log 를 쓴다.
# - DerivedData 경로가 바뀌면 매번 전체 빌드다 → 경로를 고정한다.
# - 앱 환경변수 접두어가 다르다 (시뮬레이터 SIMCTL_CHILD_, 실기기 DEVICECTL_CHILD_) → --env 로 받아 붙인다.
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: app-loop.sh (--sim <UDID> | --device <UDID|이름>) --bundle-id <id> [options] [-- <app arguments>]

  --sim <UDID>                 시뮬레이터 (xcrun simctl list devices)
  --device <UDID|이름>          실기기 (xcrun devicectl list devices). 빌드에는 서명이 필요하다
  --build "<xcodebuild args>"  빌드 후 설치. 예: --build "-project App.xcodeproj -scheme App"
                               실기기 자동 서명이면 -allowProvisioningUpdates 를 함께 준다
  --derived-data <dir>         빌드 DerivedData 경로 (기본: ./.app-loop/dd). 고정해야 증분 빌드가 된다
  --app <path>                 빌드 없이 이 .app 을 설치
  --env NAME=VALUE             앱 환경변수. 여러 번 줄 수 있다
  --seconds <n>                실행 시간 상한 (기본: 30)
  --red-if <regex>             출력에 이 패턴이 나오면 red (나오는 즉시 끝낸다)
  --red-unless <regex>         출력에 이 패턴이 끝까지 없으면 red (나오는 즉시 green 으로 끝낸다)
                               패턴과 무관하게, 앱이 제한 시간 전에 끝나면 (크래시 등) red
  --log-predicate <predicate>  통합 로그도 함께 캡처해 판정에 쓴다 (시뮬레이터만). 예: 'subsystem == "com.example.app"'
  --out <file>                 출력 저장 경로 (기본: ./.app-loop/run.log)

--build 와 --app 이 둘 다 없으면 이미 설치된 앱을 다시 실행만 한다.
EOF
}

SIM="" DEVICE="" BUNDLE="" BUILD="" DD="./.app-loop/dd" APP="" LIMIT=30 RED_IF="" RED_UNLESS="" PRED="" OUT="./.app-loop/run.log"
ENVS=() APP_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --sim) SIM="$2"; shift 2 ;;
    --device) DEVICE="$2"; shift 2 ;;
    --bundle-id) BUNDLE="$2"; shift 2 ;;
    --build) BUILD="$2"; shift 2 ;;
    --derived-data) DD="$2"; shift 2 ;;
    --app) APP="$2"; shift 2 ;;
    --env) ENVS+=("$2"); shift 2 ;;
    --seconds) LIMIT="$2"; shift 2 ;;
    --red-if) RED_IF="$2"; shift 2 ;;
    --red-unless) RED_UNLESS="$2"; shift 2 ;;
    --log-predicate) PRED="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; APP_ARGS=("$@"); break ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
if [ -n "$SIM" ] && [ -z "$DEVICE" ]; then TARGET=sim; PREFIX=SIMCTL_CHILD_
elif [ -n "$DEVICE" ] && [ -z "$SIM" ]; then TARGET=device; PREFIX=DEVICECTL_CHILD_
else usage >&2; exit 2
fi
[ -n "$BUNDLE" ] || { usage >&2; exit 2; }
if [ "$TARGET" = device ] && [ -n "$PRED" ]; then
  echo "--log-predicate is simulator-only; on a device use: trace.sh --device ... --template Logging --table os-log" >&2
  exit 2
fi

mkdir -p "$(dirname "$OUT")"
UNIFIED="$OUT.unified"
: > "$OUT"; : > "$UNIFIED"

if [ "$TARGET" = sim ]; then
  xcrun simctl boot "$SIM" 2>/dev/null
  xcrun simctl bootstatus "$SIM" -b >/dev/null 2>&1 || { echo "simulator $SIM did not boot" >&2; exit 2; }
fi

if [ -n "$BUILD" ]; then
  read -r -a BUILD_ARGS <<< "$BUILD"
  if [ "$TARGET" = sim ]; then DEST="platform=iOS Simulator,id=$SIM"; SDK_DIR="-iphonesimulator"
  else DEST="platform=iOS,id=$DEVICE"; SDK_DIR="-iphoneos"
  fi
  xcodebuild "${BUILD_ARGS[@]}" -destination "$DEST" -derivedDataPath "$DD" -quiet build \
    || { echo "build failed" >&2; exit 2; }
  APP=$(find "$DD/Build/Products" -maxdepth 2 -type d -name '*.app' -path "*$SDK_DIR/*" | head -1)
  [ -n "$APP" ] || { echo "no .app under $DD/Build/Products" >&2; exit 2; }
fi
if [ -n "$APP" ]; then
  if [ "$TARGET" = sim ]; then xcrun simctl install "$SIM" "$APP"
  else xcrun devicectl device install app --device "$DEVICE" "$APP" >/dev/null 2>&1
  fi || { echo "install failed: $APP" >&2; exit 2; }
fi

for kv in ${ENVS[@]+"${ENVS[@]}"}; do export "$PREFIX$kv"; done

LOG_PID=""
if [ -n "$PRED" ]; then
  xcrun simctl spawn "$SIM" log stream --style compact --predicate "$PRED" < /dev/null > "$UNIFIED" 2>&1 &
  LOG_PID=$!
fi
T0=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$TARGET" = sim ]; then
  xcrun simctl launch --console-pty --terminate-running-process "$SIM" "$BUNDLE" \
    ${APP_ARGS[@]+"${APP_ARGS[@]}"} < /dev/null > "$OUT" 2>&1 &
else
  xcrun devicectl device process launch --device "$DEVICE" --console --terminate-existing "$BUNDLE" \
    ${APP_ARGS[@]+"${APP_ARGS[@]}"} < /dev/null > "$OUT" 2>&1 &
fi
LAUNCH_PID=$!

matches() { cat "$OUT" "$UNIFIED" 2>/dev/null | grep -E -- "$1"; }

VERDICT="" REASON="" EXITED=""
END=$((SECONDS + LIMIT))
while [ "$SECONDS" -lt "$END" ]; do
  if [ -n "$RED_IF" ] && matches "$RED_IF" >/dev/null; then VERDICT=red; REASON="matched --red-if"; break; fi
  if [ -n "$RED_UNLESS" ] && matches "$RED_UNLESS" >/dev/null; then VERDICT=green; REASON="matched --red-unless"; break; fi
  if ! kill -0 "$LAUNCH_PID" 2>/dev/null; then EXITED=1; break; fi
  sleep 0.5
done

# 콘솔에 붙은 실행 명령을 끝내면 신호가 앱에 전달돼 앱도 끝난다.
kill "$LAUNCH_PID" 2>/dev/null
[ -n "$LOG_PID" ] && kill "$LOG_PID" 2>/dev/null
[ "$TARGET" = sim ] && xcrun simctl terminate "$SIM" "$BUNDLE" 2>/dev/null
wait 2>/dev/null

if [ -n "$PRED" ]; then
  xcrun simctl spawn "$SIM" log show --style compact --start "$T0" --predicate "$PRED" > "$UNIFIED" 2>&1
  if [ -z "$VERDICT" ] && [ -n "$RED_IF" ] && matches "$RED_IF" >/dev/null; then VERDICT=red; REASON="matched --red-if"
  elif [ -z "$VERDICT" ] && [ -n "$RED_UNLESS" ] && matches "$RED_UNLESS" >/dev/null; then VERDICT=green; REASON="matched --red-unless"
  fi
fi

if [ -z "$VERDICT" ]; then
  if [ -n "$EXITED" ]; then VERDICT=red; REASON="app exited before time limit"
  elif [ -n "$RED_UNLESS" ]; then VERDICT=red; REASON="--red-unless never matched"
  elif [ -n "$RED_IF" ]; then VERDICT=green; REASON="--red-if never matched"
  else VERDICT=none; REASON="no assertion given"
  fi
fi

echo "RESULT: $VERDICT ($REASON)"
echo "output: $OUT"
[ -n "$PRED" ] && echo "unified log: $UNIFIED"
case "$VERDICT" in
  red)
    if [ -n "$EXITED" ]; then tail -5 "$OUT"
    elif [ -n "$RED_IF" ]; then matches "$RED_IF" | head -5
    fi
    exit 1 ;;
  green) [ -n "$RED_UNLESS" ] && matches "$RED_UNLESS" | head -5; exit 0 ;;
  *) exit 0 ;;
esac
