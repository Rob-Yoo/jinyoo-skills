## jinyoo-skills

`.claude/skills/`·`.agents/skills/` 의 스킬은 jinyoo-skills 레포에서 설치된 생성물이다. 스킬을 고칠 때는 그 레포에서 고친다: 여기서 고친 내용은 재설치 때 덮어써진다.

- 작업에 맞는 스킬이 있으면 그 스킬의 절차로 진행한다. 둘 이상 맞으면 범위가 좁은 쪽을 쓴다.
- 큰 기능은 `prd` → `mission` → Phase 마다 `implement` 순서로 간다. 범위가 정해진 작은 작업은 `implement` 로 바로 간다.
- 아래 스킬은 사용자만 호출할 수 있다. 작업이 맞으면 사용자에게 그 스킬을 호출하라고 제안하고 답을 기다린다:
{{USER_ONLY_SKILLS}}
