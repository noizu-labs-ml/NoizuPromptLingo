/**
 * prompts.js - Prompts tab: list prompts, fill arguments, get messages
 */

import { el, renderContent } from "./render.js";

let ctx = null;
let domInited = false;

// session() is a function returning the current session id
function sid() { return ctx?.session(); }

export function init(context) {
  ctx = context;

  if (!domInited) {
    domInited = true;
    const panel = document.getElementById("tab-prompts");

    const header = el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "16px" } }, [
      el("h2", {}, "Prompts"),
      el("button", { class: "btn-sm", onClick: refreshPrompts }, "Refresh List")
    ]);
    panel.appendChild(header);

    const container = el("div", { id: "prompts-list" });
    panel.appendChild(container);

    ctx.events.on("notification", (data) => {
      if (data.method === "notifications/prompts/list_changed") {
        refreshPrompts();
      }
    });

    // Reset on session change
    ctx.events.on("session_changed", () => {
      const container = document.getElementById("prompts-list");
      if (container) {
        container.innerHTML = "";
        container.appendChild(el("div", { class: "session-divider" }, "— new session —"));
      }
      refreshPrompts();
    });
  }

  refreshPrompts();
}

async function refreshPrompts() {
  const session = sid();
  if (!session) return;
  try {
    const data = await ctx.api.apiGet(`/api/session/${session}/prompts`);
    renderPromptsList(data.prompts || []);
  } catch (err) {
    ctx.api.showToast(`Failed to load prompts: ${err.message}`);
  }
}

function renderPromptsList(prompts) {
  const container = document.getElementById("prompts-list");
  container.innerHTML = "";

  if (prompts.length === 0) {
    container.appendChild(el("div", { style: { color: "var(--text-muted)", padding: "20px", textAlign: "center" } }, "No prompts available"));
    return;
  }

  for (const prompt of prompts) {
    container.appendChild(buildPromptCard(prompt));
  }
}

function buildPromptCard(prompt) {
  const card = el("div", { class: "card" });

  // Header
  const headerRow = el("div", { class: "card-header" });
  const titlePart = el("div", {}, [
    el("span", { class: "card-title" }, prompt.title || prompt.name),
    prompt.title && prompt.title !== prompt.name
      ? el("code", { style: { marginLeft: "8px", fontSize: "11px", color: "var(--text-muted)" } }, prompt.name)
      : null
  ]);
  const expandIcon = el("span", { style: { fontSize: "12px", color: "var(--text-muted)" } }, "▶");
  headerRow.appendChild(titlePart);
  headerRow.appendChild(expandIcon);
  card.appendChild(headerRow);

  // Body
  const body = el("div", { class: "card-body" });

  if (prompt.description) {
    body.appendChild(el("div", { class: "card-desc", style: { marginBottom: "12px" } }, prompt.description));
  }

  // Argument inputs
  const argInputs = {};
  const args = prompt.arguments || [];

  if (args.length > 0) {
    const argsContainer = el("div", {});

    for (const arg of args) {
      const datalistId = `prompt-dl-${prompt.name}-${arg.name}`;
      const input = el("input", {
        type: "text",
        placeholder: arg.description || arg.name,
        list: datalistId,
        name: arg.name
      });
      const datalist = el("datalist", { id: datalistId });

      // Debounced completion
      let debounceTimer = null;
      input.addEventListener("input", () => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(async () => {
          try {
            const resp = await ctx.api.apiPost(`/api/session/${sid()}/complete`, {
              ref: { type: "ref/prompt", name: prompt.name },
              argument: { name: arg.name, value: input.value }
            });
            datalist.innerHTML = "";
            if (resp.values) {
              for (const v of resp.values) {
                datalist.appendChild(el("option", { value: v }));
              }
            }
          } catch {
            // ignore
          }
        }, 300);
      });

      const group = el("div", { class: "form-group" }, [
        el("label", {}, [
          arg.name,
          arg.required ? el("span", { class: "required-marker" }, "*") : null
        ]),
        arg.description ? el("div", { class: "form-hint" }, arg.description) : null,
        input,
        datalist
      ]);

      argsContainer.appendChild(group);
      argInputs[arg.name] = input;
    }

    body.appendChild(argsContainer);
  }

  // Result area
  const resultArea = el("div", { style: { marginTop: "8px" } });

  // Get button
  const getBtn = el("button", { class: "btn-primary btn-sm", style: { marginTop: "8px" } }, "Get");
  getBtn.addEventListener("click", async () => {
    const arguments_ = {};
    for (const [name, input] of Object.entries(argInputs)) {
      if (input.value) {
        arguments_[name] = input.value;
      }
    }

    getBtn.disabled = true;
    resultArea.innerHTML = "";
    resultArea.appendChild(el("span", { class: "spinner" }));

    try {
      const data = await ctx.api.apiPost(`/api/session/${sid()}/prompts/get`, {
        name: prompt.name,
        arguments: arguments_
      });

      resultArea.innerHTML = "";

      if (data.description) {
        resultArea.appendChild(el("div", { style: { color: "var(--text-muted)", fontStyle: "italic", marginBottom: "8px" } }, data.description));
      }

      const messages = data.messages || [];
      for (const msg of messages) {
        const msgBlock = el("div", { class: "message-block" });

        // Role badge
        const roleClass = `role-badge role-${msg.role || "user"}`;
        msgBlock.appendChild(el("span", { class: roleClass }, msg.role || "unknown"));

        // Content
        const contentEl = el("div", { style: { marginTop: "6px" } });
        const content = msg.content;
        if (typeof content === "string") {
          contentEl.appendChild(el("pre", { style: { whiteSpace: "pre-wrap" } }, content));
        } else if (content) {
          renderContent(Array.isArray(content) ? content : [content], contentEl);
        }
        msgBlock.appendChild(contentEl);
        resultArea.appendChild(msgBlock);
      }
    } catch (err) {
      resultArea.innerHTML = "";
      resultArea.appendChild(el("div", { style: { color: "var(--red)" } }, err.message));
    } finally {
      getBtn.disabled = false;
    }
  });

  body.appendChild(getBtn);
  body.appendChild(resultArea);
  card.appendChild(body);

  // Toggle
  headerRow.addEventListener("click", () => {
    const isOpen = body.classList.toggle("open");
    expandIcon.textContent = isOpen ? "▼" : "▶";
  });

  return card;
}
