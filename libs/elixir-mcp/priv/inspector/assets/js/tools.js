/**
 * tools.js - Tools tab: list, invoke, display results
 */

import { el, renderContent } from "./render.js";
import { buildForm } from "./schema-form.js";

let ctx = null;
let toolsList = [];
const inflight = new Map(); // call_id -> {flightArea, resultArea, progressBar, progressFill, progressMsg}

// session() is a function returning the current session id
function sid() { return ctx?.session(); }

export function init(context) {
  ctx = context;
  const panel = document.getElementById("tab-tools");

  const header = el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "16px" } }, [
    el("h2", {}, "Tools"),
    el("button", { class: "btn-sm", onClick: refreshTools }, "Refresh List")
  ]);
  panel.appendChild(header);

  panel.appendChild(el("div", { id: "tools-list" }));

  // Listen for tool list changes
  ctx.events.on("notification", (data) => {
    if (data.method === "notifications/tools/list_changed") {
      refreshTools();
    }
  });

  // Listen for progress events
  ctx.events.on("progress", (data) => {
    const entry = inflight.get(data.call_id);
    if (!entry) return;

    if (data.params?.total && data.params?.progress !== undefined) {
      const pct = Math.round((data.params.progress / data.params.total) * 100);
      entry.progressFill.style.width = `${pct}%`;
      entry.progressBar.style.display = "";
    }
    if (data.params?.message) {
      entry.progressMsg.textContent = data.params.message;
      entry.progressMsg.style.display = "";
    }
  });

  // Listen for call results
  ctx.events.on("call_result", (data) => {
    const entry = inflight.get(data.call_id);
    if (!entry) return;

    inflight.delete(data.call_id);
    entry.flightArea.innerHTML = "";

    const resultArea = entry.resultArea;
    resultArea.innerHTML = "";

    if (data.ok && data.result) {
      const content = data.result.content || [];
      if (data.result.isError) {
        const errCard = el("div", { class: "card error-border" });
        if (data.error?.message) {
          errCard.appendChild(el("div", { style: { color: "var(--red)", fontWeight: "600", marginBottom: "4px" } }, data.error.message));
        }
        renderContent(content, errCard);
        resultArea.appendChild(errCard);
      } else {
        renderContent(content, resultArea);
      }
      // structuredContent
      if (data.result.structuredContent) {
        const toggle = el("div", { class: "collapsible-toggle", style: { marginTop: "8px" } }, "Structured Content");
        const pre = el("pre", { style: { display: "none" } }, JSON.stringify(data.result.structuredContent, null, 2));
        toggle.addEventListener("click", () => {
          const open = toggle.classList.toggle("open");
          pre.style.display = open ? "" : "none";
        });
        resultArea.appendChild(toggle);
        resultArea.appendChild(pre);
      }
    } else if (data.error) {
      const errDiv = el("div", { class: "card error-border" }, [
        el("div", { style: { color: "var(--red)", fontWeight: "600" } }, data.error.message || "Error"),
        data.error.code ? el("div", { class: "mono", style: { fontSize: "11px", color: "var(--text-muted)" } }, `Code: ${data.error.code}`) : null,
        data.error.data ? el("pre", {}, JSON.stringify(data.error.data, null, 2)) : null
      ]);
      resultArea.appendChild(errDiv);
    }

    entry.runBtn.disabled = false;
  });

  // Reset on session change
  ctx.events.on("session_changed", () => {
    inflight.clear();
    toolsList = [];
    const container = document.getElementById("tools-list");
    if (container) {
      container.innerHTML = "";
      container.appendChild(el("div", {
        class: "session-divider"
      }, "— new session —"));
    }
    refreshTools();
  });
}

async function refreshTools() {
  const session = sid();
  if (!session) return;
  try {
    const data = await ctx.api.apiGet(`/api/session/${session}/tools`);
    toolsList = data.tools || [];
    renderToolsList();
  } catch (err) {
    ctx.api.showToast(`Failed to load tools: ${err.message}`);
  }
}

function renderToolsList() {
  const container = document.getElementById("tools-list");
  if (!container) return;
  container.innerHTML = "";

  for (const tool of toolsList) {
    container.appendChild(buildToolCard(tool));
  }

  if (toolsList.length === 0) {
    container.appendChild(el("div", {
      style: { color: "var(--text-muted)", padding: "20px", textAlign: "center" }
    }, "No tools available"));
  }
}

