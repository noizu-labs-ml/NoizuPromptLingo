/**
 * app.js - Main entry point: tab routing, session lifecycle, connection tab
 */

import { initToken, getToken, apiGet, apiPost, apiDelete, createEventSource, createEventBus, showToast } from "./api.js";
import { el } from "./render.js";
import { init as initTools } from "./tools.js";
import { init as initResources } from "./resources.js";
import { init as initPrompts } from "./prompts.js";
import { init as initLog } from "./log.js";
import { init as initPending } from "./pending.js";

const api = { apiGet, apiPost, apiDelete, showToast };

let sessionId = null;
let sessionInfo = null;
let eventSource = null;
let events = null;

// Shared event bus that persists across sessions so tab modules can
// subscribe once and receive session_changed + SSE events.
const globalEvents = createEventBus();

// Discovered servers from /api/servers (module names)
let knownServers = [];
let hasDefault = false;

// Track whether tab modules have been initialized (they only need DOM setup once)
let tabsInitialized = false;

// ── Tab routing ──

function setupTabs() {
  const buttons = document.querySelectorAll(".tab-btn");
  const panels = document.querySelectorAll(".tab-panel");

  for (const btn of buttons) {
    btn.addEventListener("click", () => {
      if (btn.classList.contains("tab-disabled")) return;
      const tab = btn.dataset.tab;

      for (const b of buttons) b.classList.remove("active");
      for (const p of panels) p.classList.remove("active");

      btn.classList.add("active");
      const panel = document.getElementById(`tab-${tab}`);
      if (panel) panel.classList.add("active");
    });
  }
}

function setTabsEnabled(enabled) {
  const nonConnectionTabs = ["tools", "resources", "prompts", "history", "notifications", "pending"];
  for (const name of nonConnectionTabs) {
    const btn = document.querySelector(`.tab-btn[data-tab="${name}"]`);
    if (!btn) continue;
    if (enabled) {
      btn.classList.remove("tab-disabled");
      btn.title = "";
    } else {
      btn.classList.add("tab-disabled");
      btn.title = "Connect to a server first";
    }
  }
}

// ── Connection tab ──

