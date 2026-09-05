# 프로토타입 마크업 규약

`assets/prototype.html` 을 `Docs/wip/design/<slug>/prototype.html` 로 복사하고 자리표시 네 개를 채운다.

템플릿이 맡는 것은 **동작**이다: 화면 이동, 상태 전환, 라이트·다크, 글자 크기, 동작 줄이기, 스크롤, 설계서 패널. 이 부분(템플릿의 기존 `<style>`·`<script>`)은 고치지 않는다. 화면마다 똑같은 장치라 새로 짜면 버그만 는다.

**화면의 모양과 상호작용은 네가 기능에 맞게 만든다.** 먼저 이 기능에 맞는 레이아웃과 요소를 구상하고, 아래 "시작 부품" 은 맞는 자리에만 쓴다. 부품 목록에 맞춰 기능을 끼워 넣지 않는다. 방법은 "직접 그리기" 에 있다.

| 자리표시 | 채울 것 |
|---|---|
| `__TITLE__` (두 곳) | 기능 이름 |
| `__DESIGNS__` | 설계서가 하나면 `glass`, 둘이면 `glass classic`. 디자인 모양은 템플릿이 그린다 |
| `__SCREENS__` | 화면 `<section>` 들 |
| `__NOTES__` | `data-spec` 마다 설계서 항목 하나를 담은 JSON 객체 |

## 화면

```html
<section data-screen="orders" data-title="주문 내역" data-spec="S1" data-tab="주문" data-tab-icon="🧾" data-large-title class="grouped">
  <div class="trail"><button class="bar-btn" data-go="filter" data-spec="S1.2">필터</button></div>
  <div class="search" data-spec="S1.1">검색</div>
  <div data-state="default"> … </div>
  <div data-state="empty"> … </div>
</section>
```

- `data-screen`: 화면 id. `data-title`: 내비게이션 바 제목. `data-spec`: 설계서의 화면 번호 (`S1`).
- `data-presentation`: 이 화면이 열리는 방식. `push` (기본), `sheet`, `full`, `alert`, `action-sheet`. sheet 는 `data-detent="medium"` 으로 절반 높이.
- `data-tab="라벨"` + `data-tab-icon="<글자 하나 또는 이모지>"`: 탭 루트. 붙은 순서대로 탭바가 생긴다. 하나도 없으면 첫 화면이 루트이고 탭바가 없다.
- `data-large-title`: 큰 제목. `class="grouped"`: 회색 그룹 배경 (inset grouped 리스트 화면).
- 내비게이션 바는 템플릿이 만든다. 뒤로 버튼도 자동이다. 바 오른쪽·왼쪽 버튼은 `<div class="trail">`·`<div class="lead">` 에 넣는다. sheet 의 취소·완료는 `lead`·`trail` 에 `data-dismiss` 버튼으로.
- `data-no-navbar`: 내비게이션 바 없는 화면 (온보딩 등).
- alert 화면은 내비게이션 바 없이 이렇게 쓴다:
  ```html
  <section data-screen="confirm-delete" data-presentation="alert" data-spec="S4">
    <div class="a-body"><div class="a-title">삭제할까요?</div><div class="a-msg">되돌릴 수 없습니다.</div></div>
    <div class="a-actions"><button data-dismiss>취소</button><button class="destructive" data-dismiss data-back>삭제</button></div>
  </section>
  ```
  버튼이 셋 이상이면 `a-actions stack`. 기본 동작 버튼은 `class="default"`.
- action sheet 도 내비게이션 바 없이 쓴다. 바깥(어두운 배경)을 누르면 닫힌다:
  ```html
  <section data-screen="photo-actions" data-presentation="action-sheet" data-spec="S5">
    <div class="as-group">
      <div class="as-title"><b>이 사진을 삭제할까요?</b>모든 기기에서 삭제됩니다.</div>
      <button class="destructive" data-dismiss>사진 삭제</button>
      <button data-dismiss>앨범에서만 빼기</button>
    </div>
    <button class="as-cancel" data-dismiss>취소</button>
  </section>
  ```
  `as-title` 은 필요할 때만. 사용자가 시작한 동작의 선택지(특히 되돌릴 수 없는 동작의 확인)에 쓰고, 알려야 할 중요한 정보는 alert 를 쓴다.

## 이동

| 속성 | 동작 |
|---|---|
| `data-go="<id>"` | 대상 화면의 `data-presentation` 대로 연다. 모달 안에서 push 대상이면 모달 안에서 push |
| `data-back` | 한 단계 뒤로 |
| `data-dismiss` | 맨 위 모달을 닫는다. `data-go` 가 같이 있으면 닫은 뒤 그 화면으로, `data-back` 이 같이 있으면 닫은 뒤 한 단계 뒤로 |

push 대상으로 가는 `.row` 에는 chevron 이 자동으로 붙는다.

스크롤은 템플릿이 처리한다: 내용이 바 밑으로 들어가면 바 구분(이전 디자인: 반투명 배경 + 구분선, Liquid Glass: scroll edge effect)이 생기고, 큰 제목이 다 가려지면 바에 작은 제목이 나타난다. 마우스로 끌어서도 스크롤된다. 스크롤바는 iOS 식 indicator (스크롤하는 동안만 보이는 얇은 막대) 로 그린다. 스크롤을 보여주려면 내용을 화면보다 길게 채운다.

