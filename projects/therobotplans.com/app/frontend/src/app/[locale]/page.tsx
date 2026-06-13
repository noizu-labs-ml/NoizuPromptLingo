"use client";

import React, { useState, useEffect, useCallback } from "react";
import { useTranslations, useLocale } from "next-intl";

function LocaleSwitcher() {
  const locale = useLocale();

  const toggle = () => {
    const next = locale === "en" ? "ps" : "en";
    document.cookie = `NEXT_LOCALE=${next};path=/;max-age=31536000;SameSite=Lax`;
    window.location.reload();
  };

  return (
    <button
      onClick={toggle}
      title={locale === "en" ? "Switch to h@ck3r m0d3" : "Switch to English"}
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        width: 36,
        height: 36,
        background: "transparent",
        border: "1px solid var(--border, #2A2A30)",
        borderRadius: 8,
        color: "var(--text, #EDEDF0)",
        cursor: "pointer",
        fontSize: 13,
        fontWeight: 700,
        fontFamily: "var(--font-mono, monospace)",
        textTransform: "uppercase",
        transition: "border-color 0.15s",
      }}
    >
      {locale === "en" ? "EN" : "PS"}
    </button>
  );
}

function ThemeToggle() {
  const [mode, setMode] = useState<"system" | "light" | "dark">("system");
  const [resolved, setResolved] = useState<"light" | "dark">("light");

  useEffect(() => {
    const stored = localStorage.getItem("color-mode");
    if (stored === "light" || stored === "dark") {
      setMode(stored);
      setResolved(stored);
    } else {
      setMode("system");
      setResolved(
        window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
      );
    }
  }, []);

  useEffect(() => {
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    const handler = (e: MediaQueryListEvent) => {
      if (mode === "system") {
        const next = e.matches ? "dark" : "light";
        setResolved(next);
        document.documentElement.classList.toggle("dark", e.matches);
      }
    };
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, [mode]);

  const cycle = useCallback(() => {
    const order: Array<"system" | "light" | "dark"> = ["system", "light", "dark"];
    const next = order[(order.indexOf(mode) + 1) % order.length];
    setMode(next);

    if (next === "system") {
      localStorage.removeItem("color-mode");
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      setResolved(prefersDark ? "dark" : "light");
      document.documentElement.classList.toggle("dark", prefersDark);
    } else {
      localStorage.setItem("color-mode", next);
      setResolved(next);
      document.documentElement.classList.toggle("dark", next === "dark");
    }
  }, [mode]);

  return (
    <button
      onClick={cycle}
      aria-label={`Color mode: ${mode}`}
      title={`Color mode: ${mode} (${resolved})`}
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        width: 36,
        height: 36,
        background: "transparent",
        border: "1px solid var(--border, #2A2A30)",
        borderRadius: 8,
        color: "var(--text, #EDEDF0)",
        cursor: "pointer",
        transition: "border-color 0.15s",
        position: "relative",
      }}
    >
      {resolved === "dark" ? (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
        </svg>
      ) : (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="12" r="5" /><line x1="12" y1="1" x2="12" y2="3" /><line x1="12" y1="21" x2="12" y2="23" /><line x1="4.22" y1="4.22" x2="5.64" y2="5.64" /><line x1="18.36" y1="18.36" x2="19.78" y2="19.78" /><line x1="1" y1="12" x2="3" y2="12" /><line x1="21" y1="12" x2="23" y2="12" /><line x1="4.22" y1="19.78" x2="5.64" y2="18.36" /><line x1="18.36" y1="5.64" x2="19.78" y2="4.22" />
        </svg>
      )}
      {mode === "system" && (
        <span style={{
          position: "absolute",
          bottom: -2,
          right: -2,
          width: 8,
          height: 8,
          borderRadius: "50%",
          background: "var(--teal, #4A7B6F)",
          border: "2px solid var(--surface, var(--white, #FAF7F2))",
        }} />
      )}
    </button>
  );
}

