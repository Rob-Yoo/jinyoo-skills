# 라운드 페이지 쓰는 법

`../grilling/SKILL.md` 의 원칙대로 질문마다 지형을 먼저, 선택지를 맨 뒤에 둔다. 문장은 짧게, 한 문장에 한 생각만 담는다. 용어는 처음 쓸 때 한 줄로 정의한다. 설명은 실제 값과 실제 화면으로 한다.

## 뼈대

```html
<!doctype html>
<html lang="ko">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title><주제> · 라운드 N</title>
<link rel="stylesheet" href="base.css">
<style>/* 이 페이지만의 레이아웃·시각 자료. 색은 base.css 토큰 (var(--accent) 등) 으로 */</style>
<body data-round="rN">
<main>
  <header class="read">
    <h1><주제> · 라운드 N</h1>
    <p>이번 라운드가 정하는 것 한두 줄. 사용법: 질문마다 고르고 맨 아래 "답변 완료".</p>
  </header>
  <section> 사실 표 </section>
  <section class="question" id="Q1"> … </section>
</main>
<script src="grill.js"></script>
</body>
</html>
```

`data-round` 는 파일 이름의 `r<N>` 과 같다.

## 사실 표

라운드 맨 위에 여러 질문이 함께 기대는 사실과 명세·예시와의 차이를 표로 둔다. 한 질문만의 사례는 그 질문의 지형에 둔다. 열은 항목, 값, 출처, 차이다.

- 출처: 문서 쪽수, 파일:라인, 영상 시각. 문서로 확인하지 못한 관례·기억이면 출처 칸에 "확인 안 함" 을 쓴다.
- 차이: 명세·예시와 다른 점을 `<span class="tag warn">` 으로. 같으면 비운다.

## 질문 한 덩어리

`<section class="question" id="Q<n>">` 안에 이 순서로 쓴다.

1. **번호와 제목**: `<span class="q-badge">Q1</span>` 과 `<h2>`. 제목은 정할 것 하나를 묻는 문장이다.
2. **왜 지금 정하나**: 이 결정이 막고 있는 것 한 줄.
3. **이 결정의 지형** (`<h3>이 결정의 지형</h3>`): 받은 지형을 화면에 맞게 넓게 펼친다: 터미널용으로 줄인 지형이면 사례와 축을 다시 채운다. 무엇을 보여줄지는 질문이 정한다. 선택지 키와 어느 쪽을 권하는 말은 쓰지 않는다 (grilling 의 지형 규칙). 출처를 붙이고, 확인하지 못한 것은 "확인 안 함".
4. **에이전트가 본 방향** (`<h3>에이전트가 본 방향</h3>`):
   - **다루지 않는 자리**: 그럴듯하지만 선택지에 올리지 않은 안 (grilling 의 용어). 사용자가 기타 칸에 자기 안을 쓸 출발점이다.
   - **선택지별로 사용자가 보게 되는 것**: 시안, 표 (아래 "시각 자료").
   - **선택지**: 아래 계약대로.

## 선택지 계약

`grill.js` 가 이 마크업을 읽어 저장·복원·요약을 한다.

```html
<fieldset data-q="Q1">
  <legend>Q1 · 검색 결과가 0건일 때 무엇을 보여줄까?</legend>
  <label class="choice">
    <input type="radio" name="Q1" value="A" data-short="안내 문구" data-rec>
    <span class="choice-key">A</span>
    <span><b>"결과 없음" 안내 문구</b> <span class="tag rec">추천</span></span>
    <span class="muted">결과 한두 줄. 시안·표를 넣어도 된다.</span>
  </label>
  <label class="choice"> … value="B" … </label>
</fieldset>
```

- `data-q` 와 radio `name` 은 질문 id (`Q1` …), `value` 는 선택지 키 (`A` …) 다.
- 모든 선택지에 `data-short` (요약에 쓰는 짧은 라벨) 를 단다.
- 추천 선택지 하나에 `data-rec` 과 `<span class="tag rec">추천</span>` 을 단다.
- 명세와 부딪히는 선택지에는 `<span class="tag warn">⚠ 명세와 다름</span>` 과 부딪히는 명세 줄을 붙인다.
- 선택지마다 `<label class="choice">` 하나가 버튼 하나다. 질문에서 하나만 고른다 (radio).
- 마지막 "기타" 칸은 `grill.js` 가 붙인다: 사용자는 선택지를 고르고 덧붙여 쓰거나, 고르지 않고 생각만 쓴다. 고른 선택지를 다시 누르면 선택이 풀린다.

## 시각 자료

보여줄 것이 눈에 보이는 형태를 고른다.

| 보여줄 것 | 쓰는 것 |
|---|---|
| design space (이 결정의 지형) | design space 지도: 축과 그 위의 사례, 비어 있는 자리가 보이게. 선택지는 이 지도에 찍지 않는다 |
| 화면·상태가 갈린다 | 선택지별 시안을 나란히 (`.compare`). 상태가 여럿이면 상태 × 선택지 그리드 |
| 숫자·문구가 시간에 따라 바뀐다 | 영상 프레임 띠 (`.strip`). 프레임마다 시각과 바뀐 값 |
| 이미지의 특정 부분이 근거다 | 번호 핀 (`.pins` 안의 `.pin`, `left`/`top` 은 %) 과 번호별 설명 (`.pin-legend`) |
| 여러 기준으로 비교한다 | 표 |
| 순서·흐름이 갈린다 | 단계 목록이나 인라인 SVG 흐름도 |

이미지는 `img/` 에 파일로 두고 파일마다 100KB 미만으로 줄인다. 일부 Chrome 은 로컬 파일이 그보다 크면 읽지 못하고, data URI 로 넣으면 페이지 파일이 그만큼 커진다.

## 확인

- 폭 1280px 과 390px 에서 `document.documentElement.scrollWidth - innerWidth` 가 0 이다. 넘치면 넘치는 그리드 항목에 `min-width: 0` 을 준다. 열이 셋 이상인 표와 390px 에서 라벨이 겹치는 지도는 `.scroll-x` 안에 두고 `min-width` 를 준다.
- 렌더한 화면에서 핀이 근거 글자를 가리지 않는다.
- 다크 모드에서 읽힌다: 색은 base.css 토큰만 쓴다.
- 브라우저를 다룰 수 있으면: 콘솔 오류 0, 선택지를 고르면 하단 상태 줄이 "저장됨" 이 된다. 이 확인으로 생긴 `r<N>-answers.json` 은 사용자에게 주소를 알리기 전에 지운다: 남기면 사용자가 열 때 확인용 답이 복원된다. 브라우저 도구가 프로젝트에 남긴 스크린샷·기록도 지운다.
