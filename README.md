# jinyoo-skills

Claude Code · Codex 가 함께 쓰는 개인 스킬과 공용 지침의 단일 소스(SSOT).
설치하면 대상 프로젝트의 host 별 경로로 복사된다.

| 대상 | 설치 위치 |
|------|-----------|
| Claude Code 스킬 | `<project>/.claude/skills/<name>/` |
| Codex 스킬 | `<project>/.agents/skills/<name>/` |
| 공용 지침 | `<project>/CLAUDE.md` 의 `<!-- jinyoo-skills:start/end -->` 블록 (`AGENTS.md` 가 없으면 `CLAUDE.md` 로의 symlink 생성) |

## 설치 / 업데이트

private 레포 — SSH 인증된 머신에서 1회 클론 후 사용.

```bash
# 1회 클론
git clone git@github.com:Rob-Yoo/jinyoo-skills.git ~/Dev/jinyoo-skills

# 프로젝트에 설치 / 업데이트 (git pull 후 설치)
bash ~/Dev/jinyoo-skills/install.sh                    # 현재 디렉토리
bash ~/Dev/jinyoo-skills/install.sh /path/to/project
```

필요: `git`, `python3` (표준 라이브러리만 사용).

- 설치한 스킬 목록은 `<project>/.jinyoo-skills.json` 에 기록된다. 재설치 시 여기 있는데 upstream 에서 사라진 스킬은 삭제된다.
- 프로젝트에 이미 **같은 이름의 고유 스킬**이 있으면 덮어쓰지 않고 skip 한다.
- 설치본·지침 블록은 생성물이다. 대상 프로젝트에서 직접 고치면 재설치 때 덮어써진다 — 이 레포에서 고친다.

## 구조

```
skills/
  <name>/
    SKILL.md            양 host 공용 원본 = 설치본 (frontmatter + 본문)
    agents/openai.yaml  Codex 전용 UI 메타 (선택, Claude 는 무시)
    references/ 등      SKILL.md 가 참조하는 리소스 (선택)
instructions/common.md  CLAUDE.md 블록으로 주입되는 공용 지침
scripts/install.py      설치
scripts/selfcheck.sh    install.py 셀프체크
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

host 전용 문법이 꼭 필요한 스킬이 생기면 그때 렌더 단계를 도입한다 (참고: c8c-swift `scripts/render-skills.py`).

## 스킬 추가

```bash
mkdir -p skills/<name>
# SKILL.md 작성 (grilling/ 참고), 필요시 agents/openai.yaml
bash scripts/selfcheck.sh
```

등록 단계 없음 — `skills/*/SKILL.md` 를 자동 발견한다.
