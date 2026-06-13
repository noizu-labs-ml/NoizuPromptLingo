/**
 * log.js - History tab (frame events) and Notifications tab
 */

import { el } from "./render.js";

const MAX_ROWS = 500;

let ctx = null;
let historyRows = [];
let notifRows = [];
let autoScroll = true;
let minLevel = "debug";
let domInited = false;

const LEVELS = ["debug", "info", "notice", "warning", "error", "critical", "alert", "emergency"];

export function init(context) {
  ctx = context;

  if (!domInited) {
    domInited = true;
    initHistory();
    initNotifications();
  }
}

function initHistory() {
  const panel = document.getElementById("tab-history");

  // Controls
  const controls = el("div", { class: "log-controls" }, [
    el("button", { class: "btn-sm", onClick: clearHistory }, "Clear"),
    el("label", { style: { display: "flex", alignItems: "center", gap: "4px", fontSize: "12px", fontWeight: "400" } }, [
      (() => {
        const cb = el("input", { type: "checkbox", checked: true });
        cb.addEventListener("change", () => { autoScroll = cb.checked; });
        return cb;
      })(),
      "Auto-scroll"
    ])
  ]);
  panel.appendChild(controls);

  const logContainer = el("div", {
    id: "history-log",
    class: "scroll-container",
    style: { maxHeight: "calc(100vh - 140px)" }
  });
  panel.appendChild(logContainer);

  // Listen for frame events
  ctx.events.on("frame", (data) => {
    addHistoryRow(data);
  });

  // Insert divider on session change (preserve history)
  ctx.events.on("session_changed", () => {
    const container = document.getElementById("history-log");
    if (container) {
      const divider = el("div", { class: "session-divider" }, "— target switched —");
      container.appendChild(divider);
      historyRows.push(divider);
      if (autoScroll) container.scrollTop = container.scrollHeight;
    }
  });
}

function addHistoryRow(data) {
  const container = document.getElementById("history-log");
  if (!container) return;

  const dir = data.dir || "rx";
  const message = data.message;
  const dirClass = dir === "tx" ? "log-dir-tx" : "log-dir-rx";
  const dirLabel = dir === "tx" ? "TX" : "RX";

  // Build summary
  let summary = "";
  if (message?.truncated) {
    summary = `[truncated] size=${message.size} preview=${message.preview || ""}`;
  } else if (message?.raw) {
    summary = String(message.raw).slice(0, 120);
  } else if (message) {
    if (message.method) {
      summary = message.method;
      if (message.id !== undefined) summary += ` (id: ${message.id})`;
    } else if (message.result !== undefined) {
      summary = `result (id: ${message.id})`;
    } else if (message.error) {
      summary = `error: ${message.error.message || JSON.stringify(message.error)} (id: ${message.id})`;
    } else {
      summary = JSON.stringify(message).slice(0, 120);
    }
  }

  const row = el("div", { class: "log-row" });
  const dirBadge = el("span", { class: `log-dir ${dirClass}` }, dirLabel);
  const summaryEl = el("span", { class: "log-summary" }, summary);

  row.appendChild(dirBadge);
  row.appendChild(summaryEl);

  // Expandable detail
  const detail = el("div", { class: "log-detail" });
  let detailRendered = false;

  row.addEventListener("click", () => {
    if (!detailRendered) {
      const pretty = JSON.stringify(message, null, 2);
      detail.appendChild(el("pre", {}, pretty));
      detailRendered = true;
    }
    detail.classList.toggle("open");
  });

  const wrapper = el("div", {}, [row, detail]);
  container.appendChild(wrapper);
  historyRows.push(wrapper);

  // Cap rows
  while (historyRows.length > MAX_ROWS) {
    const old = historyRows.shift();
    old.remove();
  }

  if (autoScroll) {
    container.scrollTop = container.scrollHeight;
  }
}

function clearHistory() {
  const container = document.getElementById("history-log");
  if (container) container.innerHTML = "";
  historyRows = [];
}

function initNotifications() {
  const panel = document.getElementById("tab-notifications");

  // Controls
  const levelSelect = el("select", { style: { width: "auto" } });
  for (const lvl of LEVELS) {
    levelSelect.appendChild(el("option", { value: lvl, selected: lvl === minLevel }, lvl));
  }
  levelSelect.addEventListener("change", () => {
    minLevel = levelSelect.value;
    filterNotifications();
  });

  const controls = el("div", { class: "log-controls" }, [
    el("button", { class: "btn-sm", onClick: clearNotifications }, "Clear"),
    el("label", { style: { fontSize: "12px", fontWeight: "600" } }, "Min level:"),
    levelSelect
  ]);
  panel.appendChild(controls);

  const notifContainer = el("div", {
    id: "notifications-log",
    class: "scroll-container",
    style: { maxHeight: "calc(100vh - 140px)" }
  });
  panel.appendChild(notifContainer);

  ctx.events.on("notification", (data) => {
    addNotificationRow(data);
  });

  // Insert divider on session change (preserve notification history)
  ctx.events.on("session_changed", () => {
    const container = document.getElementById("notifications-log");
    if (container) {
      const divider = el("div", { class: "session-divider" }, "— target switched —");
      container.appendChild(divider);
      notifRows.push(divider);
    }
  });
}

function addNotificationRow(data) {
  const container = document.getElementById("notifications-log");
  if (!container) return;

  const method = data.method || "";
  const params = data.params || {};

  const row = el("div", { class: "notif-row" });

  if (method === "notifications/message") {
    // Log message with level
    const level = params.level || "info";
    const logger = params.logger || "";
    const logData = params.data;

    row.dataset.level = level;

    const levelBadge = el("span", { class: `badge-pill level-${level}` }, level);
    const loggerSpan = logger ? el("span", { class: "mono", style: { color: "var(--text-muted)", marginLeft: "6px" } }, logger) : null;

    row.appendChild(levelBadge);
    if (loggerSpan) row.appendChild(loggerSpan);

    if (logData !== undefined) {
      const dataStr = typeof logData === "string" ? logData : JSON.stringify(logData, null, 2);
      row.appendChild(el("pre", { style: { marginTop: "4px", fontSize: "11px" } }, dataStr));
    }

    // Apply level filter
    if (!passesLevelFilter(level)) {
      row.style.display = "none";
    }
  } else {
    row.dataset.level = "info";

    row.appendChild(el("span", { class: "badge-pill badge-accent" }, method));

    if (params && Object.keys(params).length > 0) {
      const paramsStr = JSON.stringify(params, null, 2);
      row.appendChild(el("pre", { style: { marginTop: "4px", fontSize: "11px" } }, paramsStr));
    }
  }

  container.appendChild(row);
  notifRows.push(row);
}

function passesLevelFilter(level) {
  return LEVELS.indexOf(level) >= LEVELS.indexOf(minLevel);
}

function filterNotifications() {
  const container = document.getElementById("notifications-log");
  if (!container) return;
  for (const row of container.children) {
    const level = row.dataset.level;
    if (level) {
      row.style.display = passesLevelFilter(level) ? "" : "none";
    }
  }
}

function clearNotifications() {
  const container = document.getElementById("notifications-log");
  if (container) container.innerHTML = "";
  notifRows = [];
}
