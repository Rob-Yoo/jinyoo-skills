# Apple HIG 요약 레퍼런스 (iPhone 전용)

> 이 문서는 Apple Human Interface Guidelines를 iPhone 화면 설계용으로 요약한 것이다(원문 번역 아님). 특정 케이스에서 규칙이 모호하면 원문 JSON `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<slug>.json` 을 가져와 확인하고, 근거로는 사람이 읽는 링크 `https://developer.apple.com/design/human-interface-guidelines/<slug>` 를 인용한다. 2026-10 기준 수집. 여기 적힌 수치는 모두 원문에 있는 값만 옮겼다.

---

## 1. 내비게이션 구조 고르기

### Tab bar vs 계층 push vs 모달
- **앱의 최상위 섹션 간 이동은 Tab bar.** 각 탭은 자기 내비게이션 상태를 유지한 채 전환된다.
- **Tab bar에는 이동만, 액션은 넣지 않는다.** 현재 화면 콘텐츠에 작용하는 컨트롤은 Toolbar로 보낸다.
- **탭 개수는 적을수록 좋다.** HIG는 iPhone 탭 수 상한을 숫자로 명시하지 않는다. 대신 화면 폭을 넘으면 마지막 탭이 More 탭으로 바뀌어 나머지가 숨겨지므로, 오버플로가 생기지 않게 설계한다.
- **탭 버튼을 숨기거나 비활성화하지 않는다.** 내용이 없으면 탭은 그대로 두고 그 섹션 안에서 왜 비었는지 설명한다.
- **섹션 이동 중에도 Tab bar를 계속 보이게 한다.** 예외는 모달이 Tab bar를 덮는 경우뿐이다.
- **탭 라벨은 가능하면 한 단어로 붙이고, 아이콘은 채움(filled) 스타일 SF Symbols를 쓴다.**
- **Badge는 중요한 새 정보에만 쓴다.** 남발하면 의미가 희석된다.
- **Tab bar 끝에 검색 전용 탭을 둘 수 있다.** 탐색·추천 위주면 standard 탭(검색 랜딩 페이지), 빠른 검색 후 이전 탭으로 복귀하는 흐름이면 button 형태(탭 즉시 키보드 표시).
- **정보 계층을 파고드는 흐름(목록 → 상세)은 push 내비게이션.** Navigation bar(iOS에서 내비게이션용 Toolbar를 부르는 이름)에 표준 Back 버튼을 둔다.
- **하나의 화면 안에서 밀접한 하위 뷰 전환은 Segmented control**, 완전히 다른 섹션 전환은 Tab bar.
- **커스텀 제스처 단축키는 표준 Back 버튼을 대체하지 않고 보완만 한다.**

### 모달: 언제, 무엇으로
- **모달은 분명한 이점이 있을 때만 쓴다.** 집중이 필요하거나 콘텐츠·기기에 영향을 주는 선택을 받을 때.
- **모달 작업은 짧고 단순하게 유지한다.** 모달 안에 뷰 계층을 만들면 "앱 속의 앱"처럼 느껴진다. 하위 뷰가 꼭 필요하면 경로를 하나로 하고, 닫기 버튼과 헷갈릴 버튼을 두지 않는다.
- **모달 제목에 작업 이름을 붙인다.** 사용자가 지금 무엇을 하는 중인지 알 수 있게.
- **닫는 방법이 항상 분명해야 한다.** iPhone 사용자는 상단 Toolbar의 버튼이나 아래로 스와이프를 기대한다.
- **모달을 여러 겹 띄우지 않는다.** 새 모달 전에 기존 것을 닫게 한다. Alert은 다른 모달 위에 뜰 수 있지만 Alert 두 개를 동시에 띄우지는 않는다.
- **닫으면 사용자 입력이 사라질 때는 확인을 받는다.** 제스처로 닫든 버튼으로 닫든 같다. iOS에서는 저장 옵션이 있는 Action sheet가 적절하다.

| 상황 | 선택 |
|---|---|
| 현재 맥락과 밀접한 짧은 작업(정보 입력, 위치 선택 등) | Sheet |
| 영상·사진·카메라, 문서/사진 편집처럼 길거나 여러 단계인 작업 | Full-screen 모달 |
| 부모 화면을 계속 조작하면서 보조 도구가 필요할 때 | Nonmodal sheet (예: 메모 서식 패널) |
| 사용자가 시작한 행동에 대한 선택지 | Action sheet |
| 즉시 알아야 할 중요한, 가급적 조치 가능한 정보 | Alert |

