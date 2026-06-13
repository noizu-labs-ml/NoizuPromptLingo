"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/auth";
import { createCharacter, fetchCharacter } from "@/lib/api";
import { cyAttrs } from "@/lib/cy-attrs";

/* ============================================
   GAME DATA
   ============================================ */

type RaceDef = {
  id: string;
  name: string;
  description: string;
  bonuses: Partial<Record<Attr, number>>;
};

type ClassDef = {
  id: string;
  name: string;
  description: string;
  weapon: string;
  armor: string;
};

type Attr = "strength" | "dexterity" | "constitution" | "intelligence" | "wisdom" | "charisma";

const ATTRS: { key: Attr; label: string; abbr: string; description: string }[] = [
  { key: "strength", label: "Strength", abbr: "STR", description: "Melee damage, carry weight" },
  { key: "dexterity", label: "Dexterity", abbr: "DEX", description: "Dodge, ranged accuracy, initiative" },
  { key: "constitution", label: "Constitution", abbr: "CON", description: "Hit points, poison resistance" },
  { key: "intelligence", label: "Intelligence", abbr: "INT", description: "Spell power, lore knowledge" },
  { key: "wisdom", label: "Wisdom", abbr: "WIS", description: "Energy pool, perception, willpower" },
  { key: "charisma", label: "Charisma", abbr: "CHA", description: "Prices, persuasion, leadership" },
];

const RACES: RaceDef[] = [
  { id: "human", name: "Human", description: "Versatile and adaptable. Bonus to all attributes.", bonuses: { strength: 1, dexterity: 1, constitution: 1, intelligence: 1, wisdom: 1, charisma: 1 } },
  { id: "elf", name: "Elf", description: "Graceful and perceptive. Quick of mind and hand.", bonuses: { dexterity: 2, intelligence: 1 } },
  { id: "dwarf", name: "Dwarf", description: "Stout and enduring. Born of stone and iron will.", bonuses: { constitution: 2, strength: 1 } },
  { id: "halfling", name: "Halfling", description: "Nimble and charming. Small but impossible to ignore.", bonuses: { dexterity: 2, charisma: 1 } },
  { id: "orc", name: "Orc", description: "Fierce and unyielding. Strength runs in the blood.", bonuses: { strength: 2, constitution: 1 } },
];

const CLASSES: ClassDef[] = [
  { id: "warrior", name: "Warrior", description: "Masters of martial combat. Heavy armor, heavy hits.", weapon: "Iron Shortsword (+5 attack)", armor: "Chain Mail (+8 defense)" },
  { id: "mage", name: "Mage", description: "Wielders of arcane power. Fragile but devastating.", weapon: "Oak Staff (+2 atk, +5 spell)", armor: "Cloth Robes (+2 defense)" },
  { id: "rogue", name: "Rogue", description: "Shadows and steel. Strike where they least expect.", weapon: "Steel Dagger (+4 attack)", armor: "Leather Armor (+5 defense)" },
  { id: "cleric", name: "Cleric", description: "Divine servants. Heal the faithful, smite the wicked.", weapon: "Iron Mace (+4 attack)", armor: "Scale Mail (+6 defense)" },
  { id: "ranger", name: "Ranger", description: "Wardens of the wild. Bow, blade, and beast.", weapon: "Hunting Bow (+4 attack)", armor: "Hide Armor (+4 defense)" },
];

const BASE = 10;
const FREE_POINTS = 10;
const MIN_ATTR = 8;
const MAX_ATTR = 20;

/* ============================================
   PAGE
   ============================================ */

