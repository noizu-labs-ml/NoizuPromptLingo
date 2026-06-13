"use client";

import React, { useState, useRef } from "react";

/**
 * VoiceCaptureButton — Microphone button triggering speech-to-text with recording indicator.
 *
 * @example
 * ```tsx
 * <VoiceCaptureButton onTranscript={(text) => setNote(text)} />
 * ```
 */

interface VoiceCaptureButtonProps {
  onTranscript: (text: string) => void;
  language?: string;
  maxDuration?: number;
  disabled?: boolean;
}

export function VoiceCaptureButton({ onTranscript, language = "en-US", maxDuration = 30, disabled = false }: VoiceCaptureButtonProps) {
  const [recording, setRecording] = useState(false);
  const [seconds, setSeconds] = useState(0);
  const timerRef = useRef<ReturnType<typeof setInterval>>();
  const recognitionRef = useRef<any>(null);

  const start = () => {
    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (!SpeechRecognition) { onTranscript("[Speech recognition not supported in this browser]"); return; }

    const recognition = new SpeechRecognition();
    recognition.lang = language;
    recognition.continuous = true;
    recognition.interimResults = false;

    let transcript = "";
    recognition.onresult = (e: any) => { for (let i = e.resultIndex; i < e.results.length; i++) { if (e.results[i].isFinal) transcript += e.results[i][0].transcript + " "; } };
    recognition.onend = () => { setRecording(false); clearInterval(timerRef.current); setSeconds(0); if (transcript.trim()) onTranscript(transcript.trim()); };
    recognition.onerror = () => { setRecording(false); clearInterval(timerRef.current); setSeconds(0); };

    recognitionRef.current = recognition;
    recognition.start();
    setRecording(true);
    setSeconds(0);

    let s = 0;
    timerRef.current = setInterval(() => {
      s++;
      setSeconds(s);
      if (s >= maxDuration) { recognition.stop(); }
    }, 1000);
  };

  const stop = () => { recognitionRef.current?.stop(); };

  return (
    <button
      type="button"
      onClick={recording ? stop : start}
      disabled={disabled}
      aria-label={recording ? `Recording... ${seconds}s — click to stop` : "Start voice recording"}
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: "6px",
        padding: "6px 12px",
        borderRadius: "999px",
        border: recording ? "2px solid var(--error)" : "1px solid var(--border)",
        background: recording ? "color-mix(in srgb, var(--error) 10%, transparent)" : "var(--surface)",
        color: recording ? "var(--error)" : "var(--text-secondary)",
        fontFamily: "var(--font-body)",
        fontSize: "var(--font-size-xs)",
        fontWeight: recording ? 600 : 400,
        cursor: disabled ? "not-allowed" : "pointer",
        opacity: disabled ? 0.5 : 1,
        transition: "all 0.15s",
      }}
    >
      <span style={{ fontSize: "var(--font-size-sm)", ...(recording ? { animation: "mic-pulse 1s ease-in-out infinite" } : {}) }}>🎙</span>
      {recording ? `${seconds}s` : "Voice"}
      {recording && <style>{`@keyframes mic-pulse { 0%,100% { opacity:1; } 50% { opacity:0.4; } }`}</style>}
    </button>
  );
}

export default VoiceCaptureButton;
