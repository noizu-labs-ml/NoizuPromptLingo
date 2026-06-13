"use client";
import { useEffect, useRef } from "react";

/**
 * Keyboard shortcut hook — supports chords and multi-key sequences.
 *
 * Binding syntax:
 *   "cmd+k"    → Meta/Ctrl + k
 *   "ctrl+k"   → Ctrl + k (explicit)
 *   "g p"      → space-separated sequence; 1s timeout between keys
 *   "?"        → single key
 *   "Escape"   → named special key
 *
 * Bindings match case-insensitively on printable keys.
 * Inputs/textareas/contentEditables are ignored unless the binding
 * requires a modifier (cmd/ctrl/alt).
 *
 * @example
 * useKeyboardShortcuts({
 *   "cmd+k": () => openPalette(),
 *   "g p": () => router.push("/prompts"),
 *   "?": () => setHelpOpen(true),
 * });
 */
export type ShortcutHandler = (e: KeyboardEvent) => void;
export type ShortcutBindings = Record<string, ShortcutHandler>;

const SEQUENCE_TIMEOUT_MS = 1000;

interface ChordSpec {
  cmd: boolean;
  ctrl: boolean;
  shift: boolean;
  alt: boolean;
  key: string;
}

interface ParsedBinding {
  handler: ShortcutHandler;
  chord?: ChordSpec;
  sequence?: string[];
}

function parseBinding(raw: string, handler: ShortcutHandler): ParsedBinding {
  const trimmed = raw.trim();
  // Sequence: space-separated and not a chord string
  if (/\s/.test(trimmed) && !trimmed.includes("+")) {
    const sequence = trimmed.split(/\s+/).map((s) => s.toLowerCase());
    return { handler, sequence };
  }
  const parts = trimmed.split("+").map((p) => p.toLowerCase());
  const chord: ChordSpec = {
    cmd: false,
    ctrl: false,
    shift: false,
    alt: false,
    key: "",
  };
  for (const p of parts) {
    if (p === "cmd" || p === "meta") chord.cmd = true;
    else if (p === "ctrl") chord.ctrl = true;
    else if (p === "shift") chord.shift = true;
    else if (p === "alt" || p === "option") chord.alt = true;
    else chord.key = p;
  }
  // Single printable key with no modifier → treat as 1-step sequence
  // so input-editable rules and sequence buffer both apply.
  if (!chord.cmd && !chord.ctrl && !chord.alt && !chord.shift) {
    return { handler, sequence: [chord.key] };
  }
  return { handler, chord };
}

function isEditable(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false;
  const tag = target.tagName;
  if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return true;
  if (target.isContentEditable) return true;
  return false;
}

function eventKey(e: KeyboardEvent): string {
  if (e.key === "?") return "?";
  return e.key.length === 1 ? e.key.toLowerCase() : e.key.toLowerCase();
}

export function useKeyboardShortcuts(bindings: ShortcutBindings): void {
  const bindingsRef = useRef<ShortcutBindings>(bindings);
  bindingsRef.current = bindings;

  useEffect(() => {
    let buffer: string[] = [];
    let timer: number | null = null;

    const resetBuffer = () => {
      buffer = [];
      if (timer !== null) {
        window.clearTimeout(timer);
        timer = null;
      }
    };

    const armTimer = () => {
      if (timer !== null) window.clearTimeout(timer);
      timer = window.setTimeout(() => {
        buffer = [];
        timer = null;
      }, SEQUENCE_TIMEOUT_MS);
    };

    const handler = (e: KeyboardEvent) => {
      const parsedList: ParsedBinding[] = Object.entries(bindingsRef.current).map(
        ([raw, h]) => parseBinding(raw, h),
      );
      const hasModifier = e.metaKey || e.ctrlKey || e.altKey;
      const editable = isEditable(e.target);
      const k = eventKey(e);

      // Chord bindings first
      for (const b of parsedList) {
        if (!b.chord) continue;
        const c = b.chord;
        if (editable && !(c.cmd || c.ctrl || c.alt)) continue;
        // cmd → accept either metaKey (mac) or ctrlKey (win/linux)
        const cmdOk = c.cmd
          ? e.metaKey || e.ctrlKey
          : !e.metaKey && (c.ctrl ? true : !e.ctrlKey);
        const ctrlOk = c.ctrl ? e.ctrlKey : true;
        const shiftOk = c.shift ? e.shiftKey : true;
        const altOk = c.alt ? e.altKey : !e.altKey;
        if (cmdOk && ctrlOk && shiftOk && altOk && k === c.key) {
          e.preventDefault();
          b.handler(e);
          resetBuffer();
          return;
        }
      }

      // Sequence bindings: no modifier, not in editable
      if (hasModifier) {
        resetBuffer();
        return;
      }
      if (editable) return;
      if (
        k === "shift" ||
        k === "meta" ||
        k === "control" ||
        k === "alt" ||
        k === "capslock"
      ) {
        return;
      }

      buffer.push(k);
      armTimer();

      for (const b of parsedList) {
        if (!b.sequence) continue;
        if (buffer.length < b.sequence.length) continue;
        const tail = buffer.slice(-b.sequence.length);
        if (tail.every((step, i) => step === b.sequence![i])) {
          e.preventDefault();
          b.handler(e);
          resetBuffer();
          return;
        }
      }
    };

    window.addEventListener("keydown", handler);
    return () => {
      window.removeEventListener("keydown", handler);
      if (timer !== null) window.clearTimeout(timer);
    };
  }, []);
}
