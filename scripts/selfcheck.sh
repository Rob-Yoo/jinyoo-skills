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
python3 -c 'import json,sys; p=sys.argv[1]; m=json.load(open(p)); m["claude"].append("gone"); json.dump(m, open(p, "w"))' "$P/.jinyoo-skills.json"
mkdir -p "$P/.claude/skills/gone"
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ ! -e "$P/.claude/skills/gone" ] || fail "stale 스킬 미삭제"

# 5. --global: 없는 블록만 원문 그대로 덧붙이고, 있으면 건드리지 않음
H="$(mktemp -d)"; trap 'rm -rf "$P" "$H"' EXIT
g() { HOME="$H" CODEX_HOME="$H/codex" python3 "$REPO/scripts/install.py" --global >/dev/null; }
mkdir -p "$H/codex"; printf '# AGENTS.md\n\nmine\n\n# Ponytail — Lazy Senior Dev Mode\n\ncustom\n' > "$H/codex/AGENTS.md"
g
for f in karpathy ponytail; do grep -qF "$(head -1 "$REPO/instructions/$f.md")" "$H/.claude/CLAUDE.md" || fail "전역 claude 에 $f 없음"; done
[ "$(grep -c '^# Ponytail' "$H/codex/AGENTS.md")" = 1 ] || fail "있는 Ponytail 중복 추가"
grep -q '^custom$' "$H/codex/AGENTS.md" || fail "기존 내용 훼손"
grep -q '^## 1. Think Before Coding$' "$H/codex/AGENTS.md" || fail "codex 에 karpathy 미추가"
before="$(cat "$H/.claude/CLAUDE.md" "$H/codex/AGENTS.md")"; g
[ "$before" = "$(cat "$H/.claude/CLAUDE.md" "$H/codex/AGENTS.md")" ] || fail "--global 재실행이 파일을 바꿈"

# 6. README 스킬 목록이 skills/ 와 일치
python3 "$REPO/scripts/sync-readme.py" --check || fail "README 스킬 목록"

echo "selfcheck OK"
