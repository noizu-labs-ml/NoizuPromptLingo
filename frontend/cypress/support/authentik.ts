// AUTO-SYNCED from Portfolio/shared/cypress-authentik/src/authentik.support.ts
// Do not edit by hand — re-run: bash Portfolio/shared/cypress-authentik/scripts/sync-support.sh
//

/**
 * Self-contained Cypress support module for Authentik OIDC login.
 *
 * SOURCE OF TRUTH for the command implementation used by per-app copies.
 * Keep in sync with commands.ts + auth-config.ts.
 *
 * Sync into apps:
 *   bash Portfolio/shared/cypress-authentik/scripts/sync-support.sh
 *
 * Password is NEVER logged.
 *
 * App triggers:
 * - sso-link (default): visit /login → click data-cy SSO link → wait for IdP URL → fill
 * - email-then-sso: email step then SSO link
 * - direct-oidc: visit /auth/oidc (full-page redirect; often more reliable when
 *   the app SSO button is flaky or opens a popup). Prefer when sso-link races.
 */

export type AppTrigger = "sso-link" | "email-then-sso" | "direct-oidc";

export interface LoginViaAuthentikOptions {
  username?: string;
  password?: string;
  appTrigger?: AppTrigger;
  loginPath?: string;
  authentikOrigin?: string;
  successPathMatch?: string | RegExp;
  cacheSession?: boolean;
  consentStorageKey?: string;
  consentStorageValue?: string;
}

const DEFAULT_AUTHENTIK_ORIGIN = "https://auth.derobot.is";
const DEFAULT_AUTHENTIK_USERNAME = "testing@therobotlives.com";
const DEFAULT_LOGIN_PATH = "/login";
// Include post-auth provisioning routes (first-login register / pending approval)
const DEFAULT_SUCCESS_PATH =
  /^\/(app|studio|dashboard|auth\/register|auth\/sso-callback|auth\/oidc\/callback|auth\/callback|complete-registration|pending-approval|session-cookie-required)(\/|$|\?)/;

/**
 * Authentik 2025.x stage fields.
 *
 * IMPORTANT: Authentik injects light-DOM autofill traps
 * (name=username/password/code, often aria-hidden / tabIndex=-1 / opacity 0)
 * that Cypress can match as ":visible". Prefer PatternFly stage controls
 * and real identification field ids/names.
 */
const AUTHENTIK_SELECTORS = {
  identity:
    [
      'input#ak-stage-identification-uid-field',
      'input[name="uidField"].pf-c-form-control',
      'input.pf-c-form-control[name="uidField"]',
      'input.pf-v5-c-form-control[name="uidField"]',
      'ak-stage-identification input[name="uidField"]',
      'input[name="uidField"]',
      'input[name="uid"].pf-c-form-control',
      'input[autocomplete="username"]:not([tabindex="-1"])',
    ].join(", "),
  password:
    [
      'ak-stage-password input[type="password"]',
      'input.pf-c-form-control[type="password"]',
      'input.pf-v5-c-form-control[type="password"]',
      'input.pf-c-form-control[name="password"]',
      'input[name="password"].pf-c-form-control',
      'input[type="password"].pf-c-form-control',
      'input[autocomplete="current-password"]:not([tabindex="-1"])',
    ].join(", "),
  submit:
    [
      "button.pf-c-button.pf-m-primary",
      "button.pf-v5-c-button.pf-m-primary",
      "button.pf-m-primary.pf-m-block",
      "button.pf-c-button[type='submit']",
      "button[type='submit'].pf-c-button",
      "button[type='submit']",
    ].join(", "),
} as const;

// PatternFly v4 + v5 + bare submit (consent stage often type=submit only)
const PRIMARY_BUTTON = AUTHENTIK_SELECTORS.submit;

const APP_SSO = {
  dataCyOidc: '[data-cy="sso-provider-link"][data-cy-id="oidc"]',
  // Broader text fallbacks; data-cy is always preferred first
  ssoText:
    /sign in with sso|continue with sso|sign in with derobot\.is|continue with derobot|log in with sso|sso/i,
  directOidcPath: "/auth/oidc",
} as const;

const IDP_HOST_RE = /auth\.derobot\.is/i;