export default function CreateCharacterPage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  const [name, setName] = useState("");
  const [race, setRace] = useState("human");
  const [charClass, setCharClass] = useState("warrior");
  const [attrs, setAttrs] = useState<Record<Attr, number>>({
    strength: BASE,
    dexterity: BASE,
    constitution: BASE,
    intelligence: BASE,
    wisdom: BASE,
    charisma: BASE,
  });
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [checking, setChecking] = useState(true);

  // Redirect if not logged in
  useEffect(() => {
    if (!loading && !user) router.replace("/login");
  }, [loading, user, router]);

  // If user already has a character, go to game
  useEffect(() => {
    if (!user) return;
    fetchCharacter().then((c) => {
      if (c) router.replace("/game");
      else setChecking(false);
    });
  }, [user, router]);

  const raceDef = RACES.find((r) => r.id === race)!;
  const classDef = CLASSES.find((c) => c.id === charClass)!;

  const spent = Object.values(attrs).reduce((s, v) => s + v, 0) - BASE * 6;
  const remaining = FREE_POINTS - spent;

  function adjustAttr(key: Attr, delta: number) {
    setAttrs((prev) => {
      const next = prev[key] + delta;
      if (next < MIN_ATTR || next > MAX_ATTR) return prev;
      const newSpent = Object.entries(prev).reduce(
        (s, [k, v]) => s + (k === key ? next : v),
        0,
      ) - BASE * 6;
      if (newSpent > FREE_POINTS) return prev;
      return { ...prev, [key]: next };
    });
  }

  function getFinal(key: Attr): number {
    return attrs[key] + (raceDef.bonuses[key] || 0);
  }

  const finalCon = getFinal("constitution");
  const finalWis = getFinal("wisdom");
  const derivedHp = 50 + finalCon * 5;
  const derivedEnergy = 20 + finalWis * 3;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (name.trim().length < 2) {
      setError("Name must be at least 2 characters");
      return;
    }

    if (remaining !== 0) {
      setError(`You have ${remaining} attribute points remaining`);
      return;
    }

    setSubmitting(true);
    try {
      await createCharacter({
        name: name.trim(),
        race,
        character_class: charClass,
        ...attrs,
      });
      router.push("/game");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create character");
    } finally {
      setSubmitting(false);
    }
  }

  if (loading || !user || checking) return null;

  const sectionHeading = "mb-3 text-lg tracking-wide";
  const sectionHeadingStyle = { fontFamily: "var(--font-heading)", color: "var(--gold)" };

  return (
    <div className="min-h-screen" style={{ background: "#070707" }} {...cyAttrs({ cy: "create-character-page", cyScope: "create-character" })}>
      <div className="mx-auto max-w-[800px] px-4 py-12">
        <h1
          className="mb-2 text-center text-3xl tracking-wide"
          style={{ fontFamily: "var(--font-display)", color: "var(--gold)", textShadow: "0 0 12px rgba(201,168,76,0.3)" }}
        >
          Forge Your Legend
        </h1>
        <p className="mb-10 text-center text-sm" style={{ color: "var(--text-muted)" }}>
          Choose wisely. The world of Eternity shapes itself around you.
        </p>

        {error && (
          <div
            className="mb-6 rounded border px-4 py-3 text-sm"
            style={{ borderColor: "var(--red)", background: "rgba(205,92,92,0.1)", color: "var(--red)" }}
            role="alert"
            {...cyAttrs({ cy: "error-alert" })}
          >
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-10" {...cyAttrs({ cy: "character-form" })}>
          {/* CHARACTER NAME */}
          <section {...cyAttrs({ cy: "name-section" })}>
            <h2 className={sectionHeading} style={sectionHeadingStyle}>Character Name</h2>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter a name..."
              maxLength={30}
              className="w-full max-w-[400px] rounded border px-3 py-2 text-sm outline-none transition-colors focus:border-[var(--gold)]"
              style={{ background: "var(--bg-elevated)", borderColor: "var(--metal-mid)", color: "var(--text-primary)" }}
              {...cyAttrs({ cy: "name-input", cyId: "character-name" })}
            />
          </section>

          {/* RACE */}
          <section {...cyAttrs({ cy: "race-section" })}>
            <h2 className={sectionHeading} style={sectionHeadingStyle}>Race</h2>
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {RACES.map((r) => (
                <button
                  key={r.id}
                  type="button"
                  onClick={() => setRace(r.id)}
                  className="rounded-lg border p-4 text-left transition-colors"
                  style={{
                    background: race === r.id ? "var(--bg-elevated)" : "var(--bg-surface)",
                    borderColor: race === r.id ? "var(--gold)" : "rgba(255,255,255,0.1)",
                  }}
                  {...cyAttrs({ cy: "race-card", cyId: r.id, cyValue: race === r.id ? "selected" : undefined })}
                >
                  <div className="mb-1 text-sm font-semibold" style={{ color: race === r.id ? "var(--gold)" : "var(--text-primary)", fontFamily: "var(--font-heading)" }}>
                    {r.name}
                  </div>
                  <div className="mb-2 text-xs leading-relaxed" style={{ color: "var(--text-secondary)" }}>
                    {r.description}
                  </div>
                  <div className="flex flex-wrap gap-1.5">
                    {Object.entries(r.bonuses).map(([attr, val]) => (
                      <span
                        key={attr}
                        className="rounded px-1.5 py-0.5 text-xs"
                        style={{ background: "rgba(201,168,76,0.15)", color: "var(--gold-light)" }}
                      >
                        +{val} {attr.slice(0, 3).toUpperCase()}
                      </span>
                    ))}
                  </div>
                </button>
              ))}
            </div>
          </section>

          {/* CLASS */}
          <section {...cyAttrs({ cy: "class-section" })}>
            <h2 className={sectionHeading} style={sectionHeadingStyle}>Class</h2>
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {CLASSES.map((c) => (
                <button
                  key={c.id}
                  type="button"
                  onClick={() => setCharClass(c.id)}
                  className="rounded-lg border p-4 text-left transition-colors"
                  style={{
                    background: charClass === c.id ? "var(--bg-elevated)" : "var(--bg-surface)",
                    borderColor: charClass === c.id ? "var(--gold)" : "rgba(255,255,255,0.1)",
                  }}
                  {...cyAttrs({ cy: "class-card", cyId: c.id, cyValue: charClass === c.id ? "selected" : undefined })}
                >
                  <div className="mb-1 text-sm font-semibold" style={{ color: charClass === c.id ? "var(--gold)" : "var(--text-primary)", fontFamily: "var(--font-heading)" }}>
                    {c.name}
                  </div>
                  <div className="mb-2 text-xs leading-relaxed" style={{ color: "var(--text-secondary)" }}>
                    {c.description}
                  </div>
                  <div className="space-y-0.5 text-xs" style={{ color: "var(--text-muted)" }}>
                    <div>{c.weapon}</div>
                    <div>{c.armor}</div>
                  </div>
                </button>
              ))}
            </div>
          </section>

          {/* ATTRIBUTES */}
          <section {...cyAttrs({ cy: "attributes-section" })}>
            <div className="mb-3 flex items-baseline justify-between">
              <h2 className="text-lg tracking-wide" style={sectionHeadingStyle}>Attributes</h2>
              <span
                className="text-sm tabular-nums"
                style={{ color: remaining > 0 ? "var(--gold-light)" : remaining === 0 ? "var(--green)" : "var(--red)" }}
                {...cyAttrs({ cy: "points-remaining", cyValue: remaining })}
              >
                {remaining} points remaining
              </span>
            </div>

            <div className="space-y-3">
              {ATTRS.map((a) => {
                const bonus = raceDef.bonuses[a.key] || 0;
                const final = attrs[a.key] + bonus;
                return (
                  <div
                    key={a.key}
                    className="flex items-center gap-4 rounded border px-4 py-3"
                    style={{ background: "var(--bg-surface)", borderColor: "rgba(255,255,255,0.06)" }}
                    {...cyAttrs({ cy: "attribute-row", cyId: a.key })}
                  >
                    <div className="w-10 text-center text-xs font-bold" style={{ color: "var(--gold)", fontFamily: "var(--font-heading)" }}>
                      {a.abbr}
                    </div>
                    <div className="flex-1">
                      <div className="text-sm" style={{ color: "var(--text-primary)" }}>{a.label}</div>
                      <div className="text-xs" style={{ color: "var(--text-muted)" }}>{a.description}</div>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => adjustAttr(a.key, -1)}
                        disabled={attrs[a.key] <= MIN_ATTR}
                        className="flex h-7 w-7 items-center justify-center rounded border text-sm transition-colors disabled:opacity-30"
                        style={{ borderColor: "var(--metal-mid)", color: "var(--text-primary)", background: "var(--bg-elevated)" }}
                        aria-label={`Decrease ${a.label}`}
                        {...cyAttrs({ cy: "attr-decrease", cyFor: a.key })}
                      >
                        -
                      </button>
                      <div className="w-12 text-center">
                        <span className="text-sm tabular-nums font-bold" style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "attr-base", cyFor: a.key, cyValue: attrs[a.key] })}>{attrs[a.key]}</span>
                        {bonus > 0 && (
                          <span className="ml-1 text-xs" style={{ color: "var(--gold-light)" }} {...cyAttrs({ cy: "attr-bonus", cyFor: a.key, cyValue: bonus })}>+{bonus}</span>
                        )}
                      </div>
                      <button
                        type="button"
                        onClick={() => adjustAttr(a.key, 1)}
                        disabled={attrs[a.key] >= MAX_ATTR || remaining <= 0}
                        className="flex h-7 w-7 items-center justify-center rounded border text-sm transition-colors disabled:opacity-30"
                        style={{ borderColor: "var(--metal-mid)", color: "var(--text-primary)", background: "var(--bg-elevated)" }}
                        aria-label={`Increase ${a.label}`}
                        {...cyAttrs({ cy: "attr-increase", cyFor: a.key })}
                      >
                        +
                      </button>
                      <div className="w-8 text-right text-sm font-bold tabular-nums" style={{ color: "var(--gold)" }} {...cyAttrs({ cy: "attr-final", cyFor: a.key, cyValue: final })}>
                        {final}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </section>

          {/* PREVIEW */}
          <section
            className="rounded-lg border p-6"
            style={{ background: "var(--bg-surface)", borderColor: "rgba(255,255,255,0.1)" }}
            {...cyAttrs({ cy: "preview-section", cyScope: "preview" })}
          >
            <h2 className={sectionHeading} style={sectionHeadingStyle}>Preview</h2>
            <div className="grid grid-cols-2 gap-x-8 gap-y-2 text-sm sm:grid-cols-3">
              <div>
                <span style={{ color: "var(--text-muted)" }}>Name: </span>
                <span style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "preview-name" })}>{name || "—"}</span>
              </div>
              <div>
                <span style={{ color: "var(--text-muted)" }}>Race: </span>
                <span style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "preview-race" })}>{raceDef.name}</span>
              </div>
              <div>
                <span style={{ color: "var(--text-muted)" }}>Class: </span>
                <span style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "preview-class" })}>{classDef.name}</span>
              </div>
              <div>
                <span style={{ color: "var(--text-muted)" }}>HP: </span>
                <span style={{ color: "var(--green)" }} {...cyAttrs({ cy: "preview-hp", cyValue: derivedHp })}>{derivedHp}</span>
              </div>
              <div>
                <span style={{ color: "var(--text-muted)" }}>Energy: </span>
                <span style={{ color: "var(--blue)" }} {...cyAttrs({ cy: "preview-energy", cyValue: derivedEnergy })}>{derivedEnergy}</span>
              </div>
              <div>
                <span style={{ color: "var(--text-muted)" }}>Gold: </span>
                <span style={{ color: "var(--gold-light)" }} {...cyAttrs({ cy: "preview-gold", cyValue: 50 })}>50</span>
              </div>
              <div className="col-span-2 sm:col-span-3">
                <span style={{ color: "var(--text-muted)" }}>Weapon: </span>
                <span style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "preview-weapon" })}>{classDef.weapon}</span>
              </div>
              <div className="col-span-2 sm:col-span-3">
                <span style={{ color: "var(--text-muted)" }}>Armor: </span>
                <span style={{ color: "var(--text-primary)" }} {...cyAttrs({ cy: "preview-armor" })}>{classDef.armor}</span>
              </div>
            </div>
          </section>

          {/* SUBMIT */}
          <button
            type="submit"
            disabled={submitting || remaining !== 0}
            className="w-full rounded py-3 text-sm font-semibold tracking-wide transition-colors disabled:opacity-50"
            style={{
              fontFamily: "var(--font-heading)",
              background: "var(--gold)",
              color: "#070707",
            }}
            {...cyAttrs({ cy: "submit-button", cyId: "create-character" })}
          >
            {submitting ? "Forging..." : "Enter the World"}
          </button>
        </form>
      </div>
    </div>
  );
}
