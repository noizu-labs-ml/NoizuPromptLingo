/**
 * resources.js - Resources tab: direct resources + templates
 */

import { el, renderResourceContents } from "./render.js";

let ctx = null;
const subscribed = new Set();
const updatedUris = new Set();
let domInited = false;

// session() is a function returning the current session id
function sid() { return ctx?.session(); }

export function init(context) {
  ctx = context;

  if (!domInited) {
    domInited = true;
    const panel = document.getElementById("tab-resources");

    const header = el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "16px" } }, [
      el("h2", {}, "Resources"),
      el("button", { class: "btn-sm", onClick: refreshAll }, "Refresh List")
    ]);
    panel.appendChild(header);

    const directSection = el("div", { id: "resources-direct" }, [
      el("div", { class: "section-title" }, "Direct Resources")
    ]);
    panel.appendChild(directSection);

    const templateSection = el("div", { id: "resources-templates", style: { marginTop: "24px" } }, [
      el("div", { class: "section-title" }, "Resource Templates")
    ]);
    panel.appendChild(templateSection);

    // Auto re-list on list_changed
    ctx.events.on("notification", (data) => {
      if (data.method === "notifications/resources/list_changed") {
        refreshAll();
      }
      if (data.method === "notifications/resources/updated") {
        const uri = data.params?.uri;
        if (uri) {
          updatedUris.add(uri);
          markUpdated(uri);
        }
      }
    });

    // Reset on session change
    ctx.events.on("session_changed", () => {
      subscribed.clear();
      updatedUris.clear();
      const direct = document.getElementById("resources-direct");
      if (direct) {
        const title = direct.querySelector(".section-title");
        direct.innerHTML = "";
        if (title) direct.appendChild(title);
        direct.appendChild(el("div", { class: "session-divider" }, "— new session —"));
      }
      const templates = document.getElementById("resources-templates");
      if (templates) {
        const title = templates.querySelector(".section-title");
        templates.innerHTML = "";
        if (title) templates.appendChild(title);
      }
      refreshAll();
    });
  }

  refreshAll();
}

async function refreshAll() {
  const session = sid();
  if (!session) return;

  try {
    const [resourcesData, templatesData] = await Promise.all([
      ctx.api.apiGet(`/api/session/${session}/resources`),
      ctx.api.apiGet(`/api/session/${session}/resource_templates`).catch(() => ({ resourceTemplates: [] }))
    ]);

    renderDirectResources(resourcesData.resources || []);
    renderTemplates(templatesData.resourceTemplates || []);
  } catch (err) {
    ctx.api.showToast(`Failed to load resources: ${err.message}`);
  }
}

function renderDirectResources(resources) {
  const section = document.getElementById("resources-direct");
  // Keep section title
  const title = section.querySelector(".section-title");
  section.innerHTML = "";
  section.appendChild(title);

  if (resources.length === 0) {
    section.appendChild(el("div", { style: { color: "var(--text-muted)", padding: "12px" } }, "No direct resources"));
    return;
  }

  for (const res of resources) {
    section.appendChild(buildResourceCard(res));
  }
}

function buildResourceCard(res) {
  const isUpdated = updatedUris.has(res.uri);
  const card = el("div", {
    class: `card ${isUpdated ? "updated-border" : ""}`,
    dataset: { uri: res.uri }
  });

  const headerRow = el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "flex-start" } });

  const titlePart = el("div", {}, [
    el("div", { class: "card-title" }, res.title || res.name || res.uri),
    (res.title || res.name) ? el("code", { class: "mono", style: { fontSize: "11px", display: "block", color: "var(--text-muted)", marginTop: "2px" } }, res.uri) : null,
    res.description ? el("div", { class: "card-desc" }, res.description) : null,
    res.mimeType ? el("span", { class: "badge-pill badge-accent", style: { marginTop: "4px" } }, res.mimeType) : null
  ]);

  const controls = el("div", { style: { display: "flex", gap: "8px", alignItems: "center" } });

  // Subscribe toggle
  const toggleLabel = el("label", { class: "toggle-switch", style: { margin: "0" }, title: "Subscribe" });
  const checkbox = el("input", { type: "checkbox", checked: subscribed.has(res.uri) });
  const slider = el("span", { class: "toggle-slider" });
  toggleLabel.appendChild(checkbox);
  toggleLabel.appendChild(slider);

  checkbox.addEventListener("change", async () => {
    try {
      if (checkbox.checked) {
        await ctx.api.apiPost(`/api/session/${sid()}/resources/subscribe`, { uri: res.uri });
        subscribed.add(res.uri);
      } else {
        await ctx.api.apiPost(`/api/session/${sid()}/resources/unsubscribe`, { uri: res.uri });
        subscribed.delete(res.uri);
      }
    } catch (err) {
      ctx.api.showToast(`Subscribe error: ${err.message}`);
      checkbox.checked = !checkbox.checked;
    }
  });

  controls.appendChild(toggleLabel);

  // Read button
  const readBtn = el("button", { class: "btn-sm btn-primary" }, "Read");
  controls.appendChild(readBtn);

  headerRow.appendChild(titlePart);
  headerRow.appendChild(controls);
  card.appendChild(headerRow);

  // Result area
  const resultArea = el("div", { style: { marginTop: "8px" } });
  card.appendChild(resultArea);

  readBtn.addEventListener("click", async () => {
    readBtn.disabled = true;
    resultArea.innerHTML = "";
    resultArea.appendChild(el("span", { class: "spinner" }));

    try {
      const data = await ctx.api.apiPost(`/api/session/${sid()}/resources/read`, { uri: res.uri });
      resultArea.innerHTML = "";
      renderResourceContents(data.contents || [], resultArea);
      // Clear updated flag
      updatedUris.delete(res.uri);
      card.classList.remove("updated-border");
    } catch (err) {
      resultArea.innerHTML = "";
      resultArea.appendChild(el("div", { style: { color: "var(--red)" } }, err.message));
    } finally {
      readBtn.disabled = false;
    }
  });

  return card;
}

