# 성능 branch

[`ios-diagnosing-bugs`](SKILL.md) 의 branch 다: 증상이 느림, 멈춤 (hang), 끊김 (hitch), 늦은 앱 시작일 때. Phase 1 전에 읽는다. 성능 버그는 기준 측정으로 루프를 만들고, 측정으로 가설을 가른다. **측정 먼저, 수정은 나중.**

## 증상을 지표로 바꾼다

사용자의 말을 숫자 하나로 바꿔야 루프가 red 가 될 수 있다. red 는 "지표가 기준을 넘는다" 다.

| 사용자 말 | 지표 | 재는 법 |
|---|---|---|
| 화면이 늦게 뜬다 | 진입부터 첫 콘텐츠까지 시간 | 진입·표시 지점의 태그 로그 타임스탬프, 또는 `os_signpost` 구간 |
| 멈춘다 | 메인 스레드 hang 의 길이·횟수 | Time Profiler 기록의 `potential-hangs` 표, 또는 메인 스레드 간격 감시 |
| 스크롤이 끊긴다 | 메인 스레드 간격의 길이·횟수 | 메인 스레드 간격 감시 (기준을 끊김 크기에 맞춰 낮춘다) |
| 앱 시작이 느리다 | 실행부터 첫 화면까지 시간 | App Launch 템플릿 |
| 특정 작업이 느리다 | 그 구간 시간 | `os_signpost` begin/end, Time Profiler |

## 기준 측정

- 같은 조건에서 3회 이상 재고 중앙값을 쓴다.
- 사용자가 겪는 빌드로 잰다. Release 증상이면 `-configuration Release` 로 빌드한다. Debug 는 최적화가 꺼져 있어 CPU 병목이 부풀려진다.
- 시뮬레이터 측정은 같은 시뮬레이터에서의 전후 비교에만 쓴다. 절대값이 필요하면 [DEVICE.md](DEVICE.md) 로 실기기에서 잰다.

## xctrace (명령줄 Instruments)

이 스킬 디렉토리의 `scripts/trace.sh` 로 기록한다. 앱을 새로 띄우고 pid 로 붙어 기록한 뒤 `--table` 로 고른 표를 XML 로 내보낸다. `--table` 없이 돌리면 기록에 든 표 목록을 보여준다.

```bash
scripts/trace.sh --sim <UDID> --bundle-id <id> --seconds 10 --table potential-hangs
```

- 붙기 전 (앱 시작 직후) 은 기록되지 않는다. 시작 구간은 태그 로그 타임스탬프나 App Launch 템플릿 (미검증) 으로 잰다.
- Time Profiler 기록에는 `time-profile`, `potential-hangs`, `hang-risks`, `os-signpost`, `os-log` 표가 함께 들어 있다.
- 템플릿 목록은 `xcrun xctrace list templates` 로 본다. Time Profiler 는 기록과 내보내기를 확인했다. Animation Hitches 는 실기기에서만 기록되고 (시뮬레이터: "Hitches is not supported on this platform."), 메인 스레드를 50ms·500ms 막은 실험에서도 `hitches` 표가 비어 있었다: 어떤 조건에서 채워지는지 미검증이라 판정에 쓰지 않는다. App Launch, Allocations, Network, Swift Concurrency 템플릿은 미검증이다.
- 같은 시나리오를 수정 전후에 같은 명령으로 기록해야 비교가 된다.

## 메인 스레드 간격 감시

Instruments 없이 hang 을 루프로 만드는 가벼운 probe 다. 이 스킬 디렉토리의 `scripts/MainThreadGapProbe.swift` 를 앱 타깃에 임시로 복사하고 앱 시작 시 `MainThreadGapProbe.start(tag: "[DEBUG-a4f2]")` 를 부른다. 메인 스레드 프레임 간격이 기준 (기본 50ms) 을 넘을 때마다 `print` 태그 로그를 남기므로, `scripts/app-loop.sh --red-if 'main-thread gap'` 이 그대로 red 를 판정한다.

## 측정으로 가설 가르기

- 가설마다 "이 지표가 이렇게 나오면 기각" 을 먼저 적는다.
- 병목이 앱 밖 (서버, 네트워크) 으로 측정되면 앱 수정으로는 지표가 green 이 될 수 없다. 사용자에게 보고하고, 지표를 바꿀지 수정 전에 합의한다.
- 수정 후 같은 명령, 같은 조건으로 다시 재고 전후를 한 표에 남긴다. 그 표가 수정의 근거다.
