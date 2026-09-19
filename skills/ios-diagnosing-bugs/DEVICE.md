# 실기기 branch

[`ios-diagnosing-bugs`](SKILL.md) 의 branch 다: SKILL.md 의 실기기 전환 조건에 걸렸을 때 읽는다. Phase 와 완료 기준은 그대로이고, 루프와 도구만 실기기용으로 바꾼다.

## 준비

- 기기는 `xcrun devicectl list devices` 에서 고른다. 연결된 기기가 여러 대면 사용자에게 묻고, 보고된 기종·OS 버전의 기기가 없으면 사용자에게 요청한다.
- 빌드에 서명이 필요하다. 어느 개발 팀으로 서명할지 사용자에게 확인하고, 프로젝트 서명 설정을 바꿨으면 정리 때 되돌린다. 자동 서명이면 `app-loop.sh --build` 에 `-allowProvisioningUpdates` 를 함께 준다.
- 같은 bundle id 의 앱이 기기에 이미 있으면 설치가 그 앱을 덮어쓴다. 사용자가 실제로 쓰는 기기면 설치 전에 확인받는다 (앱 데이터가 유지되는지는 미검증).
- 잠긴 기기에서는 실행이 막힐 수 있다 (미검증). 실행이 실패하면 사용자에게 잠금 해제를 요청한다.

## 시뮬레이터 도구 → 실기기 도구

| 시뮬레이터 | 실기기 |
|---|---|
| `scripts/app-loop.sh --sim <UDID>` | `scripts/app-loop.sh --device <UDID>` |
| `Logger`·`os_log` 를 `--log-predicate` 로 함께 판정 | `app-loop.sh` 로 받지 못한다 (`log collect` 에 root 가 필요하다). 판정할 로그는 `print` 태그 로그로 찍거나, `scripts/trace.sh --device <UDID> --bundle-id <id> --template Logging --table os-log` 로 받는다 |
| `scripts/trace.sh --sim` | `scripts/trace.sh --device`. Time Profiler (`potential-hangs`) 와 Logging (`os-log`) 의 기록·내보내기를 확인했다 |
| `scripts/MainThreadGapProbe.swift` | 그대로 쓴다 (확인했다) |
| `leaks <pid>` | 맥에서 도는 프로세스에만 붙는다. `trace.sh --device ... --template Leaks` 로 기록하되, 누수 표가 `xctrace export` 로 나오지 않으므로 기록 파일을 Instruments 앱에서 연다 (HITL) |
| `xcodebuild test -destination 'platform=iOS Simulator,id=<UDID>'` | `-destination 'platform=iOS,id=<UDID>'` (미검증) |
| (없음) 메모리 한도로 인한 종료 | 확인하는 도구는 미검증이다. 사용자에게 기기의 분석 데이터에서 `JetsamEvent` 로그를 받아 앱이 종료 대상이었는지 본다 (HITL) |
| `simctl ui` 설정 변경, Maestro 조작 | `simctl` 은 시뮬레이터 전용이고, Maestro 의 실기기 지원은 미검증이다. 설정과 화면 조작은 `scripts/hitl-loop.template.sh` 로 사람에게 맡긴다 |

## 정리

SKILL.md Phase 6 에 더해 다음을 모두 확인한다. 근거 보고는 Phase 6 과 같다:

- 기기에 계측 빌드가 남지 않았다: 원래 없던 앱이면 `xcrun devicectl device uninstall app --device <UDID> <bundle id>` 로 지우고, 원래 있던 앱이면 계측 없는 빌드로 다시 설치했다
- 바꾼 서명 설정을 되돌렸다
