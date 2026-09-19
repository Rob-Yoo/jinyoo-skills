# 메모리 branch

[`ios-diagnosing-bugs`](SKILL.md) 의 branch 다: 화면을 닫아도 객체가 해제되지 않음, 같은 동작을 반복할수록 메모리가 늘어남, 누수 경고. Phase 1 전에 읽는다.

## 누수와 잔존

- **누수 (leak)**: 아무도 참조하지 않는데 해제되지 않은 메모리. 대개 참조 순환이다. `leaks` 가 찾는다.
- **잔존 (retention)**: 아직 누군가 참조하고 있어서 해제되지 않는 객체. 도달 가능하므로 `leaks` 는 0 을 보고한다.

## 루프

- **해제 단언 테스트**: 객체를 만들고, 증상이 나는 동작을 하고, 강한 참조를 놓은 뒤 weak 참조가 nil 인지 단언한다.

  ```swift
  func test_닫으면_해제된다() {
      var sut: SomeViewController? = SomeViewController()
      weak var released = sut
      sut?.loadViewIfNeeded()
      sut = nil
      XCTAssertNil(released)
  }
  ```

  XCTest 에서는 `addTeardownBlock { [weak sut] in XCTAssertNil(sut) }` 로 테스트 끝에 단언할 수도 있다.
- **실행 루프**: 화면을 띄웠다 닫고, `deinit` 에 태그 로그를 심어 정해진 시간 안에 찍히는지 grep 한다.
- **증가 루프**: 같은 동작을 N 번 반복하며 메모리를 재서 기울기를 본다. `leaks <pid>` 출력의 `nodes malloced for <N> KB` 줄을 반복마다 기록한다.

## 도구

```bash
L=$(xcrun simctl launch --terminate-running-process <UDID> <bundle id>)   # 출력: "<bundle id>: <pid>"
leaks "${L##*: }"                              # 누수 개수와 메모리 합계
leaks --outputGraph=<경로> <pid>                # memgraph 저장 (Xcode 로 열거나 다시 leaks 로 읽는다)
leaks --referenceTree <pid>                    # 루트부터 참조 트리
leaks --traceTree=<주소> <pid>                  # 특정 블록을 잡고 있는 경로
```

- 시뮬레이터 앱에는 `leaks` 가 바로 붙는다. "not debuggable ... readonly memory" 경고가 붙지만 누수 개수와 메모리 합계는 나온다.
- `--outputGraph`, `--referenceTree`, `--traceTree` 와 `xctrace` 의 Leaks·Allocations 템플릿은 미검증이다.

## 흔한 잔존 경로

Phase 3 에서 후보를 빠뜨리지 않기 위한 목록이다. 가설은 루프가 red 가 된 뒤에 세운다.

- 저장되는 클로저가 self 를 강하게 캡처한다: 콜백 프로퍼티, Combine `sink`·`assign(to:on:)`.
- `Timer`·`CADisplayLink` 의 target 이 self 다.
- NotificationCenter 블록 옵저버의 토큰을 제거하지 않는다.
- delegate 를 strong 으로 선언했다.