function renderConnectionTab(opts = {}) {
  const panel = document.getElementById("tab-connection");
  panel.innerHTML = "";

  panel.appendChild(el("h2", {}, "Connection"));

  // ── Connect panel ──
  const isConnected = !!sessionId;
  const connectSection = el("div", { class: `section connect-panel${isConnected ? "" : " connect-panel-prominent"}` });
  connectSection.appendChild(el("div", { class: "section-title" }, isConnected ? "Switch Target" : "Connect to a Server"));

  if (!isConnected) {
    connectSection.appendChild(el("p", { class: "connect-hint" }, "Choose a transport and connect to an MCP server to begin."));
  }

  // Collapsed affordance when already connected
  const switchArea = el("div", { id: "switch-target-area" });

  if (isConnected && !opts.showPicker) {
    const switchBtn = el("button", { class: "btn-sm" }, "Switch Target…");
    switchBtn.addEventListener("click", () => {
      renderConnectionTab({ showPicker: true });
    });
    switchArea.appendChild(switchBtn);
    connectSection.appendChild(switchArea);
    panel.appendChild(connectSection);
  } else {
    // Show the full target picker
    buildTargetPicker(switchArea);
    connectSection.appendChild(switchArea);
    panel.appendChild(connectSection);
  }

  // ── Server info (only when connected) ──
  if (isConnected && sessionInfo) {
    const infoSection = el("div", { class: "section" });
    infoSection.appendChild(el("div", { class: "section-title" }, "Server Info"));

    const info = sessionInfo;
    const grid = el("div", { class: "info-grid" });

    const addRow = (label, value) => {
      grid.appendChild(el("span", { class: "info-label" }, label));
      grid.appendChild(el("span", {}, String(value)));
    };

    if (info.server_info?.name) addRow("Name", info.server_info.name);
    if (info.server_info?.version) addRow("Version", info.server_info.version);
    if (info.server_info?.title) addRow("Title", info.server_info.title);
    if (info.target) addRow("Target", typeof info.target === "string" ? info.target : JSON.stringify(info.target));
    addRow("Session ID", info.session_id || sessionId);

    infoSection.appendChild(grid);

    // Instructions
    if (info.instructions) {
      const instrToggle = el("div", { class: "collapsible-toggle", style: { marginTop: "12px" } }, "Instructions");
      const instrContent = el("pre", { style: { display: "none", marginTop: "4px" } }, info.instructions);
      instrToggle.addEventListener("click", () => {
        const open = instrToggle.classList.toggle("open");
        instrContent.style.display = open ? "" : "none";
      });
      infoSection.appendChild(instrToggle);
      infoSection.appendChild(instrContent);
    }

    // Capabilities
    if (info.capabilities) {
      const capToggle = el("div", { class: "collapsible-toggle", style: { marginTop: "12px" } }, "Capabilities");
      const capContent = el("pre", { style: { display: "none", marginTop: "4px" } },
        JSON.stringify(info.capabilities, null, 2));
      capToggle.addEventListener("click", () => {
        const open = capToggle.classList.toggle("open");
        capContent.style.display = open ? "" : "none";
      });
      infoSection.appendChild(capToggle);
      infoSection.appendChild(capContent);
    }

    panel.appendChild(infoSection);

    // Ping button (standalone when connected)
    const pingSection = el("div", { class: "section" });
    pingSection.appendChild(el("div", { class: "section-title" }, "Actions"));
    const pingBtn = el("button", { class: "btn-sm" }, "Ping");
    pingBtn.addEventListener("click", async () => {
      try {
        await apiPost(`/api/session/${sessionId}/ping`);
        showToast("Pong!", "info");
      } catch (err) {
        showToast(`Ping failed: ${err.message}`);
      }
    });
    pingSection.appendChild(pingBtn);
    panel.appendChild(pingSection);

    // ── Log Level ──
    const logSection = el("div", { class: "section" });
    logSection.appendChild(el("div", { class: "section-title" }, "Log Level"));

    const logLevels = ["debug", "info", "notice", "warning", "error", "critical", "alert", "emergency"];
    const logSelect = el("select", { style: { width: "auto" } });
    for (const lvl of logLevels) {
      logSelect.appendChild(el("option", { value: lvl }, lvl));
    }

    const logSetBtn = el("button", { class: "btn-sm", style: { marginLeft: "8px" } }, "Set");
    logSetBtn.addEventListener("click", async () => {
      try {
        await apiPost(`/api/session/${sessionId}/log_level`, { level: logSelect.value });
        showToast(`Log level set to ${logSelect.value}`, "info");
      } catch (err) {
        showToast(`Failed: ${err.message}`);
      }
    });

    logSection.appendChild(el("div", { class: "inline-row" }, [logSelect, logSetBtn]));
    panel.appendChild(logSection);

    // ── Roots Editor ──
    const rootsSection = el("div", { class: "section" });
    rootsSection.appendChild(el("div", { class: "section-title" }, "Roots"));

    const rootsList = el("div", { id: "roots-list" });
    const currentRoots = info.roots || [];
    let rootsState = [...currentRoots];

    function renderRoots(roots) {
      rootsList.innerHTML = "";
      for (let i = 0; i < roots.length; i++) {
        const root = roots[i];
        const idx = i;
        const uriInput = el("input", { type: "text", value: root.uri || "", placeholder: "URI" });
        const nameInput = el("input", { type: "text", value: root.name || "", placeholder: "Name (optional)", style: { maxWidth: "200px" } });
        const removeBtn = el("button", { class: "btn-sm btn-danger" }, "×");
        removeBtn.addEventListener("click", () => {
          rootsState.splice(idx, 1);
          renderRoots(rootsState);
        });
        const row = el("div", { class: "inline-row" }, [uriInput, nameInput, removeBtn]);
        // Keep state in sync
        uriInput.addEventListener("input", () => { rootsState[idx].uri = uriInput.value; });
        nameInput.addEventListener("input", () => { rootsState[idx].name = nameInput.value; });
        rootsList.appendChild(row);
      }
    }

    renderRoots(rootsState);

    const addRootBtn = el("button", { class: "btn-sm", style: { marginTop: "4px" } }, "+ Add Root");
    addRootBtn.addEventListener("click", () => {
      rootsState.push({ uri: "", name: "" });
      renderRoots(rootsState);
    });

    const saveRootsBtn = el("button", { class: "btn-primary btn-sm", style: { marginTop: "8px" } }, "Save Roots");
    saveRootsBtn.addEventListener("click", async () => {
      const roots = rootsState.filter(r => r.uri);
      try {
        await apiPost(`/api/session/${sessionId}/roots`, { roots });
        showToast("Roots updated", "info");
      } catch (err) {
        showToast(`Failed: ${err.message}`);
      }
    });

    rootsSection.appendChild(rootsList);
    rootsSection.appendChild(addRootBtn);
    rootsSection.appendChild(saveRootsBtn);
    panel.appendChild(rootsSection);

    // ── Config Export ──
    const exportSection = el("div", { class: "section" });
    exportSection.appendChild(el("div", { class: "section-title" }, "Config Export"));

    const exportBtn = el("button", { class: "btn-sm" }, "Export Config");
    const exportResult = el("div", { style: { marginTop: "8px" } });

    exportBtn.addEventListener("click", async () => {
      try {
        const data = await apiGet(`/api/session/${sessionId}/export`);
        exportResult.innerHTML = "";

        if (data.note) {
          exportResult.appendChild(el("div", { style: { color: "var(--yellow)", marginBottom: "8px" } }, data.note));
        }

        if (data.entry !== null && data.entry !== undefined) {
          exportResult.appendChild(el("div", { class: "section-title", style: { marginTop: "8px" } }, "Entry JSON"));
          const entryPre = el("pre", {}, JSON.stringify(data.entry, null, 2));
          const copyEntryBtn = el("button", { class: "copy-btn btn-sm", style: { marginBottom: "4px" } }, "Copy");
          copyEntryBtn.addEventListener("click", () => {
            navigator.clipboard.writeText(JSON.stringify(data.entry, null, 2)).then(() => {
              copyEntryBtn.textContent = "Copied!";
              setTimeout(() => { copyEntryBtn.textContent = "Copy"; }, 2000);
            });
          });
          exportResult.appendChild(copyEntryBtn);
          exportResult.appendChild(entryPre);
        } else {
          exportResult.appendChild(el("div", { style: { color: "var(--text-muted)", fontStyle: "italic" } }, "Entry is null (not exportable)"));
        }

        if (data.servers_file) {
          exportResult.appendChild(el("div", { class: "section-title", style: { marginTop: "12px" } }, "servers_file JSON"));
          const sfPre = el("pre", {}, JSON.stringify(data.servers_file, null, 2));
          const copySfBtn = el("button", { class: "copy-btn btn-sm", style: { marginBottom: "4px" } }, "Copy");
          copySfBtn.addEventListener("click", () => {
            navigator.clipboard.writeText(JSON.stringify(data.servers_file, null, 2)).then(() => {
              copySfBtn.textContent = "Copied!";
              setTimeout(() => { copySfBtn.textContent = "Copy"; }, 2000);
            });
          });
          exportResult.appendChild(copySfBtn);
          exportResult.appendChild(sfPre);
        }
      } catch (err) {
        exportResult.innerHTML = "";
        exportResult.appendChild(el("div", { style: { color: "var(--red)" } }, err.message));
      }
    });

    exportSection.appendChild(exportBtn);
    exportSection.appendChild(exportResult);
    panel.appendChild(exportSection);
  }
}

