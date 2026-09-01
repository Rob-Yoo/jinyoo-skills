---
name: mission
description: 큰 기능을 계획부터 Phase 실행, ADR 작성까지 이어서 진행한다.
disable-model-invocation: true
---

여러 세션에 걸친 큰 기능을 처음부터 끝까지 진행한다. 인자는 `[기능 요구사항]` 과 `[P{N}]` 이다.

상태의 원천은 Phase Overview (`Docs/wip/task/<slug>/<slug>-phases-overview.md`) 하나다. 새 세션에서 `/mission` 을 다시 부르면 Overview 를 읽고 이어서 한다. 단계마다 이 스킬 디렉토리의 파일을 그때 읽고 그대로 따른다.

## 1. 상태 판단

- 기능 요구사항이 있으면 새 미션이다. 그 요구사항으로 2 를 시작한다.
- 인자가 없거나 `P{N}` 만 있으면 이어서 한다. Overview 를 모두 찾아 하나면 그것으로 3, 여럿이면 사용자에게 고르게 하고, 없으면 무엇을 만들지 묻고 2 를 시작한다.
- 모든 Phase 가 `[완료]` 면 4 로 간다.

## 2. 계획

`PLAN.md` 를 따라 Plan 과 Overview 를 만든다. 끝나면 "P1 <제목> 을 시작할까?" 를 묻는다.

## 3. Phase 루프

`RUN.md` 를 따라 Phase 하나를 진행한다. `P{N}` 을 받았으면 그 Phase 로 시작한다. Phase 가 `[완료]` 되면:

- 남은 Phase 가 있으면 "다음 P{N} <제목> 을 진행할까?" 를 묻는다. 예면 같은 세션에서 이어 가고, 아니오면 마지막 완료 Phase, 남은 Phase, 재개 방법 (`/mission`) 을 알리고 멈춘다.
- 남은 Phase 가 없으면 4 로 간다.

## 4. 종료

`CLOSE.md` 를 따라 ADR 을 쓰고 미션을 마무리한다.
