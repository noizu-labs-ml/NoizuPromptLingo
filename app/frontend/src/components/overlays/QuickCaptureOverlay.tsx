"use client";

import React, { useState, useCallback, useEffect, useRef } from "react";

/**
 * QuickCaptureOverlay — Global keyboard-triggered overlay for rapid input capture,
 * accessible from any screen. Parses inline metadata (#project, @priority, !date).
 *
 * Composes: InlineMetadataInput (T2), VoiceCaptureButton (T2).
 * Used in: Quick Capture Modal screen.
 *
 * The parent is responsible for registering the global shortcut and toggling `open`.
 * This component manages its own internal input state and emits structured data on submit.
 *
 * @example
 * ```tsx
 * <QuickCaptureOverlay
 *   open={captureOpen}
 *   onSubmit={(data) => createItem(data)}
 *   onCancel={() => setCaptureOpen(false)}
 * />
 * <QuickCaptureOverlay
 *   open={captureOpen}
 *   onSubmit={handleCapture}
 *   onCancel={close}
 *   showVoice
 *   placeholder="Quick capture: #project @p1 !tomorrow Fix the login bug"
 * />
 * ```
 */

// ── Types ───────────────────────────────────────────────────────

interface ParsedMeta {
  type: "project" | "priority" | "date" | "tag";
  value: string;
  raw: string;
}

interface CaptureData {
  /** Raw text input */
  text: string;
  /** Parsed metadata tokens */
  metadata: ParsedMeta[];
  /** Text with metadata tokens stripped */
  cleanText: string;
}

interface QuickCaptureOverlayProps {
  /** Whether the overlay is visible */
  open: boolean;
  /** Fires with structured capture data on submit */
  onSubmit: (data: CaptureData) => void;
  /** Fires on dismiss */
  onCancel: () => void;
  /** Show voice capture button */
  showVoice?: boolean;
  /** Input placeholder */
  placeholder?: string;
  /** Keyboard shortcut hint displayed in footer */
  shortcutHint?: string;
}

// ── Metadata parser (mirrors InlineMetadataInput logic) ──

