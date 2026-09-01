# 시뮬레이터 설정

[`ios-sim-test`](SKILL.md) 의 branch 다: 항목이 시뮬레이터 설정을 바꿔야 할 때. 바꾸기 전에 원래 값을 읽어 기록하고, 끝나면 되돌린 뒤 확인한다.

## 소프트 키보드

하드웨어 키보드 연결이 켜져 있으면 입력칸에 커서만 생기고 소프트 키보드가 뜨지 않는다.

- 토글은 Simulator 메뉴 `I/O > Keyboard > Connect Hardware Keyboard` 를 osascript 로 클릭한다. ⌘K 키 입력은 포커스 상태에 따라 먹지 않는다.
- 현재 상태는 그 메뉴 항목의 `AXMenuItemMarkChar` 로 읽는다. 메뉴를 열어야 읽힌다.
- `defaults write com.apple.iphonesimulator ConnectHardwareKeyboard` 는 Simulator 앱을 재시작해야 반영되므로 메뉴 토글을 쓴다.
- 토글하는 사이 입력칸에 문자 (`.` 등) 가 들어갈 수 있다. 전송 전에 Maestro `eraseText` 로 비우고 스크린샷으로 확인한다.

## 동작 줄이기

```bash
xcrun simctl spawn <UDID> defaults read com.apple.Accessibility ReduceMotionEnabled   # 원래 값
xcrun simctl spawn <UDID> defaults write com.apple.Accessibility ReduceMotionEnabled -bool true
```

바꾼 뒤 앱을 다시 실행해야 반영된다. 끝나면 원래 값으로 쓰고 앱을 다시 실행한다.

## 시뮬레이터로 확인할 수 없는 것

진동 (햅틱) 은 시뮬레이터에서 확인할 수 없다. 해당 항목은 "확인 불가, 실기기 필요" 로 판정한다.