function resolveUsername(opts?: LoginViaAuthentikOptions): string {
  return (
    opts?.username ||
    (Cypress.env("AUTHENTIK_USERNAME") as string | undefined) ||
    DEFAULT_AUTHENTIK_USERNAME
  );
}

function resolvePassword(opts?: LoginViaAuthentikOptions): string {
  const password =
    opts?.password || (Cypress.env("AUTHENTIK_PASSWORD") as string | undefined);
  if (!password) {
    throw new Error(
      "AUTHENTIK_PASSWORD is required (Cypress.env AUTHENTIK_PASSWORD / CYPRESS_AUTHENTIK_PASSWORD). Never commit passwords."
    );
  }
  return password;
}

function resolveAuthentikOrigin(opts?: LoginViaAuthentikOptions): string {
  return (
    opts?.authentikOrigin ||
    (Cypress.env("AUTHENTIK_ORIGIN") as string | undefined) ||
    DEFAULT_AUTHENTIK_ORIGIN
  );
}

function resolveSuccessMatch(opts?: LoginViaAuthentikOptions): RegExp {
  const raw = opts?.successPathMatch;
  if (raw instanceof RegExp) return raw;
  if (typeof raw === "string" && raw.length > 0) return new RegExp(raw);
  const envMatch = Cypress.env("SUCCESS_PATH_MATCH") as string | undefined;
  if (envMatch) return new RegExp(envMatch);
  return DEFAULT_SUCCESS_PATH;
}

function dismissCookieConsentIfPresent(): void {
  // Cookie banners often mount after client hydration — wait briefly then click.
  // Prefer reject/necessary-only so analytics stays off in smoke runs.
  cy.get("body", { timeout: 15000 }).should("be.visible");
  cy.wait(800);
  cy.get("body").then(($body) => {
    const rejectBtn = $body
      .find("button")
      .filter((_, el) =>
        /reject optional|reject all|necessary only|necessary cookies only/i.test(
          el.textContent || ""
        )
      );
    if (rejectBtn.length) {
      cy.wrap(rejectBtn.first()).click({ force: true });
      return;
    }
    const acceptBtn = $body
      .find("button")
      .filter((_, el) =>
        /accept all|i agree|got it/i.test(el.textContent || "")
      );
    if (acceptBtn.length) {
      cy.wrap(acceptBtn.first()).click({ force: true });
    }
  });
  // If banner still present (late mount), force-dismiss common actions
  cy.get("body").then(($body) => {
    if (!$body.find(".cookie-consent, [class*='cookie-consent']").length) return;
    const late = $body
      .find(".cookie-consent button, [class*='cookie-consent'] button")
      .filter((_, el) =>
        /reject optional|reject all|accept all|necessary only/i.test(
          el.textContent || ""
        )
      );
    if (late.length) {
      cy.wrap(late.first()).click({ force: true });
    }
  });
}

function seedConsentIfConfigured(opts?: LoginViaAuthentikOptions): void {
  const key =
    opts?.consentStorageKey ||
    (Cypress.env("CONSENT_STORAGE_KEY") as string | undefined);
  if (!key) return;
  const value =
    opts?.consentStorageValue ||
    (Cypress.env("CONSENT_STORAGE_VALUE") as string | undefined) ||
    JSON.stringify({
      version: 1,
      categories: {
        necessary: true,
        analytics: false,
        marketing: false,
        preferences: false,
      },
      acceptedAt: "2026-01-01T00:00:00.000Z",
      updatedAt: "2026-01-01T00:00:00.000Z",
    });
  cy.window({ log: false }).then((win) => {
    win.localStorage.setItem(
      key,
      typeof value === "string" ? value : JSON.stringify(value)
    );
  });
}

