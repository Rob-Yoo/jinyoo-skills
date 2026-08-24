#!/usr/bin/env bash
# jinyoo-skills 를 프로젝트에 설치/업데이트한다. 로컬 클론에서 실행.
#   bash ~/Dev/jinyoo-skills/install.sh [/path/to/project]   # 기본값: 현재 디렉토리
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
git -C "$SRC" pull --ff-only -q || echo "warning: git pull 실패 — 로컬 버전으로 설치한다" >&2
python3 "$SRC/scripts/install.py" "${1:-$PWD}"
