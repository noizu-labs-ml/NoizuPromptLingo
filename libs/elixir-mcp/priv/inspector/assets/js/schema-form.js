/**
 * schema-form.js - Build dynamic forms from JSON Schema
 */

import { el } from "./render.js";

let formIdCounter = 0;

/**
 * Build a form from a JSON Schema, appending to container.
 * Returns {getValue(), setValue(v)} interface.
 * @param {Object} schema
 * @param {HTMLElement} container
 * @param {Object} [options] - {completionFn?}
 * @returns {{getValue: function, setValue: function}}
 */
export function buildForm(schema, container, options = {}) {
  container.innerHTML = "";
  const formId = `sf-${++formIdCounter}`;

  // Raw JSON toggle
  const rawContainer = el("div", { style: { display: "none" } });
  const rawTextarea = el("textarea", { rows: "8", placeholder: "Enter raw JSON" });
  rawContainer.appendChild(rawTextarea);

  let isRaw = false;
  const toggleLink = el("span", { class: "raw-toggle" }, "Switch to raw JSON");
  toggleLink.addEventListener("click", () => {
    isRaw = !isRaw;
    if (isRaw) {
      const val = getStructuredValue();
      rawTextarea.value = JSON.stringify(val, null, 2);
      formContent.style.display = "none";
      rawContainer.style.display = "";
      toggleLink.textContent = "Switch to form";
    } else {
      try {
        const parsed = JSON.parse(rawTextarea.value);
        setStructuredValue(parsed);
      } catch {
        // keep raw open if invalid
        return;
      }
      formContent.style.display = "";
      rawContainer.style.display = "none";
      toggleLink.textContent = "Switch to raw JSON";
    }
  });

  container.appendChild(toggleLink);

  const formContent = el("div", {});
  const { getVal, setVal, node } = buildField(schema || { type: "object" }, formId, options);
  formContent.appendChild(node);

  container.appendChild(formContent);
  container.appendChild(rawContainer);

  function getStructuredValue() {
    return getVal();
  }

  function setStructuredValue(v) {
    setVal(v);
  }

  return {
    getValue() {
      if (isRaw) {
        try {
          return JSON.parse(rawTextarea.value);
        } catch {
          return {};
        }
      }
      return getStructuredValue();
    },
    setValue(v) {
      if (isRaw) {
        rawTextarea.value = JSON.stringify(v, null, 2);
      }
      setStructuredValue(v);
    }
  };
}

function buildField(schema, prefix, options) {
  if (!schema) schema = {};

  // Handle const
  if (schema.const !== undefined) {
    return buildConstField(schema, prefix);
  }

  // Handle oneOf / anyOf
  if (schema.oneOf || schema.anyOf) {
    // Nullable pattern: anyOf/oneOf with exactly [<type>, {type:"null"}] or vice versa
    // → render the non-null type directly (as optional)
    const variants = schema.oneOf || schema.anyOf;
    const nullable = extractNullable(variants);
    if (nullable) {
      return buildField({ ...nullable, _nullable: true }, prefix, options);
    }
    return buildVariantField(schema, prefix, options);
  }

  const type = schema.type || inferType(schema);

  switch (type) {
    case "object":
      return buildObjectField(schema, prefix, options);
    case "array":
      return buildArrayField(schema, prefix, options);
    case "string":
      return buildStringField(schema, prefix, options);
    case "number":
    case "integer":
      return buildNumberField(schema, prefix, type);
    case "boolean":
      return buildBooleanField(schema, prefix);
    case "null":
      return {
        node: el("div", { class: "form-hint" }, "(null)"),
        getVal() { return null; },
        setVal() {}
      };
    default:
      return buildStringField(schema, prefix, options);
  }
}

function inferType(schema) {
  if (schema.properties) return "object";
  if (schema.items) return "array";
  if (schema.enum) return "string";
  return "string";
}

