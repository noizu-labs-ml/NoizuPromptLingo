/**
 * render.js - DOM helpers and content rendering
 */

/**
 * Create a DOM element with attributes and children.
 * @param {string} tag
 * @param {Object} [attrs] - key/value pairs; "class" for className, "on*" for events, "dataset" for data-*, "style" for object styles
 * @param {Array|string|Node} [children]
 * @returns {HTMLElement}
 */
export function el(tag, attrs, children) {
  const node = document.createElement(tag);
  if (attrs) {
    for (const [k, v] of Object.entries(attrs)) {
      if (k === "class" || k === "className") {
        if (v) node.className = v;
      } else if (k === "dataset") {
        for (const [dk, dv] of Object.entries(v)) {
          node.dataset[dk] = dv;
        }
      } else if (k === "style" && typeof v === "object") {
        Object.assign(node.style, v);
      } else if (k.startsWith("on") && typeof v === "function") {
        node.addEventListener(k.slice(2).toLowerCase(), v);
      } else if (k === "htmlFor") {
        node.htmlFor = v;
      } else if (k === "checked" || k === "disabled" || k === "required" || k === "readOnly" || k === "selected" || k === "controls" || k === "autoplay" || k === "multiple") {
        if (v) node[k] = true;
      } else if (v !== null && v !== undefined && v !== false) {
        node.setAttribute(k, v);
      }
    }
  }
  if (children !== undefined && children !== null) {
    appendChildren(node, children);
  }
  return node;
}

function appendChildren(parent, children) {
  if (Array.isArray(children)) {
    for (const child of children) {
      if (child === null || child === undefined) continue;
      if (typeof child === "string" || typeof child === "number") {
        parent.appendChild(document.createTextNode(String(child)));
      } else if (child instanceof Node) {
        parent.appendChild(child);
      } else if (Array.isArray(child)) {
        appendChildren(parent, child);
      }
    }
  } else if (typeof children === "string" || typeof children === "number") {
    parent.appendChild(document.createTextNode(String(children)));
  } else if (children instanceof Node) {
    parent.appendChild(children);
  }
}

/**
 * Try to detect if a string is JSON and return parsed version, or null.
 */
function tryParseJSON(str) {
  if (typeof str !== "string") return null;
  const trimmed = str.trim();
  if ((trimmed.startsWith("{") && trimmed.endsWith("}")) ||
      (trimmed.startsWith("[") && trimmed.endsWith("]"))) {
    try {
      return JSON.parse(trimmed);
    } catch {
      return null;
    }
  }
  return null;
}

/**
 * Render an array of MCP content items into a container.
 * Content types: text, image, audio, resource_link, resource
 */
export function renderContent(contentArray, container) {
  container.innerHTML = "";
  if (!Array.isArray(contentArray)) {
    contentArray = [contentArray];
  }

  for (const item of contentArray) {
    if (!item || typeof item !== "object") continue;

    switch (item.type) {
      case "text": {
        const parsed = tryParseJSON(item.text);
        if (parsed !== null) {
          const wrapper = el("div", {}, []);
          const toggleBtn = el("span", { class: "raw-toggle" }, "Toggle raw");
          const pre = el("pre", {}, JSON.stringify(parsed, null, 2));
          const raw = el("pre", { style: { display: "none" } }, item.text);
          let showingPretty = true;
          toggleBtn.addEventListener("click", () => {
            showingPretty = !showingPretty;
            pre.style.display = showingPretty ? "" : "none";
            raw.style.display = showingPretty ? "none" : "";
          });
          wrapper.append(toggleBtn, pre, raw);
          container.appendChild(wrapper);
        } else {
          container.appendChild(el("pre", { style: { whiteSpace: "pre-wrap" } }, item.text ?? ""));
        }
        break;
      }

      case "image": {
        const src = `data:${item.mimeType || "image/png"};base64,${item.data}`;
        container.appendChild(el("img", { class: "rendered-image", src, alt: "image content" }));
        break;
      }

      case "audio": {
        const audioSrc = `data:${item.mimeType || "audio/wav"};base64,${item.data}`;
        const audio = el("audio", { controls: true, class: "rendered-audio" }, [
          el("source", { src: audioSrc, type: item.mimeType || "audio/wav" })
        ]);
        container.appendChild(audio);
        break;
      }

      case "resource_link": {
        container.appendChild(el("div", { class: "resource-link-row" }, [
          el("span", {}, "🔗"),
          el("code", {}, item.uri || ""),
          item.name ? el("span", { class: "text-muted" }, ` (${item.name})`) : null
        ]));
        break;
      }

      case "resource": {
        if (item.resource) {
          const nested = el("div", { class: "card", style: { marginTop: "8px" } });
          nested.appendChild(el("div", { class: "mono", style: { marginBottom: "4px" } }, item.resource.uri || ""));
          const contentEl = el("div", {});
          renderResourceContents([item.resource], contentEl);
          nested.appendChild(contentEl);
          container.appendChild(nested);
        }
        break;
      }

      default: {
        container.appendChild(el("pre", {}, JSON.stringify(item, null, 2)));
      }
    }
  }
}

/**
 * Render resource contents (from /resources/read response).
 * Each item has {uri, mimeType?, text?, blob?}
 */
export function renderResourceContents(contents, container) {
  container.innerHTML = "";
  if (!Array.isArray(contents)) return;

  for (const item of contents) {
    const wrapper = el("div", { style: { marginBottom: "8px" } });

    if (item.uri) {
      wrapper.appendChild(el("div", { class: "mono", style: { fontSize: "11px", color: "var(--text-muted)", marginBottom: "4px" } }, item.uri));
    }

    if (item.text !== undefined) {
      const mime = item.mimeType || "";
      if (mime === "application/json" || mime.endsWith("+json")) {
        const parsed = tryParseJSON(item.text);
        if (parsed !== null) {
          wrapper.appendChild(el("pre", {}, JSON.stringify(parsed, null, 2)));
        } else {
          wrapper.appendChild(el("pre", {}, item.text));
        }
      } else {
        wrapper.appendChild(el("pre", {}, item.text));
      }
    } else if (item.blob) {
      const mime = item.mimeType || "";
      if (mime.startsWith("image/")) {
        const src = `data:${mime};base64,${item.blob}`;
        wrapper.appendChild(el("img", { class: "rendered-image", src, alt: item.uri || "resource" }));
      } else if (mime.startsWith("audio/")) {
        const audioSrc = `data:${mime};base64,${item.blob}`;
        wrapper.appendChild(el("audio", { controls: true, class: "rendered-audio" }, [
          el("source", { src: audioSrc, type: mime })
        ]));
      } else {
        const byteLength = Math.ceil((item.blob.length * 3) / 4);
        const sizeStr = byteLength > 1024 * 1024
          ? `${(byteLength / (1024 * 1024)).toFixed(1)} MB`
          : byteLength > 1024
            ? `${(byteLength / 1024).toFixed(1)} KB`
            : `${byteLength} bytes`;

        const downloadBtn = el("button", { class: "btn-sm" }, `Download (${sizeStr})`);
        downloadBtn.addEventListener("click", () => {
          const link = document.createElement("a");
          link.href = `data:${mime || "application/octet-stream"};base64,${item.blob}`;
          link.download = (item.uri || "download").split("/").pop();
          link.click();
        });
        wrapper.appendChild(downloadBtn);
      }
    }

    container.appendChild(wrapper);
  }
}
