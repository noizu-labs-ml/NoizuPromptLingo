/**
 * @license
 * Copyright 2019 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const I = globalThis, V = I.ShadowRoot && (I.ShadyCSS === void 0 || I.ShadyCSS.nativeShadow) && "adoptedStyleSheets" in Document.prototype && "replace" in CSSStyleSheet.prototype, W = Symbol(), Y = /* @__PURE__ */ new WeakMap();
let mt = class {
  constructor(t, r, s) {
    if (this._$cssResult$ = !0, s !== W) throw Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");
    this.cssText = t, this.t = r;
  }
  get styleSheet() {
    let t = this.o;
    const r = this.t;
    if (V && t === void 0) {
      const s = r !== void 0 && r.length === 1;
      s && (t = Y.get(r)), t === void 0 && ((this.o = t = new CSSStyleSheet()).replaceSync(this.cssText), s && Y.set(r, t));
    }
    return t;
  }
  toString() {
    return this.cssText;
  }
};
const _t = (e) => new mt(typeof e == "string" ? e : e + "", void 0, W), gt = (e, ...t) => {
  const r = e.length === 1 ? e[0] : t.reduce((s, i, n) => s + ((o) => {
    if (o._$cssResult$ === !0) return o.cssText;
    if (typeof o == "number") return o;
    throw Error("Value passed to 'css' function must be a 'css' function result: " + o + ". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.");
  })(i) + e[n + 1], e[0]);
  return new mt(r, e, W);
}, St = (e, t) => {
  if (V) e.adoptedStyleSheets = t.map((r) => r instanceof CSSStyleSheet ? r : r.styleSheet);
  else for (const r of t) {
    const s = document.createElement("style"), i = I.litNonce;
    i !== void 0 && s.setAttribute("nonce", i), s.textContent = r.cssText, e.appendChild(s);
  }
}, tt = V ? (e) => e : (e) => e instanceof CSSStyleSheet ? ((t) => {
  let r = "";
  for (const s of t.cssRules) r += s.cssText;
  return _t(r);
})(e) : e;
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const { is: Pt, defineProperty: Ct, getOwnPropertyDescriptor: Tt, getOwnPropertyNames: kt, getOwnPropertySymbols: Ut, getPrototypeOf: Mt } = Object, L = globalThis, et = L.trustedTypes, Ot = et ? et.emptyScript : "", Nt = L.reactiveElementPolyfillSupport, U = (e, t) => e, z = { toAttribute(e, t) {
  switch (t) {
    case Boolean:
      e = e ? Ot : null;
      break;
    case Object:
    case Array:
      e = e == null ? e : JSON.stringify(e);
  }
  return e;
}, fromAttribute(e, t) {
  let r = e;
  switch (t) {
    case Boolean:
      r = e !== null;
      break;
    case Number:
      r = e === null ? null : Number(e);
      break;
    case Object:
    case Array:
      try {
        r = JSON.parse(e);
      } catch {
        r = null;
      }
  }
  return r;
} }, K = (e, t) => !Pt(e, t), rt = { attribute: !0, type: String, converter: z, reflect: !1, useDefault: !1, hasChanged: K };
Symbol.metadata ??= Symbol("metadata"), L.litPropertyMetadata ??= /* @__PURE__ */ new WeakMap();
let S = class extends HTMLElement {
  static addInitializer(t) {
    this._$Ei(), (this.l ??= []).push(t);
  }
  static get observedAttributes() {
    return this.finalize(), this._$Eh && [...this._$Eh.keys()];
  }
  static createProperty(t, r = rt) {
    if (r.state && (r.attribute = !1), this._$Ei(), this.prototype.hasOwnProperty(t) && ((r = Object.create(r)).wrapped = !0), this.elementProperties.set(t, r), !r.noAccessor) {
      const s = Symbol(), i = this.getPropertyDescriptor(t, s, r);
      i !== void 0 && Ct(this.prototype, t, i);
    }
  }
  static getPropertyDescriptor(t, r, s) {
    const { get: i, set: n } = Tt(this.prototype, t) ?? { get() {
      return this[r];
    }, set(o) {
      this[r] = o;
    } };
    return { get: i, set(o) {
      const l = i?.call(this);
      n?.call(this, o), this.requestUpdate(t, l, s);
    }, configurable: !0, enumerable: !0 };
  }
  static getPropertyOptions(t) {
    return this.elementProperties.get(t) ?? rt;
  }
  static _$Ei() {
    if (this.hasOwnProperty(U("elementProperties"))) return;
    const t = Mt(this);
    t.finalize(), t.l !== void 0 && (this.l = [...t.l]), this.elementProperties = new Map(t.elementProperties);
  }
  static finalize() {
    if (this.hasOwnProperty(U("finalized"))) return;
    if (this.finalized = !0, this._$Ei(), this.hasOwnProperty(U("properties"))) {
      const r = this.properties, s = [...kt(r), ...Ut(r)];
      for (const i of s) this.createProperty(i, r[i]);
    }
    const t = this[Symbol.metadata];
    if (t !== null) {
      const r = litPropertyMetadata.get(t);
      if (r !== void 0) for (const [s, i] of r) this.elementProperties.set(s, i);
    }
    this._$Eh = /* @__PURE__ */ new Map();
    for (const [r, s] of this.elementProperties) {
      const i = this._$Eu(r, s);
      i !== void 0 && this._$Eh.set(i, r);
    }
    this.elementStyles = this.finalizeStyles(this.styles);
  }
  static finalizeStyles(t) {
    const r = [];
    if (Array.isArray(t)) {
      const s = new Set(t.flat(1 / 0).reverse());
      for (const i of s) r.unshift(tt(i));
    } else t !== void 0 && r.push(tt(t));
    return r;
  }
  static _$Eu(t, r) {
    const s = r.attribute;
    return s === !1 ? void 0 : typeof s == "string" ? s : typeof t == "string" ? t.toLowerCase() : void 0;
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
    const t = /* @__PURE__ */ new Map(), r = this.constructor.elementProperties;
    for (const s of r.keys()) this.hasOwnProperty(s) && (t.set(s, this[s]), delete this[s]);
    t.size > 0 && (this._$Ep = t);
  }
  createRenderRoot() {
    const t = this.shadowRoot ?? this.attachShadow(this.constructor.shadowRootOptions);
    return St(t, this.constructor.elementStyles), t;
  }
  connectedCallback() {
    this.renderRoot ??= this.createRenderRoot(), this.enableUpdating(!0), this._$EO?.forEach((t) => t.hostConnected?.());
  }
  enableUpdating(t) {
  }
  disconnectedCallback() {
    this._$EO?.forEach((t) => t.hostDisconnected?.());
  }
  attributeChangedCallback(t, r, s) {
    this._$AK(t, s);
  }
  _$ET(t, r) {
    const s = this.constructor.elementProperties.get(t), i = this.constructor._$Eu(t, s);
    if (i !== void 0 && s.reflect === !0) {
      const n = (s.converter?.toAttribute !== void 0 ? s.converter : z).toAttribute(r, s.type);
      this._$Em = t, n == null ? this.removeAttribute(i) : this.setAttribute(i, n), this._$Em = null;
    }
  }
  _$AK(t, r) {
    const s = this.constructor, i = s._$Eh.get(t);
    if (i !== void 0 && this._$Em !== i) {
      const n = s.getPropertyOptions(i), o = typeof n.converter == "function" ? { fromAttribute: n.converter } : n.converter?.fromAttribute !== void 0 ? n.converter : z;
      this._$Em = i;
      const l = o.fromAttribute(r, n.type);
      this[i] = l ?? this._$Ej?.get(i) ?? l, this._$Em = null;
    }
  }
  requestUpdate(t, r, s, i = !1, n) {
    if (t !== void 0) {
      const o = this.constructor;
      if (i === !1 && (n = this[t]), s ??= o.getPropertyOptions(t), !((s.hasChanged ?? K)(n, r) || s.useDefault && s.reflect && n === this._$Ej?.get(t) && !this.hasAttribute(o._$Eu(t, s)))) return;
      this.C(t, r, s);
    }
    this.isUpdatePending === !1 && (this._$ES = this._$EP());
  }
  C(t, r, { useDefault: s, reflect: i, wrapped: n }, o) {
    s && !(this._$Ej ??= /* @__PURE__ */ new Map()).has(t) && (this._$Ej.set(t, o ?? r ?? this[t]), n !== !0 || o !== void 0) || (this._$AL.has(t) || (this.hasUpdated || s || (r = void 0), this._$AL.set(t, r)), i === !0 && this._$Em !== t && (this._$Eq ??= /* @__PURE__ */ new Set()).add(t));
  }
  async _$EP() {
    this.isUpdatePending = !0;
    try {
      await this._$ES;
    } catch (r) {
      Promise.reject(r);
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
      const s = this.constructor.elementProperties;
      if (s.size > 0) for (const [i, n] of s) {
        const { wrapped: o } = n, l = this[i];
        o !== !0 || this._$AL.has(i) || l === void 0 || this.C(i, void 0, n, l);
      }
    }
    let t = !1;
    const r = this._$AL;
    try {
      t = this.shouldUpdate(r), t ? (this.willUpdate(r), this._$EO?.forEach((s) => s.hostUpdate?.()), this.update(r)) : this._$EM();
    } catch (s) {
      throw t = !1, this._$EM(), s;
    }
    t && this._$AE(r);
  }
  willUpdate(t) {
  }
  _$AE(t) {
    this._$EO?.forEach((r) => r.hostUpdated?.()), this.hasUpdated || (this.hasUpdated = !0, this.firstUpdated(t)), this.updated(t);
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
    this._$Eq &&= this._$Eq.forEach((r) => this._$ET(r, this[r])), this._$EM();
  }
  updated(t) {
  }
  firstUpdated(t) {
  }
};
S.elementStyles = [], S.shadowRootOptions = { mode: "open" }, S[U("elementProperties")] = /* @__PURE__ */ new Map(), S[U("finalized")] = /* @__PURE__ */ new Map(), Nt?.({ ReactiveElement: S }), (L.reactiveElementVersions ??= []).push("2.1.2");
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const F = globalThis, st = (e) => e, D = F.trustedTypes, it = D ? D.createPolicy("lit-html", { createHTML: (e) => e }) : void 0, vt = "$lit$", v = `lit$${Math.random().toFixed(9).slice(2)}$`, yt = "?" + v, Rt = `<${yt}>`, E = document, O = () => E.createComment(""), N = (e) => e === null || typeof e != "object" && typeof e != "function", J = Array.isArray, Ht = (e) => J(e) || typeof e?.[Symbol.iterator] == "function", q = `[ 	
\f\r]`, T = /<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g, nt = /-->/g, ot = />/g, A = RegExp(`>|${q}(?:([^\\s"'>=/]+)(${q}*=${q}*(?:[^ 	
\f\r"'\`<>=]|("|')|))|$)`, "g"), at = /'/g, lt = /"/g, bt = /^(?:script|style|textarea|title)$/i, It = (e) => (t, ...r) => ({ _$litType$: e, strings: t, values: r }), m = It(1), y = Symbol.for("lit-noChange"), h = Symbol.for("lit-nothing"), ct = /* @__PURE__ */ new WeakMap(), x = E.createTreeWalker(E, 129);
function At(e, t) {
  if (!J(e) || !e.hasOwnProperty("raw")) throw Error("invalid template strings array");
  return it !== void 0 ? it.createHTML(t) : t;
}
const zt = (e, t) => {
  const r = e.length - 1, s = [];
  let i, n = t === 2 ? "<svg>" : t === 3 ? "<math>" : "", o = T;
  for (let l = 0; l < r; l++) {
    const a = e[l];
    let d, f, c = -1, p = 0;
    for (; p < a.length && (o.lastIndex = p, f = o.exec(a), f !== null); ) p = o.lastIndex, o === T ? f[1] === "!--" ? o = nt : f[1] !== void 0 ? o = ot : f[2] !== void 0 ? (bt.test(f[2]) && (i = RegExp("</" + f[2], "g")), o = A) : f[3] !== void 0 && (o = A) : o === A ? f[0] === ">" ? (o = i ?? T, c = -1) : f[1] === void 0 ? c = -2 : (c = o.lastIndex - f[2].length, d = f[1], o = f[3] === void 0 ? A : f[3] === '"' ? lt : at) : o === lt || o === at ? o = A : o === nt || o === ot ? o = T : (o = A, i = void 0);
    const u = o === A && e[l + 1].startsWith("/>") ? " " : "";
    n += o === T ? a + Rt : c >= 0 ? (s.push(d), a.slice(0, c) + vt + a.slice(c) + v + u) : a + v + (c === -2 ? l : u);
  }
  return [At(e, n + (e[r] || "<?>") + (t === 2 ? "</svg>" : t === 3 ? "</math>" : "")), s];
};
class R {
  constructor({ strings: t, _$litType$: r }, s) {
    let i;
    this.parts = [];
    let n = 0, o = 0;
    const l = t.length - 1, a = this.parts, [d, f] = zt(t, r);
    if (this.el = R.createElement(d, s), x.currentNode = this.el.content, r === 2 || r === 3) {
      const c = this.el.content.firstChild;
      c.replaceWith(...c.childNodes);
    }
    for (; (i = x.nextNode()) !== null && a.length < l; ) {
      if (i.nodeType === 1) {
        if (i.hasAttributes()) for (const c of i.getAttributeNames()) if (c.endsWith(vt)) {
          const p = f[o++], u = i.getAttribute(c).split(v), $ = /([.?@])?(.*)/.exec(p);
          a.push({ type: 1, index: n, name: $[2], strings: u, ctor: $[1] === "." ? Lt : $[1] === "?" ? jt : $[1] === "@" ? Bt : j }), i.removeAttribute(c);
        } else c.startsWith(v) && (a.push({ type: 6, index: n }), i.removeAttribute(c));
        if (bt.test(i.tagName)) {
          const c = i.textContent.split(v), p = c.length - 1;
          if (p > 0) {
            i.textContent = D ? D.emptyScript : "";
            for (let u = 0; u < p; u++) i.append(c[u], O()), x.nextNode(), a.push({ type: 2, index: ++n });
            i.append(c[p], O());
          }
        }
      } else if (i.nodeType === 8) if (i.data === yt) a.push({ type: 2, index: n });
      else {
        let c = -1;
        for (; (c = i.data.indexOf(v, c + 1)) !== -1; ) a.push({ type: 7, index: n }), c += v.length - 1;
      }
      n++;
    }
  }
  static createElement(t, r) {
    const s = E.createElement("template");
    return s.innerHTML = t, s;
  }
}
function P(e, t, r = e, s) {
  if (t === y) return t;
  let i = s !== void 0 ? r._$Co?.[s] : r._$Cl;
  const n = N(t) ? void 0 : t._$litDirective$;
  return i?.constructor !== n && (i?._$AO?.(!1), n === void 0 ? i = void 0 : (i = new n(e), i._$AT(e, r, s)), s !== void 0 ? (r._$Co ??= [])[s] = i : r._$Cl = i), i !== void 0 && (t = P(e, i._$AS(e, t.values), i, s)), t;
}
class Dt {
  constructor(t, r) {
    this._$AV = [], this._$AN = void 0, this._$AD = t, this._$AM = r;
  }
  get parentNode() {
    return this._$AM.parentNode;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  u(t) {
    const { el: { content: r }, parts: s } = this._$AD, i = (t?.creationScope ?? E).importNode(r, !0);
    x.currentNode = i;
    let n = x.nextNode(), o = 0, l = 0, a = s[0];
    for (; a !== void 0; ) {
      if (o === a.index) {
        let d;
        a.type === 2 ? d = new C(n, n.nextSibling, this, t) : a.type === 1 ? d = new a.ctor(n, a.name, a.strings, this, t) : a.type === 6 && (d = new qt(n, this, t)), this._$AV.push(d), a = s[++l];
      }
      o !== a?.index && (n = x.nextNode(), o++);
    }
    return x.currentNode = E, i;
  }
  p(t) {
    let r = 0;
    for (const s of this._$AV) s !== void 0 && (s.strings !== void 0 ? (s._$AI(t, s, r), r += s.strings.length - 2) : s._$AI(t[r])), r++;
  }
}
class C {
  get _$AU() {
    return this._$AM?._$AU ?? this._$Cv;
  }
  constructor(t, r, s, i) {
    this.type = 2, this._$AH = h, this._$AN = void 0, this._$AA = t, this._$AB = r, this._$AM = s, this.options = i, this._$Cv = i?.isConnected ?? !0;
  }
  get parentNode() {
    let t = this._$AA.parentNode;
    const r = this._$AM;
    return r !== void 0 && t?.nodeType === 11 && (t = r.parentNode), t;
  }
  get startNode() {
    return this._$AA;
  }
  get endNode() {
    return this._$AB;
  }
  _$AI(t, r = this) {
    t = P(this, t, r), N(t) ? t === h || t == null || t === "" ? (this._$AH !== h && this._$AR(), this._$AH = h) : t !== this._$AH && t !== y && this._(t) : t._$litType$ !== void 0 ? this.$(t) : t.nodeType !== void 0 ? this.T(t) : Ht(t) ? this.k(t) : this._(t);
  }
  O(t) {
    return this._$AA.parentNode.insertBefore(t, this._$AB);
  }
  T(t) {
    this._$AH !== t && (this._$AR(), this._$AH = this.O(t));
  }
  _(t) {
    this._$AH !== h && N(this._$AH) ? this._$AA.nextSibling.data = t : this.T(E.createTextNode(t)), this._$AH = t;
  }
  $(t) {
    const { values: r, _$litType$: s } = t, i = typeof s == "number" ? this._$AC(t) : (s.el === void 0 && (s.el = R.createElement(At(s.h, s.h[0]), this.options)), s);
    if (this._$AH?._$AD === i) this._$AH.p(r);
    else {
      const n = new Dt(i, this), o = n.u(this.options);
      n.p(r), this.T(o), this._$AH = n;
    }
  }
  _$AC(t) {
    let r = ct.get(t.strings);
    return r === void 0 && ct.set(t.strings, r = new R(t)), r;
  }
  k(t) {
    J(this._$AH) || (this._$AH = [], this._$AR());
    const r = this._$AH;
    let s, i = 0;
    for (const n of t) i === r.length ? r.push(s = new C(this.O(O()), this.O(O()), this, this.options)) : s = r[i], s._$AI(n), i++;
    i < r.length && (this._$AR(s && s._$AB.nextSibling, i), r.length = i);
  }
  _$AR(t = this._$AA.nextSibling, r) {
    for (this._$AP?.(!1, !0, r); t !== this._$AB; ) {
      const s = st(t).nextSibling;
      st(t).remove(), t = s;
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
  constructor(t, r, s, i, n) {
    this.type = 1, this._$AH = h, this._$AN = void 0, this.element = t, this.name = r, this._$AM = i, this.options = n, s.length > 2 || s[0] !== "" || s[1] !== "" ? (this._$AH = Array(s.length - 1).fill(new String()), this.strings = s) : this._$AH = h;
  }
  _$AI(t, r = this, s, i) {
    const n = this.strings;
    let o = !1;
    if (n === void 0) t = P(this, t, r, 0), o = !N(t) || t !== this._$AH && t !== y, o && (this._$AH = t);
    else {
      const l = t;
      let a, d;
      for (t = n[0], a = 0; a < n.length - 1; a++) d = P(this, l[s + a], r, a), d === y && (d = this._$AH[a]), o ||= !N(d) || d !== this._$AH[a], d === h ? t = h : t !== h && (t += (d ?? "") + n[a + 1]), this._$AH[a] = d;
    }
    o && !i && this.j(t);
  }
  j(t) {
    t === h ? this.element.removeAttribute(this.name) : this.element.setAttribute(this.name, t ?? "");
  }
}
class Lt extends j {
  constructor() {
    super(...arguments), this.type = 3;
  }
  j(t) {
    this.element[this.name] = t === h ? void 0 : t;
  }
}
class jt extends j {
  constructor() {
    super(...arguments), this.type = 4;
  }
  j(t) {
    this.element.toggleAttribute(this.name, !!t && t !== h);
  }
}
class Bt extends j {
  constructor(t, r, s, i, n) {
    super(t, r, s, i, n), this.type = 5;
  }
  _$AI(t, r = this) {
    if ((t = P(this, t, r, 0) ?? h) === y) return;
    const s = this._$AH, i = t === h && s !== h || t.capture !== s.capture || t.once !== s.once || t.passive !== s.passive, n = t !== h && (s === h || i);
    i && this.element.removeEventListener(this.name, this, s), n && this.element.addEventListener(this.name, this, t), this._$AH = t;
  }
  handleEvent(t) {
    typeof this._$AH == "function" ? this._$AH.call(this.options?.host ?? this.element, t) : this._$AH.handleEvent(t);
  }
}
class qt {
  constructor(t, r, s) {
    this.element = t, this.type = 6, this._$AN = void 0, this._$AM = r, this.options = s;
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  _$AI(t) {
    P(this, t);
  }
}
const Zt = { I: C }, Vt = F.litHtmlPolyfillSupport;
Vt?.(R, C), (F.litHtmlVersions ??= []).push("3.3.3");
const Wt = (e, t, r) => {
  const s = r?.renderBefore ?? t;
  let i = s._$litPart$;
  if (i === void 0) {
    const n = r?.renderBefore ?? null;
    s._$litPart$ = i = new C(t.insertBefore(O(), n), n, void 0, r ?? {});
  }
  return i._$AI(e), i;
};
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Q = globalThis;
let M = class extends S {
  constructor() {
    super(...arguments), this.renderOptions = { host: this }, this._$Do = void 0;
  }
  createRenderRoot() {
    const t = super.createRenderRoot();
    return this.renderOptions.renderBefore ??= t.firstChild, t;
  }
  update(t) {
    const r = this.render();
    this.hasUpdated || (this.renderOptions.isConnected = this.isConnected), super.update(t), this._$Do = Wt(r, this.renderRoot, this.renderOptions);
  }
  connectedCallback() {
    super.connectedCallback(), this._$Do?.setConnected(!0);
  }
  disconnectedCallback() {
    super.disconnectedCallback(), this._$Do?.setConnected(!1);
  }
  render() {
    return y;
  }
};
M._$litElement$ = !0, M.finalized = !0, Q.litElementHydrateSupport?.({ LitElement: M });
const Kt = Q.litElementPolyfillSupport;
Kt?.({ LitElement: M });
(Q.litElementVersions ??= []).push("4.2.2");
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Ft = (e) => (t, r) => {
  r !== void 0 ? r.addInitializer(() => {
    customElements.define(e, t);
  }) : customElements.define(e, t);
};
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Jt = { attribute: !0, type: String, converter: z, reflect: !1, hasChanged: K }, Qt = (e = Jt, t, r) => {
  const { kind: s, metadata: i } = r;
  let n = globalThis.litPropertyMetadata.get(i);
  if (n === void 0 && globalThis.litPropertyMetadata.set(i, n = /* @__PURE__ */ new Map()), s === "setter" && ((e = Object.create(e)).wrapped = !0), n.set(r.name, e), s === "accessor") {
    const { name: o } = r;
    return { set(l) {
      const a = t.get.call(this);
      t.set.call(this, l), this.requestUpdate(o, a, e, !0, l);
    }, init(l) {
      return l !== void 0 && this.C(o, void 0, e, l), l;
    } };
  }
  if (s === "setter") {
    const { name: o } = r;
    return function(l) {
      const a = this[o];
      t.call(this, l), this.requestUpdate(o, a, e, !0, l);
    };
  }
  throw Error("Unsupported decorator location: " + s);
};
function H(e) {
  return (t, r) => typeof r == "object" ? Qt(e, t, r) : ((s, i, n) => {
    const o = i.hasOwnProperty(n);
    return i.constructor.createProperty(n, s), o ? Object.getOwnPropertyDescriptor(i, n) : void 0;
  })(e, t, r);
}
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
function G(e) {
  return H({ ...e, state: !0, attribute: !1 });
}
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const wt = { ATTRIBUTE: 1, CHILD: 2 }, xt = (e) => (...t) => ({ _$litDirective$: e, values: t });
let Et = class {
  constructor(t) {
  }
  get _$AU() {
    return this._$AM._$AU;
  }
  _$AT(t, r, s) {
    this._$Ct = t, this._$AM = r, this._$Ci = s;
  }
  _$AS(t, r) {
    return this.update(t, r);
  }
  update(t, r) {
    return this.render(...r);
  }
};
/**
 * @license
 * Copyright 2018 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const Gt = xt(class extends Et {
  constructor(e) {
    if (super(e), e.type !== wt.ATTRIBUTE || e.name !== "class" || e.strings?.length > 2) throw Error("`classMap()` can only be used in the `class` attribute and must be the only part in the attribute.");
  }
  render(e) {
    return " " + Object.keys(e).filter((t) => e[t]).join(" ") + " ";
  }
  update(e, [t]) {
    if (this.st === void 0) {
      this.st = /* @__PURE__ */ new Set(), e.strings !== void 0 && (this.nt = new Set(e.strings.join(" ").split(/\s/).filter((s) => s !== "")));
      for (const s in t) t[s] && !this.nt?.has(s) && this.st.add(s);
      return this.render(t);
    }
    const r = e.element.classList;
    for (const s of this.st) s in t || (r.remove(s), this.st.delete(s));
    for (const s in t) {
      const i = !!t[s];
      i === this.st.has(s) || this.nt?.has(s) || (i ? (r.add(s), this.st.add(s)) : (r.remove(s), this.st.delete(s)));
    }
    return y;
  }
});
/**
 * @license
 * Copyright 2020 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const { I: Xt } = Zt, dt = (e) => e, ht = () => document.createComment(""), k = (e, t, r) => {
  const s = e._$AA.parentNode, i = t === void 0 ? e._$AB : t._$AA;
  if (r === void 0) {
    const n = s.insertBefore(ht(), i), o = s.insertBefore(ht(), i);
    r = new Xt(n, o, e, e.options);
  } else {
    const n = r._$AB.nextSibling, o = r._$AM, l = o !== e;
    if (l) {
      let a;
      r._$AQ?.(e), r._$AM = e, r._$AP !== void 0 && (a = e._$AU) !== o._$AU && r._$AP(a);
    }
    if (n !== i || l) {
      let a = r._$AA;
      for (; a !== n; ) {
        const d = dt(a).nextSibling;
        dt(s).insertBefore(a, i), a = d;
      }
    }
  }
  return r;
}, w = (e, t, r = e) => (e._$AI(t, r), e), Yt = {}, te = (e, t = Yt) => e._$AH = t, ee = (e) => e._$AH, Z = (e) => {
  e._$AR(), e._$AA.remove();
};
/**
 * @license
 * Copyright 2017 Google LLC
 * SPDX-License-Identifier: BSD-3-Clause
 */