/** True if element looks like an Authentik autofill trap, not a real stage field. */
function isAutofillTrap(el: HTMLElement): boolean {
  if (el.getAttribute("tabindex") === "-1") return true;
  if (el.getAttribute("aria-hidden") === "true") return true;
  const style = window.getComputedStyle(el);
  if (style.opacity === "0" || style.visibility === "hidden") return true;
  if (style.position === "absolute" || style.position === "fixed") {
    const r = el.getBoundingClientRect();
    if (r.width < 2 || r.height < 2 || r.top < 0 || r.left < -1000) return true;
  }
  // Trap class names / parents used by Authentik chrome
  if (
    el.closest(
      "[data-ouia-component-type='PF4/LoginMainBody'] ~ * input[name='username'], .ak-brand, [style*='opacity: 0']"
    )
  ) {
    /* fall through — bounding box check already covers most traps */
  }
  const name = (el.getAttribute("name") || "").toLowerCase();
  // Real stage uses uidField; traps use username/password without pf-c-form-control
  if (
    (name === "username" || name === "password" || name === "code") &&
    !el.classList.contains("pf-c-form-control") &&
    !el.classList.contains("pf-v5-c-form-control")
  ) {
    return true;
  }
  return false;
}

function isReallyVisible(el: HTMLElement): boolean {
  if (isAutofillTrap(el)) return false;
  const r = el.getBoundingClientRect();
  if (r.width < 4 || r.height < 4) return false;
  const style = window.getComputedStyle(el);
  if (
    style.display === "none" ||
    style.visibility === "hidden" ||
    style.opacity === "0"
  ) {
    return false;
  }
  return true;
}

/**
 * Set input value in a way Lit/web-components reliably observe.
 * Cypress .type alone often leaves Authentik required fields empty
 * ("Please fill out this field") because the stage binding never updates.
 */
function setNativeInputValue(el: HTMLInputElement, value: string): void {
  el.focus();
  el.click();
  const proto = window.HTMLInputElement.prototype;
  const desc = Object.getOwnPropertyDescriptor(proto, "value");
  if (desc?.set) {
    desc.set.call(el, "");
    desc.set.call(el, value);
  } else {
    el.value = value;
  }
  // Lit + PatternFly listen for composed input/change
  el.dispatchEvent(
    new Event("input", { bubbles: true, cancelable: true, composed: true })
  );
  el.dispatchEvent(
    new InputEvent("input", {
      bubbles: true,
      cancelable: true,
      composed: true,
      data: value,
      inputType: "insertText",
    })
  );
  el.dispatchEvent(
    new Event("change", { bubbles: true, cancelable: true, composed: true })
  );
  el.dispatchEvent(
    new KeyboardEvent("keyup", { bubbles: true, composed: true, key: "a" })
  );
  el.blur();
  el.focus();
}

function fillVisibleField(
  selector: string,
  value: string,
  opts: { log: boolean; timeout?: number }
): void {
  const timeout = opts.timeout ?? 45000;
  const q = { includeShadowDom: true as const, timeout };

  cy.get(selector, q)
    .filter((_, el) => isReallyVisible(el as HTMLElement))
    .should("have.length.at.least", 1)
    .first()
    .should("be.visible")
    .then(($input) => {
      const el = $input[0] as HTMLInputElement;
      // Clear via native + Cypress
      setNativeInputValue(el, "");
      cy.wrap($input)
        .clear({ force: true })
        .type(value, {
          log: opts.log,
          force: true,
          delay: 20,
          parseSpecialCharSequences: false,
        })
        .then(($typed) => {
          const node = $typed[0] as HTMLInputElement;
          if ((node.value || "") !== value) {
            setNativeInputValue(node, value);
          }
        })
        .should("have.value", value);
    });
}

function waitForIdpUrl(authentikOrigin: string): void {
  let host = "auth.derobot.is";
  try {
    host = new URL(authentikOrigin).hostname;
  } catch {
    /* default */
  }
  // Full-page SSO redirect must land on IdP before form fill / cy.origin
  cy.url({ timeout: 45000 }).should((url) => {
    const ok =
      url.includes(host) ||
      /auth\.derobot\.is/i.test(url) ||
      /\/if\/flow\//i.test(url) ||
      /\/application\/o\//i.test(url);
    expect(ok, `expected IdP URL, got ${url}`).to.eq(true);
  });
  cy.location("hostname", { timeout: 15000 }).should((h) => {
    expect(
      h === host || h.endsWith(`.${host}`) || /auth\.derobot\.is$/i.test(h),
      `hostname on IdP (got ${h})`
    ).to.eq(true);
  });
}

