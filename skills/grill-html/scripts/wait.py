#!/usr/bin/env python3
"""답 파일의 completed 가 true 가 될 때까지 기다렸다가 내용을 stdout 에 찍는다.

사용: wait.py <r<N>-answers.json> [--timeout 초]   (기본 3600)
종료 코드: 0 완료, 2 시간 초과.
"""
import argparse, json, sys, time

p = argparse.ArgumentParser()
p.add_argument("file")
p.add_argument("--timeout", type=float, default=3600)
a = p.parse_args()
deadline = time.monotonic() + a.timeout
while time.monotonic() < deadline:
    try:
        with open(a.file, encoding="utf-8") as f:
            doc = json.load(f)
        if doc.get("completed") is True:
            print(json.dumps(doc, ensure_ascii=False, indent=2))
            sys.exit(0)
    except (OSError, ValueError):
        pass
    time.sleep(1)
print(f"timeout: {a.file}", file=sys.stderr)
sys.exit(2)
