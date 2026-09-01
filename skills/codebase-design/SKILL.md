---
name: codebase-design
description: deep module 설계를 위한 공용 용어와 원칙. 모듈의 인터페이스를 설계·개선하거나, deepening 기회를 찾거나, seam 위치를 정하거나, 코드를 테스트하기 쉽게 만들 때, 또는 다른 스킬이 deep module 용어를 필요로 할 때 사용한다.
---

# Codebase Design

**deep module** 을 설계한다: 작은 interface 뒤에 많은 동작을 두고, 깔끔한 seam 에 놓고, 그 interface 로 테스트할 수 있게. 코드를 설계하거나 재구성하는 곳이면 어디서든 이 용어와 원칙을 쓴다. 목표는 호출자에게 leverage, 유지보수자에게 locality, 모두에게 testability 다.

## 용어

아래 용어를 정확히 쓴다: "component", "service", "API", "boundary" 로 바꿔 부르지 않는다. 일관된 용어가 핵심이다.

**Module**: interface 와 implementation 을 가진 모든 것. 일부러 규모를 가리지 않는다: 함수, 클래스, 패키지, 여러 계층을 가로지르는 조각. _쓰지 않는 말_: unit, component, service.

**Interface**: 호출자가 모듈을 올바르게 쓰기 위해 알아야 하는 모든 것: 타입 시그니처뿐 아니라 불변식, 순서 제약, 오류 방식, 필요한 설정, 성능 특성까지. _쓰지 않는 말_: API, signature (타입 수준 표면만 가리켜 너무 좁다).

**Implementation**: 모듈 안에 있는 것, 코드 본체. **Adapter** 와 구별한다: 작은 adapter 에 큰 implementation 이 있을 수도 (Postgres repo), 큰 adapter 에 작은 implementation 이 있을 수도 (in-memory fake) 있다. seam 이 주제면 "adapter", 아니면 "implementation" 을 쓴다.

**Depth**: interface 에서의 leverage. 호출자 (또는 테스트) 가 배워야 하는 interface 한 단위당 실행할 수 있는 동작의 양. 작은 interface 뒤에 많은 동작이 있으면 **deep**, interface 가 implementation 만큼 복잡하면 **shallow** 다.

**Seam** _(Michael Feathers)_: 그 자리를 편집하지 않고도 동작을 바꿀 수 있는 곳. 모듈의 interface 가 사는 _위치_ 다. seam 을 어디에 둘지는 그 뒤에 무엇을 둘지와 별개의 설계 결정이다. _쓰지 않는 말_: boundary (DDD 의 bounded context 와 겹친다).

**Adapter**: seam 에서 interface 를 충족하는 구체적인 것. 내용 (안에 무엇이 있나) 이 아니라 역할 (어느 자리를 채우나) 을 가리킨다.

**Leverage**: 호출자가 depth 에서 얻는 것. 배우는 interface 한 단위당 더 많은 능력. implementation 하나가 N 개 호출처와 M 개 테스트에 걸쳐 값을 한다.

**Locality**: 유지보수자가 depth 에서 얻는 것. 변경, 버그, 지식, 검증이 호출자들에게 퍼지지 않고 한 곳에 모인다. 한 번 고치면 모든 곳이 고쳐진다.

## Deep 과 shallow

**Deep module** = 작은 interface + 많은 implementation:

```
┌─────────────────────┐
│   Small Interface   │  ← 적은 메서드, 단순한 매개변수
├─────────────────────┤
│                     │
│  Deep Implementation│  ← 복잡한 로직이 숨어 있다
│                     │
└─────────────────────┘
```

**Shallow module** = 큰 interface + 적은 implementation (피한다):

```
┌─────────────────────────────────┐
│       Large Interface           │  ← 많은 메서드, 복잡한 매개변수
├─────────────────────────────────┤
│  Thin Implementation            │  ← 그냥 넘겨준다
└─────────────────────────────────┘
```

interface 를 설계할 때 묻는다:

- 메서드 수를 줄일 수 있나?
- 매개변수를 단순하게 할 수 있나?
- 더 많은 복잡도를 안에 숨길 수 있나?

## 원칙

- **Depth 는 implementation 이 아니라 interface 의 성질이다.** deep module 도 안에서는 작고, mock 할 수 있고, 갈아 끼울 수 있는 부품들로 이뤄질 수 있다: 그 부품들이 interface 에 속하지 않을 뿐이다. 모듈에는 interface 의 **external seam** 과 함께 **internal seam** (implementation 전용, 자기 테스트가 쓴다) 이 있을 수 있다.
- **deletion test.** 모듈을 지운다고 상상한다. 복잡도가 사라지면 그냥 넘겨주던 모듈이었다. 복잡도가 N 개 호출처에 다시 나타나면 제 몫을 하던 모듈이다.
- **interface 가 테스트 표면이다.** 호출자와 테스트는 같은 seam 을 지난다. interface _너머_ 를 테스트하고 싶다면 모듈 모양이 잘못됐을 가능성이 크다.
- **adapter 하나면 가설의 seam, 둘이면 진짜 seam 이다.** seam 을 가로질러 실제로 무언가가 달라질 때만 seam 을 도입한다.

## 테스트하기 쉬운 설계

좋은 interface 는 테스트를 자연스럽게 만든다:

1. **의존성을 만들지 말고 받는다.**

   ```swift
   // 테스트하기 쉽다
   func processOrder(_ order: Order, paymentGateway: PaymentGateway) {}

   // 테스트하기 어렵다
   func processOrder(_ order: Order) {
       let gateway = StripeGateway()
   }
   ```

2. **부수효과를 만들지 말고 결과를 돌려준다.**

   ```swift
   // 테스트하기 쉽다
   func calculateDiscount(_ cart: Cart) -> Discount {}

   // 테스트하기 어렵다
   func applyDiscount(_ cart: Cart) {
       cart.total -= discount
   }
   ```

3. **표면을 작게.** 메서드가 적으면 필요한 테스트가 적다. 매개변수가 적으면 테스트 준비가 단순하다.

## 관계

- **Module** 은 **Interface** 를 정확히 하나 가진다 (호출자와 테스트에게 내보이는 표면).
- **Depth** 는 **Module** 의 성질이고, 그 **Interface** 를 기준으로 잰다.
- **Seam** 은 **Module** 의 **Interface** 가 사는 곳이다.
- **Adapter** 는 **Seam** 에 앉아 **Interface** 를 충족한다.
- **Depth** 는 호출자에게 **Leverage** 를, 유지보수자에게 **Locality** 를 만든다.

## 채택하지 않은 관점

- **depth 를 implementation 줄 수 대 interface 줄 수의 비율로 보는 것** (Ousterhout): implementation 을 부풀리는 것을 보상한다. 여기서는 depth 를 leverage 로 본다.
- **"Interface" 를 Swift `protocol` 이나 타입의 public 메서드로 보는 것**: 너무 좁다. 여기서 interface 는 호출자가 알아야 하는 모든 사실이다.
- **"Boundary"**: DDD 의 bounded context 와 겹친다. **seam** 이나 **interface** 라고 말한다.

## 더 깊이

- **의존성을 고려해 모듈 묶음을 deepen 할 때**는 이 스킬 디렉토리의 [DEEPENING.md](DEEPENING.md): 의존성 분류, seam 규율, replace-don't-layer 테스트.
- **다른 interface 를 탐색할 때**는 [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md): 병렬 하위 에이전트로 interface 를 근본적으로 다른 여러 방식으로 설계하고 depth, locality, seam 위치로 비교한다.
