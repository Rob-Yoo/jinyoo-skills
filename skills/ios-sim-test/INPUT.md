# 입력 주입

[`ios-sim-test`](SKILL.md) 의 branch 다: 입력이 기대대로 들어가지 않거나 화면 변화가 없을 때.

## 기본

- 화면 이동, 스크롤, 텍스트 입력은 Maestro 로 한다. 요소는 `accessibilityIdentifier` 로 찾는다 ([`SKILL.md`](SKILL.md) 준비 단계). 텍스트 셀렉터는 감춰 둔 뷰(겹쳐 숨긴 탭 목록 등)의 같은 글자에 걸려 보이지 않는 요소를 누른다.
- id 탭은 요소 **가운데**를 누른다. 키보드를 내린 직후처럼 요소가 움직이는 중이면 옛 위치를 누르므로 `hideKeyboard` 뒤에는 `waitForAnimationToEnd` 를 둔다. 가운데가 화면 맨 아래 홈 인디케이터 영역(아래 34pt 안팎)에 걸린 요소는 시스템이 터치를 가져가 반응이 없을 수 있다 — 앱의 무반응으로 판정하지 않는다
- 좌표는 바로 직전 스크린샷 기준으로만 쓴다. 전송 뒤 키보드가 내려가 목록이 밀리는 식으로 화면이 바뀌면, 이전 좌표의 탭은 다른 카드에 떨어져 엉뚱한 화면을 연다.
- 두 번 탭과 연타는 `dclick` 으로 보낸다 (아래).

## 두 번 탭

Maestro `doubleTapOn` 과 `tapOn: {repeat: 2}` 는 SwiftUI `onTapGesture(count: 2)` 에 들쭉날쭉하다: 같은 좌표에서 반영되기도, 안 되기도 한다. 두 탭이 드라이버 왕복을 거쳐 따로 가서 간격이 두 번 탭 허용 시간을 넘는 것으로 추정한다 (미검증). 이때 화면 변화가 없는 것은 앱이 반응하지 않아서가 아니다.

`dclick` 은 시뮬레이터 창에 진짜 마우스 이벤트를 보낸다. 클릭 간격 80ms 더블클릭이 실측에서 매번 반영됐다.

```bash
D=$(mktemp -d); swiftc -O <이 스킬 디렉토리>/scripts/dclick.swift -o "$D/dclick"
"$D/dclick" <x> <y> [횟수=2] [간격ms=80]
```

좌표는 macOS 화면 좌표다. 시뮬레이터 창 안 좌표에 창 원점을 더한다:

1. 창 위치·크기: `osascript -e 'tell application "System Events" to tell process "Simulator" to get {position, size} of window 1'`
2. 창만 찍는다: `screencapture -x -R<x>,<y>,<w>,<h> <out.png>`. 이미지는 레티나 2배이므로 요소 위치를 절반으로 줄여 창 안 좌표를 얻는다.
3. 창 원점 + 창 안 좌표 = 보낼 좌표.

실행하는 터미널 앱에 macOS 손쉬운 사용 권한이 있어야 한다. 없으면 `osascript에서 키스트로크를 보내도록 허용되지 않습니다. (1002)` 같은 오류가 난다. 사용자에게 권한을 요청하고, 준 사실을 보고서의 환경 변경에 적는다.

## Maestro 오류

- percent 좌표는 정수만 받는다. `point: 90%, 53.6%` 는 `NumberFormatException` 으로 죽는다.
- 콘솔에 스택만 보이거나 출력이 비면 `~/.maestro/tests/<시각>/maestro.log` 에서 원인을 찾는다.
- `ConnectException: Failed to connect to /127.0.0.1:<port>` 는 드라이버 연결이 일시적으로 실패한 것이다. 다시 실행한다.
- 거꾸로 쌓이는 목록 (최신이 아래인 채팅 등) 에서 `scrollUntilVisible` 의 `direction: UP` 은 과거 쪽으로 간다. 대상이 더 최신이면 `DOWN` 이다.
