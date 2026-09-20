#!/usr/bin/env bash
# install.py 셀프체크: 임시 프로젝트에 설치해 핵심 동작을 확인한다.
#   bash scripts/selfcheck.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
P="$(mktemp -d)"
trap 'rm -rf "$P"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }

# 1. 빈 프로젝트: 양 host 설치, 가이드 블록만 담은 CLAUDE.md 와 그쪽 AGENTS.md symlink
python3 "$REPO/scripts/install.py" "$P" >/dev/null
[ -f "$P/.claude/skills/grilling/SKILL.md" ] || fail "claude 스킬 미설치"
[ -f "$P/.agents/skills/grilling/SKILL.md" ] || fail "codex 스킬 미설치"
[ -f "$P/.agents/skills/grilling/agents/openai.yaml" ] || fail "openai.yaml 미복사"
cmp -s "$REPO/skills/grilling/SKILL.md" "$P/.claude/skills/grilling/SKILL.md" || fail "SKILL.md 원본과 다름"
[ "$(readlink "$P/AGENTS.md")" = "CLAUDE.md" ] || fail "빈 프로젝트에 AGENTS.md symlink 없음"
[ "$(head -1 "$P/CLAUDE.md")" = "<!-- jinyoo-skills:start -->" ] || fail "빈 프로젝트 CLAUDE.md 가 블록으로 시작하지 않음"
grep -q '^  - `mission`: ' "$P/CLAUDE.md" || fail "사용자만 스킬 목록에 mission 없음"
! grep -q '^  - `grilling`: ' "$P/CLAUDE.md" || fail "자동 호출 스킬이 사용자만 목록에 들어감"
! grep -q '{{USER_ONLY_SKILLS}}' "$P/CLAUDE.md" || fail "자리표시자가 남음"

# 2. 기존 지침은 그대로 두고 블록만 넣고, 재설치하면 블록 안만 갈아 끼운다
G="$P/guide"; mkdir -p "$G"; echo "# 기존 지침" > "$G/CLAUDE.md"
python3 "$REPO/scripts/install.py" "$G" >/dev/null
[ "$(readlink "$G/AGENTS.md")" = "CLAUDE.md" ] || fail "AGENTS.md symlink 아님"
[ "$(head -1 "$G/CLAUDE.md")" = "# 기존 지침" ] || fail "기존 지침 훼손"
[ "$(grep -c 'jinyoo-skills:start' "$G/CLAUDE.md")" = 1 ] || fail "블록이 한 번이 아님 (symlink 쪽에 또 씀)"
echo "뒤에 쓴 지침" >> "$G/CLAUDE.md"
sed -i '' 's/^## jinyoo-skills$/## 낡은 블록/' "$G/CLAUDE.md"
python3 "$REPO/scripts/install.py" "$G" >/dev/null
grep -q '^## jinyoo-skills$' "$G/CLAUDE.md" && ! grep -q '낡은 블록' "$G/CLAUDE.md" || fail "재설치가 블록을 갈아 끼우지 않음"
[ "$(tail -1 "$G/CLAUDE.md")" = "뒤에 쓴 지침" ] || fail "블록 뒤 지침 훼손"
before="$(cat "$G/CLAUDE.md")"; python3 "$REPO/scripts/install.py" "$G" >/dev/null
[ "$before" = "$(cat "$G/CLAUDE.md")" ] || fail "재설치가 같은 내용을 바꿈"

# 2-1. 둘 다 실제 파일이면 양쪽에 블록
B="$P/both"; mkdir -p "$B"; echo "# C" > "$B/CLAUDE.md"; echo "# A" > "$B/AGENTS.md"
python3 "$REPO/scripts/install.py" "$B" >/dev/null
grep -q 'jinyoo-skills:start' "$B/CLAUDE.md" && grep -q 'jinyoo-skills:start' "$B/AGENTS.md" || fail "실제 파일 둘 중 블록 누락"

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