function buildObjectField(schema, prefix, options) {
  const properties = schema.properties || {};
  const required = new Set(schema.required || []);
  const fields = {};
  const fieldNodes = [];

  const container = el("div", {});

  for (const [key, propSchema] of Object.entries(properties)) {
    const fieldId = `${prefix}-${key}`;
    const isRequired = required.has(key);
    const desc = propSchema.description;

    const label = el("label", { htmlFor: fieldId }, [
      key,
      isRequired ? el("span", { class: "required-marker" }, "*") : null
    ]);

    const fieldWrapper = el("div", { class: "form-group" });
    fieldWrapper.appendChild(label);
    if (desc) {
      fieldWrapper.appendChild(el("div", { class: "form-hint" }, desc));
    }

    const { getVal, setVal, node } = buildField(propSchema, fieldId, options);
    fields[key] = { getVal, setVal, required: isRequired };
    fieldWrapper.appendChild(node);
    fieldNodes.push(fieldWrapper);
  }

  for (const fn of fieldNodes) {
    container.appendChild(fn);
  }

  return {
    node: container,
    getVal() {
      const result = {};
      for (const [key, field] of Object.entries(fields)) {
        const v = field.getVal();
        // Omit empty optional fields
        if (!field.required && isEmpty(v)) continue;
        result[key] = v;
      }
      return result;
    },
    setVal(v) {
      if (!v || typeof v !== "object") return;
      for (const [key, field] of Object.entries(fields)) {
        if (key in v) {
          field.setVal(v[key]);
        }
      }
    }
  };
}

function buildArrayField(schema, prefix, options) {
  const itemSchema = schema.items || {};
  const items = [];
  const listEl = el("div", {});

  function addItem(val) {
    const idx = items.length;
    const itemId = `${prefix}-item-${idx}`;
    const row = el("div", { class: "array-item-row" });
    const { getVal, setVal, node } = buildField(itemSchema, itemId, options);
    if (val !== undefined) setVal(val);

    const removeBtn = el("button", { class: "btn-sm btn-danger", type: "button" }, "x");
    removeBtn.addEventListener("click", () => {
      const itemIdx = items.findIndex(it => it.row === row);
      if (itemIdx !== -1) {
        items.splice(itemIdx, 1);
        row.remove();
      }
    });

    row.appendChild(node);
    row.appendChild(removeBtn);
    listEl.appendChild(row);

    items.push({ getVal, setVal, row });
  }

  const addBtn = el("button", { class: "btn-sm", type: "button" }, "+ Add");
  addBtn.addEventListener("click", () => addItem());

  const container = el("div", {}, [listEl, addBtn]);

  // Add defaults
  if (Array.isArray(schema.default)) {
    for (const d of schema.default) addItem(d);
  }

  return {
    node: container,
    getVal() {
      return items.map(it => it.getVal());
    },
    setVal(v) {
      // Clear existing
      items.length = 0;
      listEl.innerHTML = "";
      if (Array.isArray(v)) {
        for (const item of v) addItem(item);
      }
    }
  };
}

function buildStringField(schema, prefix, options) {
  let input;
  const datalistId = `${prefix}-dl`;

  if (schema.enum) {
    input = el("select", { id: prefix });
    input.appendChild(el("option", { value: "" }, "-- select --"));
    for (const opt of schema.enum) {
      input.appendChild(el("option", { value: opt }, opt));
    }
  } else if (schema.format === "textarea" || (schema.description && schema.description.toLowerCase().includes("multiline"))) {
    input = el("textarea", { id: prefix, rows: "4" });
  } else {
    input = el("input", { type: "text", id: prefix, list: datalistId });
  }

  if (schema.default !== undefined) {
    input.value = String(schema.default);
  }

  const container = el("div", {}, [input]);

  // Add datalist for completion support
  if (!schema.enum && input.tagName !== "TEXTAREA") {
    const datalist = el("datalist", { id: datalistId });
    container.appendChild(datalist);

    // If completionFn provided, hook up debounced completion
    if (options.completionFn) {
      let debounceTimer = null;
      input.addEventListener("input", () => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(async () => {
          try {
            const values = await options.completionFn(input.name || prefix, input.value);
            datalist.innerHTML = "";
            if (Array.isArray(values)) {
              for (const v of values) {
                datalist.appendChild(el("option", { value: v }));
              }
            }
          } catch {
            // ignore completion errors
          }
        }, 300);
      });
    }
  }

  return {
    node: container,
    getVal() {
      return input.value;
    },
    setVal(v) {
      input.value = v ?? "";
    }
  };
}