https://developer.apple.com/design/human-interface-guidelines/tab-bars · https://developer.apple.com/design/human-interface-guidelines/toolbars · https://developer.apple.com/design/human-interface-guidelines/modality · https://developer.apple.com/design/human-interface-guidelines/sheets · https://developer.apple.com/design/human-interface-guidelines/search-fields · https://developer.apple.com/design/human-interface-guidelines/gestures

---

## 2. 컴포넌트별 핵심 규칙

### Navigation bar / Toolbar
- **HIG에는 독립된 Navigation bar 페이지가 없다.** Toolbars 페이지가 "상단의 내비게이션용 Toolbar = Navigation bar"로 함께 다룬다.
- **제목은 짧게 쓴다.** 15자 미만을 목표로 하고, 앱 이름은 제목으로 쓰지 않는다.
- **iPhone에서는 Large title을 쓴다.** 스크롤하면 일반 제목으로 줄고, 맨 위로 돌아오면 다시 커진다.
- **표준 Back/Close 버튼을 쓴다.** 표준 심볼을 쓰고 "Back"/"Close" 텍스트 라벨은 달지 않는다.
- **아이템은 꼭 필요한 것만 넣는다.** 공간이 좁으니 핵심만 남기고 나머지는 More 메뉴로 보낸다.
- **아이콘은 테두리 없는 시스템 심볼을 쓴다.** 심볼로 표현이 어려운 동작(예: Edit)만 텍스트로.
- **주요 액션(Done, Submit 등)은 하나만 prominent 스타일로 강조하고 trailing 쪽에 둔다.**
- **그룹은 최대 3개 정도로 줄인다.** 텍스트 라벨 버튼끼리, 텍스트 버튼과 심볼 버튼은 붙여 두지 말고 간격을 띄운다.
- **바 배경을 커스텀 색으로 칠하지 않는다.** 콘텐츠 레이어가 바의 외관을 결정하게 두고, 필요할 때만 scroll edge effect로 구분한다.
- **Toolbar를 숨길 때는 맥락에 맞게 하고, 다시 꺼낼 확실한 방법을 준다.**

### Tab bar
- 1장 참고. **iPhone에서는 화면 하단 Liquid Glass 위에 떠 있다.** 액세서리(예: 미니 플레이어)가 붙어 있으면 스크롤 시 최소화될 수 있다. 콘텐츠가 화려하면 탭 라벨은 단색으로 두거나, 콘텐츠와 충분히 구분되는 accent color를 고른다.

### Sheet
- **한 번에 하나만 띄운다.** 시트에서 다른 시트가 필요하면 먼저 닫고 연다.
- **단일 뷰 시트는 Cancel을 leading, Done을 trailing(상단 Toolbar)에 둔다.**
- **Done만 단독으로 두지 않는다.** Cancel 또는 Back과 짝을 짓고, Cancel·Done·Back 세 개를 동시에 두지도 않는다.
- **Back은 다단계 흐름의 이전 단계로 가는 용도다.** 시트를 닫는 데 쓰지 않는다.
- **Detent를 고른다.** large는 완전히 펼친 높이, medium은 그 절반 정도다. 점진적 공개가 유용하면 medium도 지원하고(예: 공유 시트), 작성 화면처럼 공간이 필요하면 large만 쓴다.
- **크기 조절이 되는 시트에는 grabber를 넣는다.** VoiceOver로도 조절할 수 있다.
- **아래로 스와이프해 닫기를 지원한다.** 저장 안 한 변경이 있으면 Action sheet로 확인한다.

### List (Lists and tables)
- **텍스트 위주 데이터는 List로 보여 준다.** 크기가 제각각인 항목이나 이미지가 많으면 Collection을 검토한다.
- **선택 피드백을 준다.** 계층 이동형 목록은 선택 행을 계속 하이라이트하고, 옵션 목록은 잠깐 하이라이트한 뒤 체크마크를 표시한다.
- **행 텍스트는 간결하게 쓴다.** 긴 내용은 제목만 보여 주고 상세 화면으로 넘긴다.
- **하위 화면으로 들어가는 행에는 disclosure indicator를 쓴다.** info(detail disclosure) 버튼은 추가 정보 표시용이지 이동용이 아니다.
- **trailing에 컨트롤이 있는 목록에는 인덱스(알파벳 바)를 달지 않는다.** 서로 오작동을 일으킨다.
- **그룹으로 나뉜 데이터는 grouped 스타일(헤더·푸터·여백)로 보여 준다.**
- **재정렬은 추가·삭제가 안 되더라도 가능하면 허용한다.** iPhone에서 항목을 선택하려면 편집 모드에 들어가야 한다.
- **스와이프 액션:** HIG의 swipe-actions 페이지는 현재 없다(404). 남은 근거는 두 가지다. Gestures 표에서 swipe의 역할이 "액션·컨트롤 노출, 뷰 닫기, 스크롤"이라는 것, Accessibility에서 제스처 기능에는 화면상 버튼 같은 대안을 함께 줘야 한다는 것이다. 스와이프로 하는 동작은 Context menu나 편집 모드에서도 할 수 있게 한다.

