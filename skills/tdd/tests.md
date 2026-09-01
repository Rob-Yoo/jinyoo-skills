# 좋은 테스트와 나쁜 테스트

## 좋은 테스트

**통합 스타일**: 내부 부품의 mock 이 아니라 실제 interface 로 테스트한다.

```swift
// GOOD: 관찰 가능한 동작을 테스트한다
@Test func userCanCheckoutWithValidCart() async throws {
    let cart = Cart()
    cart.add(product)
    let result = try await checkout(cart, paymentMethod: paymentMethod)
    #expect(result.status == .confirmed)
}
```

특징:

- 사용자·호출자가 신경 쓰는 동작을 테스트한다
- 공개 API 만 쓴다
- 내부 리팩터링에 살아남는다
- HOW 가 아니라 WHAT 을 기술한다
- 테스트 하나에 논리적 검증 하나

## 나쁜 테스트

**implementation 세부 테스트**: 내부 구조에 결합돼 있다.

```swift
// BAD: implementation 세부를 테스트한다
@Test func checkoutCallsPaymentServiceProcess() async throws {
    let mockPayment = MockPaymentService()
    _ = try await checkout(cart, paymentService: mockPayment)
    #expect(mockPayment.processCalls == [cart.total])
}
```

경고 신호:

- 내부 협력자를 mock 한다
- private 메서드를 테스트한다
- 호출 횟수·순서를 검증한다
- 동작 변화 없는 리팩터링에 테스트가 깨진다
- 테스트 이름이 WHAT 이 아니라 HOW 를 말한다
- interface 대신 외부 수단으로 검증한다

```swift
// BAD: interface 를 우회해 검증한다
@Test func createUserSavesToDatabase() async throws {
    _ = try await createUser(name: "Alice")
    let row = try db.query("SELECT * FROM users WHERE name = ?", ["Alice"])
    #expect(row != nil)
}

// GOOD: interface 로 검증한다
@Test func createUserMakesUserRetrievable() async throws {
    let user = try await createUser(name: "Alice")
    let retrieved = try await getUser(id: user.id)
    #expect(retrieved.name == "Alice")
}
```

**Tautological 테스트**: 기댓값이 implementation 을 그대로 다시 말해 구조상 통과한다.

```swift
// BAD: 기댓값을 코드가 계산하는 방식으로 다시 계산한다
@Test func calculateTotalSumsLineItems() {
    let items = [LineItem(price: 10), LineItem(price: 5)]
    let expected = items.reduce(0) { $0 + $1.price }
    #expect(calculateTotal(items) == expected)
}

// GOOD: 기댓값이 독립된, 알려진 리터럴이다
@Test func calculateTotalSumsLineItems() {
    #expect(calculateTotal([LineItem(price: 10), LineItem(price: 5)]) == 15)
}
```
