/**
 * @license
 * Copyright 2019 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const H = globalThis, W = H.ShadowRoot && (H.ShadyCSS === void 0 || H.ShadyCSS.nativeShadow) && "adoptedStyleSheets" in Document.prototype && "replace" in CSSStyleSheet.prototype, K = Symbol(), tt = /* @__PURE__ */ new WeakMap();
let ft = class {
  constructor(t, e, r) {
    if (this._$cssResult$ = !0, r !== K) throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");
    this.cssText = t, this.t = e;
  }
  get styleSheet() {
    let t = this.o;
    const e = this.t;
    if (W && t === void 0) {
      const r = e !== void 0 && e.length === 1;
      r && (t = tt.get(e)), t === void 0 && ((this.o = t = new CSSStyleSheet()).replaceSync(this.cssText), r && tt.set(e, t));
    }
    return t;
  }
  toString() {
    return this.cssText;
  }
};
const mt = (s) => new ft(typeof s == "string" ? s : s + "", void 0, K), $t = (s, ...t) => {
  const e = s.length === 1 ? s[0] : t.reduce((r, i, n) => r + ((o) => {
    if (o._$cssResult$ === !0) return o.cssText;
    if (typeof o == "number") return o;
    throw Error("Value passed to 'css' function must be a 'css' function result: " + o + ". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.");
  })(i) + s[n + 1], s[0]);
  return new ft(e, s, K);
}, qt = (s, t) => {
  if (W) s.adoptedStyleSheets = t.map((e) => e instanceof CSSStyleSheet ? e : e.styleSheet);
  else for (const e of t) {
    const r = document.createElement("style"), i = H.litNonce;
    i !== void 0 && r.setAttribute("nonce", i), r.textContent = e.cssText, s.appendChild(r);
  }
}, et = W ? (s) => s : (s) => s instanceof CSSStyleSheet ? ((t) => {
  let e = "";
  for (const r of t.cssRules) e += r.cssText;
  return mt(e);
})(s) : s;
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const { is: Et, defineProperty: kt, getOwnPropertyDescriptor: St, getOwnPropertyNames: Pt, getOwnPropertySymbols: Ct, getPrototypeOf: Tt } = Object, I = globalThis, st = I.trustedTypes, Ut = st ? st.emptyScript : "", Ot = I.reactiveElementPolyfillSupport, U = (s, t) => s, z = { toAttribute(s, t) {
  switch (t) {
    case Boolean:
      s = s ? Ut : null;
      break;
    case Object:
    case Array:
      s = s == null ? s : JSON.stringify(s);
  }
  return s;
}, fromAttribute(s, t) {
  let e = s;
  switch (t) {
    case Boolean:
      e = s !== null;
      break;
    case Number:
      e = s === null ? null : Number(s);
      break;
    case Object:
    case Array:
      try {
        e = JSON.parse(s);
      } catch {
        e = null;
      }
  }
  return e;
} }, F = (s, t) => !Et(s, t), rt = { attribute: !0, type: String, converter: z, reflect: !1, useDefault: !1, hasChanged: F };
Symbol.metadata ??= Symbol("metadata"), I.litPropertyMetadata ??= /* @__PURE__ */ new WeakMap();
let E = class extends HTMLElement {
  static addInitializer(t) {
    this._$Ei(), (this.l ??= []).push(t);
  }
  static get observedAttributes() {
    return this.finalize(), this._$Eh && [...this._$Eh.keys()];
  }
  static createProperty(t, e = rt) {
    if (e.state && (e.attribute = !1), this._$Ei(), this.prototype.hasOwnProperty(t) && ((e = Object.create(e)).wrapped = !0), this.elementProperties.set(t, e), !e.noAccessor) {
      const r = Symbol(), i = this.getPropertyDescriptor(t, r, e);
      i !== void 0 && kt(this.prototype, t, i);
    }
  }
  static getPropertyDescriptor(t, e, r) {
    const { get: i, set: n } = St(this.prototype, t) ?? { get() {
      return this[e];
    }, set(o) {
      this[e] = o;
    } };
    return { get: i, set(o) {
      const d = i?.call(this);
      n?.call(this, o), this.requestUpdate(t, d, r);
    }, configurable: !0, enumerable: !0 };
  }
  static getPropertyOptions(t) {
    return this.elementProperties.get(t) ?? rt;
  }
  static _$Ei() {
    if (this.hasOwnProperty(U("elementProperties"))) return;
    const t = Tt(this);
    t.finalize(), t.l !== void 0 && (this.l = [...t.l]), this.elementProperties = new Map(t.elementProperties);
  }
  static finalize() {
    if (this.hasOwnProperty(U("finalized"))) return;
    if (this.finalized = !0, this._$Ei(), this.hasOwnProperty(U("properties"))) {
      const e = this.properties, r = [...Pt(e), ...Ct(e)];
      for (const i of r) this.createProperty(i, e[i]);
    }
    const t = this[Symbol.metadata];
    if (t !== null) {
      const e = litPropertyMetadata.get(t);
      if (e !== void 0) for (const [r, i] of e) this.elementProperties.set(r, i);
    }
    this._$Eh = /* @__PURE__ */ new Map();
    for (const [e, r] of this.elementProperties) {
      const i = this._$Eu(e, r);
      i !== void 0 && this._$Eh.set(i, e);
    }
    this.elementStyles = this.finalizeStyles(this.styles);
  }
  static finalizeStyles(t) {
    const e = [];
    if (Array.isArray(t)) {
      const r = new Set(t.flat(1 / 0).reverse());
      for (const i of r) e.unshift(et(i));
    } else t !== void 0 && e.push(et(t));
    return e;
  }
  static _$Eu(t, e) {
    const r = e.attribute;
    return r === !1 ? void 0 : typeof r == "string" ? r : typeof t == "string" ? t.toLowerCase() : void 0;
  }
  constructor() {
    super(), this._$Ep = void 0, this.isUpdatePending = !1, this.hasUpdated = !1, this._$Em = null, this._$Ev();
  }
  _$Ev() {
    this._$ES = new Promise((t) => this.enableUpdating = t), this._$AL = /* @__PURE__ */ new Map(), this._$E_(), this.requestUpdate(), this.constructor.l?.forEach((t) => t(this));
  }
  addController(t) {
    (this._$EO ??= /* @__PURE__ */ new Set()).add(t), this.renderRoot !== void 0 && this.isConnected && t.hostConnected?.();
  }
  removeController(t) {
    this._$EO?.delete(t);
  }
  _$E_() {
    const t = /* @__PURE__ */ new Map(), e = this.constructor.elementProperties;
    for (const r of e.keys()) this.hasOwnProperty(r) && (t.set(r, this[r]), delete this[r]);
    t.size > 0 && (this._$Ep = t);
  }
  createRenderRoot() {
    const t = this.shadowRoot ?? this.attachShadow(this.constructor.shadowRootOptions);
    return qt(t, this.constructor.elementStyles), t;
  }
  connectedCallback() {
    this.renderRoot ??= this.createRenderRoot(), this.enableUpdating(!0), this._$EO?.forEach((t) => t.hostConnected?.());
  }
  enableUpdating(t) {
  }
  disconnectedCallback() {
    this._$EO?.forEach((t) => t.hostDisconnected?.());
  }
  attributeChangedCallback(t, e, r) {
    this._$AK(t, r);
  }
  _$ET(t, e) {
    const r = this.constructor.elementProperties.get(t), i = this.constructor._$Eu(t, r);
    if (i !== void 0 && r.reflect === !0) {
      const n = (r.converter?.toAttribute !== void 0 ? r.converter : z).toAttribute(e, r.type);
      this._$Em = t, n == null ? this.removeAttribute(i) : this.setAttribute(i, n), this._$Em = null;
    }
  }
  _$AK(t, e) {
    const r = this.constructor, i = r._$Eh.get(t);
    if (i !== void 0 && this._$Em !== i) {
      const n = r.getPropertyOptions(i), o = typeof n.converter == "function" ? { fromAttribute: n.converter } : n.converter?.fromAttribute !== void 0 ? n.converter : z;
      this._$Em = i;
      const d = o.fromAttribute(e, n.type);
      this[i] = d ?? this._$Ej?.get(i) ?? d, this._$Em = null;
    }
  }
  requestUpdate(t, e, r, i = !1, n) {
    if (t !== void 0) {
      const o = this.constructor;
      if (i === !1 && (n = this[t]), r ??= o.getPropertyOptions(t), !((r.hasChanged ?? F)(n, e) || r.useDefault && r.reflect && n === this._$Ej?.get(t) && !this.hasAttribute(o._$Eu(t, r)))) return;
      this.C(t, e, r);
    }
    this.isUpdatePending === !1 && (this._$ES = this._$EP());
  }
  C(t, e, { useDefault: r, reflect: i, wrapped: n }, o) {
    r && !(this._$Ej ??= /* @__PURE__ */ new Map()).has(t) && (this._$Ej.set(t, o ?? e ?? this[t]), n !== !0 || o !== void 0) || (this._$AL.has(t) || (this.hasUpdated || r || (e = void 0), this._$AL.set(t, e)), i === !0 && this._$Em !== t && (this._$Eq ??= /* @__PURE__ */ new Set()).add(t));
  }
  async _$EP() {
    this.isUpdatePending = !0;
    try {
      await this._$ES;
    } catch (e) {
      Promise.reject(e);
    }
    const t = this.scheduleUpdate();
    return t != null && await t, !this.isUpdatePending;
  }
  scheduleUpdate() {
    return this.performUpdate();
  }
  performUpdate() {
    if (!this.isUpdatePending) return;
    if (!this.hasUpdated) {
      if (this.renderRoot ??= this.createRenderRoot(), this._$Ep) {
        for (const [i, n] of this._$Ep) this[i] = n;
        this._$Ep = void 0;
      }
      const r = this.constructor.elementProperties;
      if (r.size > 0) for (const [i, n] of r) {
        const { wrapped: o } = n, d = this[i];
        o !== !0 || this._$AL.has(i) || d === void 0 || this.C(i, void 0, n, d);
      }
    }
    let t = !1;
    const e = this._$AL;
    try {
      t = this.shouldUpdate(e), t ? (this.willUpdate(e), this._$EO?.forEach((r) => r.hostUpdate?.()), this.update(e)) : this._$EM();
    } catch (r) {
      throw t = !1, this._$EM(), r;
    }
    t && this._$AE(e);
  }
  willUpdate(t) {
  }
  _$AE(t) {
    this._$EO?.forEach((e) => e.hostUpdated?.()), this.hasUpdated || (this.hasUpdated = !0, this.firstUpdated(t)), this.updated(t);
  }
  _$EM() {
    this._$AL = /* @__PURE__ */ new Map(), this.isUpdatePending = !1;
  }
  get updateComplete() {
    return this.getUpdateComplete();
  }
  getUpdateComplete() {
    return this._$ES;
  }
  shouldUpdate(t) {
    return !0;
  }
  update(t) {
    this._$Eq &&= this._$Eq.forEach((e) => this._$ET(e, this[e])), this._$EM();
  }
  updated(t) {
  }
  firstUpdated(t) {
  }
};
E.elementStyles = [], E.shadowRootOptions = { mode: "open" }, E[U("elementProperties")] = /* @__PURE__ */ new Map(), E[U("finalized")] = /* @__PURE__ */ new Map(), Ot?.({ ReactiveElement: E }), (I.reactiveElementVersions ??= []).push("2.1.2");
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Q = globalThis, it = (s) => s, B = Q.trustedTypes, nt = B ? B.createPolicy("lit-html", { createHTML: (s) => s }) : void 0, bt = "$lit$", y = `lit$${Math.random().toFixed(9).slice(2)}$`, _t = "?" + y, Mt = `<${_t}>`, q = document, M = () => q.createComment(""), N = (s) => s === null || typeof s != "object" && typeof s != "function", J = Array.isArray, Nt = (s) => J(s) || typeof s?.[Symbol.iterator] == "function", L = `[ 	
\f\r]`, C = /<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g, ot = /-->/g, at = />/g, A = RegExp(`>|${L}(?:([^\\s"'>=/]+)(${L}*=${L}*(?:[^ 	
\f\r"'\`<>=]|("|')|))|$)`, "g"), lt = /'/g, dt = /"/g, yt = /^(?:script|style|textarea|title)$/i, Rt = (s) => (t, ...e) => ({ _$litType$: s, strings: t, values: e }), f = Rt(1), v = Symbol.for("lit-noChange"), p = Symbol.for("lit-nothing"), ct = /* @__PURE__ */ new WeakMap(), w = q.createTreeWalker(q, 129);
function vt(s, t) {
  if (!J(s) || !s.hasOwnProperty("raw")) throw Error("invalid template strings array");
  return nt !== void 0 ? nt.createHTML(t) : t;
}
const Ht = (s, t) => {
  const e = s.length - 1, r = [];
  let i, n = t === 2 ? "<svg>" : t === 3 ? "<math>" : "", o = C;
  for (let d = 0; d < e; d++) {
    const a = s[d];
    let c, g, l = -1, h = 0;
    for (; h < a.length && (o.lastIndex = h, g = o.exec(a), g !== null); ) h = o.lastIndex, o === C ? g[1] === "!--" ? o = ot : g[1] !== void 0 ? o = at : g[2] !== void 0 ? (yt.test(g[2]) && (i = RegExp("</" + g[2], "g")), o = A) : g[3] !== void 0 && (o = A) : o === A ? g[0] === ">" ? (o = i ?? C, l = -1) : g[1] === void 0 ? l = -2 : (l = o.lastIndex - g[2].length, c = g[1], o = g[3] === void 0 ? A : g[3] === '"' ? dt : lt) : o === dt || o === lt ? o = A : o === ot || o === at ? o = C : (o = A, i = void 0);
    const u = o === A && s[d + 1].startsWith("/>") ? " " : "";
    n += o === C ? a + Mt : l >= 0 ? (r.push(c), a.slice(0, l) + bt + a.slice(l) + y + u) : a + y + (l === -2 ? d : u);
  }
  return [vt(s, n + (s[e] || "<?>") + (t === 2 ? "</svg>" : t === 3 ? "</math>" : "")), r];
};
class R {
  constructor({ strings: t, _$litType$: e }, r) {
    let i;
    this.parts = [];
    let n = 0, o = 0;
    const d = t.length - 1, a = this.parts, [c, g] = Ht(t, e);
    if (this.el = R.createElement(c, r), w.currentNode = this.el.content, e === 2 || e === 3) {
      const l = this.el.content.firstChild;
      l.replaceWith(...l.childNodes);
    }
    for (; (i = w.nextNode()) !== null && a.length < d; ) {
      if (i.nodeType === 1) {
        if (i.hasAttributes()) for (const l of i.getAttributeNames()) if (l.endsWith(bt)) {
          const h = g[o++], u = i.getAttribute(l).split(y), m = /([.?@])?(.*)/.exec(h);
          a.push({ type: 1, index: n, name: m[2], strings: u, ctor: m[1] === "." ? Bt : m[1] === "?" ? It : m[1] === "@" ? jt : j }), i.removeAttribute(l);
        } else l.startsWith(y) && (a.push({ type: 6, index: n }), i.removeAttribute(l));
        if (yt.test(i.tagName)) {
          const l = i.textContent.split(y), h = l.length - 1;
          if (h > 0) {
            i.textContent = B ? B.emptyScript : "";
            for (let u = 0; u < h; u++) i.append(l[u], M()), w.nextNode(), a.push({ type: 2, index: ++n });
            i.append(l[h], M());
          }
        }
      } else if (i.nodeType === 8) if (i.data === _t) a.push({ type: 2, index: n });
      else {
        let l = -1;
        for (; (l = i.data.indexOf(y, l + 1)) !== -1; ) a.push({ type: 7, index: n }), l += y.length - 1;
      }
      n++;
    }
  }
  static createElement(t, e) {
    const r = q.createElement("template");
    return r.innerHTML = t, r;
  }
}
function k(s, t, e = s, r) {
  if (t === v) return t;
  let i = r !== void 0 ? e._$Co?.[r] : e._$Cl;
  const n = N(t) ? void 0 : t._$litDirective$;
  return i?.constructor !== n && (i?._$AO?.(!1), n === void 0 ? i = void 0 : (i = new n(s), i._$AT(s, e, r)), r !== void 0 ? (e._$Co ??= [])[r] = i : e._$Cl = i), i !== void 0 && (t = k(s, i._$AS(s, t.values), i, r)), t;
}
class zt {
  constructor(t, e) {
    this._$AV = [], this._$AN = void 0, this._$AD = t, this._$AM = e;
  }
  get parentNode() {
    return this._$AM.parentNode;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  u(t) {
    const { el: { content: e }, parts: r } = this._$AD, i = (t?.creationScope ?? q).importNode(e, !0);
    w.currentNode = i;
    let n = w.nextNode(), o = 0, d = 0, a = r[0];
    for (; a !== void 0; ) {
      if (o === a.index) {
        let c;
        a.type === 2 ? c = new S(n, n.nextSibling, this, t) : a.type === 1 ? c = new a.ctor(n, a.name, a.strings, this, t) : a.type === 6 && (c = new Dt(n, this, t)), this._$AV.push(c), a = r[++d];
      }
      o !== a?.index && (n = w.nextNode(), o++);
    }
    return w.currentNode = q, i;
  }
  p(t) {
    let e = 0;
    for (const r of this._$AV) r !== void 0 && (r.strings !== void 0 ? (r._$AI(t, r, e), e += r.strings.length - 2) : r._$AI(t[e])), e++;
  }
}
class S {
  get _$AU() {
    return this._$AM?._$AU ?? this._$Cv;
  }
  constructor(t, e, r, i) {
    this.type = 2, this._$AH = p, this._$AN = void 0, this._$AA = t, this._$AB = e, this._$AM = r, this.options = i, this._$Cv = i?.isConnected ?? !0;
  }
  get parentNode() {
    let t = this._$AA.parentNode;
    const e = this._$AM;
    return e !== void 0 && t?.nodeType === 11 && (t = e.parentNode), t;
  }
  get startNode() {
    return this._$AA;
  }
  get endNode() {
    return this._$AB;
  }
  _$AI(t, e = this) {
    t = k(this, t, e), N(t) ? t === p || t == null || t === "" ? (this._$AH !== p && this._$AR(), this._$AH = p) : t !== this._$AH && t !== v && this._(t) : t._$litType$ !== void 0 ? this.$(t) : t.nodeType !== void 0 ? this.T(t) : Nt(t) ? this.k(t) : this._(t);
  }
  O(t) {
    return this._$AA.parentNode.insertBefore(t, this._$AB);
  }
  T(t) {
    this._$AH !== t && (this._$AR(), this._$AH = this.O(t));
  }
  _(t) {
    this._$AH !== p && N(this._$AH) ? this._$AA.nextSibling.data = t : this.T(q.createTextNode(t)), this._$AH = t;
  }
  $(t) {
    const { values: e, _$litType$: r } = t, i = typeof r == "number" ? this._$AC(t) : (r.el === void 0 && (r.el = R.createElement(vt(r.h, r.h[0]), this.options)), r);
    if (this._$AH?._$AD === i) this._$AH.p(e);
    else {
      const n = new zt(i, this), o = n.u(this.options);
      n.p(e), this.T(o), this._$AH = n;
    }
  }
  _$AC(t) {
    let e = ct.get(t.strings);
    return e === void 0 && ct.set(t.strings, e = new R(t)), e;
  }
  k(t) {
    J(this._$AH) || (this._$AH = [], this._$AR());
    const e = this._$AH;
    let r, i = 0;
    for (const n of t) i === e.length ? e.push(r = new S(this.O(M()), this.O(M()), this, this.options)) : r = e[i], r._$AI(n), i++;
    i < e.length && (this._$AR(r && r._$AB.nextSibling, i), e.length = i);
  }
  _$AR(t = this._$AA.nextSibling, e) {
    for (this._$AP?.(!1, !0, e); t !== this._$AB; ) {
      const r = it(t).nextSibling;
      it(t).remove(), t = r;
    }
  }
  setConnected(t) {
    this._$AM === void 0 && (this._$Cv = t, this._$AP?.(t));
  }
}
class j {
  get tagName() {
    return this.element.tagName;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  constructor(t, e, r, i, n) {
    this.type = 1, this._$AH = p, this._$AN = void 0, this.element = t, this.name = e, this._$AM = i, this.options = n, r.length > 2 || r[0] !== "" || r[1] !== "" ? (this._$AH = Array(r.length - 1).fill(new String()), this.strings = r) : this._$AH = p;
  }
  _$AI(t, e = this, r, i) {
    const n = this.strings;
    let o = !1;
    if (n === void 0) t = k(this, t, e, 0), o = !N(t) || t !== this._$AH && t !== v, o && (this._$AH = t);
    else {
      const d = t;
      let a, c;
      for (t = n[0], a = 0; a < n.length - 1; a++) c = k(this, d[r + a], e, a), c === v && (c = this._$AH[a]), o ||= !N(c) || c !== this._$AH[a], c === p ? t = p : t !== p && (t += (c ?? "") + n[a + 1]), this._$AH[a] = c;
    }
    o && !i && this.j(t);
  }
  j(t) {
    t === p ? this.element.removeAttribute(this.name) : this.element.setAttribute(this.name, t ?? "");
  }
}
class Bt extends j {
  constructor() {
    super(...arguments), this.type = 3;
  }
  j(t) {
    this.element[this.name] = t === p ? void 0 : t;
  }
}
class It extends j {
  constructor() {
    super(...arguments), this.type = 4;
  }
  j(t) {
    this.element.toggleAttribute(this.name, !!t && t !== p);
  }
}
class jt extends j {
  constructor(t, e, r, i, n) {
    super(t, e, r, i, n), this.type = 5;
  }
  _$AI(t, e = this) {
    if ((t = k(this, t, e, 0) ?? p) === v) return;
    const r = this._$AH, i = t === p && r !== p || t.capture !== r.capture || t.once !== r.once || t.passive !== r.passive, n = t !== p && (r === p || i);
    i && this.element.removeEventListener(this.name, this, r), n && this.element.addEventListener(this.name, this, t), this._$AH = t;
  }
  handleEvent(t) {
    typeof this._$AH == "function" ? this._$AH.call(this.options?.host ?? this.element, t) : this._$AH.handleEvent(t);
  }
}
class Dt {
  constructor(t, e, r) {
    this.element = t, this.type = 6, this._$AN = void 0, this._$AM = e, this.options = r;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  _$AI(t) {
    k(this, t);
  }
}
const Lt = { I: S }, Zt = Q.litHtmlPolyfillSupport;
Zt?.(R, S), (Q.litHtmlVersions ??= []).push("3.3.3");
const Vt = (s, t, e) => {
  const r = e?.renderBefore ?? t;
  let i = r._$litPart$;
  if (i === void 0) {
    const n = e?.renderBefore ?? null;
    r._$litPart$ = i = new S(t.insertBefore(M(), n), n, void 0, e ?? {});
  }
  return i._$AI(s), i;
};
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const G = globalThis;
let O = class extends E {
  constructor() {
    super(...arguments), this.renderOptions = { host: this }, this._$Do = void 0;
  }
  createRenderRoot() {
    const t = super.createRenderRoot();
    return this.renderOptions.renderBefore ??= t.firstChild, t;
  }
  update(t) {
    const e = this.render();
    this.hasUpdated || (this.renderOptions.isConnected = this.isConnected), super.update(t), this._$Do = Vt(e, this.renderRoot, this.renderOptions);
  }
  connectedCallback() {
    super.connectedCallback(), this._$Do?.setConnected(!0);
  }
  disconnectedCallback() {
    super.disconnectedCallback(), this._$Do?.setConnected(!1);
  }
  render() {
    return v;
  }
};
O._$litElement$ = !0, O.finalized = !0, G.litElementHydrateSupport?.({ LitElement: O });
const Wt = G.litElementPolyfillSupport;
Wt?.({ LitElement: O });
(G.litElementVersions ??= []).push("4.2.2");
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Kt = (s) => (t, e) => {
  e !== void 0 ? e.addInitializer(() => {
    customElements.define(s, t);
  }) : customElements.define(s, t);
};
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Ft = { attribute: !0, type: String, converter: z, reflect: !1, hasChanged: F }, Qt = (s = Ft, t, e) => {
  const { kind: r, metadata: i } = e;
  let n = globalThis.litPropertyMetadata.get(i);
  if (n === void 0 && globalThis.litPropertyMetadata.set(i, n = /* @__PURE__ */ new Map()), r === "setter" && ((s = Object.create(s)).wrapped = !0), n.set(e.name, s), r === "accessor") {
    const { name: o } = e;
    return { set(d) {
      const a = t.get.call(this);
      t.set.call(this, d), this.requestUpdate(o, a, s, !0, d);
    }, init(d) {
      return d !== void 0 && this.C(o, void 0, s, d), d;
    } };
  }
  if (r === "setter") {
    const { name: o } = e;
    return function(d) {
      const a = this[o];
      t.call(this, d), this.requestUpdate(o, a, s, !0, d);
    };
  }
  throw Error("Unsupported decorator location: " + r);
};
function P(s) {
  return (t, e) => typeof e == "object" ? Qt(s, t, e) : ((r, i, n) => {
    const o = i.hasOwnProperty(n);
    return i.constructor.createProperty(n, r), o ? Object.getOwnPropertyDescriptor(i, n) : void 0;
  })(s, t, e);
}
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
function Y(s) {
  return P({ ...s, state: !0, attribute: !1 });
}
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const At = { ATTRIBUTE: 1, CHILD: 2 }, xt = (s) => (...t) => ({ _$litDirective$: s, values: t });
let wt = class {
  constructor(t) {
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  _$AT(t, e, r) {
    this._$Ct = t, this._$AM = e, this._$Ci = r;
  }
  _$AS(t, e) {
    return this.update(t, e);
  }
  update(t, e) {
    return this.render(...e);
  }
};
/**
 * @license
 * Copyright 2018 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Jt = xt(class extends wt {
  constructor(s) {
    if (super(s), s.type !== At.ATTRIBUTE || s.name !== "class" || s.strings?.length > 2) throw Error("`classMap()` can only be used in the `class` attribute and must be the only part in the attribute.");
  }
  render(s) {
    return " " + Object.keys(s).filter((t) => s[t]).join(" ") + " ";
  }
  update(s, [t]) {
    if (this.st === void 0) {
      this.st = /* @__PURE__ */ new Set(), s.strings !== void 0 && (this.nt = new Set(s.strings.join(" ").split(/\s/).filter((r) => r !== "")));
      for (const r in t) t[r] && !this.nt?.has(r) && this.st.add(r);
      return this.render(t);
    }
    const e = s.element.classList;
    for (const r of this.st) r in t || (e.remove(r), this.st.delete(r));
    for (const r in t) {
      const i = !!t[r];
      i === this.st.has(r) || this.nt?.has(r) || (i ? (e.add(r), this.st.add(r)) : (e.remove(r), this.st.delete(r)));
    }
    return v;
  }
});
/**
 * @license
 * Copyright 2020 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const { I: Gt } = Lt, ht = (s) => s, ut = () => document.createComment(""), T = (s, t, e) => {
  const r = s._$AA.parentNode, i = t === void 0 ? s._$AB : t._$AA;
  if (e === void 0) {
    const n = r.insertBefore(ut(), i), o = r.insertBefore(ut(), i);
    e = new Gt(n, o, s, s.options);
  } else {
    const n = e._$AB.nextSibling, o = e._$AM, d = o !== s;
    if (d) {
      let a;
      e._$AQ?.(s), e._$AM = s, e._$AP !== void 0 && (a = s._$AU) !== o._$AU && e._$AP(a);
    }
    if (n !== i || d) {
      let a = e._$AA;
      for (; a !== n; ) {
        const c = ht(a).nextSibling;
        ht(r).insertBefore(a, i), a = c;
      }
    }
  }
  return e;
}, x = (s, t, e = s) => (s._$AI(t, e), s), Yt = {}, Xt = (s, t = Yt) => s._$AH = t, te = (s) => s._$AH, Z = (s) => {
  s._$AR(), s._$AA.remove();
};
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const pt = (s, t, e) => {
  const r = /* @__PURE__ */ new Map();
  for (let i = t; i <= e; i++) r.set(s[i], i);
  return r;
}, V = xt(class extends wt {
  constructor(s) {
    if (super(s), s.type !== At.CHILD) throw Error("repeat() can only be used in text expressions");
  }
  dt(s, t, e) {
    let r;
    e === void 0 ? e = t : t !== void 0 && (r = t);
    const i = [], n = [];
    let o = 0;
    for (const d of s) i[o] = r ? r(d, o) : o, n[o] = e(d, o), o++;
    return { values: n, keys: i };
  }
  render(s, t, e) {
    return this.dt(s, t, e).values;
  }
  update(s, [t, e, r]) {
    const i = te(s), { values: n, keys: o } = this.dt(t, e, r);
    if (!Array.isArray(i)) return this.ut = o, n;
    const d = this.ut ??= [], a = [];
    let c, g, l = 0, h = i.length - 1, u = 0, m = n.length - 1;
    for (; l <= h && u <= m; ) if (i[l] === null) l++;
    else if (i[h] === null) h--;
    else if (d[l] === o[u]) a[u] = x(i[l], n[u]), l++, u++;
    else if (d[h] === o[m]) a[m] = x(i[h], n[m]), h--, m--;
    else if (d[l] === o[m]) a[m] = x(i[l], n[m]), T(s, a[m + 1], i[l]), l++, m--;
    else if (d[h] === o[u]) a[u] = x(i[h], n[u]), T(s, i[l], i[h]), h--, u++;
    else if (c === void 0 && (c = pt(o, u, m), g = pt(d, l, h)), c.has(d[l])) if (c.has(d[h])) {
      const b = g.get(o[u]), D = b !== void 0 ? i[b] : null;
      if (D === null) {
        const X = T(s, i[l]);
        x(X, n[u]), a[u] = X;
      } else a[u] = x(D, n[u]), T(s, i[l], D), i[b] = null;
      u++;
    } else Z(i[h]), h--;
    else Z(i[l]), l++;
    for (; u <= m; ) {
      const b = T(s, a[m + 1]);
      x(b, n[u]), a[u++] = b;
    }
    for (; l <= h; ) {
      const b = i[l++];
      b !== null && Z(b);
    }
    return this.ut = o, Xt(s, a), v;
  }
}), gt = mt(`
  --nqb-bg: #14161b;
  --nqb-surface: #1d2027;
  --nqb-surface-raised: #262a33;
  --nqb-border: #323743;
  --nqb-text: #e8eaf0;
  --nqb-text-muted: #9aa3b2;
  --nqb-accent: #818cf8;
  --nqb-accent-contrast: #101223;
  --nqb-danger: #f87171;
  --nqb-warn: #fbbf24;
  --nqb-ok: #34d399;
  --nqb-chip-bg: #262a33;
`), ee = $t`
  :host {
    --nqb-bg: #f5f6f8;
    --nqb-surface: #ffffff;
    --nqb-surface-raised: #eef0f4;
    --nqb-border: #d9dde5;
    --nqb-text: #1f2430;
    --nqb-text-muted: #5b6472;
    --nqb-accent: #4f46e5;
    --nqb-accent-contrast: #ffffff;
    --nqb-danger: #b91c1c;
    --nqb-warn: #92400e;
    --nqb-ok: #047857;
    --nqb-chip-bg: #e8ebf1;

    --nqb-radius: 10px;
    --nqb-radius-sm: 6px;
    --nqb-font: system-ui, -apple-system, 'Segoe UI', sans-serif;
    --nqb-mono: ui-monospace, 'SF Mono', Menlo, Consolas, monospace;
    --nqb-column-width: 280px;
    --nqb-gap: 12px;
    --nqb-pad: 16px;

    display: block;
    background: var(--nqb-bg);
    color: var(--nqb-text);
    font-family: var(--nqb-font);
    color-scheme: light;
  }

  :host([theme='dark']) {
    ${gt}
    color-scheme: dark;
  }

  @media (prefers-color-scheme: dark) {
    :host(:not([theme='light'])) {
      ${gt}
      color-scheme: dark;
    }
  }
`;
function se(s) {
  if (Array.isArray(s.tags))
    return s.tags.filter((e) => typeof e == "string");
  const t = s.custom_fields?.tags;
  return Array.isArray(t) ? t.filter((e) => typeof e == "string") : [];
}
function re(s, t) {
  return (t ? s.queues.filter((r) => r.id === t) : s.queues).map((r) => {
    const i = [...r.stages ?? []].sort(
      (c, g) => (c.position ?? 0) - (g.position ?? 0)
    ), n = s.items.filter((c) => c.queue_id === r.id), o = i.map((c) => ({
      stage: c,
      tickets: n.filter((g) => g.stage_id === c.id)
    })), d = new Set(i.map((c) => c.id)), a = n.filter((c) => !c.stage_id || !d.has(c.stage_id));
    return a.length && o.push({ stage: null, tickets: a }), { board: r, columns: o, totalCount: n.length };
  });
}
function ie(s) {
  const t = (s ?? "").toLowerCase();
  return /done|complete|closed|shipped/.test(t) ? "done" : /progress|review|active|start/.test(t) ? "active" : /block|wait|hold/.test(t) ? "blocked" : "open";
}
function ne(s) {
  const t = (s ?? "").toLowerCase();
  return !t || t === "none" || t === "unset" ? null : /high|urgent|critical|hot/.test(t) ? "high" : /low|minor/.test(t) ? "low" : "medium";
}
function oe(s) {
  const t = s.trim().split(/\s+/).filter(Boolean);
  return ((t[0]?.[0] ?? "?") + (t[1]?.[0] ?? "")).toUpperCase();
}
var ae = Object.defineProperty, le = Object.getOwnPropertyDescriptor, _ = (s, t, e, r) => {
  for (var i = r > 1 ? void 0 : r ? le(t, e) : t, n = s.length - 1, o; n >= 0; n--)
    (o = s[n]) && (i = (r ? o(t, e, i) : o(i)) || i);
  return r && i && ae(t, e, i), i;
};
const de = "__unstaged__";
let $ = class extends O {
  constructor() {
    super(...arguments), this.dataProvider = null, this.boardId = "", this.heading = "", this.theme = "auto", this.hideEmptyStages = !1, this._loading = !1, this._error = null, this._data = null, this._loadSeq = 0, this._abort = null;
  }
  refresh() {
    return this._load();
  }
  willUpdate(s) {
    (s.has("dataProvider") || s.has("boardId")) && this._load();
  }
  async _load() {
    const s = this.dataProvider;
    if (this._abort?.abort(), this._abort = null, this._loadSeq++, !s) {
      this._data = null, this._error = null, this._loading = !1;
      return;
    }
    const t = this._loadSeq, e = new AbortController();
    this._abort = e, this._loading = !0, this._error = null;
    try {
      const r = await s({ signal: e.signal });
      if (t !== this._loadSeq) return;
      this._data = r && Array.isArray(r.queues) && Array.isArray(r.items) ? r : { queues: [], items: [] }, this._loading = !1;
    } catch (r) {
      if (t !== this._loadSeq) return;
      this._loading = !1, this._error = r instanceof Error ? r.message : String(r), this.dispatchEvent(
        new CustomEvent("queue-load-error", {
          detail: { error: this._error },
          bubbles: !0,
          composed: !0
        })
      );
    }
  }
  _activate(s) {
    this.dispatchEvent(
      new CustomEvent("card-activate", {
        detail: { ticket: s },
        bubbles: !0,
        composed: !0
      })
    );
  }
  render() {
    return f`
      <section
        class="board-region"
        role="region"
        aria-label=${this.heading || "Ticket queues"}
        aria-busy=${this._loading ? "true" : "false"}
      >
        ${this.heading ? f`<h2 class="heading">${this.heading}</h2>` : p}
        ${this._loading ? this._renderLoading() : p}
        ${this._error ? this._renderError() : p}
        ${!this._loading && !this._error ? this._renderBoards() : p}
      </section>
    `;
  }
  _renderLoading() {
    return f`
      <div class="state" role="status">
        <span class="spinner" aria-hidden="true"></span>
        <span>Loading queues…</span>
      </div>
    `;
  }
  _renderError() {
    return f`
      <div class="state state--error" role="alert">
        <strong>Failed to load queues.</strong>
        <p>${this._error}</p>
        <button type="button" class="retry" @click=${() => void this._load()}>Retry</button>
      </div>
    `;
  }
  _renderBoards() {
    if (!this._data)
      return f`
        <div class="state" role="status">
          <span>No queues to display.</span>
        </div>
      `;
    const s = re(this._data, this.boardId || void 0);
    return s.length ? f`
      ${V(
      s,
      (t) => t.board.id,
      (t) => this._renderBoard(t)
    )}
    ` : f`
        <div class="state" role="status">
          <span>No queues to display.</span>
        </div>
      `;
  }
  _renderBoard(s) {
    const t = s.columns.filter(
      (e) => !(this.hideEmptyStages && e.tickets.length === 0)
    );
    return f`
      <section class="board" aria-label=${s.board.name}>
        <header class="board-header">
          <h3 class="board-name">${s.board.name}</h3>
          ${s.board.methodology ? f`<span class="methodology">${s.board.methodology}</span>` : p}
          <span class="board-count">${s.totalCount} ${s.totalCount === 1 ? "item" : "items"}</span>
        </header>
        ${t.length ? f`
              <div class="columns">
                ${V(
      t,
      (e) => e.stage?.id ?? de,
      (e) => this._renderColumn(e)
    )}
              </div>
            ` : f`<p class="cards-empty">No stages configured.</p>`}
      </section>
    `;
  }
  _renderColumn(s) {
    const t = s.stage?.name ?? "Unstaged", e = s.stage?.wip_limit ?? null, r = e != null && s.tickets.length > e;
    return f`
      <div class="column" role="group" aria-label=${`${t} (${s.tickets.length})`}>
        <header class="column-header">
          <h4 class="column-title">${t}</h4>
          <span class=${Jt({ "column-count": !0, over: r })}
            >${s.tickets.length}${e != null ? `/${e}` : ""}</span
          >
        </header>
        ${s.tickets.length ? f`
              <ul class="cards">
                ${V(
      s.tickets,
      (i) => i.id,
      (i) => f`<li>${this._renderCard(i)}</li>`
    )}
              </ul>
            ` : f`<p class="cards-empty">Nothing here.</p>`}
      </div>
    `;
  }
  _renderCard(s) {
    const t = ie(s.status), e = ne(s.priority), r = se(s);
    return f`
      <button type="button" class="card" @click=${() => this._activate(s)}>
        <span class="card-top">
          ${s.key ? f`<span class="key">${s.key}</span>` : p}
          ${s.ticket_type ? f`<span class="type">${s.ticket_type}</span>` : p}
        </span>
        <span class="title">${s.title}</span>
        <span class="meta">
          <span class=${`status status--${t}`}>
            <span class="dot" aria-hidden="true"></span>${(s.status ?? "unknown").replace(/_/g, " ")}
          </span>
          ${e ? f`<span class=${`chip chip--${e}`}>${s.priority}</span>` : p}
        </span>
        ${r.length ? f`
              <span class="tags">
                ${r.map((i) => f`<span class="tag">${i}</span>`)}
              </span>
            ` : p}
        <span class="assignee">
          ${s.assignee ? f`<span class="avatar" aria-hidden="true">${oe(s.assignee)}</span>` : p}
          <span>${s.assignee || "Unassigned"}</span>
        </span>
      </button>
    `;
  }
};
$.styles = [
  ee,
  $t`
      :host {
        border-radius: var(--nqb-radius);
      }
      .board-region {
        display: block;
        padding: var(--nqb-pad);
      }
      .heading {
        margin: 0 0 var(--nqb-gap);
        font-size: 1.05rem;
        font-weight: 650;
      }
      .board + .board {
        margin-top: 24px;
      }
      .board-header {
        display: flex;
        align-items: baseline;
        gap: 10px;
        margin: 0 0 var(--nqb-gap);
      }
      .board-name {
        margin: 0;
        font-size: 0.95rem;
        font-weight: 650;
      }
      .methodology {
        font-size: 0.7rem;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: var(--nqb-text-muted);
        background: var(--nqb-surface-raised);
        border: 1px solid var(--nqb-border);
        border-radius: 999px;
        padding: 2px 8px;
      }
      .board-count {
        font-size: 0.78rem;
        color: var(--nqb-text-muted);
      }
      .columns {
        display: grid;
        grid-auto-flow: column;
        grid-auto-columns: clamp(230px, 34vw, var(--nqb-column-width));
        gap: var(--nqb-gap);
        align-items: start;
        overflow-x: auto;
        padding-bottom: 6px;
      }
      .column {
        background: var(--nqb-surface);
        border: 1px solid var(--nqb-border);
        border-radius: var(--nqb-radius);
        min-width: 0;
      }
      .column-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        padding: 10px 12px;
        border-bottom: 1px solid var(--nqb-border);
      }
      .column-title {
        margin: 0;
        font-size: 0.82rem;
        font-weight: 650;
        color: var(--nqb-text);
      }
      .column-count {
        font-size: 0.75rem;
        color: var(--nqb-text-muted);
        font-family: var(--nqb-mono);
        white-space: nowrap;
      }
      .column-count.over {
        color: var(--nqb-danger);
        font-weight: 700;
      }
      .cards {
        list-style: none;
        margin: 0;
        padding: 10px;
        display: flex;
        flex-direction: column;
        gap: 8px;
      }
      .cards-empty {
        padding: 6px 12px 12px;
        font-size: 0.78rem;
        color: var(--nqb-text-muted);
      }
      .card {
        display: block;
        width: 100%;
        text-align: left;
        background: var(--nqb-surface);
        border: 1px solid var(--nqb-border);
        border-radius: var(--nqb-radius-sm);
        padding: 10px 12px;
        font: inherit;
        color: inherit;
        cursor: pointer;
        transition: border-color 120ms ease, background 120ms ease;
      }
      .card:hover {
        border-color: var(--nqb-accent);
      }
      .card:focus-visible {
        outline: 2px solid var(--nqb-accent);
        outline-offset: 2px;
      }
      .card-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        margin-bottom: 4px;
      }
      .key {
        font-family: var(--nqb-mono);
        font-size: 0.72rem;
        color: var(--nqb-accent);
        font-weight: 600;
      }
      .type {
        font-size: 0.68rem;
        color: var(--nqb-text-muted);
        text-transform: uppercase;
        letter-spacing: 0.05em;
      }
      .title {
        display: block;
        font-size: 0.86rem;
        font-weight: 550;
        line-height: 1.35;
        margin-bottom: 8px;
      }
      .meta {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 6px;
        margin-bottom: 8px;
      }
      .status {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: 0.73rem;
        color: var(--nqb-text-muted);
      }
      .dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: var(--nqb-text-muted);
      }
      .status--done .dot { background: var(--nqb-ok); }
      .status--active .dot { background: var(--nqb-accent); }
      .status--blocked .dot { background: var(--nqb-danger); }
      .chip {
        font-size: 0.68rem;
        font-weight: 600;
        border-radius: 999px;
        padding: 1px 7px;
        background: var(--nqb-chip-bg);
        color: var(--nqb-text-muted);
      }
      .chip--high { background: var(--nqb-danger); color: var(--nqb-surface); }
      .chip--medium { background: var(--nqb-warn); color: var(--nqb-surface); }
      .tags {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        margin-bottom: 8px;
      }
      .tag {
        font-size: 0.68rem;
        background: var(--nqb-surface-raised);
        border: 1px solid var(--nqb-border);
        color: var(--nqb-text-muted);
        border-radius: 999px;
        padding: 1px 7px;
      }
      .assignee {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.75rem;
        color: var(--nqb-text-muted);
      }
      .avatar {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        background: var(--nqb-accent);
        color: var(--nqb-accent-contrast);
        font-size: 0.6rem;
        font-weight: 700;
      }
      .state {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        padding: 32px 16px;
        color: var(--nqb-text-muted);
        font-size: 0.9rem;
        text-align: center;
      }
      .state--error {
        color: var(--nqb-danger);
      }
      .spinner {
        width: 22px;
        height: 22px;
        border: 3px solid var(--nqb-border);
        border-top-color: var(--nqb-accent);
        border-radius: 50%;
        animation: nqb-spin 0.8s linear infinite;
      }
      @keyframes nqb-spin {
        to { transform: rotate(360deg); }
      }
      .retry {
        font: inherit;
        font-size: 0.82rem;
        padding: 6px 14px;
        border-radius: var(--nqb-radius-sm);
        border: 1px solid var(--nqb-accent);
        background: var(--nqb-accent);
        color: var(--nqb-accent-contrast);
        cursor: pointer;
      }
      .retry:focus-visible {
        outline: 2px solid var(--nqb-accent);
        outline-offset: 2px;
      }
    `
];
_([
  P({ attribute: !1 })
], $.prototype, "dataProvider", 2);
_([
  P()
], $.prototype, "boardId", 2);
_([
  P()
], $.prototype, "heading", 2);
_([
  P({ reflect: !0 })
], $.prototype, "theme", 2);
_([
  P({ type: Boolean, attribute: "hide-empty-stages" })
], $.prototype, "hideEmptyStages", 2);
_([
  Y()
], $.prototype, "_loading", 2);
_([
  Y()
], $.prototype, "_error", 2);
_([
  Y()
], $.prototype, "_data", 2);
$ = _([
  Kt("npl-queue-board")
], $);
function fe(s) {
  const { baseUrl: t, orgId: e, projectId: r = null, token: i = null, fetchImpl: n = fetch } = s;
  return async (o = {}) => {
    const d = `/api/v1/organizations/${encodeURIComponent(e)}`, a = new URLSearchParams();
    r && a.set("project_id", r);
    const c = a.toString(), g = i ? { Authorization: `Bearer ${i}` } : {}, [l, h] = await Promise.all([
      n(`${t}${d}/boards${c ? `?${c}` : ""}`, {
        headers: g,
        signal: o.signal
      }),
      n(`${t}${d}/tickets${c ? `?${c}` : ""}`, {
        headers: g,
        signal: o.signal
      })
    ]);
    if (!l.ok)
      throw new Error(`Boards request failed: ${l.status} ${l.statusText}`);
    if (!h.ok)
      throw new Error(`Tickets request failed: ${h.status} ${h.statusText}`);
    const u = await l.json(), m = await h.json();
    return { queues: u.boards ?? [], items: m.tickets ?? [] };
  };
}
function ce() {
  const s = {
    id: "board-release-ops",
    name: "Release Ops",
    slug: "release-ops",
    methodology: "kanban",
    scope: "org",
    stages: [
      { id: "st-ro-todo", slug: "todo", name: "To Do", kind: "todo", position: 0, wip_limit: null },
      { id: "st-ro-wip", slug: "in_progress", name: "In Progress", kind: "in_progress", position: 1, wip_limit: 3 },
      { id: "st-ro-review", slug: "in_review", name: "In Review", kind: "in_review", position: 2, wip_limit: null },
      { id: "st-ro-done", slug: "done", name: "Done", kind: "done", position: 3, wip_limit: null }
    ]
  }, t = {
    id: "board-agent-tools",
    name: "Agent Tools Sprint",
    slug: "agent-tools-sprint",
    methodology: "scrum",
    scope: "project",
    stages: [
      { id: "st-at-todo", slug: "todo", name: "To Do", kind: "todo", position: 0, wip_limit: null },
      { id: "st-at-wip", slug: "in_progress", name: "In Progress", kind: "in_progress", position: 1, wip_limit: 2 },
      { id: "st-at-review", slug: "in_review", name: "In Review", kind: "in_review", position: 2, wip_limit: null },
      { id: "st-at-done", slug: "done", name: "Done", kind: "done", position: 3, wip_limit: null }
    ]
  }, e = [
    {
      id: "t-ro-101",
      key: "NPL-101",
      number: 101,
      title: "Harden ticket key generation",
      status: "done",
      priority: "high",
      assignee: "Keith Brings",
      tags: ["tickets", "stability"],
      ticket_type: "task",
      queue_id: s.id,
      stage_id: "st-ro-done",
      updated_at: "2026-08-30T14:12:00Z"
    },
    {
      id: "t-ro-102",
      key: "NPL-102",
      number: 102,
      title: "Board stage reorder API",
      status: "in_progress",
      priority: "medium",
      assignee: "Ana Okafor",
      tags: ["boards"],
      ticket_type: "feature",
      queue_id: s.id,
      stage_id: "st-ro-wip",
      updated_at: "2026-08-30T10:02:00Z"
    },
    {
      id: "t-ro-103",
      key: "NPL-103",
      number: 103,
      title: "Rate-limit ticket feed polling",
      status: "in_review",
      priority: "low",
      assignee: null,
      tags: ["mcp", "perf"],
      ticket_type: "task",
      queue_id: s.id,
      stage_id: "st-ro-review",
      updated_at: "2026-08-29T18:40:00Z"
    },
    {
      id: "t-ro-104",
      key: "NPL-104",
      number: 104,
      title: "Queue web component spike",
      status: "open",
      priority: "high",
      assignee: "Priya Nair",
      ticket_type: "spike",
      queue_id: s.id,
      stage_id: null,
      custom_fields: { tags: ["lit", "frontend"] },
      updated_at: "2026-08-31T08:15:00Z"
    },
    {
      id: "t-ro-105",
      key: null,
      number: null,
      title: "Investigate flaky seed job",
      status: "open",
      priority: null,
      assignee: null,
      tags: [],
      ticket_type: "bug",
      queue_id: s.id,
      stage_id: "st-ro-todo",
      updated_at: "2026-08-28T09:30:00Z"
    },
    {
      id: "t-ro-106",
      key: "NPL-106",
      number: 106,
      title: "Document board token contract",
      status: "blocked",
      priority: "medium",
      assignee: "Ana Okafor",
      tags: ["docs"],
      ticket_type: "documentation",
      queue_id: s.id,
      stage_id: "st-ro-todo",
      updated_at: "2026-08-30T16:55:00Z"
    },
    {
      id: "t-at-201",
      key: "TRP-201",
      number: 201,
      title: "Embed queue board in plans dashboard",
      status: "in_progress",
      priority: "high",
      assignee: "Priya Nair",
      tags: ["trp", "embed"],
      ticket_type: "feature",
      queue_id: t.id,
      stage_id: "st-at-wip",
      updated_at: "2026-08-31T07:05:00Z"
    },
    {
      id: "t-at-202",
      key: "TRP-202",
      number: 202,
      title: "Per-key toolset registry seam",
      status: "open",
      priority: "medium",
      assignee: "Keith Brings",
      tags: ["registry"],
      ticket_type: "task",
      queue_id: t.id,
      stage_id: "st-at-todo",
      updated_at: "2026-08-30T12:20:00Z"
    },
    {
      id: "t-at-203",
      key: "TRP-203",
      number: 203,
      title: "Ship shared component bundle",
      status: "done",
      priority: "low",
      assignee: "Sam Ruiz",
      tags: ["ci"],
      ticket_type: "chore",
      queue_id: t.id,
      stage_id: "st-at-done",
      updated_at: "2026-08-27T11:00:00Z"
    }
  ];
  return { queues: [s, t], items: e };
}
function me(s = {}) {
  const t = s.fixture ?? ce(), e = s.delayMs ?? 0;
  return async (r = {}) => {
    if (e && await new Promise((i, n) => {
      const o = setTimeout(i, e);
      r.signal?.addEventListener(
        "abort",
        () => {
          clearTimeout(o), n(new DOMException("Aborted", "AbortError"));
        },
        { once: !0 }
      );
    }), r.signal?.aborted)
      throw new DOMException("Aborted", "AbortError");
    return structuredClone(t);
  };
}
export {
  $ as NplQueueBoard,
  fe as createLockerProvider,
  me as createMockProvider,
  ce as defaultFixture,
  re as groupBoards,
  se as ticketTags
};
//# sourceMappingURL=npl-queue-board.js.map
