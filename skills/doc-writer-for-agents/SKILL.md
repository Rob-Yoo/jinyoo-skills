---
name: doc-writer-for-agents
description: 에이전트가 읽는 문서를 쓴다. 스킬을 만들거나 고칠 때, AGENTS.md·CLAUDE.md 를 수정할 때 사용한다.
---

에이전트가 소비하는 모든 문서를 쓸 때의 레퍼런스다: 스킬, `AGENTS.md` / `CLAUDE.md`, 포인터로 도달하는 문서. 포장은 달라도 쓰는 법은 같다: 같은 레버가 각 문서를 예측 가능하게 만든다. 에이전트가 매번 같은 출력을 내는 게 아니라 매번 같은 _process_ 를 밟게 된다는 뜻이다.

작성하는 문서가 스킬이면 frontmatter, invocation 선택, router skill 에 대해 [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md) 를 읽는다.

## Context pointer

**context pointer** 는 에이전트 컨텍스트에 있으면서, 컨텍스트 밖의 자료를 가리키고 그 자료에 도달할 조건을 담은 참조다. 스킬의 description 이 하나이고, `AGENTS.md` 에서 문서를 가리키는 한 줄도 같은 것이다. 에이전트가 언제, 얼마나 확실하게 그 자료에 도달하는지는 대상이 아니라 pointer 의 _문구_ 가 정한다. 꼭 필요한 대상이 약한 문구의 pointer 뒤에 있으면 variance 버그다: 먼저 문구를 날카롭게 하고, 그래도 안 될 때만 자료를 인라인한다.

pointer 는 두 가지 일을 한다: 자료가 무엇인지 밝히고, 그 자료에 도달해야 하는 **branch** 를 나열한다 (branch 는 문서가 다루는 서로 다른 경우로, 실행마다 문서 안의 다른 경로를 타게 만든다). 항상 로드되는 pointer 는 모든 단어가 매 턴 비용이므로 본문보다 더 세게 가지쳐야 한다:

- **leading word 를 앞에 둔다**: pointer 는 그 단어가 트리거 역할을 하는 자리다.
- **branch 하나에 트리거 하나.** 한 branch 의 이름만 바꾼 동의어는 같은 branch 를 두 번 쓴 것이다. 합치고, 진짜로 구별되는 branch 만 남긴다.
- **본문이 이미 담고 있는 정체성은 뺀다.**

## Context load 와 cognitive load

문서나 pointer 를 하나 추가할 때마다 두 예산 중 하나를 쓴다:

- **context load** 는 항상 로드되는 자료가 에이전트 컨텍스트 창에 지우는 비용이다: `AGENTS.md` 한 줄, 스킬 description, 매 턴 컨텍스트에 있는 모든 것. 발동하든 안 하든 토큰과 주의를 쓴다.
- **cognitive load** 는 사람이 지는 비용이다: 어떤 문서가 있고 각각을 언제 써야 하는지. 사람이 곧 인덱스다. 최소화할 비용이 아니라 사람이 주도권을 갖는 대가다: 사람의 판단이 중요한 곳에 쓰고, 그렇지 않은 곳에서는 없앤다.

pointer 를 통해서만 도달하는 자료는 pointer 한 줄 값만 치르고 context load 를 피한다. pointer 가 전혀 없는 자료는 전부 cognitive load 에 얹힌다.

## Information hierarchy

문서는 두 가지 내용으로 이루어진다: **step** (에이전트가 순서대로 수행하는 행동) 과 **reference** (필요할 때 찾아보는 정의, 규칙, 사실). 둘은 자유롭게 섞인다: 전부 step 일 수도 있고 (레시피), 전부 reference 일 수도 있고 (리뷰 규칙, 이 스킬), 둘 다일 수도 있다. 핵심 결정은 각 조각을 **information hierarchy** 의 어디에 두느냐다. 에이전트가 그 자료를 얼마나 즉시 필요로 하는지로 순위를 매긴 사다리다:

1. **In-file step** 이 첫째 층이다: 에이전트가 하는 일을 순서대로.
2. **In-file reference** 는 필요할 때 찾아본다. 평평한 peer-set 인 경우가 많은데 (리뷰의 모든 규칙이 한 단에 있는 식), 그건 문제가 아니라 괜찮은 배치다.
3. **Disclosed reference** 는 별도 파일로 밀려나 context pointer 로 도달하고, pointer 가 발동할 때만 로드된다. 같은 폴더의 형제 파일부터, 어디에나 있고 어느 문서든 가리킬 수 있는 완전 외부 reference 까지 걸친다.

너무 적게 내리면 위가 비대해지고, 너무 많이 내리면 에이전트가 실제로 필요한 자료를 숨긴다. 그 긴장이 결정의 전부다.