// ── Target picker builder ──

function buildTargetPicker(container) {
  const isConnected = !!sessionId;

  // Radio group
  const radioGroup = el("div", { class: "radio-group" });
  const modes = [
    { value: "module", label: "Module" },
    { value: "stdio", label: "Stdio command" },
    { value: "http", label: "HTTP URL" }
  ];

  // If a default is configured, add it as first option
  if (hasDefault) {
    modes.unshift({ value: "default", label: "Default (server-configured)" });
  }

  let selectedMode = hasDefault ? "default" : "module";

  const modeFields = {};

  for (const m of modes) {
    const radio = el("input", { type: "radio", name: "target-mode", value: m.value });
    if (m.value === selectedMode) radio.checked = true;
    radio.addEventListener("change", () => {
      selectedMode = m.value;
      updateFields();
    });
    radioGroup.appendChild(el("label", { class: "radio-label" }, [radio, " " + m.label]));
  }

  container.appendChild(radioGroup);

  // Module fields
  const moduleFields = el("div", { class: "target-fields" });
  const moduleSelect = el("select", { id: "target-module-select" });

  // Populate with discovered servers
  if (knownServers.length > 0) {
    for (const s of knownServers) {
      moduleSelect.appendChild(el("option", { value: s }, s));
    }
    moduleSelect.appendChild(el("option", { value: "__custom__" }, "Other (type below)…"));
  } else {
    moduleSelect.appendChild(el("option", { value: "__custom__" }, "Enter module name below…"));
  }

  const moduleCustomInput = el("input", {
    type: "text",
    id: "target-module-custom",
    placeholder: "e.g. MyApp.MCPServer",
    style: { marginTop: "6px", display: knownServers.length > 0 ? "none" : "" }
  });

  moduleSelect.addEventListener("change", () => {
    moduleCustomInput.style.display = moduleSelect.value === "__custom__" ? "" : "none";
  });

  moduleFields.appendChild(el("div", { class: "form-group" }, [
    el("label", {}, "Module name"),
    moduleSelect,
    moduleCustomInput
  ]));
  modeFields.module = moduleFields;

  // Stdio fields
  const stdioFields = el("div", { class: "target-fields" });
  stdioFields.appendChild(el("div", { class: "form-group" }, [
    el("label", {}, "Command"),
    el("input", { type: "text", id: "target-stdio-cmd", placeholder: "e.g. node /path/to/server.js" })
  ]));
  stdioFields.appendChild(el("div", { class: "form-group" }, [
    el("label", {}, "Arguments (space-separated, optional)"),
    el("input", { type: "text", id: "target-stdio-args", placeholder: "--port 3000" })
  ]));
  stdioFields.appendChild(el("div", { class: "form-group" }, [
    el("label", {}, "Working directory (optional)"),
    el("input", { type: "text", id: "target-stdio-cd", placeholder: "/path/to/dir" })
  ]));
  modeFields.stdio = stdioFields;

  // HTTP fields
  const httpFields = el("div", { class: "target-fields" });
  httpFields.appendChild(el("div", { class: "form-group" }, [
    el("label", {}, "URL"),
    el("input", { type: "text", id: "target-http-url", placeholder: "https://..." })
  ]));
  httpFields.appendChild(el("div", { class: "form-group" }, [
    el("label", {}, "Bearer token (optional)"),
    el("input", { type: "text", id: "target-http-bearer", placeholder: "Token" })
  ]));
  modeFields.http = httpFields;

  // Default fields (no extra fields needed)
  if (hasDefault) {
    modeFields.default = el("div", { class: "target-fields" }, [
      el("span", { style: { color: "var(--text-muted)", fontSize: "12px" } }, "Uses the server-configured default target.")
    ]);
  }

  function updateFields() {
    for (const [mode, el_] of Object.entries(modeFields)) {
      el_.style.display = mode === selectedMode ? "" : "none";
    }
  }

  // Append all field groups
  for (const [, fieldEl] of Object.entries(modeFields)) {
    container.appendChild(fieldEl);
  }
  updateFields();

  // Buttons
  const btnRow = el("div", { class: "btn-group", style: { marginTop: "16px" } });

  const connectBtn = el("button", { class: "btn-primary btn-sm" }, isConnected ? "Reconnect" : "Connect");
  connectBtn.addEventListener("click", async () => {
    await doConnect(selectedMode, modeFields, moduleSelect, moduleCustomInput);
  });
  btnRow.appendChild(connectBtn);

  if (isConnected) {
    const cancelBtn = el("button", { class: "btn-sm" }, "Cancel");
    cancelBtn.addEventListener("click", () => renderConnectionTab());
    btnRow.appendChild(cancelBtn);
  }

  container.appendChild(btnRow);
}