### Search field
- **placeholder로 검색 범위·대상을 알려 준다.**
- **가능하면 입력하는 즉시 검색한다.** 입력 전에는 최근 검색, 입력 중에는 추천어를 보여 준다.
- **가장 관련 높은 결과를 먼저 보여 주고 필요하면 분류한다.** 결과 필터는 Scope bar로.
- **범위는 넓게 시작하고 사용자가 좁히게 한다.** 자주 쓰는 필터는 token으로 만들고 추천어와 함께 보여 준다.
- **iPhone 배치:** 검색 비중이 크면 하단 Toolbar, 하단 콘텐츠를 가리면 안 될 때는 상단(Navigation bar 버튼), 특정 목록만 거를 때는 그 목록 위 인라인(스크롤 시 상단 고정 고려).
- **검색 기록을 보여 준다면 지우는 방법도 준다.**

### Button
- **히트 영역은 최소 44x44pt.**
- **커스텀 버튼에도 눌림 상태를 반드시 만든다.**
- **prominent 버튼은 화면당 1~2개로 제한한다.** 선택지 간 우선순위는 크기가 아니라 스타일로 구분한다.
- **라벨은 동사로 시작하는 짧은 텍스트나 익숙한 심볼로 쓴다.**
- **역할(role)을 지정한다.** primary는 가장 가능성 높은 선택이고, 파괴적 동작에는 primary를 주지 않는다. destructive는 시스템 빨강이다.
- **바로 끝나지 않는 동작은 버튼 안에 activity indicator를 표시한다.** 라벨도 바꿀 수 있다(예: "Checkout" → "Checking out…").

### Alert
- 3장 참고. **제목, 선택적 본문, 버튼 최대 3개로 구성한다.**
- **제목은 무엇이 왜 일어났는지 구체적으로, 두 줄을 넘지 않게 쓴다.** "Error" 같은 무의미한 제목은 피한다.
- **버튼은 결과를 말하는 한두 단어 동사로 쓴다.** OK는 순수 정보 Alert에서만, 취소는 항상 "Cancel".
- **기본(default) 버튼은 행의 trailing 또는 스택 맨 위에 두고, Cancel은 leading 또는 맨 아래에 둔다.**
- **destructive 스타일은 사용자가 의도하지 않은 파괴적 동작에만 붙인다.** 파괴적 동작이 있으면 Cancel을 반드시 넣고, Cancel을 default로 만들지 않는다.
- **스크롤되는 Alert은 피한다.** 큰 글자 크기에서 스크롤이 생기지 않게 문구를 짧게 쓴다.
- **텍스트 필드는 문제 해결에 입력이 꼭 필요할 때만 넣는다**(예: 비밀번호).

### Action sheet
- **사용자가 의도적으로 시작한 행동에 딸린 선택지에 쓴다.** 예기치 않은 문제를 알리는 것은 Alert의 몫이다.
- **메뉴 대신 Action sheet를 쓴다.** 행동 직후 선택지가 필요할 때가 그렇다(메뉴는 사용자가 직접 열 때).
- **제목은 한 줄, 메시지는 꼭 필요할 때만 쓴다.** 스크롤되지 않게 버튼 수를 줄인다.
- **destructive 버튼은 맨 위, Cancel은 맨 아래에 둔다.**

### Context menu
- **현재 항목에 가장 자주 필요한 명령만, 적은 수로 담는다.** 구분선 그룹은 3개 정도까지.
- **Context menu에 있는 기능은 메인 UI에도 있어야 한다.** Context menu는 숨겨져 있어 발견되지 않을 수 있다.
- **앱 전체에서 일관되게 지원한다.** 하위 메뉴는 1단계까지만.
- **쓸 수 없는 항목은 흐리게 하지 말고 숨긴다.**
- **Delete 같은 파괴적 항목은 맨 끝에 두고 destructive로 표시한다.**
- **같은 항목에 Context menu와 Edit menu를 둘 다 붙이지 않는다.**
- **미리보기(preview)는 대상을 확인시켜 주는 축약 콘텐츠로 보여 준다.**