function buildNumberField(schema, prefix, type) {
  const input = el("input", {
    type: "number",
    id: prefix,
    step: type === "integer" ? "1" : "any"
  });

  if (schema.default !== undefined) {
    input.value = String(schema.default);
  }
  if (schema.minimum !== undefined) input.min = String(schema.minimum);
  if (schema.maximum !== undefined) input.max = String(schema.maximum);

  return {
    node: el("div", {}, [input]),
    getVal() {
      const v = input.value;
      if (v === "") return undefined;
      return type === "integer" ? parseInt(v, 10) : parseFloat(v);
    },
    setVal(v) {
      input.value = v !== undefined && v !== null ? String(v) : "";
    }
  };
}

function buildBooleanField(schema, prefix) {
  const input = el("input", {
    type: "checkbox",
    id: prefix
  });

  if (schema.default === true) {
    input.checked = true;
  }

  const wrapper = el("div", { style: { display: "flex", alignItems: "center", gap: "6px" } }, [input]);

  return {
    node: wrapper,
    getVal() {
      return input.checked;
    },
    setVal(v) {
      input.checked = !!v;
    }
  };
}

function buildConstField(schema, prefix) {
  const val = schema.const;
  const display = el("code", {}, JSON.stringify(val));
  return {
    node: el("div", {}, [display]),
    getVal() { return val; },
    setVal() { /* const cannot be changed */ }
  };
}

function extractNullable(variants) {
  if (variants.length !== 2) return null;
  const nullIdx = variants.findIndex(v => v.type === "null");
  if (nullIdx === -1) return null;
  return variants[1 - nullIdx];
}

function variantLabel(v, i) {
  if (v.title) return v.title;
  if (v.description) return v.description;
  if (v.type) return Array.isArray(v.type) ? v.type.join(" | ") : v.type;
  if (v.properties) return "object";
  if (v.items) return "array";
  if (v.const !== undefined) return JSON.stringify(v.const);
  if (v.enum) return `enum(${v.enum.join(", ")})`;
  return `Variant ${i + 1}`;
}

function buildVariantField(schema, prefix, options) {
  const variants = schema.oneOf || schema.anyOf || [];
  const selectId = `${prefix}-variant-sel`;

  const select = el("select", { id: selectId });
  const subContainer = el("div", {});
  const subForms = [];

  for (let i = 0; i < variants.length; i++) {
    const v = variants[i];
    const label = variantLabel(v, i);
    select.appendChild(el("option", { value: String(i) }, label));

    const { getVal, setVal, node } = buildField(v, `${prefix}-var-${i}`, options);
    node.style.display = i === 0 ? "" : "none";
    subContainer.appendChild(node);
    subForms.push({ getVal, setVal, node });
  }

  select.addEventListener("change", () => {
    const idx = parseInt(select.value, 10);
    for (let i = 0; i < subForms.length; i++) {
      subForms[i].node.style.display = i === idx ? "" : "none";
    }
  });

  const container = el("div", {}, [
    el("div", { class: "form-group" }, [select]),
    subContainer
  ]);

  return {
    node: container,
    getVal() {
      const idx = parseInt(select.value, 10);
      return subForms[idx]?.getVal();
    },
    setVal(v) {
      // Try to match value to variant
      for (let i = 0; i < subForms.length; i++) {
        try {
          subForms[i].setVal(v);
          select.value = String(i);
          for (let j = 0; j < subForms.length; j++) {
            subForms[j].node.style.display = j === i ? "" : "none";
          }
          return;
        } catch {
          // try next
        }
      }
    }
  };
}

function isEmpty(v) {
  if (v === undefined || v === null || v === "") return true;
  if (typeof v === "object" && !Array.isArray(v) && Object.keys(v).length === 0) return true;
  if (Array.isArray(v) && v.length === 0) return true;
  return false;
}
