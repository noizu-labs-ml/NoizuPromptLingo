/**
 * pending.js - Pending tab: sampling and elicitation requests
 */

import { el, renderContent } from "./render.js";
import { buildForm } from "./schema-form.js";

let ctx = null;
const pendingCards = new Map(); // request_id -> card element
let domInited = false;

// session() is a function returning the current session id
function sid() { return ctx?.session(); }

export function init(context) {
  ctx = context;

  if (!domInited) {
    domInited = true;
    const panel = document.getElementById("tab-pending");

    panel.appendChild(el("h2", {}, "Pending Requests"));

    const container = el("div", { id: "pending-list" });
    panel.appendChild(container);

    const emptyMsg = el("div", {
      id: "pending-empty",
      style: { color: "var(--text-muted)", padding: "20px", textAlign: "center" }
    }, "No pending requests");
    panel.appendChild(emptyMsg);

    ctx.events.on("pending_request", (data) => {
      addPendingRequest(data);
    });

    ctx.events.on("pending_resolved", (data) => {
      removePendingRequest(data.request_id);
    });

    // Reset on session change
    ctx.events.on("session_changed", () => {
      pendingCards.clear();
      const container = document.getElementById("pending-list");
      if (container) container.innerHTML = "";
      updateBadge();
    });
  }
}

function updateBadge() {
  const badge = document.getElementById("pending-badge");
  const count = pendingCards.size;
  if (badge) {
    badge.textContent = String(count);
    if (count > 0) {
      badge.classList.remove("hidden");
      badge.classList.add("pulse");
    } else {
      badge.classList.add("hidden");
      badge.classList.remove("pulse");
    }
  }

  const emptyMsg = document.getElementById("pending-empty");
  if (emptyMsg) {
    emptyMsg.style.display = count > 0 ? "none" : "";
  }
}

function addPendingRequest(data) {
  const container = document.getElementById("pending-list");
  if (!container) return;

  const requestId = data.request_id;
  const kind = data.kind; // "sampling" or "elicitation"
  const params = data.params || {};

  let card;
  if (kind === "sampling") {
    card = buildSamplingCard(requestId, params);
  } else if (kind === "elicitation") {
    card = buildElicitationCard(requestId, params);
  } else {
    card = buildGenericPendingCard(requestId, kind, params);
  }

  pendingCards.set(requestId, card);
  container.appendChild(card);
  updateBadge();
}

function removePendingRequest(requestId) {
  const card = pendingCards.get(requestId);
  if (card) {
    card.remove();
    pendingCards.delete(requestId);
  }
  updateBadge();
}

function buildSamplingCard(requestId, params) {
  const card = el("div", { class: "card" });

  card.appendChild(el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "center" } }, [
    el("span", { class: "card-title" }, "Sampling Request"),
    el("span", { class: "badge-pill badge-blue" }, requestId)
  ]));

  // Render messages
  if (params.messages && params.messages.length > 0) {
    const messagesArea = el("div", { style: { marginTop: "12px" } });
    for (const msg of params.messages) {
      const msgBlock = el("div", { class: "message-block" });
      const roleClass = `role-badge role-${msg.role || "user"}`;
      msgBlock.appendChild(el("span", { class: roleClass }, msg.role || "unknown"));

      const contentEl = el("div", { style: { marginTop: "6px" } });
      const content = msg.content;
      if (typeof content === "string") {
        contentEl.appendChild(el("pre", { style: { whiteSpace: "pre-wrap" } }, content));
      } else if (content) {
        renderContent(Array.isArray(content) ? content : [content], contentEl);
      }
      msgBlock.appendChild(contentEl);
      messagesArea.appendChild(msgBlock);
    }
    card.appendChild(messagesArea);
  }

  // Model preferences / maxTokens
  const meta = el("div", { style: { marginTop: "8px", fontSize: "12px", color: "var(--text-muted)" } });
  if (params.modelPreferences) {
    meta.appendChild(el("div", {}, `Model preferences: ${JSON.stringify(params.modelPreferences)}`));
  }
  if (params.maxTokens !== undefined) {
    meta.appendChild(el("div", {}, `Max tokens: ${params.maxTokens}`));
  }
  if (params.systemPrompt) {
    meta.appendChild(el("div", { style: { marginTop: "4px" } }, [
      el("strong", {}, "System: "),
      el("span", {}, params.systemPrompt)
    ]));
  }
  card.appendChild(meta);

  // Response form
  const responseArea = el("div", { style: { marginTop: "12px" } });
  responseArea.appendChild(el("label", {}, "Response"));
  const textarea = el("textarea", { rows: "4", placeholder: "Enter response text..." });
  responseArea.appendChild(textarea);

  const modelGroup = el("div", { class: "form-group", style: { marginTop: "8px" } }, [
    el("label", {}, "Model (optional)"),
    el("input", { type: "text", placeholder: "e.g. claude-3-opus", id: `sampling-model-${requestId}` })
  ]);
  responseArea.appendChild(modelGroup);

  card.appendChild(responseArea);

  // Buttons
  const btnRow = el("div", { class: "btn-group", style: { marginTop: "12px" } });

  const respondBtn = el("button", { class: "btn-primary btn-sm" }, "Respond");
  respondBtn.addEventListener("click", async () => {
    const modelInput = document.getElementById(`sampling-model-${requestId}`);
    const body = {
      role: "assistant",
      content: { type: "text", text: textarea.value },
    };
    if (modelInput?.value) {
      body.model = modelInput.value;
    }

    try {
      await ctx.api.apiPost(`/api/session/${sid()}/respond/${requestId}`, body);
      removePendingRequest(requestId);
    } catch (err) {
      ctx.api.showToast(`Respond failed: ${err.message}`);
    }
  });

  const rejectBtn = el("button", { class: "btn-danger btn-sm" }, "Reject");
  rejectBtn.addEventListener("click", async () => {
    try {
      await ctx.api.apiPost(`/api/session/${sid()}/respond/${requestId}`, {
        error: "rejected by user"
      });
      removePendingRequest(requestId);
    } catch (err) {
      ctx.api.showToast(`Reject failed: ${err.message}`);
    }
  });

  btnRow.appendChild(respondBtn);
  btnRow.appendChild(rejectBtn);
  card.appendChild(btnRow);

  return card;
}