### Menu (Pull-down 등 일반)
- **라벨은 동사구로 짧게 쓴다.** 추가 입력이 필요한 항목은 말줄임표(…)를 붙인다.
- **중요한 항목을 위에 두고 관련 항목끼리 묶는다.**
- **하위 메뉴는 1단계까지만, 항목이 5개 정도를 넘으면 메뉴를 분리한다.**
- **아이콘은 그룹 단위로 전부 달거나 전부 뺀다.**
- **iPhone에서는 small/medium 레이아웃을 쓸 수 있다.** small은 상단 4개를 아이콘만으로, medium은 상단 3개를 아이콘+짧은 라벨로 보여 준다. 핵심 액션 3개는 medium으로, Bold·Italic처럼 묶인 동작은 small로.

### Segmented control
- **밀접하게 관련된 선택지나 하위 뷰 전환에 쓴다.**
- **iPhone에서는 세그먼트를 5개 정도까지만 둔다.**
- **한 컨트롤 안에서는 선택형과 액션형을 섞지 않는다.** 텍스트와 이미지도 섞지 않는다.
- **세그먼트 폭은 같게, 라벨은 명사로 쓴다.**

### Toggle
- **두 반대 상태(켜기/끄기)에만 쓴다.**
- **switch 스타일은 List 행 안에서만 쓴다.** 행 내용이 맥락이 되므로 별도 라벨이 필요 없다.
- **List 밖에서는 상태를 배경 변화로 보여 주는 토글형 버튼을 쓴다.**
- **상태 차이를 색만으로 표현하지 않는다.** 기본 초록을 바꾸려면 꺼진 상태와 대비가 충분한 색을 고른다.

### Picker
- **중~장 길이 목록에 쓴다.** 짧으면 Pull-down button, 아주 길면 List.
- **값은 예측 가능한 순서로 둔다**(예: 알파벳순).
- **화면을 전환하지 말고 편집 중인 필드 근처에 띄운다.**
- **분 단위는 60을 나누어떨어지는 간격으로 줄일 수 있다**(예: 0/15/30/45).
- **공간이 좁으면 compact date picker를 쓴다.** 버튼을 누르면 모달로 열린다.

### Text field
- **이름·이메일처럼 짧은 입력에 쓴다.** 긴 텍스트는 Text view.
- **placeholder는 입력하면 사라지므로 별도 라벨을 함께 두는 것을 고려한다.**
- **민감 정보는 secure text field로 받고, 입력 내용에 맞는 키보드 타입을 띄우고, trailing에 Clear 버튼을 둔다.**
- **검증 시점을 구분한다.** 이메일은 다음 필드로 넘어갈 때, 아이디·비밀번호는 넘어가기 전에. 오류는 필드 바로 옆에 표시한다.

### Label / Text view
- **편집하지 않는 짧은 텍스트는 Label로 쓰고, 오류 메시지처럼 쓸모 있는 텍스트는 선택·복사 가능하게 한다.** 중요도는 시스템 label 색 4단계로 표현한다.

### Scroll view
- **같은 방향의 스크롤 뷰를 중첩하지 않는다.** 가로 안에 세로, 세로 안에 가로는 괜찮다.
- **더 있는 콘텐츠는 가장자리에 걸치게 보여 줘서 스크롤 가능함을 드러낸다.**
- **페이지 단위 스크롤에는 page control을 쓰고, 스크롤 인디케이터는 함께 보이지 않게 한다.**
- **scroll edge effect는 떠 있는 컨트롤 뒤에서만, 뷰당 하나만 쓴다.**

