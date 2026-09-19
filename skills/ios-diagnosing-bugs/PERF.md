# 성능 branch

[`ios-diagnosing-bugs`](SKILL.md) 의 branch 다: 증상이 느림, 멈춤 (hang), 끊김 (hitch), 늦은 앱 시작일 때. Phase 1 전에 읽는다. 성능 버그는 기준 측정으로 루프를 만들고, 측정으로 가설을 가른다. **측정 먼저, 수정은 나중.**

## 증상을 지표로 바꾼다

사용자의 말을 숫자 하나로 바꿔야 루프가 red 가 될 수 있다. red 는 "지표가 기준을 넘는다" 다.

| 사용자 말 | 지표 | 재는 법 |
|---|---|---|
| 화면이 늦게 뜬다 | 진입부터 첫 콘텐츠까지 시간 | 진입·표시 지점의 태그 로그 타임스탬프, 또는 `os_signpost` 구간 |
| 멈춘다 | 메인 스레드 hang 의 길이·횟수 | Time Profiler 기록의 `potential-hangs` 표, 또는 메인 스레드 간격 감시 |
| 스크롤이 끊긴다 | hitch 길이·비율 | Animation Hitches 템플릿 |
| 앱 시작이 느리다 | 실행부터 첫 화면까지 시간 | App Launch 템플릿 |
| 특정 작업이 느리다 | 그 구간 시간 | `os_signpost` begin/end, Time Profiler |

## 기준 측정

- 같은 조건에서 3회 이상 재고 중앙값을 쓴다.
- 사용자가 겪는 빌드로 잰다. Release 증상이면 `-configuration Release` 로 빌드한다. Debug 는 최적화가 꺼져 있어 CPU 병목이 부풀려진다.
- 시뮬레이터 측정은 같은 기기에서의 전후 비교에만 쓴다. 절대값을 주장하려면 실기기에서 잰다.

## xctrace (명령줄 Instruments)

```bash
L=$(xcrun simctl launch --terminate-running-process <UDID> <bundle id>)   # 출력: "<bundle id>: <pid>"
xcrun xctrace record --template 'Time Profiler' --device <UDID> --attach "${L##*: }" \
  --time-limit 10s --output run.trace --no-prompt
xcrun xctrace export --input run.trace --toc        # 표 목록
xcrun xctrace export --input run.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="potential-hangs"]'
```

- 시뮬레이터 앱은 `--attach` 에 이름이 아니라 pid 를 준다. 이름으로는 프로세스를 찾지 못했다.
- Time Profiler 기록에는 `time-profile`, `potential-hangs`, `hang-risks`, `os-signpost`, `os-log` 표가 함께 들어 있다.
- 템플릿 목록은 `xcrun xctrace list templates` 로 본다. Animation Hitches, App Launch, Allocations, Network, Swift Concurrency 템플릿의 기록은 미검증이다.
- 같은 시나리오를 수정 전후에 같은 명령으로 기록해야 비교가 된다.

## 메인 스레드 간격 감시

Instruments 없이 hang 을 루프로 만드는 가벼운 probe 다. `CADisplayLink` 나 짧은 주기 `Timer` 로 메인 스레드 콜백 간격을 재고, 기준 (예: 50ms) 을 넘는 간격을 태그 로그로 남긴다. `Timer` 는 스크롤 중 (tracking 모드) 멈추므로 `RunLoop.Mode.common` 에 건다.

## 측정으로 가설 가르기

- 가설마다 "이 지표가 이렇게 나오면 기각" 을 먼저 적는다.
- 수정 후 같은 명령, 같은 조건으로 다시 재고 전후를 한 표에 남긴다. 그 표가 수정의 근거다.