function triggerAppSso(
  appTrigger: AppTrigger,
  loginPath: string,
  username: string,
  authentikOrigin: string
): void {
  if (appTrigger === "direct-oidc") {
    cy.visit(APP_SSO.directOidcPath, { failOnStatusCode: false });
    waitForIdpUrl(authentikOrigin);
    return;
  }

  cy.visit(loginPath, { failOnStatusCode: false });
  dismissCookieConsentIfPresent();

  if (appTrigger === "email-then-sso") {
    // Cookie banner may still overlay; always force clear/type.
    cy.get('input[type="email"], input[name="email"], input#email', {
      timeout: 15000,
    })
      .first()
      .clear({ force: true })
      .type(username, { log: true, force: true });
    cy.contains("button, a", /continue|next|sign in/i)
      .first()
      .click({ force: true });
  }

  // Prefer data-cy SSO link, then text match, then direct /auth/oidc
  cy.get("body", { timeout: 20000 }).should("be.visible");
  // Wait for client-rendered SSO control (Next.js login cards hydrate late)
  cy.get("body", { timeout: 20000 }).then(($body) => {
    const hasDataCy = $body.find(APP_SSO.dataCyOidc).length > 0;
    if (hasDataCy) {
      cy.get(APP_SSO.dataCyOidc, { timeout: 15000 })
        .first()
        .should("be.visible")
        .click({ force: true });
      return;
    }
    // Retry once after short wait for hydration
    cy.wait(1200);
    cy.get("body").then(($b2) => {
      if ($b2.find(APP_SSO.dataCyOidc).length) {
        cy.get(APP_SSO.dataCyOidc).first().click({ force: true });
        return;
      }
      const textLink = $b2
        .find("a, button")
        .filter((_, el) => APP_SSO.ssoText.test(el.textContent || ""));
      if (textLink.length) {
        cy.wrap(textLink.first()).click({ force: true });
        return;
      }
      cy.log("SSO link not found — falling back to direct-oidc");
      cy.visit(APP_SSO.directOidcPath, { failOnStatusCode: false });
    });
  });

  // Critical for sso-link: do not enter form fill until IdP URL is live
  waitForIdpUrl(authentikOrigin);
}

/** Deep text through open shadow roots (Authentik Lit stages). Browser-only. */
function deepBodyText(doc: Document): string {
  const walk = (node: Node | null): string => {
    if (!node) return "";
    if (node.nodeType === Node.TEXT_NODE) return node.textContent || "";
    let out = "";
    const el = node as Element & { shadowRoot?: ShadowRoot | null };
    if (el.shadowRoot) out += walk(el.shadowRoot);
    const children = node.childNodes;
    for (let i = 0; i < children.length; i++) out += walk(children[i]);
    return out;
  };
  return walk(doc.body).replace(/\s+/g, " ").trim();
}

/**
 * Authentik stage fill (identity → password → optional consent).
 * Must run either inside cy.origin(IdP) OR when top is already the IdP
 * (e.g. direct-oidc / sso-link full-page redirect so cy.origin is illegal).
 */
function clickIdpPrimary(
  q: { includeShadowDom: boolean; timeout: number },
  opts?: { preferContinue?: boolean }
): void {
  const preferContinue = opts?.preferContinue === true;
  const pick = ($list: JQuery<HTMLElement>) => {
    // Prefer real stage submit over random buttons
    const filtered = $list.filter((_, el) => {
      if (isAutofillTrap(el)) return false;
      const r = el.getBoundingClientRect();
      return r.width >= 4 && r.height >= 4;
    });
    const pool = filtered.length ? filtered : $list;
    if (preferContinue) {
      const cont = pool.filter((_, el) =>
        /^\s*(continue|allow|consent|accept|log\s*in|sign\s*in|next)\s*$/i.test(
          (el.textContent || "").replace(/\s+/g, " ").trim()
        )
      );
      if (cont.length) return cont.first();
    }
    // Prefer "Log in" / "Continue" text when multiple primaries
    const labeled = pool.filter((_, el) =>
      /log\s*in|continue|sign\s*in|next/i.test(el.textContent || "")
    );
    if (labeled.length) return labeled.first();
    return pool.first();
  };

  const clickOnce = () => {
    cy.get(PRIMARY_BUTTON, q)
      .filter(":visible")
      .then(($btns) => pick($btns))
      .scrollIntoView()
      .then(($btn) => {
        const el = $btn[0] as HTMLButtonElement;
        el.focus();
        el.click();
        el.dispatchEvent(
          new MouseEvent("click", {
            bubbles: true,
            cancelable: true,
            composed: true,
            view: window,
          })
        );
        const form = el.closest("form");
        if (form && typeof form.requestSubmit === "function") {
          try {
            form.requestSubmit(el);
          } catch {
            /* ignore */
          }
        }
      });
    cy.get(PRIMARY_BUTTON, q)
      .filter(":visible")
      .then(($btns) => pick($btns))
      .click({ force: true });
  };

  clickOnce();
}

