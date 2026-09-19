#!/usr/bin/env bash
# 명령에 시간 상한을 건다. macOS 에는 timeout 명령이 없다.
# Usage: with-timeout.sh <seconds> <command> [args...]
# 예: with-timeout.sh 10 xcrun simctl spawn <UDID> log stream --predicate 'subsystem == "com.example.app"'
# 상한에 걸리면 명령은 SIGALRM 으로 끝나고 종료 코드 142 를 돌려준다.
[ $# -ge 2 ] || { sed -n '3,5p' "$0" >&2; exit 2; }
exec perl -e 'alarm shift; exec @ARGV or die "exec failed: $!\n"' "$@"
