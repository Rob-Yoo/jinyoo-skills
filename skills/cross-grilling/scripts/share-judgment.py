#!/usr/bin/env python3
"""이번 라운드에 내 판단(선택지·추천안)을 상대에게 공유할지 Jev 에게 묻는다.

    python3 share-judgment.py <context.md>

stdout: "share <p>" 또는 "blind <p>" (p = 공유가 낫다는 확률).
TYPESAFE_API_KEY 가 없거나 호출이 실패하면 stderr 에 사유를 쓰고 exit 1.
"""
import json
import os
import sys
import urllib.request

QUESTION = {
    "type": "noul",
    "instructions": (
        "The state is a design-interview context file. Its last section is the draft of "
        "the next interview round: a question, candidate options, and the drafter's "
        "recommendation. A second reviewer agent will check this round. Should the reviewer "
        "see the drafter's options and recommendation?"
    ),
    "criteria": {
        "true": (
            "The round mostly checks a concrete recommendation against already decided "
            "constraints or verifiable facts; the answer space is narrow, so seeing the "
            "recommendation lets the reviewer find errors in it."
        ),
        "false": (
            "The round is an open design question with many plausible directions; seeing "
            "the drafter's options would anchor the reviewer, so an independent proposal "
            "is more valuable."
        ),
    },
}


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: share-judgment.py <context.md>", file=sys.stderr)
        return 1
    key = os.environ.get("TYPESAFE_API_KEY")
    if not key:
        print("TYPESAFE_API_KEY 없음", file=sys.stderr)
        return 1
    with open(sys.argv[1], encoding="utf-8") as f:
        state = f.read()
    body = json.dumps({"state": state, "model": "jev-latest", "questions": {"share": QUESTION}})
    req = urllib.request.Request(
        "https://api.typesafe.ai/v1/systemone",
        data=body.encode(),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            p = json.load(res)["answers"]["share"]["noul"]
    except Exception as e:  # 네트워크·인증·응답 형식 오류 모두 호출자가 기본값으로 처리
        print(f"Jev 호출 실패: {e}", file=sys.stderr)
        return 1
    print(f"{'share' if p >= 0.5 else 'blind'} {p:.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
