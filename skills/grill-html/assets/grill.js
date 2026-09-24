// grill.js: 라운드 페이지의 답 수집 장치. 페이지 내용은 건드리지 않고 아래만 한다.
// - 각 <fieldset data-q> 끝에 "기타" 칸을 덧붙인다. 선택지를 고르고 덧붙여 써도, 고르지 않고 생각만 써도 답이 된다.
// - 고른 선택지를 다시 누르면 선택이 풀린다.
// - 고를 때마다 답을 서버(/answers/<round>)와 localStorage 에 저장하고, 열 때 서버 → localStorage 순으로 복원한다.
// - 하단 고정 바(진행률, 남은 질문 추천안으로, 초기화, 답변 완료, 저장 상태)와 요약 미리보기를 붙인다.
(() => {
  const round = document.body.dataset.round;
  if (!/^r\d{1,3}$/.test(round || "")) { console.error("grill.js: <body data-round=\"r1\"> 이 필요하다"); return; }
  const served = location.protocol.startsWith("http");
  const storeKey = `grill:${location.pathname}:${round}`;
  const sets = [...document.querySelectorAll("fieldset[data-q]")];
  let completed = false;
  let touched = false;   // 복원이 끝나기 전에 고른 답을 덮어쓰지 않게
  let saveState = served ? "저장 안 됨" : "서버 없이 열림: 답이 저장되지 않는다";

  const el = (tag, attrs = {}, text) => {
    const n = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs)) n.setAttribute(k, v);
    if (text != null) n.textContent = text;
    return n;
  };

  // 1. 기타 칸 덧붙이기
  for (const fs of sets) {
    const q = fs.dataset.q;
    const box = el("label", { class: "opinion" });
    const area = el("textarea", { rows: "3", placeholder: "고른 선택지에 덧붙일 말, 또는 선택지가 맞지 않을 때 내 생각을 자유롭게", "aria-label": `${q} 기타` });
    box.append(el("span", { class: "choice-key" }, "기타"), area);
    fs.append(box);
    area.addEventListener("input", () => { touched = true; mark(fs); save(); });
    fs.addEventListener("change", () => onChange(fs));
    // 고른 선택지를 다시 누르면 선택을 푼다 (radio 는 기본으로 풀리지 않는다)
    fs.querySelectorAll("input[type=radio]").forEach((r) => {
      let was = false;
      r.closest("label").addEventListener("pointerdown", () => { was = r.checked; });
      r.closest("label").addEventListener("click", (e) => {
        if (e.target !== r) return;              // label 클릭은 radio 클릭으로 한 번 더 들어온다
        if (was) { r.checked = false; was = false; onChange(fs); }
      });
    });
  }

  // 2. 하단 바와 요약
  const bar = el("div", { class: "grill-bar", role: "region", "aria-label": "답변 진행" });
  const progress = el("button", { type: "button", class: "grill-progress" });
  const fillRec = el("button", { type: "button" }, "남은 질문 추천안으로");
  const reset = el("button", { type: "button" }, "초기화");
  const done = el("button", { type: "button", class: "primary" }, "답변 완료");
  const status = el("span", { class: "grill-status", "aria-live": "polite" });
  bar.append(progress, fillRec, reset, done, status);
  const summary = el("section", { class: "grill-summary" });
  const pre = el("pre");
  const copy = el("button", { type: "button" }, "요약 복사");
  summary.append(el("h2", {}, "에이전트에게 전달될 요약"), pre, copy);
  (document.querySelector("main") || document.body).append(summary);
  document.body.append(bar);
  if (!served) document.body.prepend(el("p", { class: "grill-warn", role: "alert" },
    "이 페이지는 서버 없이 열렸다. 답이 에이전트에게 저장되지 않으니, 다 고른 뒤 맨 아래 \"요약 복사\" 로 채팅에 붙여 넣어라."));

  const picked = (fs) => fs.querySelector("input[type=radio]:checked");
  const opinion = (fs) => fs.querySelector(".opinion textarea").value.trim();
  const answered = (fs) => !!picked(fs) || !!opinion(fs);

  function collect() {
    const answers = {};
    for (const fs of sets) {
      const r = picked(fs), op = opinion(fs);
      if (!r && !op) continue;
      const a = {};
      if (r) {
        a.key = r.value; a.short = r.dataset.short || r.value;
        if (fs.querySelector("input[data-rec]")) a.recommended = r.hasAttribute("data-rec");   // 추천이 없는 질문은 recommended 를 두지 않는다
      }
      if (op) a.opinion = op;
      answers[fs.dataset.q] = a;
    }
    return { round, completed, updatedAt: new Date().toISOString(), answers };
  }

  function summaryText(doc) {
    return sets.map((fs) => {
      const a = doc.answers[fs.dataset.q];
      if (!a) return `${fs.dataset.q} = (미답)`;
      const choice = a.key ? `${a.key}${a.recommended ? " (추천)" : ""} · ${a.short}` : "선택 없음";
      return `${fs.dataset.q} = ${choice}${a.opinion ? ` / 기타: ${a.opinion}` : ""}`;
    }).join("\n");
  }

  function render(doc) {
    const n = Object.keys(doc.answers).length;
    progress.textContent = `${n} / ${sets.length}`;
    progress.title = n < sets.length ? "누르면 첫 미답 질문으로 간다" : "모두 답했다";
    done.textContent = completed ? "완료됨" : "답변 완료";
    status.textContent = saveState;
    pre.textContent = summaryText(doc);
    for (const fs of sets) fs.classList.toggle("answered", answered(fs));
  }

  async function save() {
    const doc = collect();
    try { localStorage.setItem(storeKey, JSON.stringify(doc)); } catch (_) { /* 저장소 막힘: 서버 저장으로 충분 */ }
    if (served) {
      try {
        const res = await fetch(`/answers/${round}`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(doc) });
        saveState = res.ok ? `저장됨 ${new Date().toLocaleTimeString()}` : `저장 실패 (${res.status})`;
      } catch (_) { saveState = "저장 실패: 서버에 연결할 수 없다"; }
    }
    if (completed) saveState += " · 완료 뒤 고친 답은 채팅으로도 알려라";
    render(doc);
  }

  // 고른 선택지와 내용이 있는 기타 칸 강조
  function mark(fs) {
    const r = picked(fs);
    fs.querySelector(".opinion").classList.toggle("selected", !!opinion(fs));
    fs.querySelectorAll(".choice").forEach((c) => c.classList.toggle("selected", !!r && c.contains(r)));
  }

  function onChange(fs) {
    touched = true;
    mark(fs);
    save();
  }

  function apply(doc) {
    completed = doc.completed === true;
    for (const fs of sets) {
      const a = (doc.answers || {})[fs.dataset.q];
      if (!a) continue;
      const r = a.key ? fs.querySelector(`input[type=radio][value="${CSS.escape(a.key)}"]`) : null;
      if (r) r.checked = true;
      if (a.opinion) fs.querySelector(".opinion textarea").value = a.opinion;
      mark(fs);
    }
  }

  progress.addEventListener("click", () => {
    const first = sets.find((fs) => !answered(fs));
    if (first) { first.scrollIntoView({ block: "center" }); first.querySelector("input")?.focus({ preventScroll: true }); }
  });
  fillRec.addEventListener("click", () => {
    for (const fs of sets) {
      const rec = fs.querySelector("input[type=radio][data-rec]");
      if (!answered(fs) && rec) { rec.checked = true; onChange(fs); }
    }
    save();
  });
  reset.addEventListener("click", () => {
    if (reset.dataset.armed !== "1") { reset.dataset.armed = "1"; reset.textContent = "한 번 더 누르면 초기화"; setTimeout(() => { reset.dataset.armed = ""; reset.textContent = "초기화"; }, 3000); return; }
    reset.dataset.armed = ""; reset.textContent = "초기화";
    completed = false;
    for (const fs of sets) {
      fs.querySelectorAll("input[type=radio]").forEach((r) => (r.checked = false));
      fs.querySelector(".opinion textarea").value = "";
      mark(fs);
    }
    save();
  });
  done.addEventListener("click", () => {
    const missing = sets.filter((fs) => !answered(fs)).map((fs) => fs.dataset.q);
    if (missing.length) { saveState = `미답: ${missing.join(", ")}`; render(collect()); progress.click(); return; }
    completed = true;
    save();
  });
  copy.addEventListener("click", async () => {
    try { await navigator.clipboard.writeText(pre.textContent); copy.textContent = "복사됨"; }
    catch (_) { getSelection().selectAllChildren(pre); copy.textContent = "선택됨: ⌘C 로 복사"; }
    setTimeout(() => (copy.textContent = "요약 복사"), 2000);
  });

  // 3. 복원: 서버 → localStorage
  (async () => {
    // 서버가 답하면 서버가 기준이다 (null 이면 새 라운드). localStorage 는 서버에 닿지 못할 때만 쓴다.
    let doc = null, reached = false;
    if (served) {
      try { const res = await fetch(`/answers/${round}`); if (res.ok) { doc = await res.json(); reached = true; } } catch (_) { /* 서버 없음 */ }
    }
    if (!reached) { try { doc = JSON.parse(localStorage.getItem(storeKey) || "null"); } catch (_) { doc = null; } }
    if (doc && !touched) { apply(doc); if (served) saveState = "불러옴"; }
    render(collect());
  })();
})();