https://developer.apple.com/design/human-interface-guidelines/toolbars · https://developer.apple.com/design/human-interface-guidelines/tab-bars · https://developer.apple.com/design/human-interface-guidelines/sheets · https://developer.apple.com/design/human-interface-guidelines/lists-and-tables · https://developer.apple.com/design/human-interface-guidelines/gestures · https://developer.apple.com/design/human-interface-guidelines/search-fields · https://developer.apple.com/design/human-interface-guidelines/searching · https://developer.apple.com/design/human-interface-guidelines/buttons · https://developer.apple.com/design/human-interface-guidelines/alerts · https://developer.apple.com/design/human-interface-guidelines/action-sheets · https://developer.apple.com/design/human-interface-guidelines/context-menus · https://developer.apple.com/design/human-interface-guidelines/edit-menus · https://developer.apple.com/design/human-interface-guidelines/menus · https://developer.apple.com/design/human-interface-guidelines/segmented-controls · https://developer.apple.com/design/human-interface-guidelines/toggles · https://developer.apple.com/design/human-interface-guidelines/pickers · https://developer.apple.com/design/human-interface-guidelines/text-fields · https://developer.apple.com/design/human-interface-guidelines/labels · https://developer.apple.com/design/human-interface-guidelines/scroll-views

---

## 3. 상태: 로딩 · 빈 화면 · 오류 · 피드백

### 로딩
- **무엇이든 최대한 빨리 보여 준다.** 아무것도 없으면 고장으로 오해한다. placeholder 텍스트·그래픽을 먼저 그리고 콘텐츠가 오면 교체한다.
- **로딩 중에도 다른 기능은 쓸 수 있게 한다**(백그라운드 로딩).
- **걸리는 시간을 알면 determinate(진행 바·원형 채움), 모르면 indeterminate(spinner)를 쓴다.** 가능하면 determinate를 쓴다.
- **진행률은 정직하게 표시한다.** 90%까지 금방 가고 마지막 10%가 오래 걸리는 식은 피한다.
- **멈추면 멈춘 것처럼 보이므로 인디케이터를 계속 움직이게 한다.** 실제로 멈췄으면 원인과 할 수 있는 일을 알려 준다.
- **indeterminate에서 소요 시간을 알게 되면 determinate로 바꿀 수 있다.** 단 spinner ↔ bar로 형태를 바꾸지는 않는다.
- **설명 문구는 구체적으로 쓰고("Loading" 같은 뻔한 말 금지), 인디케이터 위치는 일관되게 둔다.**
- **안전하게 중단할 수 있으면 Cancel을, 중단 시 손실이 있으면 Pause도 함께 준다.** 취소로 진행분을 잃는다면 Alert으로 확인받는다.
- **당겨서 새로고침(refresh control)을 지원하되 자동 갱신도 한다.** refresh 제목은 "당기세요" 같은 안내 말고 마지막 갱신 시각처럼 유용한 정보로 쓴다.
- **런치 화면은 첫 화면과 거의 같게 만든다.** 텍스트·로고·광고는 넣지 않는다. 재실행하면 이전 상태(스크롤 위치 포함)를 복원한다.

### 빈 화면 (Empty state)
- **다음 행동을 분명히 안내한다.** 가능하면 그 행동을 바로 하는 버튼이나 링크를 둔다.
- **빈 상태는 일시적이므로 중요한 정보를 여기에만 두지 않는다.**
- **탭 섹션이 비었다고 탭을 숨기지 말고 화면 안에서 이유를 설명한다.**

### 오류
- **오류는 문제 지점 가까이에 표시한다.** 탓하지 말고, 고치는 방법을 말한다(나쁜 예: "비밀번호가 너무 짧음", 좋은 예: "8자 이상으로 정하세요"). "앗!" 같은 감탄사는 뺀다.
- **명령을 실행할 수 없으면 그 사실과 이유를 알려 준다.**
- **시작 시점의 문제(예: 오프라인)는 Alert 대신 캐시·placeholder 데이터와 눈에 덜 띄는 상태 라벨로 알린다.**
- **제스처가 동작하지 않는 상황이면 그렇다는 신호를 준다.**

### Alert을 쓸까, 인라인으로 할까
- **Alert은 중요하고 가급적 조치 가능한 정보에만 쓴다.** 정보만 전달하는 경우라면 화면 안 인디케이터 등 맥락 속 표시로 대체한다.
- **흔하고 되돌릴 수 있는 삭제에는 Alert을 띄우지 않는다.** 드물고 되돌릴 수 없는 파괴적 동작에는 띄운다.
- **앱 실행 직후에는 Alert을 띄우지 않는다.**
- **선택지가 2개 이상 필요한 확인은 Action sheet로 한다**(예: 초안 삭제/저장).
- **상태 정보는 관련 항목 근처에 수동적으로(passive) 둔다**(예: Toolbar의 "방금 업데이트됨").
- **성공 확인은 중요한 작업에만 보여 준다.** 사람들은 성공을 기대하므로 실패만 알면 된다.
- **피드백은 색·텍스트·소리·햅틱을 함께 쓴다.** 무음이거나 화면을 보지 않을 때, VoiceOver를 쓸 때도 전달되게.

