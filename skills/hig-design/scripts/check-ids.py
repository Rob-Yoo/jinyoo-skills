#!/usr/bin/env python3
"""spec.md 의 S 번호, prototype.html 의 data-spec, notes JSON 키가 1:1 인지 확인한다.

    python3 check-ids.py <design dir>      # spec.md, prototype.html 이 있는 디렉토리

어긋나면 무엇이 어디에 없는지 출력하고 exit 1.
"""
import json
import re
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: check-ids.py <design dir>", file=sys.stderr)
        return 1
    d = Path(sys.argv[1])
    spec = (d / "spec.md").read_text(encoding="utf-8")
    html = (d / "prototype.html").read_text(encoding="utf-8")

    # 화면: "## S1 이름", 요소: "  - S1.1 이름"
    in_spec = set(re.findall(r"^## (S\d+)\b", spec, re.M)) | set(re.findall(r"^\s*- (S\d+(?:\.\d+)+)\b", spec, re.M))
    in_html = set(re.findall(r'data-spec="(S[\d.]+)"', html))
    m = re.search(r'<script type="application/json" id="notes">(.*?)</script>', html, re.S)
    try:
        in_notes = set(json.loads(m.group(1))) if m else set()
    except json.JSONDecodeError as e:
        print(f"notes JSON 파싱 실패: {e}")
        return 1

    problems = []
    pairs = [
        ("spec.md 에만 있음 (data-spec 없음)", in_spec - in_html),
        ("data-spec 에만 있음 (spec.md 없음)", in_html - in_spec),
        ("notes 에 없음", in_spec - in_notes),
        ("notes 에만 있음 (spec.md 없음)", in_notes - in_spec),
    ]
    for label, ids in pairs:
        if ids:
            problems.append(f"{label}: {', '.join(sorted(ids))}")
    if problems:
        print("\n".join(problems))
        return 1
    print(f"OK: {len(in_spec)}개 항목 일치")
    return 0


if __name__ == "__main__":
    sys.exit(main())
