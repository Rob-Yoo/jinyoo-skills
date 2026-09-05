# jinyoo-skills

Claude Code · Codex 가 함께 쓰는 개인 스킬의 단일 소스(SSOT).
설치하면 대상 프로젝트의 host 별 경로로 복사된다.

| 대상 | 설치 위치 |
|------|-----------|
| Claude Code 스킬 | `<project>/.claude/skills/<name>/` |
| Codex 스킬 | `<project>/.agents/skills/<name>/` |
| 지침 문서 | `CLAUDE.md`·`AGENTS.md` 중 한쪽만 있으면 없는 쪽을 symlink 로 연결 (내용은 건드리지 않음) |

## 스킬

<!-- skills:start -->
| 스킬 | 호출 | 설명 |
|------|------|------|
| [codebase-design](skills/codebase-design/SKILL.md) | 자동 호출 가능 | deep module 설계 용어와 원칙을 제공합니다 |
| [cross-grilling](skills/cross-grilling/SKILL.md) | 사용자만 | 다른 에이전트의 교차 검증을 거치며 grilling 을 진행합니다 |
| [doc-writer-for-agents](skills/doc-writer-for-agents/SKILL.md) | 자동 호출 가능 | 에이전트가 읽는 문서를 씁니다 |
| [explain-for-junior](skills/explain-for-junior/SKILL.md) | 자동 호출 가능 | 실제 예시와 애니메이션으로 주니어에게 설명합니다 |
| [grill-with-adr](skills/grill-with-adr/SKILL.md) | 사용자만 | grilling 후 남길 결정을 ADR 로 기록합니다 |
| [grilling](skills/grilling/SKILL.md) | 자동 호출 가능 | 한 라운드씩 질문을 던지며 생각을 검증합니다 |
| [impl-review](skills/impl-review/SKILL.md) | 자동 호출 가능 | 변경을 Standards 와 Spec 두 축으로 리뷰합니다 |
| [implement](skills/implement/SKILL.md) | 사용자만 | 테스트 주도 구현과 두 축 리뷰까지 진행합니다 |
| [ios-sim-test](skills/ios-sim-test/SKILL.md) | 사용자만 | iOS 시뮬레이터로 체크리스트를 판정하고 근거 보고서를 만듭니다 |
| [mission](skills/mission/SKILL.md) | 사용자만 | 큰 기능을 계획부터 Phase 실행, ADR 작성까지 진행합니다 |
| [refactor-like-fowler](skills/refactor-like-fowler/SKILL.md) | 사용자만 | Fowler 의 규율로 재작성 없이 한 기법씩 리팩터링합니다 |
| [second-opinion](skills/second-opinion/SKILL.md) | 자동 호출 가능 | 다른 에이전트에게 독립적인 의견을 받습니다 |
| [tdd](skills/tdd/SKILL.md) | 자동 호출 가능 | 합의한 seam 에서 red-green 으로 테스트 주도 구현합니다 |
<!-- skills:end -->

## 설치 / 업데이트

private 레포 — SSH 인증된 머신에서 1회 클론 후 사용.

```bash
# 1회 클론
git clone git@github.com:Rob-Yoo/jinyoo-skills.git ~/Dev/jinyoo-skills

# 프로젝트에 설치 / 업데이트 (git pull 후 설치)
bash ~/Dev/jinyoo-skills/install.sh                    # 현재 디렉토리
bash ~/Dev/jinyoo-skills/install.sh /path/to/project

# 새 머신: 전역 지침에 Karpathy 4원칙·Ponytail 이 없으면 원문 그대로 추가
bash ~/Dev/jinyoo-skills/install.sh --global
```

필요: `git`, `python3` (표준 라이브러리만 사용).

- 설치한 스킬 목록은 `<project>/.jinyoo-skills.json` 에 기록된다. 재설치 시 여기 있는데 upstream 에서 사라진 스킬은 삭제된다.
- 프로젝트에 이미 **같은 이름의 고유 스킬**이 있으면 덮어쓰지 않고 skip 한다.
- 설치본은 생성물이다. 대상 프로젝트에서 직접 고치면 재설치 때 덮어써진다 — 이 레포에서 고친다.

## 구조

```
skills/
  <name>/
    SKILL.md            양 host 공용 원본 = 설치본 (frontmatter + 본문)
    agents/openai.yaml  Codex UI 메타 + README 목록의 한 줄 설명 (필수, Claude 는 무시)
    references/ 등      SKILL.md 가 참조하는 리소스 (선택)
instructions/           --global 이 덧붙이는 전역 지침 원문 (karpathy.md, ponytail.md)
scripts/install.py      설치
scripts/selfcheck.sh    install.py 셀프체크 + README 스킬 목록 최신 여부 검사
scripts/sync-readme.py  README 스킬 목록 생성 (--check: 확인만)
install.sh              git pull + install.py 실행
```

## 스킬 작성 규칙 — host 중립

SKILL.md 하나를 Claude Code·Codex 가 그대로 읽으므로 **본문에 한쪽 host 전용 문법을 쓰지 않는다**.

| 하고 싶은 것 | 이렇게 |
|------|------|
| 다른 스킬 호출 | `Skill 도구로 "grilling" 스킬을 호출하라` — `/grilling`·`$grilling` 금지 |
| 사용자 인자 받기 | 자연어로 ("사용자가 준 URL") — `$ARGUMENTS` 금지 |
| 셸 결과 주입 | 본문에서 실행 지시 — `` !`cmd` `` 금지 |
| 사용자에게 질문 | "사용자에게 물어라" — `AskUserQuestion` 등 툴명 금지 |
| 모델 자동 호출 막기 | frontmatter `disable-model-invocation: true` **와** `agents/openai.yaml` 의 `policy.allow_implicit_invocation: false` 를 함께 |

frontmatter 필수 키는 `name`·`description` 뿐. Claude 전용 키(`disable-model-invocation`, `argument-hint`, `allowed-tools` 등)는 넣어도 Codex 가 무시한다.

host 전용 문법이 꼭 필요한 스킬이 생기면 그때 렌더 단계를 도입한다.

## 스킬 추가 · 수정 · 삭제

```bash
mkdir -p skills/<name>/agents
# SKILL.md 와 agents/openai.yaml (short_description 필수) 작성 (grilling/ 참고)
python3 scripts/sync-readme.py   # README 스킬 목록 갱신
bash scripts/selfcheck.sh
```

스킬을 고치거나 지울 때도 마지막 두 줄을 실행한다. 등록 단계 없음 — `skills/*/SKILL.md` 를 자동 발견한다.