### 햅틱
- **시스템 햅틱 패턴은 문서화된 의미대로만, 다른 피드백의 보조로 가볍게 쓴다**(notification은 작업 결과, impact는 충돌·스냅, selection은 값 변경 중). 끌 수 있어야 하고, 꺼져도 앱 사용에 지장이 없어야 한다.

### 권한 요청
- **기능을 실제로 쓰려는 순간에 요청한다.** 실행 시점 요청은 그 데이터가 없으면 앱이 작동하지 않을 때만 한다.
- **목적 문구는 "무엇을 왜"를 담은 능동형 완결 문장으로 쓴다.**
- **사전 안내 화면에는 시스템 알림을 여는 버튼 하나만 둔다.** 닫기·취소 같은 다른 출구를 두지 않고, 버튼 이름을 "Allow"처럼 시스템 버튼과 헷갈리게 짓지 않는다.

https://developer.apple.com/design/human-interface-guidelines/loading · https://developer.apple.com/design/human-interface-guidelines/progress-indicators · https://developer.apple.com/design/human-interface-guidelines/feedback · https://developer.apple.com/design/human-interface-guidelines/alerts · https://developer.apple.com/design/human-interface-guidelines/action-sheets · https://developer.apple.com/design/human-interface-guidelines/writing · https://developer.apple.com/design/human-interface-guidelines/launching · https://developer.apple.com/design/human-interface-guidelines/onboarding · https://developer.apple.com/design/human-interface-guidelines/playing-haptics · https://developer.apple.com/design/human-interface-guidelines/privacy

---

## 4. 전환 · 모션

- **모션은 목적이 있을 때만 넣는다.** 과하면 산만하고 신체적 불편까지 준다.
- **모션만으로 중요한 정보를 전달하지 않는다.** 햅틱·소리로 보완한다.
- **제스처 방향과 맞는 사실적인 움직임을 쓴다.** 위에서 내려온 뷰를 옆으로 밀어 닫게 하지 않는다.
- **피드백 애니메이션은 짧고 정확하게 만든다.**
- **자주 반복되는 상호작용에는 커스텀 모션을 붙이지 않는다.** 표준 요소에는 시스템이 이미 미세한 애니메이션을 준다.
- **애니메이션이 끝날 때까지 기다리게 하지 않는다.** 중간에 취소하거나 조작할 수 있어야 한다.
- **SF Symbols 애니메이션은 의미가 분명할 때만 쓴다**(무언가 일어났다는 시각적 확인).
- **Context menu preview는 펼쳐지는 동안 모서리 모양이 바뀌지 않게 클리핑을 맞춘다.**
- **전환 방식은 2장의 표를 따른다.** 계층 이동은 push, 짧은 하위 작업은 Sheet(스와이프 다운으로 닫힘), 몰입·다단계 작업은 Full-screen 모달.
- **Reduce Motion이 켜지면 자동·반복 애니메이션(확대·축소, 주변부 움직임)을 줄인다.** 방법: 스프링을 단단하게 해 바운스 감소, 애니메이션을 손가락 움직임에 직접 연동, z축 깊이 애니메이션 회피, x·y·z축 이동 전환은 페이드로 대체, 블러 인·아웃 회피.
- **빠르게 깜빡이거나 움직이는 효과를 조심한다**(어지럼증, 발작 위험).

https://developer.apple.com/design/human-interface-guidelines/motion · https://developer.apple.com/design/human-interface-guidelines/modality · https://developer.apple.com/design/human-interface-guidelines/accessibility · https://developer.apple.com/design/human-interface-guidelines/sf-symbols · https://developer.apple.com/design/human-interface-guidelines/context-menus

---

## 5. 레이아웃 · 타이포 · 색

