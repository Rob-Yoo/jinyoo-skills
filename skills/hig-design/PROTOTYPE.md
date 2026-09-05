# 프로토타입 마크업 규약

`assets/prototype.html` 을 `Docs/wip/design/<slug>/prototype.html` 로 복사하고 자리표시 세 개만 채운다. 템플릿의 CSS·JS 는 고치지 않는다. 기존 앱 디자인을 따를 때만 "앱 토큰" 블록의 값을 바꾼다.

| 자리표시 | 채울 것 |
|---|---|
| `__TITLE__` (두 곳) | 기능 이름 |
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

- `data-screen`: 화면 id. `data-title`: 내비게이션 바 제목. `data-spec`: spec.md 의 화면 번호 (`S1`).
- `data-presentation`: 이 화면이 열리는 방식. `push` (기본), `sheet`, `full`, `alert`. sheet 는 `data-detent="medium"` 으로 절반 높이.
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

## 이동

| 속성 | 동작 |
|---|---|
| `data-go="<id>"` | 대상 화면의 `data-presentation` 대로 연다. 모달 안에서 push 대상이면 모달 안에서 push |
| `data-back` | 한 단계 뒤로 |
| `data-dismiss` | 맨 위 모달을 닫는다. `data-go` 가 같이 있으면 닫은 뒤 그 화면으로, `data-back` 이 같이 있으면 닫은 뒤 한 단계 뒤로 |

push 대상으로 가는 `.row` 에는 chevron 이 자동으로 붙는다.

## 상태

화면 안의 요소에 `data-state="default|empty|loading|error"` 를 붙이면, 오른쪽 상태 버튼으로 그 화면의 상태를 바꿔 볼 수 있다. `data-state` 가 없는 요소는 늘 보인다. 상태가 하나뿐인 화면은 붙이지 않는다. 그 밖의 상태 이름(`offline` 등)도 쓸 수 있다.

## 컴포넌트 클래스

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

여기 없는 컴포넌트(기존 앱의 커스텀 요소, 카드, 이미지 등)는 인라인 `style` 로 그리되 색은 앱 토큰 (`var(--tint)`, `var(--label-2)`, `var(--bg-2)` 등) 만 쓴다. 그래야 다크 모드 전환이 따라온다. 글자 크기는 `calc(<pt>px * var(--dt))` 로 써야 글자 크기 전환이 따라온다.

## 설계서 항목

```json
{
  "S1":   { "name": "주문 내역", "purpose": "지난 주문을 찾아 상세로 간다", "entry": "주문 탭", "states": "기본 / 빈 / 로딩 / 오류", "hig": "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables" },
  "S1.1": { "name": "검색", "component": "Search field", "behavior": "입력 즉시 목록을 거른다", "hig": "https://developer.apple.com/design/human-interface-guidelines/search-fields" }
}
```

키는 spec.md 의 S 번호다. 값의 필드는 `name`, `component`, `purpose`, `entry`, `behavior`, `transition`, `states`, `a11y`, `hig` 중 spec.md 에 적은 것만 같은 내용으로 옮긴다. 값은 문자열이거나 문자열 배열이다. URL 은 링크로 그려진다.
