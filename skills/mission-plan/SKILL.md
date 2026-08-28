---
name: mission-plan
description: 큰 기능을 cross-grilling 으로 설계하고, 계획 문서와 Phase Overview 를 만든다.
disable-model-invocation: true
---

여러 세션에 걸쳐 구현할 큰 기능을 계획한다. 설계 결정을 확정하고, 계획 문서와 Phase Overview 를 `Docs/tmp/` 에 만든다. `Docs/tmp/` 는 미션이 진행되는 동안의 작업 공간이다. 미션이 끝나면 이 문서들을 바탕으로 ADR 을 쓰고 지운다.

## 1. 설계 결정

이 스킬 디렉토리 기준 `../cross-grilling/SKILL.md` 를 읽고 그대로 진행한다. 첫 라운드에 기능 이름과 slug (영문 kebab-case, 문서 경로에 쓴다) 를 대화에서 추론해 추천안으로 묻는다. Phase 분할도 설계 트리의 일부로 다룬다.

## 2. Plan

`Docs/tmp/plan/<slug>.md` 에 쓴다. cross-grilling 의 맥락 파일 (목표, 확정된 결정, 확인된 사실) 을 바탕으로 정리한다. 미션이 끝나 ADR 을 쓸 때 grilling 대화는 남아 있지 않다. 그래서 결정마다 사유와 버린 대안을 대화에서 옮겨 둔다. 사용자가 말한 이유를 쓰고, 대화에 없는 이유는 쓰지 않는다.

```markdown
# <기능명> 구현 계획

> 작성: YYYY-MM-DD · Overview: `Docs/tmp/task/<slug>/<slug>-phases-overview.md`

## 목표
<사용자가 처음 말한 계획 원문 + 한 줄 요약>

## 설계 결정
| # | 항목 | 결정 | 사유 | 버린 대안 |
|---|------|------|------|-----------|
| Q1 | ... | ... | ... | <B안: 버린 이유> |

## 확인된 사실 · 가정 · 제약
- ...

## Phase 분할
| Phase | 제목 |
|-------|------|
| P1 | ... |
```

## 3. Phase 분할 확인

Phase 는 다음을 모두 만족하게 나눈다:

- 독립적으로 리뷰하고 검증할 수 있는 단위다 (보통 PR 하나).
- 에이전트 세션 하나 안에 끝나는 크기다.
- 끝나면 확인 가능한 완료 기준이 있다.
- 의존은 선형이다: 각 Phase 는 바로 앞 Phase 에만 기댄다.

Overview 를 쓰기 전에 Phase 목록 (제목, 목표, 완료 기준) 을 사용자에게 보여주고 확정받는다.

## 4. Phase Overview

`Docs/tmp/task/<slug>/<slug>-phases-overview.md` 에 쓴다. 세션을 넘어 미션을 이어가는 상태 문서다. 이 문서만 읽어도 어디까지 했고 다음에 무엇을 할지 알 수 있게 쓴다. 파일 경로, 담당자처럼 금방 낡는 내용은 넣지 않는다.

```markdown
# <기능명> Phases

> Plan: `Docs/tmp/plan/<slug>.md` · 작성: YYYY-MM-DD
> Phase 를 시작하면 [진행중], 끝내면 [완료] 로 바꾼다. 계획과 다르게 했으면 그 Phase 에 `변경:` 한 줄을 남긴다.

P1 → P2 → P3

## P1 <제목> [미착수]
- 목표: <이 Phase 가 끝나면 무엇이 가능해지나>
- 범위: <포함 / 제외>
- 완료 기준: <확인 가능한 조건 1~3개>
```

상태 마커는 `[미착수]`, `[진행중]`, `[완료]`, `[보류]` 다.