`data-go` 요소에 `data-transition="zoom"` 을 붙이면 push 가 zoom 전환이 된다: 누른 요소 자리에서 새 화면이 펼쳐지고, 뒤로 가면 그 자리로 접힌다. 카드·썸네일처럼 새 화면의 내용을 대표하는 요소에 쓴다. 동작 줄이기에서는 cross-fade 가 된다.

## 제스처

iOS 표준 제스처는 템플릿이 마우스로도 되게 처리한다. 속성만 붙이면 된다.

| 제스처 | 쓰는 법 |
|---|---|
| 왼쪽 가장자리에서 끌어 뒤로 | 자동 (push 로 들어온 화면) |
| sheet 를 아래로 끌어 닫기 | 자동. 닫으면 입력이 사라지는 sheet 는 `data-confirm-dismiss="<alert 화면 id>"`: 끌어 닫으려 하면 닫지 않고 그 alert 를 띄운다. alert 의 "버리기" 버튼은 `data-dismiss="2"` (alert 와 sheet 를 함께 닫음) |
| 당겨서 새로 고침 | 화면 `<section>` 에 `data-refreshable`. 새로 고침 때 그 화면에 `refresh` 이벤트가 온다 |
| 행 스와이프 액션 | `.row` 안에 `<div class="swipe-actions"><button class="destructive" data-remove>삭제</button></div>` (오른쪽에서 나옴). 왼쪽에서 나오게 하려면 `swipe-actions leading`. 버튼 색: `destructive`, `tinted`, 그 밖은 인라인 `style` |
| 길게 누르기 → context menu | 요소에 `data-menu`, 그 안에 `<div class="context-menu">…</div>`. 마우스는 오른쪽 클릭으로도 열린다. 아래 "메뉴" 참고 |
| 끌어 스크롤 | 자동 |

- `data-remove`: 스와이프 액션 버튼이면 그 행을, context menu 항목이면 메뉴를 연 요소를 지운다. 이동 속성(`data-go` 등)이 없는 액션 버튼은 행의 `data-go` 로 이동하지 않는다.
- 그 밖의 제스처(double tap 확대, pinch, 회전, 끌어서 정렬)는 "직접 그리기" 의 상호작용으로 만든다. 마우스에서 double tap 은 `dblclick`, pinch 는 트랙패드의 `wheel` 이벤트 중 `e.ctrlKey` 가 참인 것으로 받는다.
- 설계서에 적은 제스처마다 같은 일을 하는 버튼(대안)이 프로토타입에도 있어야 한다.

## 메뉴

두 가지를 구분한다. 모양과 여는 방식이 다르다.

| | Context menu | Pull-down 메뉴 |
|---|---|---|
| 여는 방법 | 요소를 길게 누르기 | 버튼을 탭 (⋯ More 버튼, 정렬·추가 버튼 등) |
| 화면 | 배경을 흐리게 하고 누른 요소를 띄운 뒤 그 옆에 메뉴 | 배경은 그대로, 버튼에 붙어 메뉴만 열림 |
| 마크업 | 요소에 `data-menu` + 자식 `.context-menu` | 버튼에 `data-pulldown` |

- Pull-down 의 항목: 버튼 안에는 버튼을 넣을 수 없으므로 셋 중 하나로 준다. 자식 `.context-menu` (버튼이 아닌 요소일 때), `data-pulldown="<id>"` 로 같은 화면의 항목 묶음 (예: `<div class="context-menu" id="sort-items">`, 화면 안 어디에 두어도 숨겨진다), 값 없이 `data-pulldown` 이면 버튼을 감싼 `[data-menu]` 요소의 메뉴 (게시물의 ⋯ 버튼이 길게 누르기와 같은 메뉴를 여는 경우).
- 항목 마크업 (두 메뉴 공통):
  ```html
  <div class="context-menu">
    <button data-go="share">공유… <span class="mi">↗</span></button>
    <button>저장 <span class="mi">☆</span></button>
    <hr>
    <button class="destructive" data-remove>삭제 <span class="mi">🗑</span></button>
  </div>
  ```
  `<span class="mi">` 는 항목 뒤 아이콘 (SF Symbol 대신 기호·이모지·인라인 SVG). 한 그룹은 아이콘을 전부 달거나 전부 뺀다. `<hr>` 은 그룹 구분. 지우기처럼 되돌릴 수 없는 항목은 `destructive` (빨간 글씨). 추가 입력이 필요한 항목은 라벨 끝에 `…`.
- 메뉴 항목을 고르거나 바깥을 누르면 메뉴가 닫힌다.

## 상태

화면 안의 요소에 `data-state="default|empty|loading|error"` 를 붙이면, 오른쪽 상태 버튼으로 그 화면의 상태를 바꿔 볼 수 있다. `data-state` 가 없는 요소는 늘 보인다. 상태가 하나뿐인 화면은 붙이지 않는다. 그 밖의 상태 이름(`offline` 등)도 쓸 수 있다.