const ut = (e, t, r) => {
  const s = /* @__PURE__ */ new Map();
  for (let i = t; i <= r; i++) s.set(e[i], i);
  return s;
}, pt = xt(class extends Et {
  constructor(e) {
    if (super(e), e.type !== wt.CHILD) throw Error("repeat() can only be used in text expressions");
  }
  dt(e, t, r) {
    let s;
    r === void 0 ? r = t : t !== void 0 && (s = t);
    const i = [], n = [];
    let o = 0;
    for (const l of e) i[o] = s ? s(l, o) : o, n[o] = r(l, o), o++;
    return { values: n, keys: i };
  }
  render(e, t, r) {
    return this.dt(e, t, r).values;
  }
  update(e, [t, r, s]) {
    const i = ee(e), { values: n, keys: o } = this.dt(t, r, s);
    if (!Array.isArray(i)) return this.ut = o, n;
    const l = this.ut ??= [], a = [];
    let d, f, c = 0, p = i.length - 1, u = 0, $ = n.length - 1;
    for (; c <= p && u <= $; ) if (i[c] === null) c++;
    else if (i[p] === null) p--;
    else if (l[c] === o[u]) a[u] = w(i[c], n[u]), c++, u++;
    else if (l[p] === o[$]) a[$] = w(i[p], n[$]), p--, $--;
    else if (l[c] === o[$]) a[$] = w(i[c], n[$]), k(e, a[$ + 1], i[c]), c++, $--;
    else if (l[p] === o[u]) a[u] = w(i[p], n[u]), k(e, i[c], i[p]), p--, u++;
    else if (d === void 0 && (d = ut(o, u, $), f = ut(l, c, p)), d.has(l[c])) if (d.has(l[p])) {
      const g = f.get(o[u]), B = g !== void 0 ? i[g] : null;
      if (B === null) {
        const X = k(e, i[c]);
        w(X, n[u]), a[u] = X;
      } else a[u] = w(B, n[u]), k(e, i[c], B), i[g] = null;
      u++;
    } else Z(i[p]), p--;
    else Z(i[c]), c++;
    for (; u <= $; ) {
      const g = k(e, a[$ + 1]);
      w(g, n[u]), a[u++] = g;
    }
    for (; c <= p; ) {
      const g = i[c++];
      g !== null && Z(g);
    }
    return this.ut = o, te(e, a), y;
  }
}), ft = _t(`
  --trt-bg: #14161b;
  --trt-surface: #1d2027;
  --trt-surface-raised: #262a33;
  --trt-border: #323743;
  --trt-text: #e8eaf0;
  --trt-text-muted: #9aa3b2;
  --trt-accent: #818cf8;
  --trt-accent-contrast: #101223;
  --trt-danger: #f87171;
  --trt-warn: #fbbf24;
  --trt-ok: #34d399;
  --trt-chip-bg: #262a33;
  --trt-rule: #262a33;
`), re = gt`
  :host {
    --trt-bg: #f5f6f8;
    --trt-surface: #ffffff;
    --trt-surface-raised: #eef0f4;
    --trt-border: #d9dde5;
    --trt-text: #1f2430;
    --trt-text-muted: #5b6472;
    --trt-accent: #4f46e5;
    --trt-accent-contrast: #ffffff;
    --trt-danger: #b91c1c;
    --trt-warn: #92400e;
    --trt-ok: #047857;
    --trt-chip-bg: #e8ebf1;
    --trt-rule: #e3e6ec;

    --trt-radius: 10px;
    --trt-radius-sm: 6px;
    --trt-font: system-ui, -apple-system, 'Segoe UI', sans-serif;
    --trt-mono: ui-monospace, 'SF Mono', Menlo, Consolas, monospace;
    --trt-pad: 16px;
    --trt-gap: 12px;

    display: block;
    background: var(--trt-bg);
    color: var(--trt-text);
    font-family: var(--trt-font);
    color-scheme: light;
  }

  :host([theme='dark']) {
    ${ft}
    color-scheme: dark;
  }

  @media (prefers-color-scheme: dark) {
    :host(:not([theme='light'])) {
      ${ft}
      color-scheme: dark;
    }
  }
`;
function se(e) {
  const t = /* @__PURE__ */ new Map();
  for (const r of e) {
    const s = ie(r.occurred_at), i = t.get(s);
    i ? i.push(r) : t.set(s, [r]);
  }
  return [...t.entries()].sort((r, s) => r[0] === "undated" ? 1 : s[0] === "undated" ? -1 : r[0] < s[0] ? 1 : r[0] > s[0] ? -1 : 0).map(([r, s]) => ({ date: r, label: ne(r), events: s }));
}
function ie(e) {
  if (!e) return "undated";
  const t = /^(\d{4}-\d{2}-\d{2})/.exec(e);
  return t ? t[1] : "undated";
}
function ne(e) {
  if (e === "undated") return "undated";
  const t = /* @__PURE__ */ new Date(`${e}T00:00:00Z`);
  return Number.isNaN(t.getTime()) ? e : t.toLocaleDateString("en-US", {
    timeZone: "UTC",
    year: "numeric",
    month: "short",
    day: "numeric"
  });
}
function $t(e) {
  if (e == null || e === "") return "—";
  if (typeof e == "string") return e;
  if (typeof e == "number" || typeof e == "boolean") return String(e);
  try {
    return JSON.stringify(e);
  } catch {
    return String(e);
  }
}
function oe(e) {
  const t = e.field?.trim() || "update", r = $t(e.new_value);
  return e.old_value === null || e.old_value === void 0 || e.old_value === "" ? `${t}: set to ${r}` : `${t}: ${$t(e.old_value)} → ${r}`;
}
function ae(e) {
  if (!e.occurred_at) return "";
  const t = new Date(e.occurred_at);
  return Number.isNaN(t.getTime()) ? "" : t.toLocaleTimeString("en-US", {
    timeZone: "UTC",
    hour: "2-digit",
    minute: "2-digit",
    hour12: !1
  });
}
function le(e) {
  switch (e) {
    case "done":
    case "closed":
      return "ok";
    case "in_progress":
    case "in_review":
      return "accent";
    case "blocked":
      return "warn";
    default:
      return "muted";
  }
}
var ce = Object.defineProperty, de = Object.getOwnPropertyDescriptor, b = (e, t, r, s) => {
  for (var i = s > 1 ? void 0 : s ? de(t, r) : t, n = e.length - 1, o; n >= 0; n--)
    (o = e[n]) && (i = (s ? o(t, r, i) : o(i)) || i);
  return s && i && ce(t, r, i), i;
};
let _ = class extends M {
  constructor() {
    super(...arguments), this.dataProvider = null, this.itemId = "", this.heading = "", this.theme = "auto", this._loading = !1, this._error = null, this._data = null, this._loadSeq = 0, this._abort = null;
  }
  refresh() {
    return this._load();
  }
  willUpdate(e) {
    (e.has("dataProvider") || e.has("itemId")) && this._load();
  }
  async _load() {
    const e = this.dataProvider;
    if (this._abort?.abort(), this._abort = null, this._loadSeq++, !e || !this.itemId) {
      this._data = null, this._error = null, this._loading = !1;
      return;
    }
    const t = this._loadSeq, r = new AbortController();
    this._abort = r, this._loading = !0, this._error = null;
    try {
      const s = await e({ signal: r.signal });
      if (t !== this._loadSeq) return;
      this._data = s && s.item && Array.isArray(s.events) ? s : { item: s?.item ?? {}, events: [] }, this._loading = !1;
    } catch (s) {
      if (t !== this._loadSeq) return;
      this._loading = !1, this._error = s instanceof Error ? s.message : String(s), this.dispatchEvent(
        new CustomEvent("item-load-error", {
          detail: { error: this._error },
          bubbles: !0,
          composed: !0
        })
      );
    }
  }
  _activate(e) {
    this.dispatchEvent(
      new CustomEvent("item-activate", {
        detail: { item: e },
        bubbles: !0,
        composed: !0
      })
    );
  }
  render() {
    return m`
      <section
        class="timeline-region"
        role="region"
        aria-label=${this.heading || "Item timeline"}
        aria-busy=${this._loading ? "true" : "false"}
      >
        ${this.heading ? m`<h2 class="heading">${this.heading}</h2>` : h}
        ${this._loading ? this._renderLoading() : h}
        ${this._error ? this._renderError() : h}
        ${!this._loading && !this._error ? this._renderTimeline() : h}
      </section>
    `;
  }
  _renderLoading() {
    return m`
      <div class="state" role="status">
        <span class="spinner" aria-hidden="true"></span>
        <span>Loading item…</span>
      </div>
    `;
  }
  _renderError() {
    return m`
      <div class="state state--error" role="alert">
        <strong>Failed to load item.</strong>
        <p>${this._error}</p>
        <button type="button" class="retry" @click=${() => void this._load()}>Retry</button>
      </div>
    `;
  }
  _renderTimeline() {
    if (!this._data || !this._data.item?.id)
      return m`
        <div class="state" role="status">
          <span>No item to display.</span>
        </div>
      `;
    const e = this._data.item, t = se(this._data.events);
    return m`
      <button
        type="button"
        class="item-card"
        @click=${() => this._activate(e)}
        @keydown=${(r) => {
      (r.key === "Enter" || r.key === " ") && (r.preventDefault(), this._activate(e));
    }}
        aria-label="Activate item ${e.key ?? e.id}"
      >
        <h3 class="item-title">
          ${e.key ? m`<span class="item-key">${e.key}</span>` : h}
          <span>${e.title}</span>
        </h3>
        ${e.description ? m`<p class="item-desc">${e.description}</p>` : h}
        <div class="chips">
          ${e.item_type ? m`<span class="chip">${e.item_type}</span>` : h}
          ${e.status ? m`<span class=${Gt({ chip: !0, [`chip--${le(e.status)}`]: !0 })}>
                ${e.status}
              </span>` : h}
          ${e.priority ? m`<span class="chip">priority: ${e.priority}</span>` : h}
          <span class="chip chip--muted">${e.assignee || "Unassigned"}</span>
        </div>
        ${(e.due_date || e.reporter) && m`
          <p class="meta">
            ${e.due_date ? m`due ${e.due_date}` : h}
            ${e.due_date && e.reporter ? " · " : h}
            ${e.reporter ? m`reported by ${e.reporter}` : h}
          </p>
        `}
      </button>
      <section class="feed" aria-label="Activity">
        <h4 class="feed-title">Activity</h4>
        ${t.length ? m`
              ${pt(
      t,
      (r) => r.date,
      (r) => m`
                  <div class="day">
                    <p class="day-label">${r.label}</p>
                    ${pt(
        r.events,
        (s) => s.id,
        (s) => m`
                        <div class="event">
                          <span class="event-time">${ae(s) || "·"}</span>
                          <span class="event-actor">${s.actor || "system"}</span>
                          <span class="event-desc">${oe(s)}</span>
                        </div>
                      `
      )}
                  </div>
                `
    )}
            ` : m`<p class="feed-empty">No activity recorded yet.</p>`}
      </section>
    `;
  }
};
_.styles = [
  re,
  gt`
      :host {
        border-radius: var(--trt-radius);
      }
      .timeline-region {
        display: block;
        padding: var(--trt-pad);
      }
      .heading {
        margin: 0 0 var(--trt-gap);
        font-size: 1.05rem;
        font-weight: 650;
      }
      .item-card {
        background: var(--trt-surface);
        border: 1px solid var(--trt-border);
        border-radius: var(--trt-radius);
        padding: 14px 16px;
        margin: 0 0 var(--trt-gap);
        cursor: pointer;
        text-align: left;
        font: inherit;
        color: inherit;
        width: 100%;
      }
      .item-card:focus-visible {
        outline: 2px solid var(--trt-accent);
        outline-offset: 2px;
      }
      .item-title {
        margin: 0;
        font-size: 0.98rem;
        font-weight: 650;
        display: flex;
        align-items: baseline;
        gap: 10px;
        flex-wrap: wrap;
      }
      .item-key {
        font-family: var(--trt-mono);
        font-size: 0.78rem;
        color: var(--trt-accent);
      }
      .item-desc {
        margin: 6px 0 0;
        font-size: 0.82rem;
        color: var(--trt-text-muted);
      }
      .chips {
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
        margin: 10px 0 0;
        align-items: center;
      }
      .chip {
        font-size: 0.7rem;
        padding: 2px 8px;
        border-radius: 999px;
        border: 1px solid var(--trt-border);
        background: var(--trt-chip-bg);
        color: var(--trt-text);
        white-space: nowrap;
      }
      .chip--muted {
        color: var(--trt-text-muted);
      }
      .chip--ok {
        color: var(--trt-ok);
        border-color: var(--trt-ok);
      }
      .chip--warn {
        color: var(--trt-warn);
        border-color: var(--trt-warn);
      }
      .chip--accent {
        color: var(--trt-accent);
        border-color: var(--trt-accent);
      }
      .meta {
        margin: 10px 0 0;
        font-size: 0.78rem;
        color: var(--trt-text-muted);
      }
      .feed {
        background: var(--trt-surface);
        border: 1px solid var(--trt-border);
        border-radius: var(--trt-radius);
        padding: 12px 16px;
      }
      .feed-title {
        margin: 0 0 10px;
        font-size: 0.82rem;
        font-weight: 650;
        color: var(--trt-text-muted);
        text-transform: uppercase;
        letter-spacing: 0.05em;
      }
      .day {
        margin: 0 0 14px;
      }
      .day-label {
        margin: 0 0 6px;
        font-size: 0.75rem;
        font-weight: 650;
        color: var(--trt-text-muted);
      }
      .event {
        display: flex;
        gap: 10px;
        align-items: baseline;
        padding: 6px 0;
        border-top: 1px solid var(--trt-rule);
        font-size: 0.84rem;
      }
      .event:first-of-type {
        border-top: 0;
      }
      .event-time {
        font-family: var(--trt-mono);
        font-size: 0.72rem;
        color: var(--trt-text-muted);
        white-space: nowrap;
        min-width: 44px;
      }
      .event-actor {
        font-weight: 600;
        white-space: nowrap;
      }
      .event-desc {
        color: var(--trt-text);
      }
      .feed-empty {
        font-size: 0.82rem;
        color: var(--trt-text-muted);
        margin: 0;
      }
      .state {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        padding: 32px 16px;
        color: var(--trt-text-muted);
        font-size: 0.9rem;
        text-align: center;
      }
      .state--error {
        color: var(--trt-danger);
      }
      .spinner {
        width: 22px;
        height: 22px;
        border: 3px solid var(--trt-border);
        border-top-color: var(--trt-accent);
        border-radius: 50%;
        animation: trt-spin 0.8s linear infinite;
      }
      @keyframes trt-spin {
        to { transform: rotate(360deg); }
      }
      .retry {
        font: inherit;
        font-size: 0.82rem;
        padding: 6px 14px;
        border-radius: var(--trt-radius-sm);
        border: 1px solid var(--trt-accent);
        background: var(--trt-accent);
        color: var(--trt-accent-contrast);
        cursor: pointer;
      }
      .retry:focus-visible {
        outline: 2px solid var(--trt-accent);
        outline-offset: 2px;
      }
    `
];
b([
  H({ attribute: !1 })
], _.prototype, "dataProvider", 2);
b([
  H()
], _.prototype, "itemId", 2);
b([
  H()
], _.prototype, "heading", 2);
b([
  H({ reflect: !0 })
], _.prototype, "theme", 2);
b([
  G()
], _.prototype, "_loading", 2);
b([
  G()
], _.prototype, "_error", 2);
b([
  G()
], _.prototype, "_data", 2);
_ = b([
  Ft("trp-item-timeline")
], _);
function me(e) {
  const { baseUrl: t, orgId: r, itemId: s, token: i = null, fetchImpl: n = fetch } = e;
  return async (o = {}) => {
    const l = `/api/v1/organizations/${encodeURIComponent(r)}/items/${encodeURIComponent(s)}`, a = i ? { Authorization: `Bearer ${i}` } : {}, [d, f] = await Promise.all([
      n(`${t}${l}`, { headers: a, signal: o.signal }),
      n(`${t}${l}/activity`, { headers: a, signal: o.signal })
    ]);
    if (!d.ok)
      throw new Error(`Item request failed: ${d.status} ${d.statusText}`);
    if (!f.ok)
      throw new Error(`Activity request failed: ${f.status} ${f.statusText}`);
    const c = await d.json(), p = await f.json();
    return { item: c.item ?? {}, events: p.activity ?? [] };
  };
}
function he() {
  const e = {
    id: "0f6c2a5e-6f6f-4a4a-9c4c-0a1b2c3d4e5f",
    key: "TRP-0142",
    number: 142,
    organization_id: "org-trp-demo",
    project_id: "proj-shared-key",
    title: "Mount item endpoints on the shared-key pipeline",
    description: "Wire /api/v1/organizations/:org_id/items onto [:api, :authenticated, :shared_key] so NPL shared connections can read item + activity data.",
    item_type: "task",
    status: "in_progress",
    priority: "high",
    assignee: "Keith Brings",
    reporter: "Loom",
    queue_id: "queue-integration",
    parent_id: null,
    stage_id: "stage-wip",
    iteration_id: null,
    rank: 1200,
    start_date: "2026-08-29",
    due_date: "2026-09-02",
    estimate: 5,
    custom_fields: { epic: "NPL ⇄ TRP integration" },
    inserted_at: "2026-08-29T03:10:00Z",
    updated_at: "2026-08-31T04:20:00Z"
  }, t = [
    {
      id: "ev-1",
      item_id: e.id,
      actor: "Loom",
      field: "item",
      old_value: null,
      new_value: "created",
      occurred_at: "2026-08-29T03:10:00Z"
    },
    {
      id: "ev-2",
      item_id: e.id,
      actor: "Loom",
      field: "status",
      old_value: "backlog",
      new_value: "in_progress",
      occurred_at: "2026-08-30T07:42:00Z"
    },
    {
      id: "ev-3",
      item_id: e.id,
      actor: "Keith Brings",
      field: "priority",
      old_value: "medium",
      new_value: "high",
      occurred_at: "2026-08-30T09:05:00Z"
    },
    {
      id: "ev-4",
      item_id: e.id,
      actor: "Keith Brings",
      field: "assignee",
      old_value: null,
      new_value: "Keith Brings",
      occurred_at: "2026-08-30T09:06:00Z"
    },
    {
      id: "ev-5",
      item_id: e.id,
      actor: "W2",
      field: "status",
      old_value: "in_progress",
      new_value: "in_review",
      occurred_at: "2026-08-31T02:11:00Z"
    }
  ];
  return { item: e, events: t };
}
function _e(e = {}) {
  const t = e.fixture ?? he(), r = e.delayMs ?? 0;
  return async (s = {}) => {
    if (r && await new Promise((i, n) => {
      const o = setTimeout(i, r);
      s.signal?.addEventListener(
        "abort",
        () => {
          clearTimeout(o), n(new DOMException("Aborted", "AbortError"));
        },
        { once: !0 }
      );
    }), s.signal?.aborted)
      throw new DOMException("Aborted", "AbortError");
    return structuredClone(t);
  };
}
export {
  _ as TrpItemTimeline,
  _e as createMockProvider,
  me as createTrpApiProvider,
  he as defaultFixture,
  oe as describeEvent,
  ae as formatEventTime,
  $t as formatEventValue,
  se as groupByDay,
  le as statusTone
};
//# sourceMappingURL=trp-item-timeline.js.map
