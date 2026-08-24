#!/usr/bin/env bash
# install.py 셀프체크: 임시 프로젝트에 설치해 핵심 동작을 확인한다.
#   bash scripts/selfcheck.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
P="$(mktemp -d)"
trap 'rm -rf "$P"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }

# 1. 빈 프로젝트: 양 host 설치 + CLAUDE.md 생성 + AGENTS.md symlink
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ -f "$P/.claude/skills/grilling/SKILL.md" ] || fail "claude 스킬 미설치"
[ -f "$P/.agents/skills/grilling/SKILL.md" ] || fail "codex 스킬 미설치"
[ -f "$P/.agents/skills/grilling/agents/openai.yaml" ] || fail "openai.yaml 미복사"
[ "$(readlink "$P/AGENTS.md")" = "CLAUDE.md" ] || fail "AGENTS.md symlink 아님"
cmp -s "$REPO/skills/grilling/SKILL.md" "$P/.claude/skills/grilling/SKILL.md" || fail "SKILL.md 원본과 다름"

# 2. 재설치 멱등: 지침 블록 1개 유지
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ "$(grep -c 'jinyoo-skills:start' "$P/CLAUDE.md")" = 1 ] || fail "지침 블록 중복"

# 3. 기존 CLAUDE.md 내용 보존 + 프로젝트 고유 동명 스킬은 skip
Q="$P/existing"; mkdir -p "$Q/.claude/skills/grilling"
echo "# 기존 지침" > "$Q/CLAUDE.md"
echo "own" > "$Q/.claude/skills/grilling/SKILL.md"
python3 "$REPO/scripts/install.py" "$Q" >/dev/null 2>&1
grep -q '# 기존 지침' "$Q/CLAUDE.md" || fail "기존 CLAUDE.md 내용 유실"
[ "$(cat "$Q/.claude/skills/grilling/SKILL.md")" = "own" ] || fail "프로젝트 고유 스킬 덮어씀"

# 4. upstream 에서 사라진 스킬은 재설치 시 삭제
echo '{"claude": ["grilling", "gone"], "codex": ["grilling"]}' > "$P/.jinyoo-skills.json"
mkdir -p "$P/.claude/skills/gone"
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ ! -e "$P/.claude/skills/gone" ] || fail "stale 스킬 미삭제"

echo "selfcheck OK"
