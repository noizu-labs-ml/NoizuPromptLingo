/**
 * api.js - HTTP API client and SSE event source management
 */

import { el } from "./render.js";
export { el };

let token = null;

/**
 * Initialize token from query param or sessionStorage.
 * Strips token from URL after capture.
 */
export function initToken() {
  const params = new URLSearchParams(window.location.search);
  const paramToken = params.get("token");
  if (paramToken) {
    sessionStorage.setItem("inspector_token", paramToken);
    token = paramToken;
    params.delete("token");
    const newUrl = params.toString()
      ? `${window.location.pathname}?${params.toString()}`
      : window.location.pathname;
    window.history.replaceState({}, "", newUrl);
  } else {
    token = sessionStorage.getItem("inspector_token");
  }

  // Token is optional — the origin guard (localhost-only) provides baseline
  // security. When no token is configured server-side, api_auth is a no-op.

  return token;
}

/**
 * Get the current token.
 */
export function getToken() {
  return token;
}

/**
 * Show a toast notification.
 */
export function showToast(message, type = "error") {
  const area = document.getElementById("toast-area");
  if (!area) return;

  const toast = el("div", { class: `toast toast-${type}` }, [
    el("span", { style: { flex: "1" } }, message),
    el("button", {
      class: "toast-close",
      onClick: () => toast.remove()
    }, "×")
  ]);
  area.appendChild(toast);

  setTimeout(() => {
    if (toast.parentNode) toast.remove();
  }, 5000);
}

/**
 * Make an authenticated JSON fetch.
 * @param {string} path
 * @param {Object} [options]
 * @returns {Promise<any>}
 */
export async function apiFetch(path, options = {}) {
  const headers = {
    "Content-Type": "application/json",
    ...options.headers
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const fetchOpts = {
    ...options,
    headers
  };

  if (options.body && typeof options.body === "object" && !(options.body instanceof FormData)) {
    fetchOpts.body = JSON.stringify(options.body);
  }

  const resp = await fetch(path, fetchOpts);

  if (!resp.ok) {
    let errorMsg = `HTTP ${resp.status}`;
    try {
      const body = await resp.json();
      if (body.error) {
        errorMsg = typeof body.error === "string" ? body.error : body.error.message || JSON.stringify(body.error);
      }
    } catch {
      // use status text
      errorMsg = `HTTP ${resp.status}: ${resp.statusText}`;
    }
    throw new Error(errorMsg);
  }

  if (resp.status === 204) return null;

  const contentType = resp.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    return resp.json();
  }
  return resp.text();
}

// Convenience methods
export function apiGet(path) {
  return apiFetch(path, { method: "GET" });
}

export function apiPost(path, body) {
  return apiFetch(path, { method: "POST", body });
}

export function apiDelete(path) {
  return apiFetch(path, { method: "DELETE" });
}

/**
 * Create an SSE EventSource connection.
 * Returns an object with methods to add listeners and close.
 */
export function createEventSource(sessionId, eventBus) {
  let es = null;
  let lastEventId = null;
  let reconnectTimer = null;
  let closed = false;

  const EVENT_NAMES = ["frame", "notification", "progress", "call_result", "pending_request", "pending_resolved", "status"];

  function connect() {
    if (closed) return;

    let url = `/api/session/${sessionId}/events?token=${encodeURIComponent(token || "")}`;
    if (lastEventId) {
      url += `&last_event_id=${encodeURIComponent(lastEventId)}`;
    }

    es = new EventSource(url);

    for (const name of EVENT_NAMES) {
      es.addEventListener(name, (evt) => {
        if (evt.lastEventId) {
          lastEventId = evt.lastEventId;
        }
        let data;
        try {
          data = JSON.parse(evt.data);
        } catch {
          data = evt.data;
        }
        eventBus.emit(name, data, evt.lastEventId);
      });
    }

    es.onerror = () => {
      if (closed) return;
      es.close();
      reconnectTimer = setTimeout(connect, 1000);
    };
  }

  connect();

  return {
    close() {
      closed = true;
      if (reconnectTimer) clearTimeout(reconnectTimer);
      if (es) es.close();
    }
  };
}

/**
 * Create a simple event bus for re-broadcasting SSE events.
 */
export function createEventBus() {
  const listeners = {};

  return {
    on(event, fn) {
      if (!listeners[event]) listeners[event] = [];
      listeners[event].push(fn);
    },

    off(event, fn) {
      if (!listeners[event]) return;
      listeners[event] = listeners[event].filter(f => f !== fn);
    },

    emit(event, data, id) {
      if (listeners[event]) {
        for (const fn of listeners[event]) {
          try {
            fn(data, id);
          } catch (err) {
            console.error(`Event handler error [${event}]:`, err);
          }
        }
      }
    }
  };
}