function authentikStageFill(
  user: string,
  pass: string,
  selectors: {
    identity: string;
    password: string;
    submit: string;
  }
): void {
  const q = { includeShadowDom: true as const, timeout: 45000 };

  // Wait past Loading for interactive controls
  cy.get(
    `${selectors.identity}, ${selectors.password}, ${PRIMARY_BUTTON}`,
    q
  )
    .filter((_, el) => isReallyVisible(el as HTMLElement))
    .should("have.length.at.least", 1);

  // --- Identity stage ---
  fillVisibleField(selectors.identity, user, { log: true, timeout: 30000 });

  // Re-assert value stuck before submit (HTML5 required)
  cy.get(selectors.identity, q)
    .filter((_, el) => isReallyVisible(el as HTMLElement))
    .first()
    .should("have.value", user)
    .then(($input) => {
      const el = $input[0] as HTMLInputElement;
      if (el.value !== user) setNativeInputValue(el, user);
    });

  clickIdpPrimary(q);

  // If still on identity (validation / slow stage), retry fill + submit once
  cy.get("body", { timeout: 8000 }).then(($body) => {
    const stillIdentity =
      $body.find(selectors.identity).filter((_, el) =>
        isReallyVisible(el as HTMLElement)
      ).length > 0 &&
      $body.find(selectors.password).filter((_, el) =>
        isReallyVisible(el as HTMLElement)
      ).length === 0;
    if (stillIdentity) {
      cy.log("Identity stage still present after submit — retry fill");
      fillVisibleField(selectors.identity, user, { log: true, timeout: 15000 });
      clickIdpPrimary(q);
    }
  });

  // --- Password stage (must wait for multi-step; do not match traps) ---
  cy.get(selectors.password, { includeShadowDom: true, timeout: 45000 })
    .filter((_, el) => isReallyVisible(el as HTMLElement))
    .should("have.length.at.least", 1);

  fillVisibleField(selectors.password, pass, { log: false, timeout: 30000 });

  cy.get(selectors.password, q)
    .filter((_, el) => isReallyVisible(el as HTMLElement))
    .first()
    .should(($el) => {
      expect(($el[0] as HTMLInputElement).value.length, "password length").to.be
        .greaterThan(0);
    });

  clickIdpPrimary(q);

  // Consent / residual Continue while still on IdP
  cy.location("href", { timeout: 30000 }).then((href) => {
    if (!IDP_HOST_RE.test(href)) return;
    cy.get("body", { timeout: 15000 }).should("be.visible");
  });

  const advanceIfOnIdp = () => {
    cy.location("href", { timeout: 20000 }).then((href) => {
      if (!IDP_HOST_RE.test(href)) return;
      cy.document().then((doc) => {
        const text = deepBodyText(doc);
        if (
          /Request has been denied|Flow does not apply to current user/i.test(
            text
          )
        ) {
          throw new Error(
            `Authentik denied authorization (policy/binding): ${text.slice(0, 240)}`
          );
        }
      });
      // Do not re-submit empty identity if we somehow bounced back
      cy.get("body").then(($body) => {
        const idVisible = $body
          .find(selectors.identity)
          .filter((_, el) => isReallyVisible(el as HTMLElement));
        const pwVisible = $body
          .find(selectors.password)
          .filter((_, el) => isReallyVisible(el as HTMLElement));
        if (idVisible.length && !pwVisible.length) {
          cy.log("Bounced to identity during advance — refill user");
          fillVisibleField(selectors.identity, user, {
            log: true,
            timeout: 15000,
          });
        }
        if (pwVisible.length) {
          fillVisibleField(selectors.password, pass, {
            log: false,
            timeout: 15000,
          });
        }
      });
      const onConsent = /explicit-consent|consent/i.test(href);
      clickIdpPrimary(
        { includeShadowDom: true, timeout: 15000 },
        { preferContinue: onConsent || true }
      );
      cy.wait(2000);
    });
  };
  advanceIfOnIdp();
  advanceIfOnIdp();
  advanceIfOnIdp();
  advanceIfOnIdp();
}

