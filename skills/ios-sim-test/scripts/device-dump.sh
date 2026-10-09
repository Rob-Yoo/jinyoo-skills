#!/usr/bin/env bash
# 실기기 앞 화면의 요소 id·bounds 를 출력한다.
# `maestro hierarchy` 는 포워딩 없이 기기 드라이버에 붙지 못하므로, 일부러 실패하는 assert 로
# Maestro 가 남기는 hierarchy JSON 을 읽는다. 실패 때 자동 저장된 화면 (다른 앱일 수 있음 = 사생활) 은 지운다.
#   device-dump.sh <UDID> <bundle id> [out.json]
# 출력: 줄마다 "resource-id=… | accessibilityText=… | value=… | bounds=…". hierarchy 를 못 얻으면 종료 코드 1.
set -u
[ $# -ge 2 ] || { echo "usage: device-dump.sh <UDID> <bundle id> [out.json]" >&2; exit 2; }
U="$1"; APP="$2"; OUT="${3:-}"
DIR="$(cd "$(dirname "$0")" && pwd)"
F=$(mktemp -t dump).yaml
printf 'appId: %s\n---\n- assertVisible:\n    id: "__never_exists__"\n' "$APP" > "$F"
"$DIR/device-run.sh" "$U" "$F" >/dev/null 2>&1
D=$(ls -td ~/.maestro/tests/*/ | head -1)
J=$(find "$D" -path "*screen-hierarchy*" -name "*.json" | head -1)
[ -z "$J" ] && { echo "hierarchy 없음"; exit 1; }
python3 - "$J" <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); out = []
def walk(n):
    a = n.get('attributes', {})
    if a.get('resource-id') or a.get('accessibilityText'):
        out.append(' | '.join(f'{k}={a[k]}' for k in ('resource-id','accessibilityText','value','bounds') if a.get(k)))
    for c in n.get('children', []): walk(c)
walk(d); print('\n'.join(out))
PY
[ -n "$OUT" ] && cp "$J" "$OUT"
find "$D" \( -path "*screenshots*" -o -path "*screen-hierarchy*" \) -print0 | xargs -0 rm -rf