### 레이아웃
- **safe area를 지킨다.** Dynamic Island, 상태 바, Toolbar, Tab bar가 콘텐츠·컨트롤을 가리지 않게 한다. 시스템 margin과 layout guide를 따른다. HIG 본문에 iPhone margin 수치는 따로 없다.
- **중요한 것을 위쪽·leading 쪽에 둔다.** RTL 언어는 표준 컴포넌트를 써서 자동 대응한다.
- **정렬로 관계를 보여 주고, 들여쓰기로 종속을 표현한다.** 여백·컨테이너·구분선으로 그룹을 짓는다.
- **점진적 공개를 쓴다.** 처음에 다 보여 주지 말고 메뉴·하위 뷰·스크롤 섹션으로 나눈다.
- **컨트롤과 콘텐츠를 구분한다.** 컨트롤은 Liquid Glass 레이어에 둔다. 컨트롤 밑에 불투명 배경을 깔지 말고 scroll edge effect로 띄운다. 전체 화면 배경은 Toolbar·Tab bar 밑까지 확장한다.
- **Liquid Glass는 콘텐츠 레이어에 쓰지 않는다.** 콘텐츠 레이어에는 standard material(ultra-thin, thin, regular, thick)을 쓴다. clear 변형 아래 밝은 콘텐츠가 있으면 35% 불투명도의 어두운 dimming layer를 고려한다.
- **기기 종류나 방향이 아니라 size class(compact/regular)로 레이아웃을 정한다.** 공간이 달라져도 기능은 그대로 유지한다.
- **가장 큰 글자 크기와 가장 작은 화면에서 먼저 테스트한다.**

### 타이포그래피
- **iOS 기본 본문 17pt, 최소 11pt.** 얇은 커스텀 폰트는 이보다 크게 쓴다.
- **Ultralight/Thin/Light 굵기는 피하고 Regular/Medium/Semibold/Bold를 쓴다.**
- **시스템 폰트는 SF Pro(serif가 필요하면 New York)를 쓴다.** 서체 수는 최소화한다.
- **시스템 text style(body, headline 등)을 써서 위계를 만든다.** Dynamic Type을 자동 지원한다. 강조는 bold 등 symbolic trait로 한다.
- **3줄 이상 텍스트에는 좁은 행간(tight leading)을 쓰지 않는다.**
- **Dynamic Type 대응:**
  - 모든 크기에서 레이아웃이 깨지지 않게 한다(손쉬운 사용의 더 큰 텍스트 포함)
  - 큰 크기에서는 가로 배치를 세로로 쌓는다. 행 높이를 늘리고 다단 컬럼 수를 줄인다
  - 잘림(truncation)을 최소화한다. 표준 최대 크기에서 보이던 정보량을 접근성 최대 크기에서도 유지한다
  - 의미 있는 아이콘도 글자 크기에 맞춰 키운다(SF Symbols는 자동)
  - 큰 크기에서도 주요 요소는 위쪽에 두어 위계를 유지한다
  - 모든 글자를 키울 필요는 없다. 사용자가 읽으려는 콘텐츠를 우선한다(예: 탭 제목은 그대로 둬도 됨)
- **커스텀 폰트도 Dynamic Type과 Bold Text에 반응하게 구현한다.**

### 색
- **같은 색에 다른 의미를 주지 않는다.** 예: 상호작용 가능을 뜻하는 브랜드 색을 일반 텍스트에 쓰지 않는다.
- **시스템 색과 semantic(dynamic) 색을 우선 쓴다.** 색 값을 하드코딩하지 않는다.
  - 배경: system 세트(primary/secondary/tertiary). grouped List에는 grouped 배경 세트를 쓴다. primary는 전체 화면, secondary는 그 안의 그룹, tertiary는 그 안의 하위 그룹.
  - 전경: label / secondary label / tertiary label / quaternary label, placeholder text, separator, opaque separator, link.
  - semantic 의미를 바꿔 쓰지 않는다(예: separator 색을 텍스트에 쓰지 않는다).
- **커스텀 색은 light/dark 변형과 각각의 increased contrast 변형을 모두 정의한다.**
- **Liquid Glass 위 색은 아껴 쓴다.** 주요 액션 강조는 심볼이 아니라 배경에 accent color를 칠한다. 여러 컨트롤 배경에 색을 넣지 않는다.
- **색의 문화적 의미를 고려한다**(빨강 = 위험이 보편적이지 않음).

### Dark Mode
- **앱 자체 외관 설정을 만들지 말고 시스템 설정을 따른다.** 몰입형 미디어 앱처럼 드문 경우만 항상 어둡게 한다.
- **두 모드 모두에서 보기 좋게 만든다.** 실행 중에 Auto 전환이 일어날 수 있다.
- **dark 색은 light 색의 단순 반전이 아니다.** semantic 색을 쓴다.
- **대비는 최소 4.5:1, 커스텀 전경/배경은(특히 작은 글자) 7:1을 목표로 한다.**
- **iPhone dark 배경은 base(뒤)와 elevated(앞, 시트·팝오버)로 나뉜다.** 시스템 배경을 써야 이 구분이 자동으로 된다.
- **흰 배경 이미지는 살짝 어둡게 한다.** 아이콘은 필요하면 light/dark를 따로 만든다.
- **Increase Contrast, Reduce Transparency와 조합해서도 확인한다.**