function buildToolCard(tool) {
  const card = el("div", { class: "card" });

  // Header
  const headerRow = el("div", { class: "card-header" });
  const titlePart = el("div", {}, [
    el("span", { class: "card-title" }, tool.title || tool.name),
    tool.title && tool.title !== tool.name
      ? el("code", { style: { marginLeft: "8px", fontSize: "11px", color: "var(--text-muted)" } }, tool.name)
      : null
  ]);
  const expandIcon = el("span", { style: { fontSize: "12px", color: "var(--text-muted)" } }, "▶");
  headerRow.appendChild(titlePart);
  headerRow.appendChild(expandIcon);
  card.appendChild(headerRow);

  // Body
  const body = el("div", { class: "card-body" });

  if (tool.description) {
    body.appendChild(el("div", { class: "card-desc", style: { marginBottom: "12px" } }, tool.description));
  }

  // Annotations
  if (tool.annotations && typeof tool.annotations === "object") {
    const annots = el("div", { class: "annotations" });
    for (const [key, value] of Object.entries(tool.annotations)) {
      let badgeClass = "badge-pill badge-accent";
      if (key === "destructiveHint" && value) badgeClass = "badge-pill badge-red";
      else if (key === "readOnlyHint" && value) badgeClass = "badge-pill badge-green";
      else if (key === "idempotentHint" && value) badgeClass = "badge-pill badge-blue";
      else if (key === "openWorldHint" && value) badgeClass = "badge-pill badge-yellow";
      const label = typeof value === "boolean" ? key : `${key}: ${value}`;
      annots.appendChild(el("span", { class: badgeClass }, label));
    }
    body.appendChild(annots);
  }

  // Definition (collapsible)
  const defToggle = el("div", { class: "collapsible-toggle", style: { marginTop: "8px" } }, "Definition");
  const defBody = el("div", { style: { display: "none", marginTop: "4px" } });
  const defTable = el("table", { class: "def-table" });

  const defRows = [
    ["name", tool.name],
    tool.title && tool.title !== tool.name ? ["title", tool.title] : null,
    tool.description ? ["description", tool.description] : null,
  ].filter(Boolean);

  if (tool.inputSchema) {
    defRows.push(["inputSchema", null]);
  }
  if (tool.outputSchema) {
    defRows.push(["outputSchema", null]);
  }

  for (const [label, value] of defRows) {
    const tr = el("tr", {});
    tr.appendChild(el("td", { class: "def-label" }, label));
    if (value !== null) {
      tr.appendChild(el("td", {}, el("span", {}, value)));
    } else {
      const schemaData = label === "inputSchema" ? tool.inputSchema : tool.outputSchema;
      const pre = el("pre", { class: "schema-json" }, JSON.stringify(schemaData, null, 2));
      tr.appendChild(el("td", {}, pre));
    }
    defTable.appendChild(tr);
  }

  if (tool.annotations && typeof tool.annotations === "object" && Object.keys(tool.annotations).length > 0) {
    const tr = el("tr", {});
    tr.appendChild(el("td", { class: "def-label" }, "annotations"));
    tr.appendChild(el("td", {}, el("pre", { class: "schema-json" }, JSON.stringify(tool.annotations, null, 2))));
    defTable.appendChild(tr);
  }

  defBody.appendChild(defTable);
  defToggle.addEventListener("click", () => {
    const open = defToggle.classList.toggle("open");
    defBody.style.display = open ? "" : "none";
  });
  body.appendChild(defToggle);
  body.appendChild(defBody);

  // Input form
  const formContainer = el("div", { style: { marginTop: "12px" } });
  let form = null;
  if (tool.inputSchema) {
    form = buildForm(tool.inputSchema, formContainer);
  }
  body.appendChild(formContainer);

  // Flight area
  const flightArea = el("div", {});
  body.appendChild(flightArea);

  // Result area
  const resultArea = el("div", { style: { marginTop: "8px" } });
  body.appendChild(resultArea);

  // Run button
  const btnRow = el("div", { class: "btn-group", style: { marginTop: "12px" } });
  const runBtn = el("button", { class: "btn-primary btn-sm" }, "Run");
  runBtn.addEventListener("click", () => runTool(tool, form, flightArea, resultArea, runBtn));
  btnRow.appendChild(runBtn);
  body.appendChild(btnRow);

  card.appendChild(body);

  // Toggle expand
  headerRow.addEventListener("click", () => {
    const isOpen = body.classList.toggle("open");
    expandIcon.textContent = isOpen ? "▼" : "▶";
  });

  return card;
}

async function runTool(tool, form, flightArea, resultArea, runBtn) {
  const session = sid();
  if (!session) return;

  const args = form ? form.getValue() : {};

  resultArea.innerHTML = "";
  flightArea.innerHTML = "";

  const spinner = el("span", { class: "spinner" });
  const progressBar = el("div", { class: "progress-bar", style: { display: "none" } });
  const progressFill = el("div", { class: "progress-fill", style: { width: "0%" } });
  progressBar.appendChild(progressFill);
  const progressMsg = el("div", { class: "progress-msg", style: { display: "none" } });

  const cancelBtn = el("button", { class: "btn-sm btn-danger" }, "Cancel");

  const flightRow = el("div", {
    style: { display: "flex", alignItems: "center", gap: "8px", marginTop: "8px" }
  }, [spinner, el("span", { style: { fontSize: "12px", color: "var(--text-muted)" } }, "Running…"), cancelBtn]);

  flightArea.appendChild(flightRow);
  flightArea.appendChild(progressBar);
  flightArea.appendChild(progressMsg);

  runBtn.disabled = true;

  try {
    const resp = await ctx.api.apiPost(`/api/session/${session}/calls`, {
      name: tool.name,
      arguments: args
    });

    const callId = resp.call_id;

    inflight.set(callId, { flightArea, resultArea, progressBar, progressFill, progressMsg, runBtn });

    cancelBtn.addEventListener("click", async () => {
      try {
        await ctx.api.apiDelete(`/api/session/${session}/calls/${callId}`);
        inflight.delete(callId);
        flightArea.innerHTML = "";
        resultArea.appendChild(el("div", {
          style: { color: "var(--text-muted)", fontStyle: "italic" }
        }, "Cancelled"));
        runBtn.disabled = false;
      } catch (err) {
        ctx.api.showToast(`Cancel failed: ${err.message}`);
      }
    });
  } catch (err) {
    flightArea.innerHTML = "";
    resultArea.appendChild(el("div", { class: "card error-border" }, [
      el("div", { style: { color: "var(--red)" } }, err.message)
    ]));
    runBtn.disabled = false;
  }
}