/**
 * Inline stage fill for cy.origin (outer helpers are not available inside origin).
 * Duplicated intentionally — Cypress serializes only the callback + args.
 */
function originStageFillSource(): string {
  // Not used as string eval — kept for docs. Real impl is inlined in fillAuthentikForm.
  return "inline";
}
void originStageFillSource;

function fillAuthentikForm(
  origin: string,
  username: string,
  password: string
): void {
  const selectors = {
    identity: AUTHENTIK_SELECTORS.identity,
    password: AUTHENTIK_SELECTORS.password,
    submit: AUTHENTIK_SELECTORS.submit,
  };
  let idpHost = "auth.derobot.is";
  try {
    idpHost = new URL(origin).hostname;
  } catch {
    /* keep default */
  }

  // After sso-link we already waited for IdP URL; re-check so we pick path correctly.
  cy.location("hostname", { timeout: 45000 }).then((host) => {
    const onIdp =
      host === idpHost ||
      host.endsWith(`.${idpHost}`) ||
      /auth\.derobot\.is$/i.test(host);

    if (onIdp) {
      // Full-page redirect to IdP — cannot wrap cy.origin when already there
      authentikStageFill(username, password, selectors);
      return;
    }

    // Secondary origin (popup or delayed cross-origin) — rare for our apps
    cy.origin(
      origin,
      { args: { username, password, selectors } },
      ({ username: user, password: pass, selectors: sel }) => {
        const q = { includeShadowDom: true as const, timeout: 45000 };
        const primarySel = sel.submit;

        const isTrap = (el: HTMLElement) => {
          if (el.getAttribute("tabindex") === "-1") return true;
          if (el.getAttribute("aria-hidden") === "true") return true;
          const style = window.getComputedStyle(el);
          if (style.opacity === "0" || style.visibility === "hidden") return true;
          const name = (el.getAttribute("name") || "").toLowerCase();
          if (
            (name === "username" || name === "password" || name === "code") &&
            !el.classList.contains("pf-c-form-control") &&
            !el.classList.contains("pf-v5-c-form-control")
          ) {
            return true;
          }
          const r = el.getBoundingClientRect();
          if (r.width < 4 || r.height < 4) return true;
          return false;
        };

        const isReal = (el: HTMLElement) => !isTrap(el);

        const setVal = (el: HTMLInputElement, value: string) => {
          el.focus();
          el.click();
          const desc = Object.getOwnPropertyDescriptor(
            window.HTMLInputElement.prototype,
            "value"
          );
          if (desc?.set) {
            desc.set.call(el, "");
            desc.set.call(el, value);
          } else {
            el.value = value;
          }
          el.dispatchEvent(
            new Event("input", { bubbles: true, cancelable: true, composed: true })
          );
          el.dispatchEvent(
            new InputEvent("input", {
              bubbles: true,
              cancelable: true,
              composed: true,
              data: value,
              inputType: "insertText",
            })
          );
          el.dispatchEvent(
            new Event("change", {
              bubbles: true,
              cancelable: true,
              composed: true,
            })
          );
        };

        const fill = (selector: string, value: string, log: boolean) => {
          cy.get(selector, q)
            .filter((_, el) => isReal(el as HTMLElement))
            .should("have.length.at.least", 1)
            .first()
            .should("be.visible")
            .then(($input) => {
              const el = $input[0] as HTMLInputElement;
              setVal(el, "");
              cy.wrap($input)
                .clear({ force: true })
                .type(value, {
                  log,
                  force: true,
                  delay: 20,
                  parseSpecialCharSequences: false,
                })
                .then(($typed) => {
                  const node = $typed[0] as HTMLInputElement;
                  if ((node.value || "") !== value) setVal(node, value);
                })
                .should("have.value", value);
            });
        };

        const deepText = (doc: Document) => {
          const walk = (node: Node | null): string => {
            if (!node) return "";
            if (node.nodeType === 3) return node.textContent || "";
            let out = "";
            const el = node as Element & { shadowRoot?: ShadowRoot | null };
            if (el.shadowRoot) out += walk(el.shadowRoot);
            const children = node.childNodes;
            for (let i = 0; i < children.length; i++) out += walk(children[i]);
            return out;
          };
          return walk(doc.body).replace(/\s+/g, " ").trim();
        };

        const pickPrimary = (
          $list: JQuery<HTMLElement>,
          preferContinue: boolean
        ) => {
          const pool = $list.filter((_, el) => {
            const r = el.getBoundingClientRect();
            return r.width >= 4 && r.height >= 4;
          });
          const use = pool.length ? pool : $list;
          if (preferContinue) {
            const cont = use.filter((_, el) =>
              /^\s*(continue|allow|consent|accept|log\s*in|sign\s*in|next)\s*$/i.test(
                (el.textContent || "").replace(/\s+/g, " ").trim()
              )
            );
            if (cont.length) return cont.first();
          }
          const labeled = use.filter((_, el) =>
            /log\s*in|continue|sign\s*in|next/i.test(el.textContent || "")
          );
          if (labeled.length) return labeled.first();
          return use.first();
        };

        const clickPrimary = (preferContinue = false) => {
          cy.get(primarySel, q)
            .filter(":visible")
            .then(($btns) => pickPrimary($btns, preferContinue))
            .scrollIntoView()
            .then(($btn) => {
              const el = $btn[0] as HTMLButtonElement;
              el.focus();
              el.click();
              el.dispatchEvent(
                new MouseEvent("click", {
                  bubbles: true,
                  cancelable: true,
                  composed: true,
                  view: window,
                })
              );
              const form = el.closest("form");
              if (form && typeof form.requestSubmit === "function") {
                try {
                  form.requestSubmit(el);
                } catch {
                  /* ignore */
                }
              }
            });
          cy.get(primarySel, q)
            .filter(":visible")
            .then(($btns) => pickPrimary($btns, preferContinue))
            .click({ force: true });
        };

        cy.get(`${sel.identity}, ${sel.password}, ${primarySel}`, q)
          .filter((_, el) => isReal(el as HTMLElement))
          .should("have.length.at.least", 1);

        // Identity
        fill(sel.identity, user, true);
        cy.get(sel.identity, q)
          .filter((_, el) => isReal(el as HTMLElement))
          .first()
          .should("have.value", user);
        clickPrimary(false);

        // Retry identity once if password not appearing
        cy.get("body", { timeout: 8000 }).then(($body) => {
          const idStill = $body
            .find(sel.identity)
            .toArray()
            .some((el) => isReal(el as HTMLElement));
          const pwGone = !$body
            .find(sel.password)
            .toArray()
            .some((el) => isReal(el as HTMLElement));
          if (idStill && pwGone) {
            fill(sel.identity, user, true);
            clickPrimary(false);
          }
        });

        // Password
        cy.get(sel.password, q)
          .filter((_, el) => isReal(el as HTMLElement))
          .should("have.length.at.least", 1);
        fill(sel.password, pass, false);
        clickPrimary(false);

        const advance = () => {
          cy.location("href", { timeout: 20000 }).then((href) => {
            if (!/auth\.derobot\.is/i.test(href)) return;
            cy.document().then((doc) => {
              const text = deepText(doc);
              if (
                /Request has been denied|Flow does not apply to current user/i.test(
                  text
                )
              ) {
                throw new Error(
                  `Authentik denied authorization (policy/binding): ${text.slice(0, 240)}`
                );
              }
            });
            cy.get("body").then(($body) => {
              const idVisible = $body
                .find(sel.identity)
                .toArray()
                .some((el) => isReal(el as HTMLElement));
              const pwVisible = $body
                .find(sel.password)
                .toArray()
                .some((el) => isReal(el as HTMLElement));
              if (idVisible && !pwVisible) {
                fill(sel.identity, user, true);
              }
              if (pwVisible) {
                fill(sel.password, pass, false);
              }
            });
            clickPrimary(true);
            cy.wait(2000);
          });
        };
        advance();
        advance();
        advance();
        advance();
      }
    );
  });
}