function renderTemplates(templates) {
  const section = document.getElementById("resources-templates");
  const title = section.querySelector(".section-title");
  section.innerHTML = "";
  section.appendChild(title);

  if (templates.length === 0) {
    section.appendChild(el("div", { style: { color: "var(--text-muted)", padding: "12px" } }, "No resource templates"));
    return;
  }

  for (const tmpl of templates) {
    section.appendChild(buildTemplateCard(tmpl));
  }
}

function buildTemplateCard(tmpl) {
  const card = el("div", { class: "card" });

  card.appendChild(el("div", { class: "card-title" }, tmpl.name || tmpl.uriTemplate));
  card.appendChild(el("code", { class: "mono", style: { fontSize: "11px", color: "var(--text-muted)", display: "block", marginTop: "2px" } }, tmpl.uriTemplate));
  if (tmpl.description) {
    card.appendChild(el("div", { class: "card-desc" }, tmpl.description));
  }
  if (tmpl.mimeType) {
    card.appendChild(el("span", { class: "badge-pill badge-accent", style: { marginTop: "4px", display: "inline-block" } }, tmpl.mimeType));
  }

  // Parse template vars
  const varPattern = /\{(\w+)\}/g;
  const vars = [];
  let match;
  while ((match = varPattern.exec(tmpl.uriTemplate)) !== null) {
    vars.push(match[1]);
  }

  const inputsContainer = el("div", { style: { marginTop: "12px" } });
  const varInputs = {};

  for (const v of vars) {
    const datalistId = `tmpl-dl-${tmpl.uriTemplate}-${v}`;
    const input = el("input", {
      type: "text",
      placeholder: v,
      list: datalistId,
      name: v
    });
    const datalist = el("datalist", { id: datalistId });

    // Debounced completion
    let debounceTimer = null;
    input.addEventListener("input", () => {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(async () => {
        try {
          const resp = await ctx.api.apiPost(`/api/session/${sid()}/complete`, {
            ref: { type: "ref/resource", uri: tmpl.uriTemplate },
            argument: { name: v, value: input.value }
          });
          datalist.innerHTML = "";
          if (resp.values) {
            for (const val of resp.values) {
              datalist.appendChild(el("option", { value: val }));
            }
          }
        } catch {
          // ignore completion errors
        }
      }, 300);
    });

    const group = el("div", { class: "form-group" }, [
      el("label", {}, v),
      input,
      datalist
    ]);
    inputsContainer.appendChild(group);
    varInputs[v] = input;
  }

  card.appendChild(inputsContainer);

  // Read button + result
  const resultArea = el("div", { style: { marginTop: "8px" } });
  const readBtn = el("button", { class: "btn-sm btn-primary", style: { marginTop: "8px" } }, "Read");

  readBtn.addEventListener("click", async () => {
    // Expand URI
    let uri = tmpl.uriTemplate;
    for (const [varName, input] of Object.entries(varInputs)) {
      uri = uri.replace(`{${varName}}`, encodeURIComponent(input.value));
    }

    readBtn.disabled = true;
    resultArea.innerHTML = "";
    resultArea.appendChild(el("span", { class: "spinner" }));

    try {
      const data = await ctx.api.apiPost(`/api/session/${sid()}/resources/read`, { uri });
      resultArea.innerHTML = "";
      renderResourceContents(data.contents || [], resultArea);
    } catch (err) {
      resultArea.innerHTML = "";
      resultArea.appendChild(el("div", { style: { color: "var(--red)" } }, err.message));
    } finally {
      readBtn.disabled = false;
    }
  });

  card.appendChild(readBtn);
  card.appendChild(resultArea);

  return card;
}

function markUpdated(uri) {
  const cards = document.querySelectorAll(`[data-uri="${CSS.escape(uri)}"]`);
  for (const card of cards) {
    card.classList.add("updated-border");
  }
}
