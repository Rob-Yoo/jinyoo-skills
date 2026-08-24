#!/usr/bin/env bash
# install.py 셀프체크: 임시 프로젝트에 설치해 핵심 동작을 확인한다.
#   bash scripts/selfcheck.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
P="$(mktemp -d)"
trap 'rm -rf "$P"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }

# 1. 빈 프로젝트: 양 host 설치, 지침 파일은 만들지 않음
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ -f "$P/.claude/skills/grilling/SKILL.md" ] || fail "claude 스킬 미설치"
[ -f "$P/.agents/skills/grilling/SKILL.md" ] || fail "codex 스킬 미설치"
[ -f "$P/.agents/skills/grilling/agents/openai.yaml" ] || fail "openai.yaml 미복사"
[ ! -e "$P/CLAUDE.md" ] && [ ! -e "$P/AGENTS.md" ] || fail "지침 파일이 생성됨"
cmp -s "$REPO/skills/grilling/SKILL.md" "$P/.claude/skills/grilling/SKILL.md" || fail "SKILL.md 원본과 다름"

# 2. CLAUDE.md 만 있으면 AGENTS.md symlink 생성 (내용은 그대로)
echo "# 기존 지침" > "$P/CLAUDE.md"
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ "$(readlink "$P/AGENTS.md")" = "CLAUDE.md" ] || fail "AGENTS.md symlink 아님"
[ "$(cat "$P/CLAUDE.md")" = "# 기존 지침" ] || fail "CLAUDE.md 내용 변경됨"

# 3. 프로젝트 고유 동명 스킬은 skip
Q="$P/existing"; mkdir -p "$Q/.claude/skills/grilling"
echo "own" > "$Q/.claude/skills/grilling/SKILL.md"
python3 "$REPO/scripts/install.py" "$Q" >/dev/null 2>&1
[ "$(cat "$Q/.claude/skills/grilling/SKILL.md")" = "own" ] || fail "프로젝트 고유 스킬 덮어씀"

# 4. upstream 에서 사라진 스킬은 재설치 시 삭제
echo '{"claude": ["grilling", "gone"], "codex": ["grilling"]}' > "$P/.jinyoo-skills.json"
mkdir -p "$P/.claude/skills/gone"
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ ! -e "$P/.claude/skills/gone" ] || fail "stale 스킬 미삭제"

echo "selfcheck OK"