// ── Connect / Reconnect ──

function buildTarget(mode, moduleSelect, moduleCustomInput) {
  switch (mode) {
    case "default":
      return undefined;
    case "module": {
      const name = moduleSelect?.value === "__custom__"
        ? moduleCustomInput?.value?.trim()
        : moduleSelect?.value;
      if (!name) return undefined;
      return { type: "module", module: name };
    }
    case "stdio": {
      const cmd = document.getElementById("target-stdio-cmd")?.value?.trim();
      if (!cmd) return undefined;
      const argsRaw = document.getElementById("target-stdio-args")?.value?.trim();
      const cd = document.getElementById("target-stdio-cd")?.value?.trim();
      const target = { type: "stdio", command: cmd };
      if (argsRaw) target.args = argsRaw.split(/\s+/);
      if (cd) target.cd = cd;
      return target;
    }
    case "http": {
      const url = document.getElementById("target-http-url")?.value?.trim();
      if (!url) return undefined;
      const bearer = document.getElementById("target-http-bearer")?.value?.trim();
      const target = { type: "url", url };
      if (bearer) target.bearer = bearer;
      return target;
    }
    default:
      return undefined;
  }
}

async function doConnect(mode, modeFields, moduleSelect, moduleCustomInput, explicitTarget) {
  const target = explicitTarget || buildTarget(mode, moduleSelect, moduleCustomInput);
  const body = {};
  if (target !== undefined) body.target = target;

  // Tear down existing session
  if (sessionId) {
    try {
      if (eventSource) eventSource.close();
      await apiDelete(`/api/session/${sessionId}`);
    } catch {
      // ignore cleanup errors
    }
    sessionId = null;
    sessionInfo = null;
    eventSource = null;
    clearPersistedSession();
  }

  try {
    const data = await apiPost("/api/connect", body);
    sessionId = data.session_id;
    sessionInfo = data;

    // Create a fresh per-session event bus that proxies into globalEvents
    events = createEventBus();
    const SSE_EVENTS = ["frame", "notification", "progress", "call_result", "pending_request", "pending_resolved", "status"];
    for (const name of SSE_EVENTS) {
      events.on(name, (payload, id) => globalEvents.emit(name, payload, id));
    }

    eventSource = createEventSource(sessionId, events);

    // Persist session so page reloads reconnect
    persistSession(sessionId, body.target || null);

    // Re-enable tabs
    setTabsEnabled(true);

    // Broadcast session change so all tab modules reset and re-fetch
    globalEvents.emit("session_changed", { session_id: sessionId });

    // Listen for status changes (session-scoped)
    events.on("status", (data) => {
      if (data.state === "closed" || data.state === "error") {
        showToast(`Session closed${data.reason || data.error ? ": " + (data.reason || data.error) : ""}`, "info");
        setTabsEnabled(false);
        sessionId = null;
        sessionInfo = null;
        clearPersistedSession();
        renderConnectionTab();
      }
    });

    // Re-render connection tab with server info
    renderConnectionTab();

    showToast(`Connected to ${data.server_info?.name || "server"}`, "info");
  } catch (err) {
    // If 400 "no target configured", stay on connection tab quietly
    if (err.message?.includes("no target configured")) {
      showToast("No default target — please choose one above.", "error");
    } else {
      showToast(`Connection failed: ${err.message}`);
    }
  }
}

