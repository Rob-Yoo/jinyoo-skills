# 언제 mock 하나

**시스템 경계**에서만 mock 한다:

- 외부 API (결제, 이메일 등)
- 데이터베이스 (때때로: 테스트 DB 가 낫다)
- 시간·난수
- 파일시스템 (때때로)

mock 하지 않는 것:

- 자기 클래스·모듈
- 내부 협력자
- 자기가 통제하는 모든 것

## mock 하기 쉬운 설계

시스템 경계에서는 mock 하기 쉬운 interface 를 설계한다:

**1. 의존성 주입을 쓴다**

외부 의존성을 안에서 만들지 말고 넘겨받는다:

```swift
// mock 하기 쉽다
func processPayment(_ order: Order, client: PaymentClient) async throws -> Receipt {
    try await client.charge(order.total)
}

// mock 하기 어렵다
func processPayment(_ order: Order) async throws -> Receipt {
    let client = StripeClient(apiKey: ProcessInfo.processInfo.environment["STRIPE_KEY"] ?? "")
    return try await client.charge(order.total)
}
```

**2. 범용 fetcher 보다 SDK 형태 interface 를 쓴다**

조건 로직이 든 범용 함수 하나 대신 외부 작업마다 함수를 만든다:

```swift
// GOOD: 함수마다 독립적으로 mock 할 수 있다
protocol UserAPI {
    func getUser(id: User.ID) async throws -> User
    func getOrders(userID: User.ID) async throws -> [Order]
    func createOrder(_ draft: OrderDraft) async throws -> Order
}

// BAD: mock 안에 조건 로직이 필요하다
protocol UserAPI {
    func fetch(_ endpoint: String, method: String, body: Data?) async throws -> Data
}
```

SDK 방식이면:
- mock 마다 정해진 모양 하나를 돌려준다
- 테스트 준비에 조건 로직이 없다
- 테스트가 어떤 엔드포인트를 쓰는지 보기 쉽다
- 엔드포인트마다 타입 안전성이 있다
