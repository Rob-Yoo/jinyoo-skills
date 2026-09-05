#!/usr/bin/env python3
"""설계서의 S 번호, prototype.html 의 data-spec, notes JSON 키가 1:1 인지 확인한다.

    python3 check-ids.py <design dir>      # spec-*.md, prototype.html 이 있는 디렉토리

설계서가 둘(spec-liquid-glass.md, spec-classic.md)이면 둘 다 확인한다. 화면 구조와 S 번호는 두 설계서가 같아야 한다.
어긋나면 무엇이 어디에 없는지 출력하고 exit 1.
"""
import json
import re
import sys
from pathlib import Path


def spec_ids(text):
    # 화면: "## S1 이름", 요소: "  - S1.1 이름"
    return set(re.findall(r"^## (S\d+)\b", text, re.M)) | set(re.findall(r"^\s*- (S\d+(?:\.\d+)+)\b", text, re.M))


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: check-ids.py <design dir>", file=sys.stderr)
        return 1
    d = Path(sys.argv[1])
    specs = sorted(d.glob("spec-*.md"))
    if not specs:
        print(f"설계서 없음: {d}/spec-*.md")
        return 1
    html = (d / "prototype.html").read_text(encoding="utf-8")
    in_html = set(re.findall(r'data-spec="(S[\d.]+)"', html))
    m = re.search(r'<script type="application/json" id="notes">(.*?)</script>', html, re.S)
    try:
        in_notes = set(json.loads(m.group(1))) if m else set()
    except json.JSONDecodeError as e:
        print(f"notes JSON 파싱 실패: {e}")
        return 1

    problems = []
    for spec in specs:
        ids = spec_ids(spec.read_text(encoding="utf-8"))
        for label, diff in [
            (f"{spec.name} 에만 있음 (data-spec 없음)", ids - in_html),
            (f"data-spec 에만 있음 ({spec.name} 없음)", in_html - ids),
            (f"notes 에 없음 ({spec.name} 기준)", ids - in_notes),
            (f"notes 에만 있음 ({spec.name} 없음)", in_notes - ids),
        ]:
            if diff:
                problems.append(f"{label}: {', '.join(sorted(diff))}")
    if problems:
        print("\n".join(problems))
        return 1
    print(f"OK: {', '.join(s.name for s in specs)} · {len(in_html)}개 항목 일치")
    return 0


if __name__ == "__main__":
    sys.exit(main())