// ── Session persistence ──

function persistSession(sid, target) {
  try {
    sessionStorage.setItem("inspector_session", JSON.stringify({ session_id: sid, target }));
  } catch { /* ignore */ }
}

function clearPersistedSession() {
  try { sessionStorage.removeItem("inspector_session"); } catch { /* ignore */ }
}

function getPersistedSession() {
  try {
    const raw = sessionStorage.getItem("inspector_session");
    return raw ? JSON.parse(raw) : null;
  } catch { return null; }
}

async function tryResumeSession(persisted) {
  try {
    const info = await apiGet(`/api/session/${persisted.session_id}`);
    if (info.session_id) {
      sessionId = info.session_id;
      sessionInfo = info;

      events = createEventBus();
      const SSE_EVENTS = ["frame", "notification", "progress", "call_result", "pending_request", "pending_resolved", "status"];
      for (const name of SSE_EVENTS) {
        events.on(name, (payload, id) => globalEvents.emit(name, payload, id));
      }
      eventSource = createEventSource(sessionId, events);
      setTabsEnabled(true);

      events.on("status", (data) => {
        if (data.state === "closed" || data.state === "error") {
          showToast(`Session closed${data.reason || data.error ? ": " + (data.reason || data.error) : ""}`, "info");
          setTabsEnabled(false);
          sessionId = null;
          sessionInfo = null;
          clearPersistedSession();
          renderConnectionTab();
        }
      });

      globalEvents.emit("session_changed", { session_id: sessionId });
      renderConnectionTab();
      return true;
    }
  } catch { /* session expired or server restarted */ }

  // Session gone — try reconnecting with the saved target
  if (persisted.target) {
    try {
      await doConnect("custom", {}, null, null, persisted.target);
      return true;
    } catch { /* fall through to normal boot */ }
  }

  clearPersistedSession();
  return false;
}

// ── Boot flow ──

async function boot() {
  initToken();
  setupTabs();

  // Disable non-connection tabs until connected
  setTabsEnabled(false);

  // Initialize all tab modules once (they wire their own DOM and subscribe to globalEvents)
  const ctx = { api, session: () => sessionId, events: globalEvents };
  initTools(ctx);
  initResources(ctx);
  initPrompts(ctx);
  initLog(ctx);
  initPending(ctx);

  // Fetch server list
  try {
    const serversData = await apiGet("/api/servers");
    knownServers = serversData.servers || [];
    hasDefault = serversData.has_default || false;
  } catch {
    knownServers = [];
    hasDefault = false;
  }

  // Try to resume a persisted session from before a page reload
  const persisted = getPersistedSession();
  if (persisted && getToken()) {
    const resumed = await tryResumeSession(persisted);
    if (resumed) return;
  }

  // Render connection tab initially
  renderConnectionTab();

  // Auto-connect if a default is configured
  if (getToken() && hasDefault) {
    await doConnect("default", {}, null, null);
  }
}

document.addEventListener("DOMContentLoaded", boot);
