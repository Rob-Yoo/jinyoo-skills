#!/usr/bin/env python3
"""README 의 스킬 목록을 skills/*/ 에서 생성한다.

  python3 scripts/sync-readme.py          README 를 고쳐 쓴다
  python3 scripts/sync-readme.py --check  최신인지 확인만 한다 (selfcheck 가 부른다)

설명은 agents/openai.yaml 의 short_description, 호출 방식은 SKILL.md 의
disable-model-invocation 과 openai.yaml 의 policy.allow_implicit_invocation 을 함께 읽는다.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"
START, END = "<!-- skills:start -->", "<!-- skills:end -->"


def skills():
    """skills/*/ 마다 (이름, 사용자만 호출 여부, 한 줄 설명) 과 설정 오류를 돌려준다. install.py 도 쓴다."""
    errors, out = [], []
    for skill_md in sorted(ROOT.glob("skills/*/SKILL.md")):
        name = skill_md.parent.name
        fm = skill_md.read_text().split("---", 2)[1]
        user_only = re.search(r"^disable-model-invocation:\s*true\s*$", fm, re.M) is not None
        yaml = skill_md.parent / "agents" / "openai.yaml"
        if not yaml.is_file():
            errors.append(f"{name}: agents/openai.yaml 없음")
            continue
        y = yaml.read_text()
        m = re.search(r'^\s*short_description:\s*"?(.*?)"?\s*$', y, re.M)
        desc = m.group(1).strip() if m else ""
        if not desc:
            errors.append(f"{name}: short_description 없음 또는 비어 있음")
        no_implicit = re.search(r"^\s*allow_implicit_invocation:\s*false\s*$", y, re.M) is not None
        if user_only != no_implicit:
            on = lambda b: "있음" if b else "없음"
            errors.append(f"{name}: 사용자만 호출 설정이 한쪽에만 있다 — SKILL.md disable-model-invocation: true "
                          f"{on(user_only)}, openai.yaml allow_implicit_invocation: false {on(no_implicit)}")
        out.append((name, user_only, desc))
    return errors, out


def rows():
    errors, found = skills()
    out = [f"| [{name}](skills/{name}/SKILL.md) | {'사용자만' if user_only else '자동 호출 가능'} | {desc} |"
           for name, user_only, desc in found]
    return errors, out


def main():
    check = sys.argv[1:] == ["--check"]
    errors, out = rows()
    if errors:
        sys.exit("error:\n  " + "\n  ".join(errors))
    table = "\n".join(["| 스킬 | 호출 | 설명 |", "|------|------|------|", *out])
    text = README.read_text()
    if text.count(START) != 1 or text.count(END) != 1:
        sys.exit(f"error: README 에 {START} / {END} 표시가 각각 하나씩 있어야 한다")
    head, rest = text.split(START)
    new = f"{head}{START}\n{table}\n{END}{rest.split(END, 1)[1]}"
    if new == text:
        return
    if check:
        sys.exit("error: README 스킬 목록이 최신이 아니다 — python3 scripts/sync-readme.py 를 실행하라")
    README.write_text(new)
    print("README 스킬 목록 갱신")


if __name__ == "__main__":
    main()
