# 실기기

[`ios-sim-test`](SKILL.md) 의 branch 다: 사용자가 실기기 판정을 요청할 때. 핵심 규칙, 판정, 보고서는 그대로이고, 아래가 시뮬레이터의 준비·이동·항목 확인 수단을 대신한다. iPhone 13 Pro, iOS 27.0.1, Xcode 26.2, Maestro 2.7.0 에서 실측한 절차다.

Maestro 는 실기기를 공식 지원하지 않는다 (2026-10 기준, 이슈 #3608 "Physical devices aren't supported"). 아래 드라이버 절차는 우회라서 Maestro 버전이 바뀌면 깨질 수 있다. 드라이버 단계에서 실패하면 앱 결함이 아니라 도구 한계로 본다.

## 안전

기기는 사용자가 실제로 쓰는 폰이다.

- 시작 전에 사용자에게 잠금을 풀어 두고 기기에 손대지 말아 달라고 알린다.
- flow 를 실행할 때마다 먼저 앞 화면이 대상 앱인지 확인한다: 이 스킬 디렉토리의 `scripts/device-dump.sh <UDID> <bundle id>` 출력에 대상 앱에만 있는 id (탭바 등) 가 있어야 한다. 없으면 (다른 앱, 잠금 화면) 입력 없이 멈추고 사용자에게 알린다. 자동 입력이 사용자가 쓰던 Safari 에 떨어질 뻔했다 (실측).
- 대상 앱이 아닌 화면 (다른 앱, 알림 배너) 이 담긴 이미지는 Maestro 실패 산출물 (`~/.maestro/tests/<시각>/`) 이든 수집한 프레임이든 바로 지운다. 사용자의 사생활이다. 보고서에 넣는 이미지는 넣기 전에 한 장씩 확인한다.
- 기기 설정 (글자 크기, 다크 모드 등) 이 필요한 항목은 사용자에게 원래 값과 함께 변경을 요청하고, 사용자가 직접 바꾼다. 원래 값은 사용자의 답으로 기록하고, 끝나면 되돌려 달라고 요청해 확인을 받는다. 요청할 수 없으면 "확인 불가 (기기 설정 변경 필요)" 로 두고 바꾸는 경로 (설정 앱 경로, 제어 센터의 텍스트 크기) 를 적는다.
- 설치가 기존 앱 (같은 bundle id 의 App Store 앱 등) 때문에 실패하면 사용자에게 알리고 결정을 받는다. 기존 앱을 지우면 사용자 데이터가 사라진다.

## 빌드·설치

- 기기 ID 는 모든 명령에 UDID (`xcrun xctrace list devices`) 를 쓴다. `devicectl` 이 UDID 를 거부하면 `xcrun devicectl list devices` 의 식별자를 쓴다 (help 는 UDID 를 받는다고 하지만 기기로 확인하지 않았다).
- 서명할 팀 ID 는 사용자에게 묻는다. 회사 인증서가 있는 Mac 에서 고르면 회사 계정으로 서명된다.
- 프로젝트 지침의 빌드 명령에서 destination 을 `platform=iOS,id=<UDID>` 로 바꾸고 (`-sdk iphonesimulator` 가 있으면 뺀다), `DEVELOPMENT_TEAM=<팀 ID> -allowProvisioningUpdates` 를 더한다. 프로젝트 파일의 서명 설정은 그대로 두어, 개인 팀 ID 가 저장소에 들어가지 않게 한다.
- 설치: `xcrun devicectl device install app --device <UDID> <.app 경로>`
- 실행: `xcrun devicectl device process launch --terminate-existing --device <UDID> <bundle id>`
- "이 기기에서는 안 된다" 로 확인 불가를 내기 전에 이전 설치 이력 (`xcrun devicectl device info apps --device <UDID>`) 을 본다. 설치된 적이 있으면 이 조합에서 빌드가 된다는 뜻이니 실제로 다시 시도한다. "Xcode 가 이 iOS 를 지원하지 않는 듯" 이라는 추측으로 확인 불가를 냈다가, 다시 시도하니 됐다 (실측).

## Maestro 드라이버

- `maestro test` 가 Apple 팀 ID 를 요구하며 멈추면, help 에 나오지 않는 `maestro driver-setup --apple-team-id <팀 ID> --destination 'platform=iOS,id=<UDID>'` 로 기기에 드라이버를 설치한다.
- 드라이버 빌드가 `MaestroDriverLib` 를 찾지 못해 실패하면: 배포 jar 가 그 폴더를 빠뜨렸다 (2.4.0~2.11.0 확인, 이슈 #3218). 먼저 `unzip -l ~/.maestro/lib/maestro-cli-<버전>.jar | grep MaestroDriverLib/` 로 폴더가 빠졌는지 확인하고, 빠졌을 때만:
  1. `unzip ~/.maestro/lib/maestro-cli-<버전>.jar 'driver/ios/*' -d <작업 디렉토리>`
  2. GitHub `mobile-dev-inc/Maestro` 의 설치된 버전 태그 (`cli-<버전>`) 에서 `maestro-ios-xctest-runner/MaestroDriverLib` 를 받아 `<작업 디렉토리>/driver/ios/` 에 넣는다.
  3. `<작업 디렉토리>/driver/ios` 에서 빌드한다: `xcodebuild build-for-testing -project maestro-driver-ios.xcodeproj -scheme maestro-driver-ios -destination 'generic/platform=iOS' -derivedDataPath ~/.maestro/maestro-iphoneos-driver-build/driver-iphoneos DEVELOPMENT_TEAM=<팀 ID> -allowProvisioningUpdates`
  4. `device-run.sh` 로 짧은 flow 가 COMPLETED 되면 끝난 것이다.
- 드라이버는 기기 안 `127.0.0.1:<port>` 에 떠서 Mac 에서 바로 닿지 않는다. flow 는 이 스킬 디렉토리의 `scripts/device-run.sh <UDID> <flow 절대경로>` 로 실행한다: 실행하는 동안만 포트를 `iproxy` 로 포워딩한다. `iproxy` 가 없으면 설치 (`brew install libimobiledevice`) 를 사용자에게 묻는다.

## 근거 수집

- `scripts/rec.sh` 의 화면 녹화는 실기기에서 쓸 수 없다. 항목 확인은 `SHOTS=<프레임 디렉토리> device-run.sh …` 로 실행해 드라이버 `/screenshot` 프레임을 0.2~0.3초 간격으로 모은다. 입력 전후 화면은 그 프레임의 처음과 끝이다. 반복 간격보다 짧은 끊김은 볼 수 없으므로 보고서 끝 절의 도구 한계에 적는다.
- Maestro `takeScreenshot` 은 화면이 멈춘 뒤에 찍혀 탭 직후 상태를 놓친다. 탭 직후는 프레임에서 본다. `takeScreenshot` 을 쓰면 `SHOT_ROOT=<작업 디렉토리>` 를 주어 `device-run.sh` 가 지정한 경로로 옮기게 한다.
- 보고서 클립: 프레임 파일명이 ms 시각이라 이름순이 시간순이다. 초당 장수는 프레임 수 ÷ (마지막 − 처음 시각) 으로 구해 `ffmpeg -framerate <초당 장수> -pattern_type glob -i '<디렉토리>/*.jpg' -vf "scale=360:-2,format=yuv420p" -c:v libx264 <클립>.mp4` 로 만든다. `REPORT.md` 의 VFR 크기 비교와 `trim-still.sh` 는 녹화 영상용이다. 화면 변화는 프레임끼리 비교해 본다.
- 요소의 id 와 bounds 는 `device-dump.sh` 로 얻는다. `maestro hierarchy` 는 포워딩 없이 기기 드라이버에 붙지 못한다.
- 앱 데이터: `xcrun devicectl device copy from --device <UDID> --domain-type appDataContainer --domain-identifier <bundle id> --source <경로> --destination <작업 디렉토리>` 로 받아 읽는다 (기기로 확인하지 않았다).
- 두 번 탭: `INPUT.md` 의 `dclick` 은 시뮬레이터 창 전용이다. 기기에서 `doubleTapOn` 이 반영되지 않으면 입력 방법 한계로 보고 확인 불가에 그 이유를 적는다.
- 햅틱은 기기에서도 에이전트가 느낄 수 없다. "확인 불가, 사람 확인 필요" 로 둔다.

## 정리

`device-run.sh` 는 자기가 띄운 maestro 와 `iproxy` 를 끝낸다. 남을 수 있는 것은 이 기기 UDID 가 명령줄에 든 프로세스뿐이다: `pgrep -fl "<UDID>"` 로 보고 (드라이버의 `xcodebuild test-without-building`, 멈춘 maestro, `iproxy`), 그 PID 만 끝낸 뒤 다시 `pgrep` 으로 남지 않았는지 확인한다. 이름만으로 끝내면 사용자의 다른 빌드와 포워딩도 끝난다. 기기 설정은 안전 절대로 사용자의 확인으로 원복을 마친다.

## 보고서

- 머리의 환경에 기기 모델, OS, 다크 모드, 글자 크기를 적는다. 시뮬레이터 결과와 모양이 다르면 먼저 기기 설정 차이인지 확인하고, 설정 차이로 설명되면 환경 차이로 기록한다.
- 같은 체크리스트를 시뮬레이터에서 이미 판정했으면, 실기기는 "확인 불가, 실기기 필요" 항목과 기기에서만 달라질 수 있는 항목 (성능, 카메라, 푸시, 생체 인증) 만 판정한다. 나머지 항목은 시뮬레이터 보고서의 판정을 출처와 함께 옮겨 적는다.