function buildElicitationCard(requestId, params) {
  const card = el("div", { class: "card" });

  card.appendChild(el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "center" } }, [
    el("span", { class: "card-title" }, "Elicitation Request"),
    el("span", { class: "badge-pill badge-yellow" }, requestId)
  ]));

  // Message
  if (params.message) {
    card.appendChild(el("div", { style: { marginTop: "8px" } }, params.message));
  }

  // Build form from requestedSchema
  const formContainer = el("div", { style: { marginTop: "12px" } });
  let form = null;
  if (params.requestedSchema) {
    form = buildForm(params.requestedSchema, formContainer);
  }
  card.appendChild(formContainer);

  // Buttons: Accept, Decline, Cancel
  const btnRow = el("div", { class: "btn-group", style: { marginTop: "12px" } });

  const acceptBtn = el("button", { class: "btn-primary btn-sm" }, "Accept");
  acceptBtn.addEventListener("click", async () => {
    const value = form ? form.getValue() : {};
    try {
      await ctx.api.apiPost(`/api/session/${sid()}/respond/${requestId}`, {
        action: "accept",
        content: value
      });
      removePendingRequest(requestId);
    } catch (err) {
      ctx.api.showToast(`Accept failed: ${err.message}`);
    }
  });

  const declineBtn = el("button", { class: "btn-sm" }, "Decline");
  declineBtn.addEventListener("click", async () => {
    try {
      await ctx.api.apiPost(`/api/session/${sid()}/respond/${requestId}`, {
        action: "decline"
      });
      removePendingRequest(requestId);
    } catch (err) {
      ctx.api.showToast(`Decline failed: ${err.message}`);
    }
  });

  const cancelBtn = el("button", { class: "btn-danger btn-sm" }, "Cancel");
  cancelBtn.addEventListener("click", async () => {
    try {
      await ctx.api.apiPost(`/api/session/${sid()}/respond/${requestId}`, {
        action: "cancel"
      });
      removePendingRequest(requestId);
    } catch (err) {
      ctx.api.showToast(`Cancel failed: ${err.message}`);
    }
  });

  btnRow.appendChild(acceptBtn);
  btnRow.appendChild(declineBtn);
  btnRow.appendChild(cancelBtn);
  card.appendChild(btnRow);

  return card;
}

function buildGenericPendingCard(requestId, kind, params) {
  const card = el("div", { class: "card" });

  card.appendChild(el("div", { style: { display: "flex", justifyContent: "space-between", alignItems: "center" } }, [
    el("span", { class: "card-title" }, `${kind} Request`),
    el("span", { class: "badge-pill badge-accent" }, requestId)
  ]));

  card.appendChild(el("pre", { style: { marginTop: "8px" } }, JSON.stringify(params, null, 2)));

  const textarea = el("textarea", { rows: "4", placeholder: "Enter response JSON...", style: { marginTop: "8px" } });
  card.appendChild(textarea);

  const respondBtn = el("button", { class: "btn-primary btn-sm", style: { marginTop: "8px" } }, "Respond");
  respondBtn.addEventListener("click", async () => {
    let body;
    try {
      body = JSON.parse(textarea.value);
    } catch {
      body = { text: textarea.value };
    }
    try {
      await ctx.api.apiPost(`/api/session/${sid()}/respond/${requestId}`, body);
      removePendingRequest(requestId);
    } catch (err) {
      ctx.api.showToast(`Respond failed: ${err.message}`);
    }
  });
  card.appendChild(respondBtn);

  return card;
}
