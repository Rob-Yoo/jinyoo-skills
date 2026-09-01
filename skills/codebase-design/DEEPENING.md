# Deepening

shallow module 묶음을 그 의존성을 고려해 안전하게 deepen 하는 법. [SKILL.md](SKILL.md) 의 용어를 전제한다: **module**, **interface**, **seam**, **adapter**.

## 의존성 분류

deepening 후보를 평가할 때 그 의존성을 분류한다. 분류가 deepen 된 모듈을 seam 너머에서 어떻게 테스트할지를 정한다.

### 1. In-process

순수 계산, 메모리 안 상태, I/O 없음. 언제나 deepen 할 수 있다: 모듈들을 합치고 새 interface 로 바로 테스트한다. adapter 가 필요 없다.

### 2. Local-substitutable

로컬 테스트 대역이 있는 의존성 (Postgres 대신 PGLite, in-memory 파일시스템). 대역이 있으면 deepen 할 수 있다. deepen 된 모듈은 테스트 스위트 안에서 대역을 돌려 테스트한다. seam 은 내부에 있다: 모듈의 external interface 에 port 가 없다.

### 3. Remote but owned (Ports & Adapters)

네트워크 너머에 있는 자기 서비스 (마이크로서비스, 내부 API). seam 에 **port** (interface) 를 정의한다. deep module 이 로직을 갖고, 전송은 **adapter** 로 주입한다. 테스트는 in-memory adapter 를, 운영은 HTTP/gRPC/큐 adapter 를 쓴다.

권고 형태: *"seam 에 port 를 정의하고, 운영용 HTTP adapter 와 테스트용 in-memory adapter 를 구현해, 네트워크에 걸쳐 배포돼도 로직이 deep module 하나에 있게 한다."*

### 4. True external (Mock)

통제할 수 없는 서드파티 서비스 (Stripe, Twilio 등). deepen 된 모듈은 외부 의존성을 주입받는 port 로 받고, 테스트는 mock adapter 를 넣는다.

## Seam 규율

- **adapter 하나면 가설의 seam, 둘이면 진짜 seam 이다.** adapter 가 최소 둘 (보통 운영 + 테스트) 정당화될 때만 port 를 도입한다. adapter 하나짜리 seam 은 간접 참조일 뿐이다.
- **internal seam 과 external seam.** deep module 에는 interface 의 external seam 과 함께 internal seam (implementation 전용, 자기 테스트가 쓴다) 이 있을 수 있다. 테스트가 쓴다는 이유만으로 internal seam 을 interface 에 노출하지 않는다.

## 테스트 전략: replace, don't layer

- deepen 된 모듈의 interface 에 테스트가 생기면, shallow module 에 걸려 있던 옛 단위 테스트는 쓸모가 없어진다: 지운다.
- 새 테스트는 deepen 된 모듈의 interface 에 쓴다. **interface 가 테스트 표면이다.**
- 테스트는 내부 상태가 아니라 interface 를 통한 관찰 가능한 결과를 검증한다.
- 테스트는 implementation 이 아니라 동작을 기술하므로 내부 리팩터링에도 살아남아야 한다. implementation 이 바뀔 때 테스트도 바뀌어야 한다면 interface 너머를 테스트하고 있는 것이다.
