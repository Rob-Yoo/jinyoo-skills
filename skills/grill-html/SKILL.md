---
name: grill-html
description: grilling 라운드를 결정의 design space 를 펼친 HTML 페이지로 묻고, 사용자의 답을 로컬 서버로 받는다.
disable-model-invocation: true
---

grilling 라운드 하나를 HTML 페이지로 묻고 답을 받아 부른 쪽에 돌려준다. 부른 쪽 (`../grilling/SKILL.md`, `../cross-grilling/SKILL.md`) 이 design space 를 조사해 만든 라운드를 받는다: 질문, 지형, 선택지, 추천, 근거 출처. 페이지는 grilling 의 원칙대로 지형을 먼저, 선택지를 맨 뒤에 펼치고, 화면이기에 할 수 있는 만큼 넓게 보여준다: 지도, 시안, 근거 이미지.

넘겨받은 라운드 없이 직접 불렸으면 "grilling 중에 'HTML 로' 라고 말하면 쓰인다" 고 알리고 끝낸다.

## 작업 디렉토리

프로젝트 루트의 `Docs/wip/grilling/<slug>/` 하나를 grilling 이 끝날 때까지 쓴다. slug 는 부른 쪽이 정한 것 (미션·PRD slug) 을 쓰고, 없으면 주제에서 영문 kebab-case 로 만든다. 정리는 사용자가 한다.

| 파일 | 누가 쓰나 |
|---|---|
| `r<N>.html` | 에이전트. 라운드 N 페이지 |
| `img/` | 에이전트. 근거 이미지 |
| `serve.log`, `serve.pid` | 서버 실행 기록 |
| `r<N>-answers.json` | 서버. 사용자가 고른 답 |
| `base.css`, `grill.js` | 첫 라운드에 이 스킬 디렉토리의 `assets/` 에서 복사한다. 답 저장·복원이 여기 달려 있어 그대로 둔다. 페이지 고유 스타일은 페이지의 `<style>` 에 쓴다 |

## 라운드마다

명령은 프로젝트 루트에서 실행한다. `D=Docs/wip/grilling/<slug>`.

1. **페이지 쓰기**: 이 스킬 디렉토리의 `GUIDE.md` 대로 `r<N>.html` 을 쓴다. 지형이 그림으로 더 잘 보이면 받은 지형을 지도·시안으로 다시 그린다. 내용은 받은 라운드를 따른다. 완료: `GUIDE.md` 의 "확인" 항목을 모두 통과했다.
2. **서버**: 첫 라운드에 띄우고 grilling 이 끝날 때까지 둔다.
   ```sh
   nohup python3 <이 스킬 디렉토리>/scripts/serve.py "$D" > "$D/serve.log" 2>&1 & echo $! > "$D/serve.pid"
   ```
   `serve.log` 첫 줄의 `URL` 을 쓴다. 띄울 수 없으면 페이지를 `file://` 로 열게 하고, 다 고른 뒤 맨 아래 "요약 복사" 결과를 채팅에 붙여 달라고 한다 (이때 3~4 는 건너뛴다).
3. **열기**: `<URL>r<N>.html` 을 브라우저로 열고 (macOS: `open`) 주소를 알린다.
4. **기다리기**: `python3 <이 스킬 디렉토리>/scripts/wait.py "$D/r<N>-answers.json"` 으로 사용자가 "답변 완료" 를 누를 때까지 기다린다. 백그라운드 명령의 완료 알림을 받는 호스트에서는 백그라운드로 돌리고, exit 2 (기본 3600초 초과) 면 사용자에게 진행 상황을 묻는다. 그런 알림이 없는 호스트에서는 그 호스트의 명령 시간 제한보다 짧은 `--timeout` 으로 그대로 실행하고, exit 2 면 같은 명령을 다시 실행한다. 완료: exit 0 과 함께 답 JSON 을 받았다.
5. **답 돌려주기**: 답 JSON 을 부른 쪽에 사용자의 답으로 넘긴다. 답 필드:
   - `key`: 고른 선택지. 없을 수 있다.
   - `opinion`: "기타" 칸에 쓴 글. `key` 와 함께 있으면 그 선택지에 덧붙인 조건·이유로 결정과 함께 기록한다. `key` 없이 있으면 선택지가 모두 맞지 않아 쓴 사용자의 생각이다: 그 생각을 답으로 읽고, 결정으로 정리되지 않으면 다음 라운드에서 다시 묻는다.
   - `recommended`: 추천을 골랐는지. 추천이 없던 질문이나 `key` 가 없으면 없다.

"답변 완료" 뒤에 고친 답은 파일에만 반영되고 알림은 다시 오지 않는다. 다음 라운드를 쓰기 전에 직전 `r<N>-answers.json` 을 다시 읽어 바뀐 답을 반영한다.

## 끝

grilling 이 끝나면 `kill "$(cat "$D/serve.pid")"` 로 서버를 내리고 `Docs/wip/grilling/<slug>/` 경로를 알린다.