function assertAuthenticated(successPathMatch: RegExp): void {
  // Leave IdP first (may land on apex or app.* subdomain)
  cy.url({ timeout: 60000 }).should(
    "not.match",
    /auth\.derobot\.is|\/if\/flow\//
  );
  cy.location("pathname", { timeout: 15000 }).should("match", successPathMatch);
  cy.window({ timeout: 15000 }).then((win) => {
    const token =
      win.localStorage.getItem("access_token") ||
      win.localStorage.getItem("token") ||
      win.sessionStorage.getItem("access_token");
    if (token) {
      expect(token, "access token present").to.be.a("string").and.not.be.empty;
    } else {
      cy.log("No access_token in storage; relying on success path / cookies");
    }
  });
}

export function loginViaAuthentikImpl(
  options: LoginViaAuthentikOptions = {}
): void {
  const username = resolveUsername(options);
  const password = resolvePassword(options);
  const authentikOrigin = resolveAuthentikOrigin(options);
  const appTrigger = (options.appTrigger ||
    (Cypress.env("APP_TRIGGER") as AppTrigger | undefined) ||
    "sso-link") as AppTrigger;
  const loginPath =
    options.loginPath ||
    (Cypress.env("LOGIN_PATH") as string | undefined) ||
    DEFAULT_LOGIN_PATH;
  const successPathMatch = resolveSuccessMatch(options);
  const cacheSession = options.cacheSession !== false;
  const baseUrl = Cypress.config("baseUrl") || "";

  const run = () => {
    seedConsentIfConfigured(options);
    triggerAppSso(appTrigger, loginPath, username, authentikOrigin);
    fillAuthentikForm(authentikOrigin, username, password);
    assertAuthenticated(successPathMatch);
  };

  if (cacheSession) {
    const sessionKey = `authentik-${username}-${baseUrl}`;
    cy.session(
      sessionKey,
      () => {
        run();
      },
      {
        validate() {
          // Soft validate: token OR any auth-ish cookie; missing both forces re-login
          cy.getCookies().then((cookies) => {
            cy.window().then((win) => {
              const token =
                win.localStorage.getItem("access_token") ||
                win.localStorage.getItem("token");
              const hasAuthCookie = cookies.some((c) =>
                /session|auth|token|guardian|csrf/i.test(c.name)
              );
              if (!token && !hasAuthCookie) {
                throw new Error("session missing token/cookie — re-auth");
              }
            });
          });
        },
        cacheAcrossSpecs: true,
      }
    );
    cy.visit("/", { failOnStatusCode: false });
  } else {
    run();
  }
}

export function registerAuthentikCommands(): void {
  Cypress.Commands.add(
    "loginViaAuthentik",
    (options?: LoginViaAuthentikOptions) => {
      loginViaAuthentikImpl(options ?? {});
    }
  );
}

// Auto-register when this file is imported as a support module
registerAuthentikCommands();

/**
 * Next.js production builds often throw hydration mismatches (React #418/#423)
 * that React recovers from client-side. Do not fail Authentik SSO smoke on those.
 * Still fail on unexpected app errors.
 */
Cypress.on("uncaught:exception", (err) => {
  const msg = err?.message || String(err);
  if (
    /Minified React error #(418|423|425)/i.test(msg) ||
    /Hydration/i.test(msg) ||
    /hydrat/i.test(msg) ||
    /Text content does not match server-rendered HTML/i.test(msg) ||
    /There was an error while hydrating/i.test(msg)
  ) {
    return false;
  }
  return true;
});

declare global {
  namespace Cypress {
    interface Chainable {
      loginViaAuthentik(options?: LoginViaAuthentikOptions): Chainable<void>;
    }
  }
}

export {};