**Progressive disclosure** 는 사다리를 내려가는 이동이다 (메인 파일 밖으로, pointer 뒤로). 위를 읽기 쉽게 유지하기 위해서다. 주로 토큰 최적화가 아니다: hierarchy 를 지키는 방법이다. branch 가 가장 깔끔한 disclosure 기준이다: 모든 branch 가 필요한 것은 인라인하고, 일부 branch 만 도달하는 것은 pointer 뒤로 민다. 문서에 step 이 있을 때, disclose 해야 할 in-file reference 는 step 을 묻어버리고 step 에 주의를 기울일지를 동전 던지기로 만든다: 읽기 쉬움의 레버일 뿐 아니라 variance 의 레버다.

**Co-location** 은 파일 안에서의 짝이다: 사다리가 조각을 _얼마나 아래에_ 둘지 정한다면, co-location 은 거기 놓인 조각 _옆에 무엇을_ 둘지 정한다. 한 개념의 정의, 규칙, 주의사항을 여기저기 흩지 말고 한 heading 아래 둔다. 한 부분을 읽으면 이웃도 함께 따라오게. 기준: 문서는 에이전트를 위해 쓴 documentation 처럼 읽혀야 한다. 묶인 자료는 그렇게 읽히고, 흩어진 자료는 그렇지 않다. (duplication 과는 다르다: duplication 은 한 의미를 두 곳에서 반복하는 것이고, scattering 은 한 의미를 여러 곳으로 쪼개는 것이다.)

**Sprawl** 은 여기서의 실패 양상이다: 모든 줄이 살아 있고 고유해도 문서가 그냥 너무 긴 것. 초과분에 걸쳐 주의가 얇아지고, 줄이 하나 늘 때마다 relevance 를 유지해야 할 줄도 하나 는다. 처방은 사다리다: reference 를 pointer 뒤로 disclose 하고, branch 나 sequence 로 나눠 각 경로가 필요한 것만 지니게 한다.

## Step 과 completion criterion

모든 step 은 **completion criterion** 으로 끝난다. 일이 끝났다는 걸 에이전트에게 알려주는 조건이다. 두 속성이 이것을 레버로 만든다:

- **Clarity**: 에이전트가 끝남과 안 끝남을 구별할 수 있는가? 모호한 경계 ("이해에 도달함") 는 **premature completion** 을 부른다: 정말 끝나기 전에 step 을 끝내는 것으로, 주의가 _끝내는 것_ 으로 미끄러진다. 앞에 보이는 남은 step 들 (**post-completion step**) 이 끌어당기고, criterion 의 clarity 가 버틴다. 순서대로 방어한다: **먼저 경계를 날카롭게 한다** (국소적이고 싸다). 경계가 본질적으로 흐릿하고 _그리고_ 서두르는 게 실제로 관찰될 때만 sequence 를 나눠 뒤의 step 을 숨긴다. 숨기기는 진짜 context 경계를 넘을 때만 통한다 (hand-off 나 subagent dispatch. 인라인 호출은 뒤의 step 을 컨텍스트에 남겨서 아무것도 치우지 못한다).
- **Demand**: 얼마나 많이 요구하는가. "수정된 모든 모델을 설명함" 은 철저한 작업을 강제하지만 "변경 목록을 만든다" 는 그렇지 않다. demand 는 **legwork** 를 이끈다 (작업 안에서 에이전트가 하는 파고들기로, 별도 step 으로 쓰이지 않고 문구 속에 잠재해 있다). 그리고 step 에 묶이지 않는다: "모든 step 완료" 가 sequence 를 묶듯 "모든 규칙 적용" 은 평평한 reference 덩어리를 묶는다. 전부 reference 인 문서도 이렇게 철저함의 기준을 지닌다.

가장 강한 criterion 은 확인 가능하면서 철저하다.

## 분리할 때

문서 하나를 둘로 나누면 두 load 중 하나를 쓴다. 그러니 그 분리가 값을 할 때만 나눈다:

- **Sequence 로**: post-completion step 이 에이전트에게 지금 앞의 step 을 서두르게 만드는 step 구간을 나눈다. 그것들을 시야 밖에 두면 현재 작업에 legwork 가 더 들어간다. 반대도 조심한다: sequence 를 합치면 각 step 의 뒤 step 들이 노출되어 premature completion 을 부른다.
- **Invocation 으로** (스킬 한정): [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md) 를 본다.

## Leading word

**leading word** 는 모델의 pretraining 에 이미 살고 있는 압축된 개념으로, 에이전트가 문서를 실행하는 동안 그것으로 생각한다 (_lesson_, _fog of war_, _tracer bullets_). 문장이 아니라 토큰으로 반복하면 분산된 정의가 쌓이고, 모델이 이미 지닌 prior 를 끌어와 가장 적은 토큰으로 행동 영역 하나를 통째로 고정한다. 직접 만든 단어도 명확히 정의하면 통하지만, 만든 단어는 prior 를 끌어오지 못한다: pretraining 된 단어가 공짜로 주는 것을 정의 토큰으로 치른다. 이미 있는 단어를 먼저 찾는다.

두 번 고정한다. 본문에서는 _execution_ 을: 그 단어가 나올 때마다 에이전트가 같은 행동을 떠올리고, 평평한 reference 안에서는 찾아야 할 부류에 주의를 모은다. pointer 에서는 _invocation_ 을: 같은 단어가 프롬프트, 문서, 코드베이스에 함께 살면 에이전트가 그 공유 언어를 자료와 연결해 더 확실하게 도달한다.

