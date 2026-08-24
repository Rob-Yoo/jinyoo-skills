#!/usr/bin/env python3
"""jinyoo-skills 를 대상 프로젝트에 설치한다.

1. 스킬: skills/<name>/ 를 그대로 양 host 경로에 복사
     claude → <project>/.claude/skills/<name>/
     codex  → <project>/.agents/skills/<name>/
   SKILL.md 는 host 중립으로 작성한다 (README 참고). Claude 전용 frontmatter 키는 Codex 가
   무시하고, Codex 전용 메타는 agents/openai.yaml 에 둔다(Claude 가 무시).
2. 지침: instructions/common.md 를 <project>/CLAUDE.md 의 marker 블록으로 주입.
     AGENTS.md 가 없으면 CLAUDE.md 로의 symlink 로 만든다 (반대도 동일).

설치한 스킬 이름은 <project>/.jinyoo-skills.json 에 기록한다. 재설치 시
  - 기록에 없는데 같은 이름이 이미 있으면 프로젝트 고유 스킬로 보고 건드리지 않는다(skip).
  - 기록에 있는데 upstream 에서 사라진 스킬은 삭제한다.

Usage: install.py [project-dir]   # 기본값: 현재 디렉토리
"""
import json
import os
import re
import shutil
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS = REPO / "skills"
HOSTS = {"claude": Path(".claude/skills"),
         "codex": Path(".agents/skills")}
MANIFEST = ".jinyoo-skills.json"

BLOCK_START = "<!-- jinyoo-skills:start -->"
BLOCK_END = "<!-- jinyoo-skills:end -->"
BLOCK_RE = re.compile(re.escape(BLOCK_START) + r".*?" + re.escape(BLOCK_END), re.S)


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


def inject_instructions(dest):
    block = f"{BLOCK_START}\n{(REPO / 'instructions' / 'common.md').read_text().strip()}\n{BLOCK_END}"
    claude, agents = dest / "CLAUDE.md", dest / "AGENTS.md"
    if not os.path.lexists(claude) and not os.path.lexists(agents):
        claude.write_text("")
    # 없는 쪽은 있는 쪽으로의 symlink — 한 파일만 편집하면 양 host 에 반영
    for link, real in ((agents, claude), (claude, agents)):
        if not os.path.lexists(link):
            link.symlink_to(real.name)
            print(f"linked: {link.name} -> {real.name}")
    for f in {claude.resolve(), agents.resolve()}:
        cur = f.read_text()
        if BLOCK_RE.search(cur):
            new = BLOCK_RE.sub(lambda _: block, cur, count=1)
        else:
            new = cur.rstrip("\n") + ("\n\n" if cur.strip() else "") + block + "\n"
        if new != cur:
            f.write_text(new)
            print(f"updated: {f.name} (jinyoo-skills 블록)")


def main():
    dest = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    if not dest.is_dir():
        print(f"error: 디렉토리가 아님: {dest}", file=sys.stderr)
        return 1
    install_skills(dest)
    inject_instructions(dest)
    return 0


if __name__ == "__main__":
    sys.exit(main())