## 시작 부품

자주 쓰는 HIG 표준 컴포넌트를 미리 그려 둔 클래스다. 모양이 기존 앱이나 기능과 맞지 않으면 덮어쓰거나 쓰지 않는다.

| 클래스 | HIG 컴포넌트 |
|---|---|
| `list-header` / `list` > `row` / `list-footer` | List (inset grouped). `list plain` 은 그룹 없는 plain list |
| `row` 안: `main` > (텍스트, `sub`), `detail`, 끝에 `toggle` | 행 제목·부제·오른쪽 값·스위치 |
| `row destructive`, `row action` | 빨간 행, 틴트색 행 |
| `btn`, `btn tinted`, `btn plain`, `btn destructive`, `btn small` | Button (filled / tinted / plain / destructive / capsule 작은 버튼) |
| `bar-btn`, `bar-btn done` | 내비게이션 바 버튼, 굵은 완료 버튼 |
| `search` | Search field |
| `field` (`<input>`) | Text field (리스트 행 안에) |
| `seg` > `button[aria-pressed]` | Segmented control (누르면 선택이 바뀐다) |
| `toggle` (`<input type="checkbox">`) | Toggle |
| `empty` > `ic`, `t`, `m`, `btn` | 빈 화면·오류 화면 (아이콘, 제목, 설명, 동작) |
| `spinner` | 진행 표시 (indeterminate) |
| `placeholder` | 로딩 중 자리표시 블록 |
| `t-largeTitle` … `t-caption2`, `secondary`, `pad` | 텍스트 스타일, 보조 색, 좌우 16pt 여백 |

## 직접 그리기

- **모양**: `</head>` 바로 앞에 `<style>` 블록을 하나 더해 거기에 쓴다. 새 요소(카드, 차트, 캐러셀, 기존 앱의 커스텀 컴포넌트)도, 시작 부품의 모양 덮어쓰기도 여기서 한다. 디자인마다 달라야 하면 `.phone[data-design="glass"]` 로 가른다.
  - 색은 앱 토큰 (`var(--tint)`, `var(--label)`, `var(--label-2)`, `var(--bg-2)`, `var(--fill)`, 유리 컨트롤이면 `var(--glass)` 등) 으로 쓴다. 그래야 라이트·다크 전환이 따라온다.
  - 글자 크기는 `calc(<pt>px * var(--dt))` 로 쓴다. 그래야 글자 크기 전환이 따라온다.
  - 애니메이션은 `.phone.reduce-motion` 일 때 끄거나 cross-fade 로 바꾼다.
- **상호작용**: 템플릿의 `<script>` 다음, `</body>` 바로 앞에 `<script>` 블록을 하나 더해 거기에 쓴다 (스와이프 액션, 캐러셀 넘기기, 드래그 정렬, 차트 막대 선택 등).
  - 화면은 지금 보이는 것만 문서에 붙어 있다. 그래서 요소를 미리 찾아 이벤트를 걸지 말고, `document.getElementById('phone')` 에 이벤트를 걸고 `e.target.closest('<선택자>')` 로 대상을 찾는다.
  - 끌기 제스처는 `pointerdown` 에서 `e.stopPropagation()` 을 불러 템플릿의 끌어 스크롤을 막는다. 끌기가 끝난 뒤 따라오는 클릭이 행 이동을 일으키지 않게 하려면, `phone` 에 capture 단계 `click` 리스너 (`addEventListener('click', fn, true)`) 를 걸어 그 클릭에서 `e.stopPropagation()` 을 부른다.
  - 화면 이동은 템플릿 함수를 부르지 말고 `data-go` / `data-back` / `data-dismiss` 요소로 한다.
  - 동작 줄이기 여부는 `phone.classList.contains('reduce-motion')` 로 본다.

## 설계서 항목

```json
{
  "S1":   { "name": "주문 내역", "purpose": "지난 주문을 찾아 상세로 간다", "entry": "주문 탭", "states": "기본 / 빈 / 로딩 / 오류", "hig": "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables" },
  "S1.1": { "name": "검색", "component": "Search field", "behavior": "입력 즉시 목록을 거른다", "hig": "https://developer.apple.com/design/human-interface-guidelines/search-fields" }
}
```

키는 설계서의 S 번호다. 값의 필드는 `name`, `component`, `purpose`, `entry`, `behavior`, `transition`, `states`, `a11y`, `hig` 중 설계서에 적은 것만 같은 내용으로 옮긴다. 값은 문자열이거나 문자열 배열이다. URL 은 링크로 그려진다.

설계서가 둘이고 항목 내용이 디자인에 따라 다르면, 공통 필드는 그대로 두고 다른 필드만 `glass` / `classic` 객체에 넣는다. 지금 보고 있는 디자인의 객체가 공통 필드를 덮어쓴다.

```json
"S1.2": { "name": "필터", "behavior": "필터 sheet 를 연다",
          "glass":   { "component": "Toolbar item (유리 capsule)" },
          "classic": { "component": "Navigation bar 텍스트 버튼" } }
```
