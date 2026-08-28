# Skill mechanics

[`doc-writer-for-agents`](SKILL.md) 의 스킬 branch 다: 문서가 스킬일 때 달라지는 것 (frontmatter, invocation 선택, router skill). 그 밖에 스킬을 쓰는 법은 전부 `SKILL.md` 의 범용 reference 다.

## Invocation

두 선택지가 있고, 두 load 를 맞바꾼다:

- **model-invoked** 스킬은 `description` 을 유지해서 에이전트가 스스로 발동할 수 있고, 다른 스킬도 도달할 수 있다. 이름을 직접 쳐서 부를 수도 있다: model-invocation 은 언제나 사용자 도달을 _포함_ 한다. description 은 에이전트의 발견을 더할 뿐 사람의 도달을 빼지 않는다. description 은 스킬의 최상위 context pointer 로, 항상 로드된 채로 있어야 한다: 발견 가능성을 얻는 대가로 영구적인 context load 를 치른다. 내용이 전부 reference 인 model-invoked 스킬은 공유 reference 의 집이 되기도 한다: 다른 스킬이 그것을 호출할 수 있으니, 여러 스킬이 필요로 하는 reference 가 한 곳에 산다. 방법: `disable-model-invocation` 을 빼고, trigger branch 를 담은 모델용 description 을 쓴다 (`SKILL.md` 의 pointer 작성 규칙이 전부 적용된다).
- **user-invoked** 스킬은 description 을 에이전트 손에서 떼어낸다: 이름을 치는 사람만 호출할 수 있고, 다른 어떤 스킬도 호출할 수 없다. context load 는 0 이지만 cognitive load 를 쓴다: 그것이 있다는 걸 기억해야 하는 인덱스가 당신이다. 방법: `disable-model-invocation: true` 를 두고, Codex 용으로 `agents/openai.yaml` 에 `policy.allow_implicit_invocation: false` 를 함께 둔다. `description` 은 사람용이 된다: 한 줄 요약, trigger 목록은 뺀다.

에이전트가 스스로 도달해야 하거나 다른 스킬이 도달해야 할 때만 model-invocation 을 고른다. 손으로만 발동한다면 user-invoked 로 만들고 context load 를 치르지 않는다.

user-invoked 스킬 둘이 함께 필요로 하는 공유 reference 는 어느 쪽에도 살 수 없다: description 이 없으니 서로를 발동할 수 없다. 스킬 시스템 밖의 평범한 파일로 민다: 어느 스킬이든 가리킬 수 있는 외부 reference 다.

## Invocation 으로 분리하기

분리의 invocation 쪽 기준이다 (sequence 쪽은 `SKILL.md` 에 있다): 그것만으로 발동해야 할 별개의 leading word 가 있을 때 (실제로 프롬프트에 쓰는 trigger 단어), 또는 다른 스킬이 도달해야 할 때 model-invoked 스킬로 떼어낸다. 새로 항상 로드되는 description 만큼 context load 를 치르므로, 그 독립된 도달이 그만한 값을 해야 한다.

## Router skill

user-invoked 스킬이 기억할 수 있는 수를 넘어 늘어나면, 쌓인 cognitive load 는 **router skill** 로 처방한다: 나머지 스킬들의 이름과 각각을 언제 쓸지를 적은 user-invoked 스킬 하나로, 사람은 여러 개 대신 스킬 하나만 기억하면 된다. 다른 스킬을 암시할 수만 있고 발동할 수는 없다: user-invoked 스킬은 description 이 없어서 사람 말고는 아무도 도달할 수 없다.