function parseMeta(text: string): ParsedMeta[] {
  const meta: ParsedMeta[] = [];
  const patterns: [RegExp, ParsedMeta["type"]][] = [
    [/#(\S+)/g, "project"],
    [/@(p[0-3])\b/g, "priority"],
    [/!(tomorrow|today|next\s+week|next\s+month|\d{4}-\d{2}-\d{2})/gi, "date"],
    [/\+(\S+)/g, "tag"],
  ];
  for (const [re, type] of patterns) {
    let m;
    while ((m = re.exec(text)) !== null) {
      meta.push({ type, value: m[1], raw: m[0] });
    }
  }
  return meta;
}

function stripMeta(text: string, meta: ParsedMeta[]): string {
  let cleaned = text;
  for (const m of meta) {
    cleaned = cleaned.replace(m.raw, "");
  }
  return cleaned.replace(/\s{2,}/g, " ").trim();
}

const metaColors: Record<string, string> = {
  project: "var(--info, var(--blue))",
  priority: "var(--warning)",
  date: "var(--success)",
  tag: "var(--violet, #7C3AED)",
};

// ── Component ───────────────────────────────────────────────────

export function QuickCaptureOverlay({
  open,
  onSubmit,
  onCancel,
  showVoice = false,
  placeholder = "Capture an idea... #project @p1 !tomorrow",
  shortcutHint = "Cmd+K",
}: QuickCaptureOverlayProps) {
  const [text, setText] = useState("");
  const inputRef = useRef<HTMLTextAreaElement>(null);

  const meta = parseMeta(text);

  // Focus and reset on open
  useEffect(() => {
    if (open) {
      setText("");
      requestAnimationFrame(() => inputRef.current?.focus());
    }
  }, [open]);

  const handleSubmit = useCallback(() => {
    const trimmed = text.trim();
    if (!trimmed) return;
    onSubmit({
      text: trimmed,
      metadata: meta,
      cleanText: stripMeta(trimmed, meta),
    });
    setText("");
  }, [text, meta, onSubmit]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === "Escape") {
        e.stopPropagation();
        onCancel();
      }
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        handleSubmit();
      }
    },
    [onCancel, handleSubmit],
  );

  const handleVoiceTranscript = useCallback(
    (transcript: string) => {
      setText((prev) => (prev ? prev + " " + transcript : transcript));
    },
    [],
  );

  // ── Voice capture button (inline render, no import to avoid circular) ──
  const [recording, setRecording] = useState(false);
  const [recSeconds, setRecSeconds] = useState(0);
  const timerRef = useRef<ReturnType<typeof setInterval>>();
  const recognitionRef = useRef<any>(null);

  const startVoice = () => {
    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (!SpeechRecognition) {
      handleVoiceTranscript("[Speech recognition not supported]");
      return;
    }
    const recognition = new SpeechRecognition();
    recognition.lang = "en-US";
    recognition.continuous = true;
    recognition.interimResults = false;
    let transcript = "";
    recognition.onresult = (e: any) => {
      for (let i = e.resultIndex; i < e.results.length; i++) {
        if (e.results[i].isFinal) transcript += e.results[i][0].transcript + " ";
      }
    };
    recognition.onend = () => {
      setRecording(false);
      clearInterval(timerRef.current);
      setRecSeconds(0);
      if (transcript.trim()) handleVoiceTranscript(transcript.trim());
    };
    recognition.onerror = () => {
      setRecording(false);
      clearInterval(timerRef.current);
      setRecSeconds(0);
    };
    recognitionRef.current = recognition;
    recognition.start();
    setRecording(true);
    setRecSeconds(0);
    let s = 0;
    timerRef.current = setInterval(() => {
      s++;
      setRecSeconds(s);
      if (s >= 30) recognition.stop();
    }, 1000);
  };

  const stopVoice = () => {
    recognitionRef.current?.stop();
  };

  if (!open) return null;

  return (
    /* Backdrop */
    <div
      role="presentation"
      onClick={onCancel}
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 9999,
        display: "flex",
        alignItems: "flex-start",
        justifyContent: "center",
        paddingTop: "15vh",
        background: "rgba(0, 0, 0, 0.5)",
      }}
    >
      {/* Overlay panel */}
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Quick capture"
        onClick={(e) => e.stopPropagation()}
        onKeyDown={handleKeyDown}
        tabIndex={-1}
        style={{
          width: "100%",
          maxWidth: 560,
          borderRadius: "var(--radius, 6px)",
          border: "1px solid var(--border)",
          background: "var(--surface)",
          boxShadow: "0 12px 40px rgba(0,0,0,0.25)",
          overflow: "hidden",
        }}
      >
        {/* Input area */}
        <div style={{ display: "flex", alignItems: "flex-start", gap: "8px", padding: "var(--space-3) var(--space-4, 16px)" }}>
          <textarea
            ref={inputRef}
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={placeholder}
            rows={3}
            aria-label="Quick capture input"
            style={{
              flex: 1,
              padding: 0,
              border: "none",
              background: "transparent",
              color: "var(--text)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-base)",
              resize: "none",
              outline: "none",
              lineHeight: 1.5,
            }}
          />

          {showVoice && (
            <button
              type="button"
              onClick={recording ? stopVoice : startVoice}
              aria-label={recording ? `Recording ${recSeconds}s — click to stop` : "Start voice capture"}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "4px",
                padding: "6px 10px",
                borderRadius: "999px",
                border: recording ? "2px solid var(--error)" : "1px solid var(--border)",
                background: recording ? "color-mix(in srgb, var(--error) 10%, transparent)" : "none",
                color: recording ? "var(--error)" : "var(--text-muted)",
                fontFamily: "var(--font-body)",
                fontSize: "var(--font-size-xs)",
                cursor: "pointer",
                flexShrink: 0,
              }}
            >
              <span style={recording ? { animation: "qc-pulse 1s ease-in-out infinite" } : {}}>
                🎙
              </span>
              {recording && `${recSeconds}s`}
              {recording && (
                <style>{`@keyframes qc-pulse { 0%,100% { opacity:1; } 50% { opacity:0.4; } }`}</style>
              )}
            </button>
          )}
        </div>

        {/* Parsed metadata chips */}
        {meta.length > 0 && (
          <div
            style={{
              display: "flex",
              flexWrap: "wrap",
              gap: "4px",
              padding: "0 var(--space-4, 16px) var(--space-2)",
            }}
          >
            {meta.map((m, i) => (
              <span
                key={i}
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  padding: "1px 8px",
                  borderRadius: "999px",
                  background: `color-mix(in srgb, ${metaColors[m.type]} 12%, transparent)`,
                  color: metaColors[m.type],
                  fontFamily: "var(--font-mono)",
                  fontSize: "var(--font-size-2xs, 10px)",
                  fontWeight: 500,
                }}
              >
                {m.type === "project" ? "#" : m.type === "priority" ? "@" : m.type === "date" ? "!" : "+"}
                {m.value}
              </span>
            ))}
          </div>
        )}

        {/* Footer */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "6px var(--space-4, 16px)",
            borderTop: "1px solid var(--border)",
            background: "color-mix(in srgb, var(--text-muted) 4%, transparent)",
          }}
        >
          <span
            style={{
              fontFamily: "var(--font-mono)",
              fontSize: "var(--font-size-2xs, 10px)",
              color: "var(--text-muted)",
            }}
          >
            Enter=submit · Esc=dismiss · {shortcutHint}=toggle
          </span>

          <button
            type="button"
            onClick={handleSubmit}
            disabled={!text.trim()}
            style={{
              padding: "4px 14px",
              borderRadius: "var(--radius, 6px)",
              border: "none",
              background: text.trim() ? "var(--info, var(--blue))" : "color-mix(in srgb, var(--text-muted) 20%, transparent)",
              color: text.trim() ? "#fff" : "var(--text-muted)",
              fontFamily: "var(--font-body)",
              fontSize: "var(--font-size-xs)",
              fontWeight: 600,
              cursor: text.trim() ? "pointer" : "not-allowed",
            }}
          >
            Capture
          </button>
        </div>
      </div>
    </div>
  );
}

export default QuickCaptureOverlay;
