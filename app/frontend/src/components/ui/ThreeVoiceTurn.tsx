"use client";
import * as React from "react";
import { cyAttrs } from "@/utils/cypress";

export type Voice = "author" | "agent" | "evaluator";

export interface ThreeVoiceTurnProps {
  voice: Voice;
  content: React.ReactNode;
  turnNumber?: number;
  timestamp?: string;
  glyphBefore?: React.ReactNode;
  className?: string;
  cy?: string;
  cyId?: string | number;
}

const voiceClass: Record<Voice, string> = {
  author: "sg-voice-author",
  agent: "sg-voice-agent",
  evaluator: "sg-voice-evaluator",
};

const voiceLabel: Record<Voice, string> = {
  author: "author",
  agent: "agent",
  evaluator: "evaluator",
};

const voiceGlyph: Record<Voice, React.ReactElement> = {
  author: (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d="M3 4.5l3.5 3.5L3 11.5" />
      <line x1="9" y1="11.5" x2="13" y2="11.5" />
    </svg>
  ),
  agent: (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" aria-hidden="true">
      <circle cx="8" cy="8" r="5.5" />
      <circle cx="8" cy="8" r="2" fill="currentColor" stroke="none" />
    </svg>
  ),
  evaluator: (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d="M3 11a5.5 5.5 0 0110 0" />
      <line x1="8" y1="11" x2="10.5" y2="6.5" />
      <circle cx="8" cy="11" r="1" fill="currentColor" stroke="none" />
    </svg>
  ),
};

/**
 * Three-voice transcript turn — author (mono), agent (sans/readable), evaluator (copper annotation).
 *
 * @example
 * <ThreeVoiceTurn voice="agent" content="Sure, I can help with that." turnNumber={3} />
 */
export function ThreeVoiceTurn({
  voice,
  content,
  turnNumber,
  timestamp,
  glyphBefore,
  className,
  cy = "voice-turn",
  cyId,
}: ThreeVoiceTurnProps) {
  return (
    <div
      className={["sg-turn", className || ""].filter(Boolean).join(" ")}
      {...cyAttrs({ cy, cyId, cyValue: voice })}
    >
      <div className="sg-turn__marker">
        <span aria-hidden="true">{glyphBefore ?? voiceGlyph[voice]}</span>
        <span>{voiceLabel[voice]}</span>
        {turnNumber !== undefined ? (
          <span style={{ color: "var(--text-ghost)" }}>· turn {turnNumber}</span>
        ) : null}
        {timestamp ? (
          <span style={{ color: "var(--text-ghost)" }}>· {timestamp}</span>
        ) : null}
      </div>
      <div className={voiceClass[voice]}>{content}</div>
    </div>
  );
}