https://developer.apple.com/design/human-interface-guidelines/layout · https://developer.apple.com/design/human-interface-guidelines/materials · https://developer.apple.com/design/human-interface-guidelines/scroll-views · https://developer.apple.com/design/human-interface-guidelines/typography · https://developer.apple.com/design/human-interface-guidelines/color · https://developer.apple.com/design/human-interface-guidelines/dark-mode

---

## 6. 접근성 체크리스트

화면마다 아래 항목을 확인한다.

- [ ] **히트 타깃:** iOS 기본 44x44pt, 최소 28x28pt. 간격도 크기만큼 중요하다. 테두리(bezel)가 있는 요소는 주변 약 12pt, 없는 요소는 보이는 가장자리 기준 약 24pt 여백.
- [ ] **대비(WCAG AA):** 17pt 이하 텍스트 4.5:1, 18pt 이상 또는 Bold 3:1. light와 dark 모두에서 확인한다. 기본 대비가 부족하면 Increase Contrast가 켜졌을 때라도 고대비 색을 제공한다.
- [ ] **색만으로 구분하지 않는다:** 상태·기능 차이는 모양·아이콘·텍스트로도 보여 준다(Toggle 상태, 오류, 차트 등).
- [ ] **스크린 리더(VoiceOver) 라벨:**
  - 모든 주요 요소, 특히 아이콘만 있는 버튼과 커스텀 요소에 기능을 설명하는 라벨을 단다
  - 의미 있는 이미지는 설명하고, 장식 이미지는 VoiceOver에서 제외한다
  - 차트·인포그래픽에는 요약 설명을 주고, 상호작용도 VoiceOver로 할 수 있게 한다
  - 화면마다 고유하고 간결한 제목을 붙이고, 섹션 헤딩을 정확히 단다
  - 시각적으로만 드러나는 그룹·순서 관계(이미지+캡션 등)를 묶어서 알려 준다
  - 화면 내용이나 레이아웃이 바뀌면 VoiceOver에 알린다
  - 커스텀 SF Symbol에는 대체 텍스트를 넣는다
- [ ] **큰 글자:** 최소 200%까지 확대를 지원한다(Dynamic Type). 잘림·겹침이 없어야 하고, 필요하면 세로로 쌓는 레이아웃으로 바꾼다.
- [ ] **Reduce Motion:** 4장의 대체 방식을 적용한다. 깜빡임·빠른 움직임을 자제한다. 영상이 있으면 Dim Flashing Lights에 대응한다.
- [ ] **제스처 대안:** 스와이프·커스텀 제스처로 하는 일은 화면상 버튼으로도 할 수 있어야 한다. 복잡한 다중 손가락 제스처는 피한다.
- [ ] **시간 제한 UI 최소화:** 타이머로 자동으로 사라지는 뷰는 피하고 명시적 동작으로 닫게 한다.
- [ ] **미디어 제어:** 자동 재생에는 재생/정지 컨트롤을 준다. 오디오 정보에는 자막·텍스트를, 오디오 신호에는 햅틱·시각 신호를 함께 준다.
- [ ] **Voice Control / Switch Control / Full Keyboard Access:** 요소 라벨이 정확해야 음성으로 조작할 수 있다. 시스템 단축키를 가로채지 않는다.
- [ ] **언어:** 쉬운 말을 쓰고 전문 용어는 정의한다. 관용구·유머·불필요한 성별 표현을 피한다. 사용자를 "사용자"가 아니라 "you"로 직접 부른다.
- [ ] **되돌리기 어려운 동작:** 확인 단계를 둔다(Alert/Action sheet). Assistive Access에서는 두 번 확인한다.

https://developer.apple.com/design/human-interface-guidelines/accessibility · https://developer.apple.com/design/human-interface-guidelines/voiceover · https://developer.apple.com/design/human-interface-guidelines/typography · https://developer.apple.com/design/human-interface-guidelines/color · https://developer.apple.com/design/human-interface-guidelines/toggles · https://developer.apple.com/design/human-interface-guidelines/gestures · https://developer.apple.com/design/human-interface-guidelines/inclusion · https://developer.apple.com/design/human-interface-guidelines/writing