leading word 로 리팩터링할 기회를 찾아라. 세 군데에 풀어 쓴 세 단어 묶음, 한 가지 생각을 가리키느라 한 문장을 쓰는 pointer. 각각 토큰 하나로 접히길 기다리는 구절이다:

- "빠르고, 결정적이고, 오버헤드가 적은" → _tight_ (_tight_ loop).
- "믿을 수 있는 루프" → _red_. 흐릿한 관문을 이진의 관찰 가능한 상태로 바꾼다 (루프가 버그에서 _red_ 가 되거나, 안 되거나).

두 번 이긴다: 토큰이 줄고, 에이전트가 생각을 걸 고리가 날카로워진다. 모든 문서가 leading word 로 은퇴시킬 재진술을 지니고 있다고 가정하고, 찾아내라.

**Negation** 은 이 레버 옆의 실패 양상이다: 금지로 조종하면 금지된 행동을 컨텍스트로 끌어와 덜이 아니라 _더_ 쓰이게 만든다. _코끼리를 생각하지 마라_ 하면 코끼리만 남는다. 부정은 약한 수식어라 강하게 활성화된 개념에 짓눌리고, 금지가 반쯤은 그 일을 하라는 지시로 읽힌다. **긍정** 을 쓴다: 목표 행동을 말해서 ("한 줄 주석을 쓴다") 금지된 행동이 아예 말해지지 않게 한다. 금지는 긍정으로 바꿀 수 없는 단단한 guardrail 일 때만 자리를 얻는다. 그때도 긍정 목표와 짝지어 주의가 할 일에 내려앉게 한다.

## Pruning

- 각 의미는 **single source of truth** 에 둔다: 권위 있는 한 곳에 두어 동작을 바꾸는 게 한 곳 수정이 되게 한다. **Duplication** (같은 의미가 둘 이상의 곳에 있는 것) 은 유지보수와 토큰을 쓰고, 그 의미의 사다리 위 비중을 실제 순위보다 부풀린다. (leading word 의 우연한 반대다: leading word 는 의미가 아니라 토큰을 일부러 반복한다.)
- **environment** 도 source of truth 다 (`package.json` scripts, 설정 파일, 디렉토리 구조, `--help` 출력). 그것을 재진술하는 문서는 **cache** 다: 조회 결과의 복사본으로, 조회가 비쌀 때만 load 값을 한다. 에이전트가 찾아봐서는 알 수 없는 것을 cache 한다: 쓰여지지 않은 관례, 선택의 이유, 어떤 설정도 털어놓지 않는 함정. 파일 하나, 명령 하나면 되는 조회는 environment 에 맡겨 낡을 수 없게 한다.
- 문서가 기대는 사실 (경로, 심볼, 명령, 규칙) 은 쓰기 전에 environment 에서 확인한다. 확인하지 못한 사실은 빼거나 미검증으로 표시하고, 보고에 확인한 출처를 함께 남긴다. 문서가 environment 와 어긋나면 문서를 environment 에 맞춘다. 코드를 고쳐야 할 사안이면 사용자에게 알리고 판단을 넘긴다.
- 모든 줄의 **relevance** 를 확인한다: 아직 문서가 하는 일에 관여하는가? 줄은 작업에 애초에 관여하지 않거나 (단순 설명, 또는 disclose 해야 할 branch), 설명하던 동작이나 세계가 바뀌어 낡으면서 relevance 를 잃는다. 짧은 문서일수록 relevance 를 유지하기 쉽다. pruning 규율이 없으면 기본 운명은 **sediment** 다: 추가는 안전하고 삭제는 위험하게 느껴져서 가라앉는 낡은 층으로, 결국 살아 있는 내용을 찾으려면 그 층을 파고 내려가야 한다.
- **sediment** 를 걷어낼 때 이유는 남긴다: 지우는 줄이 담던 결정이 [`../grill-with-adr/ADR-FORMAT.md`](../grill-with-adr/ADR-FORMAT.md) 의 세 조건을 통과하면 그 형식대로 **ADR** 로 옮기고, 문서에는 그 ADR 을 가리키는 context pointer 한 줄만 둔다.
- 문장 단위로 **no-op** 을 찾는다: 모델이 기본으로 이미 따르는 지시는 아무 말도 하지 않으면서 load 를 치른다. 기준 (기본 동작 대비 행동을 바꾸는가?) 은 읽는 사람이 아니라 모델에 상대적이다: 두 사람이 no-op 여부로 다투면 기본 동작에 대해 다투는 것이고, 토론이 아니라 문서를 실행해서 결론 낸다. 문장이 기준에 못 미치면 단어를 다듬지 말고 문장째 지운다. 이 기준은 leading word 도 채점한다: 기본 동작을 이기기엔 너무 약한 단어 (에이전트가 이미 어느 정도 철저한데 _be thorough_) 는 no-op 이고, 처방은 다른 기법이 아니라 더 강한 단어 (_relentless_) 다.