function LoginWidget() {
  const t = useTranslations("nav");
  const [open, setOpen] = useState(false);

  return (
    <div style={{ position: "relative" }}>
      <button
        onClick={() => setOpen(!open)}
        style={{
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "8px 16px",
          background: "transparent",
          border: "1px solid var(--border, #2A2A30)",
          borderRadius: 8,
          color: "var(--text, #EDEDF0)",
          cursor: "pointer",
          fontSize: 14,
          fontFamily: "var(--font-body, inherit)",
          transition: "border-color 0.15s",
        }}
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
          <circle cx="12" cy="7" r="4" />
        </svg>
        {t("signIn")}
      </button>

      {open && (
        <div
          style={{
            position: "absolute",
            top: "calc(100% + 8px)",
            right: 0,
            width: 280,
            background: "var(--surface-alt, #141416)",
            border: "1px solid var(--border, #2A2A30)",
            borderRadius: 12,
            padding: 20,
            boxShadow: "var(--shadow-overlay, 0 4px 24px rgba(0,0,0,0.2))",
            zIndex: 100,
          }}
        >
          <p style={{ fontSize: 13, color: "var(--text-muted, #5A5A62)", marginBottom: 16, textAlign: "center" }}>
            {t("signInHeading")}
          </p>
          <button
            style={{
              width: "100%",
              padding: "10px 16px",
              background: "var(--surface, #1C1C20)",
              border: "1px solid var(--border, #2A2A30)",
              borderRadius: 8,
              color: "var(--text, #EDEDF0)",
              cursor: "pointer",
              fontSize: 14,
              fontFamily: "var(--font-body, inherit)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
              marginBottom: 8,
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
            {t("continueGithub")}
          </button>
          <button
            style={{
              width: "100%",
              padding: "10px 16px",
              background: "var(--surface, #1C1C20)",
              border: "1px solid var(--border, #2A2A30)",
              borderRadius: 8,
              color: "var(--text, #EDEDF0)",
              cursor: "pointer",
              fontSize: 14,
              fontFamily: "var(--font-body, inherit)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/></svg>
            {t("continueGoogle")}
          </button>
        </div>
      )}
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode; title: string; description: string }) {
  return (
    <div
      style={{
        padding: 24,
        background: "var(--surface-alt, #141416)",
        border: "1px solid var(--border, #2A2A30)",
        borderRadius: 12,
      }}
    >
      <div style={{ marginBottom: 12, color: "var(--teal, #14B8A6)" }}>{icon}</div>
      <h3 style={{ fontSize: 18, fontWeight: 600, marginBottom: 8, color: "var(--text, #EDEDF0)" }}>{title}</h3>
      <p style={{ fontSize: 14, lineHeight: 1.6, color: "var(--text-secondary, #8E8E96)" }}>{description}</p>
    </div>
  );
}

const featureIcons = {
  todayView: (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
    </svg>
  ),
  methodology: (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="18" height="18" rx="2" ry="2" /><line x1="3" y1="9" x2="21" y2="9" /><line x1="9" y1="21" x2="9" y2="9" />
    </svg>
  ),
  agents: (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M23 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  ),
  ops: (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
    </svg>
  ),
  rag: (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" /><line x1="2" y1="12" x2="22" y2="12" /><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
    </svg>
  ),
  okrs: (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 20V10" /><path d="M18 20V4" /><path d="M6 20v-4" />
    </svg>
  ),
};

const featureKeys = ["todayView", "methodology", "agents", "ops", "rag", "okrs"] as const;
const agentKeys = ["pm", "triage", "coder", "monitor", "reviewer", "planner"] as const;

export default function LandingPage() {
  const t = useTranslations();

  return (
    <div style={{ minHeight: "100dvh", background: "var(--surface, var(--white, #FAF7F2))", color: "var(--text, #2C1810)" }}>
      {/* ── Nav ── */}
      <nav
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "16px 32px",
          borderBottom: "1px solid var(--border, #2A2A30)",
          position: "sticky",
          top: 0,
          background: "var(--surface, var(--white, #FAF7F2))",
          zIndex: 50,
          backdropFilter: "blur(12px)",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 20, fontWeight: 700, fontFamily: "var(--font-body, 'Lora', serif)", letterSpacing: "-0.02em" }}>
            tobornalp
          </span>
          <span style={{ fontSize: 11, fontWeight: 500, letterSpacing: "0.08em", textTransform: "uppercase", color: "var(--text-muted, #5A5A62)", background: "var(--surface-alt, #141416)", padding: "2px 8px", borderRadius: 4 }}>
            {t("nav.preview")}
          </span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <LocaleSwitcher />
          <ThemeToggle />
          <LoginWidget />
        </div>
      </nav>

      {/* ── Hero ── */}
      <section style={{ maxWidth: 960, margin: "0 auto", padding: "80px 32px 60px", textAlign: "center" }}>
        <h1
          style={{
            fontSize: "clamp(36px, 5vw, 56px)",
            fontWeight: 700,
            lineHeight: 1.15,
            fontFamily: "var(--font-body, 'Lora', serif)",
            letterSpacing: "-0.02em",
            marginBottom: 24,
          }}
        >
          {t("hero.headlineStart")}{" "}
          <span style={{ color: "var(--teal, #4A7B6F)" }}>{t("hero.headlineAccent")}</span>
        </h1>
        <p style={{ fontSize: 18, lineHeight: 1.7, color: "var(--text-secondary, #8E8E96)", maxWidth: 640, margin: "0 auto 40px" }}>
          {t("hero.subtext")}
        </p>
        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
          <button
            style={{
              padding: "14px 32px",
              background: "var(--teal, #4A7B6F)",
              color: "#fff",
              border: "none",
              borderRadius: 8,
              fontSize: 16,
              fontWeight: 600,
              cursor: "pointer",
              fontFamily: "var(--font-body, inherit)",
            }}
          >
            {t("hero.ctaPrimary")}
          </button>
          <button
            style={{
              padding: "14px 32px",
              background: "transparent",
              color: "var(--text, #EDEDF0)",
              border: "1px solid var(--border, #2A2A30)",
              borderRadius: 8,
              fontSize: 16,
              fontWeight: 500,
              cursor: "pointer",
              fontFamily: "var(--font-body, inherit)",
            }}
          >
            {t("hero.ctaSecondary")}
          </button>
        </div>
      </section>

      {/* ── Tagline ── */}
      <div
        style={{
          textAlign: "center",
          padding: "24px 32px",
          color: "var(--text-muted, #5A5A62)",
          fontSize: 13,
          letterSpacing: "0.05em",
          textTransform: "uppercase",
          fontWeight: 500,
        }}
      >
        {t("tagline")}
      </div>

      {/* ── Features grid ── */}
      <section style={{ maxWidth: 1080, margin: "0 auto", padding: "40px 32px 80px" }}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))", gap: 20 }}>
          {featureKeys.map((key) => (
            <FeatureCard
              key={key}
              icon={featureIcons[key]}
              title={t(`features.${key}.title`)}
              description={t(`features.${key}.description`)}
            />
          ))}
        </div>
      </section>

      {/* ── Agent roles ── */}
      <section style={{ borderTop: "1px solid var(--border, #2A2A30)", padding: "60px 32px", textAlign: "center" }}>
        <h2 style={{ fontSize: 28, fontWeight: 700, fontFamily: "var(--font-body, 'Lora', serif)", marginBottom: 12 }}>
          {t("agentRoles.heading")}
        </h2>
        <p style={{ fontSize: 15, color: "var(--text-secondary, #8E8E96)", maxWidth: 560, margin: "0 auto 40px" }}>
          {t("agentRoles.subtext")}
        </p>
        <div style={{ display: "flex", gap: 16, justifyContent: "center", flexWrap: "wrap", maxWidth: 800, margin: "0 auto" }}>
          {agentKeys.map((key) => (
            <div
              key={key}
              style={{
                padding: "16px 20px",
                background: "var(--surface-alt, #141416)",
                border: "1px solid var(--border, #2A2A30)",
                borderRadius: 10,
                textAlign: "left",
                minWidth: 180,
                flex: "1 1 180px",
                maxWidth: 240,
              }}
            >
              <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 4, color: "var(--teal, #4A7B6F)" }}>
                {t(`agentRoles.${key}.role`)}
              </div>
              <div style={{ fontSize: 13, color: "var(--text-muted, #5A5A62)", lineHeight: 1.4 }}>
                {t(`agentRoles.${key}.desc`)}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* ── CTA ── */}
      <section style={{ padding: "80px 32px", textAlign: "center", borderTop: "1px solid var(--border, #2A2A30)" }}>
        <h2 style={{ fontSize: 32, fontWeight: 700, fontFamily: "var(--font-body, 'Lora', serif)", marginBottom: 16 }}>
          {t("cta.heading")}
        </h2>
        <p style={{ fontSize: 16, color: "var(--text-secondary, #8E8E96)", maxWidth: 480, margin: "0 auto 32px" }}>
          {t("cta.subtext")}
        </p>
        <button
          style={{
            padding: "16px 40px",
            background: "var(--teal, #4A7B6F)",
            color: "#fff",
            border: "none",
            borderRadius: 8,
            fontSize: 17,
            fontWeight: 600,
            cursor: "pointer",
            fontFamily: "var(--font-body, inherit)",
          }}
        >
          {t("cta.button")}
        </button>
      </section>

      {/* ── Footer ── */}
      <footer
        style={{
          borderTop: "1px solid var(--border, #2A2A30)",
          padding: "24px 32px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          fontSize: 13,
          color: "var(--text-muted, #5A5A62)",
        }}
      >
        <span>{t("footer.brand")}</span>
        <span>{t("footer.status")}</span>
      </footer>
    </div>
  );
}
