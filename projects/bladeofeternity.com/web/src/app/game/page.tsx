"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import { fetchCharacter } from "@/lib/api";
import { cyAttrs } from "@/lib/cy-attrs";

/* ============================================
   TYPES
   ============================================ */
interface GameState {
  characterName: string;
  location: string;
  narrative: string[];
  alert: string | null;
  status: string | null;
  actions: string[];
  hp: number;
  maxHp: number;
  energy: number;
  maxEnergy: number;
  gold: number;
  level: number;
  xp: number;
  xpNext: number;
  weapon: string;
  armor: string;
  effects: string[];
}

/* ============================================
   MAIN GAME VIEW
   ============================================ */
export default function GamePage() {
  const { user, loading, logout } = useAuth();
  const router = useRouter();
  const [state, setState] = useState<GameState | null>(null);
  const [input, setInput] = useState("");
  const [history, setHistory] = useState<string[]>([]);
  const [historyIdx, setHistoryIdx] = useState(-1);
  const inputRef = useRef<HTMLInputElement>(null);
  const logEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!loading && !user) router.replace("/login");
  }, [loading, user, router]);

  // Fetch character data from backend
  useEffect(() => {
    if (!user) return;
    fetchCharacter()
      .then((c) => {
        if (!c) {
          router.replace("/create-character");
          return;
        }
        setState({
          characterName: c.name,
          location: c.location,
          narrative: [
            `Welcome, ${c.name}. You find yourself in ${c.location}.`,
            "The world awaits your command.",
          ],
          alert: null,
          status: "Connected.",
          actions: ["Look around", "Go north", "Go east", "Go west", "Go south", "Check inventory"],
          hp: c.hp,
          maxHp: c.max_hp,
          energy: c.energy,
          maxEnergy: c.max_energy,
          gold: c.gold,
          level: c.level,
          xp: c.xp,
          xpNext: c.xp_next,
          weapon: c.weapon,
          armor: c.armor,
          effects: c.effects,
        });
      })
      .catch(() => {
        router.replace("/create-character");
      });
  }, [user, router]);

  // Auto-scroll narrative log
  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [state?.narrative.length]);

  // Clear alert after 5 seconds
  useEffect(() => {
    if (!state?.alert) return;
    const t = setTimeout(() => setState((s) => s ? ({ ...s, alert: null }) : s), 5000);
    return () => clearTimeout(t);
  }, [state?.alert]);

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      const cmd = input.trim();
      if (!cmd) return;

      setHistory((h) => [cmd, ...h]);
      setHistoryIdx(-1);
      setInput("");

      // Demo: echo the command into narrative
      setState((s) => s ? ({
        ...s,
        narrative: [...s.narrative, `> ${cmd}`, "The world shifts around you..."],
        status: `Command received: ${cmd}`,
      }) : s);

      inputRef.current?.focus();
    },
    [input],
  );

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "ArrowUp") {
        e.preventDefault();
        const next = Math.min(historyIdx + 1, history.length - 1);
        setHistoryIdx(next);
        if (history[next]) setInput(history[next]);
      } else if (e.key === "ArrowDown") {
        e.preventDefault();
        const next = historyIdx - 1;
        if (next < 0) {
          setHistoryIdx(-1);
          setInput("");
        } else {
          setHistoryIdx(next);
          setInput(history[next]);
        }
      }
    },
    [history, historyIdx],
  );

  const handleAction = useCallback((action: string) => {
    setState((s) => s ? ({
      ...s,
      narrative: [...s.narrative, `> ${action}`, "The world shifts around you..."],
      status: `Action: ${action}`,
    }) : s);
    inputRef.current?.focus();
  }, []);

  if (loading || !user || !state) return null;

  const hpPct = (state.hp / state.maxHp) * 100;
  const energyPct = (state.energy / state.maxEnergy) * 100;
  const xpPct = (state.xp / state.xpNext) * 100;

  return (
    <div className="mx-auto flex min-h-screen max-w-[1200px] flex-col" style={{ background: "var(--bg-void)" }} {...cyAttrs({ cy: "game-page", cyScope: "game" })}>
      {/* Skip links */}
      <a
        href="#narrative-log"
        className="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-50 focus:rounded focus:px-3 focus:py-1 focus:text-sm"
        style={{ background: "var(--gold)", color: "#070707", fontFamily: "var(--font-heading)" }}
      >
        Skip to story
      </a>
      <a
        href="#command-input"
        className="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-36 focus:z-50 focus:rounded focus:px-3 focus:py-1 focus:text-sm"
        style={{ background: "var(--gold)", color: "#070707", fontFamily: "var(--font-heading)" }}
      >
        Skip to command input
      </a>

      {/* HEADER */}
      <header
        className="border-b"
        style={{ background: "var(--bg-primary)", borderColor: "var(--metal-dark)" }}
        {...cyAttrs({ cy: "game-header", cyId: "game-header" })}
      >
        <div className="flex items-center justify-between px-4 py-2">
          <a
            href="/"
            className="text-xl tracking-widest"
            style={{
              fontFamily: "var(--font-display)",
              color: "var(--gold)",
              textShadow: "0 0 8px rgba(201,168,76,0.2)",
            }}
          >
            BoE
          </a>
          <div className="flex items-center gap-4">
            <span className="text-sm" style={{ color: "var(--gold-light)" }} {...cyAttrs({ cy: "character-name" })}>
              {state.characterName}
            </span>
            <span className="text-sm" style={{ color: "var(--text-muted)" }} {...cyAttrs({ cy: "character-level", cyValue: state.level })}>
              Level {state.level}
            </span>
            <button
              onClick={() => {
                logout();
                router.push("/");
              }}
              className="text-xs transition-colors hover:text-[var(--gold)]"
              style={{ color: "var(--text-muted)" }}
              {...cyAttrs({ cy: "logout-button" })}
            >
              Logout
            </button>
          </div>
        </div>
      </header>

      {/* STATS BAR — second-level header */}
      <div
        className="border-b"
        style={{ background: "var(--bg-surface)", borderColor: "var(--metal-dark)" }}
        role="banner"
        aria-label="Character status"
        {...cyAttrs({ cy: "stats-bar", cyScope: "character-status" })}
      >
        <div className="flex flex-wrap items-center gap-x-6 gap-y-2 px-4 py-2">
          {/* HP */}
          <div className="flex items-center gap-2">
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>HP</span>
            <div className="relative h-2 w-24 overflow-hidden rounded-full" style={{ background: "var(--metal-dark)" }}>
              <div className="h-full rounded-full transition-all" style={{ width: `${hpPct}%`, background: hpPct < 25 ? "var(--red)" : "var(--green)" }} role="progressbar" aria-valuenow={state.hp} aria-valuemin={0} aria-valuemax={state.maxHp} aria-label={`Health: ${state.hp} of ${state.maxHp}`} {...cyAttrs({ cy: "hp-bar", cyValue: state.hp })} />
            </div>
            <span className="text-xs tabular-nums" style={{ color: "var(--text-primary)" }}>{state.hp}/{state.maxHp}</span>
          </div>

          {/* Energy */}
          <div className="flex items-center gap-2">
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>EN</span>
            <div className="relative h-2 w-20 overflow-hidden rounded-full" style={{ background: "var(--metal-dark)" }}>
              <div className="h-full rounded-full transition-all" style={{ width: `${energyPct}%`, background: "var(--blue)" }} role="progressbar" aria-valuenow={state.energy} aria-valuemin={0} aria-valuemax={state.maxEnergy} aria-label={`Energy: ${state.energy} of ${state.maxEnergy}`} {...cyAttrs({ cy: "energy-bar", cyValue: state.energy })} />
            </div>
            <span className="text-xs tabular-nums" style={{ color: "var(--text-primary)" }}>{state.energy}/{state.maxEnergy}</span>
          </div>

          {/* XP */}
          <div className="flex items-center gap-2">
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>XP</span>
            <div className="relative h-2 w-20 overflow-hidden rounded-full" style={{ background: "var(--metal-dark)" }}>
              <div className="h-full rounded-full transition-all" style={{ width: `${xpPct}%`, background: "var(--gold)" }} role="progressbar" aria-valuenow={state.xp} aria-valuemin={0} aria-valuemax={state.xpNext} aria-label={`Experience: ${state.xp} of ${state.xpNext}`} {...cyAttrs({ cy: "xp-bar", cyValue: state.xp })} />
            </div>
            <span className="text-xs tabular-nums" style={{ color: "var(--text-primary)" }}>{state.xp}/{state.xpNext}</span>
          </div>

          {/* Gold */}
          <div className="flex items-center gap-1.5">
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>Gold</span>
            <span className="text-xs tabular-nums" style={{ color: "var(--gold-light)" }} {...cyAttrs({ cy: "gold", cyValue: state.gold })}>{state.gold.toLocaleString()}</span>
          </div>

          {/* Divider */}
          <div className="hidden h-4 border-l md:block" style={{ borderColor: "var(--metal-mid)" }} />

          {/* Equipment */}
          <div className="flex items-center gap-1.5">
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>Weapon:</span>
            <span className="text-xs" style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "weapon" })}>{state.weapon}</span>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="text-xs" style={{ color: "var(--text-muted)" }}>Armor:</span>
            <span className="text-xs" style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "armor" })}>{state.armor}</span>
          </div>

          {/* Divider */}
          <div className="hidden h-4 border-l md:block" style={{ borderColor: "var(--metal-mid)" }} />

          {/* Effects */}
          {state.effects.length > 0 && (
            <div className="flex items-center gap-1.5" {...cyAttrs({ cy: "effects" })}>
              <span className="text-xs" style={{ color: "var(--text-muted)" }}>Effects:</span>
              {state.effects.map((eff) => (
                <span
                  key={eff}
                  className="rounded px-1.5 py-0.5 text-xs"
                  style={{ background: "var(--bg-elevated)", color: "var(--gold-light)", border: "1px solid var(--metal-mid)" }}
                  {...cyAttrs({ cy: "effect", cyId: eff })}
                >
                  {eff}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* MAIN LAYOUT */}
      <div className="flex w-full flex-1">
        {/* GAME PANEL */}
        <main className="flex flex-1 flex-col" aria-label="Game">
          {/* Location heading */}
          <div
            className="border-b px-4 py-3"
            style={{ borderColor: "var(--metal-dark)", background: "var(--bg-primary)" }}
          >
            <h1
              className="text-lg tracking-wide"
              style={{ fontFamily: "var(--font-heading)", color: "var(--gold)" }}
              {...cyAttrs({ cy: "location" })}
            >
              {state.location}
            </h1>
          </div>

          {/* Narrative log */}
          <section className="flex-1 overflow-y-auto px-4 py-4" aria-label="Story">
            <h2 className="sr-only">Story</h2>
            <div
              id="narrative-log"
              role="log"
              aria-live="polite"
              {...cyAttrs({ cy: "narrative-log" })}
              aria-atomic="false"
              aria-relevant="additions"
              aria-label="Story"
              tabIndex={-1}
              className="space-y-3"
            >
              {state.narrative.map((line, i) => (
                <p
                  key={i}
                  className={`leading-7 ${line.startsWith(">") ? "font-mono text-sm" : ""}`}
                  style={{
                    color: line.startsWith(">") ? "var(--gold-light)" : "var(--text-primary)",
                    fontFamily: line.startsWith(">") ? "var(--font-code)" : "var(--font-body)",
                  }}
                >
                  {line}
                </p>
              ))}
              <div ref={logEndRef} />
            </div>
          </section>

          {/* Actions menu */}
          <section
            className="border-t px-4 py-3"
            style={{ borderColor: "var(--metal-dark)", background: "var(--bg-surface)" }}
            aria-label="Available actions"
            {...cyAttrs({ cy: "actions-menu", cyScope: "actions" })}
          >
            <h2 className="sr-only">Available Actions</h2>
            <div className="flex flex-wrap gap-2" role="menu" aria-label="Choices">
              {state.actions.map((action) => (
                <button
                  key={action}
                  role="menuitem"
                  onClick={() => handleAction(action)}
                  {...cyAttrs({ cy: "action-button", cyId: action.toLowerCase().replace(/\s+/g, "-") })}
                  className="rounded border px-3 py-1.5 text-sm transition-colors hover:border-[var(--gold)] hover:text-[var(--gold)]"
                  style={{
                    borderColor: "var(--metal-mid)",
                    color: "var(--text-primary)",
                    background: "var(--bg-elevated)",
                  }}
                >
                  {action}
                </button>
              ))}
            </div>
          </section>

          {/* Command input */}
          <form
            onSubmit={handleSubmit}
            className="border-t px-4 py-3"
            style={{ borderColor: "var(--metal-dark)", background: "var(--bg-primary)" }}
            aria-label="Command input"
            {...cyAttrs({ cy: "command-form" })}
          >
            <label htmlFor="command-input" className="sr-only">
              Enter command
            </label>
            <div className="flex gap-2">
              <span className="py-2 text-sm" style={{ color: "var(--gold)", fontFamily: "var(--font-code)" }}>
                &gt;
              </span>
              <input
                ref={inputRef}
                id="command-input"
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKeyDown}
                autoComplete="off"
                spellCheck={false}
                placeholder="Enter command..."
                {...cyAttrs({ cy: "command-input" })}
                className="flex-1 bg-transparent py-2 text-sm outline-none"
                style={{
                  color: "var(--text-primary)",
                  fontFamily: "var(--font-code)",
                }}
                aria-describedby="input-hint"
              />
              <button
                type="submit"
                className="rounded px-4 py-1.5 text-sm font-semibold transition-colors"
                style={{ background: "var(--gold)", color: "#070707", fontFamily: "var(--font-heading)" }}
                {...cyAttrs({ cy: "command-send" })}
              >
                Send
              </button>
            </div>
            <div id="input-hint" className="sr-only">
              Type a command or use arrow keys to browse command history. Press Tab to navigate to other game panels.
            </div>
          </form>
        </main>

      </div>

      {/* ARIA live regions (hidden) */}
      <div
        role="alert"
        aria-live="assertive"
        aria-atomic="true"
        aria-label="Game alerts"
        className="sr-only"
      >
        {state.alert}
      </div>
      <div
        role="status"
        aria-live="polite"
        aria-atomic="true"
        aria-label="Game status"
        className="sr-only"
      >
        {state.status}
      </div>

      {/* Footer — connection status */}
      <footer
        className="border-t"
        style={{
          borderColor: "var(--metal-dark)",
          background: "var(--bg-primary)",
          color: "var(--text-muted)",
        }}
      >
        <div
          className="px-4 py-2 text-center text-xs"
          role="status"
          aria-live="assertive"
          aria-label="Connection status"
        >
          Connected — {state.location}
        </div>
      </footer>
    </div>
  );
}
