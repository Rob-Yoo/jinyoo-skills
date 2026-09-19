# Credits

이 스킬은 Matt Pocock 의 `diagnosing-bugs` 스킬을 iOS 용으로 고쳐 쓴 것이다.

- 원본: https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs (커밋 `f3fc5632f401` 기준)
- 따른 것: Phase 1~6 구조와 규율 (red 가 되는 tight 루프 먼저, 반증 가능한 가설, 한 번에 변수 하나, 올바른 seam 의 회귀 테스트, 태그 로그 정리)
- 바꾼 것: 피드백 루프 방법과 계측 도구를 iOS 로 (XCTest·Swift Testing, `simctl`, `xctrace`, `leaks`), 성능·메모리 branch 를 `PERF.md`·`MEMORY.md` 로 분리, 회귀 테스트와 seam 보고를 jinyoo-skills 의 `tdd`·`codebase-design` 에 연결
- 새로 쓴 것: 루프 스크립트 (`scripts/app-loop.sh`, `trace.sh`, `with-timeout.sh`, `MainThreadGapProbe.swift`) 와 실기기 루프
- `scripts/hitl-loop.template.sh` 는 원본 그대로다.

원본 라이선스:

```
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
