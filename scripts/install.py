#!/usr/bin/env python3
"""jinyoo-skills 를 대상 프로젝트에 설치한다.

1. 스킬: skills/<name>/ 를 그대로 양 host 경로에 복사
     claude → <project>/.claude/skills/<name>/
     codex  → <project>/.agents/skills/<name>/
   SKILL.md 는 host 중립으로 작성한다 (README 참고). Claude 전용 frontmatter 키는 Codex 가
   무시하고, Codex 전용 메타는 agents/openai.yaml 에 둔다(Claude 가 무시).
2. 지침: CLAUDE.md·AGENTS.md 중 한쪽만 있으면 없는 쪽을 symlink 로 연결 (둘 다 없으면 무동작).
3. --global: 전역 ~/.claude/CLAUDE.md·$CODEX_HOME/AGENTS.md 에 instructions/ 의 Karpathy·Ponytail
   블록 중 없는 것만 원문 그대로 덧붙인다. 프로젝트는 건드리지 않는다.

설치한 스킬 이름은 <project>/.jinyoo-skills.json 에 기록한다. 재설치 시
  - 기록에 없는데 같은 이름이 이미 있으면 프로젝트 고유 스킬로 보고 건드리지 않는다(skip).
  - 기록에 있는데 upstream 에서 사라진 스킬은 삭제한다.

Usage: install.py [project-dir]   # 기본값: 현재 디렉토리
       install.py --global
"""
import json
import os
import shutil
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS = REPO / "skills"
HOSTS = {"claude": Path(".claude/skills"),
         "codex": Path(".agents/skills")}
MANIFEST = ".jinyoo-skills.json"


def install_skills(dest):
    names = sorted(p.parent.name for p in SKILLS.glob("*/SKILL.md"))
    mpath = dest / MANIFEST
    prev = json.loads(mpath.read_text()) if mpath.exists() else {}
    manifest = {}
    for host, rel in HOSTS.items():
        base = dest / rel
        owned = set(prev.get(host, []))
        installed = []
        for name in names:
            target = base / name
            if os.path.lexists(target) and name not in owned:
                print(f"skip: {target.relative_to(dest)} — 프로젝트 고유 스킬과 이름 충돌", file=sys.stderr)
                continue
            # ponytail: 설치본은 통째로 지우고 다시 복사한다(파일 단위 동기화·orphan 추적 대신).
            #   스킬 디렉토리 안에 런타임 상태를 쓰는 스킬이 생기면 그 상태도 재설치 때 지워진다.
            shutil.rmtree(target, ignore_errors=True)
            shutil.copytree(SKILLS / name, target)  # copy2 기반 — exec 비트 보존
            installed.append(name)
            print(f"installed: {target.relative_to(dest)}")
        for name in sorted(owned - set(installed)):
            shutil.rmtree(base / name, ignore_errors=True)
            print(f"removed: {(base / name).relative_to(dest)}")
        manifest[host] = installed
    mpath.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")


def link_instructions(dest):
    """CLAUDE.md·AGENTS.md 중 한쪽만 있으면 없는 쪽을 있는 쪽으로의 symlink 로 만든다."""
    claude, agents = dest / "CLAUDE.md", dest / "AGENTS.md"
    for link, real in ((agents, claude), (claude, agents)):
        if os.path.lexists(real) and not os.path.lexists(link):
            link.symlink_to(real.name)
            print(f"linked: {link.name} -> {real.name}")


# 전역 지침에 넣을 블록: (이미 적혀 있다고 보는 제목 줄, 원문 파일). 이 순서로 덧붙인다.
GLOBAL_BLOCKS = [
    ("## 1. Think Before Coding", "karpathy.md"),
    ("# Ponytail — Lazy Senior Dev Mode", "ponytail.md"),
]


def install_global():
    """전역 CLAUDE.md·AGENTS.md 에 없는 블록만 원문 그대로 맨 뒤에 덧붙인다. 있는 블록은 내용이 달라도 건드리지 않는다."""
    home = Path.home()
    targets = [home / ".claude" / "CLAUDE.md",
               Path(os.environ.get("CODEX_HOME", home / ".codex")) / "AGENTS.md"]
    for target in targets:
        text = target.read_text() if target.exists() else ""
        lines = text.splitlines()
        missing = [f for title, f in GLOBAL_BLOCKS if title not in lines]
        if not missing:
            print(f"skip: {target} (이미 있음)")
            continue
        add = "\n\n".join((REPO / "instructions" / f).read_text().strip() for f in missing)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text.rstrip("\n") + ("\n\n" if text.strip() else "") + add + "\n")
        print(f"appended: {target} <- {', '.join(missing)}")


def main():
    if sys.argv[1:] == ["--global"]:
        install_global()
        return 0
    dest = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    if not dest.is_dir():
        print(f"error: 디렉토리가 아님: {dest}", file=sys.stderr)
        return 1
    install_skills(dest)
    link_instructions(dest)
    return 0


if __name__ == "__main__":
    sys.exit(main())
