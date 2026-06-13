import { useState, useRef, useCallback, useEffect } from 'react';
import { startRecording, computeAmplitude } from '../services/audio.js';
import type { Readable } from 'node:stream';

interface RecorderState {
  isRecording: boolean;
  duration: number;
  amplitude: number;
  amplitudeHistory: number[];
  audioBuffer: Buffer | null;
  error: string | null;
}

export function useRecorder() {
  const [state, setState] = useState<RecorderState>({
    isRecording: false,
    duration: 0,
    amplitude: 0,
    amplitudeHistory: [],
    audioBuffer: null,
    error: null,
  });

  const streamRef = useRef<Readable | null>(null);
  const stopFnRef = useRef<(() => void) | null>(null);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const chunksRef = useRef<Buffer[]>([]);

  const start = useCallback(async () => {
    try {
      chunksRef.current = [];
      const recording = await startRecording();
      streamRef.current = recording.stream;
      stopFnRef.current = recording.stop;

      recording.stream.on('data', (chunk: Buffer) => {
        chunksRef.current.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
        const amp = computeAmplitude(chunk);
        setState(prev => ({
          ...prev,
          amplitude: amp,
          amplitudeHistory: [...prev.amplitudeHistory.slice(-59), amp],
        }));
      });

      recording.stream.on('error', (err: Error) => {
        setState(prev => ({ ...prev, error: err.message, isRecording: false }));
      });

      const startTime = Date.now();
      timerRef.current = setInterval(() => {
        setState(prev => ({
          ...prev,
          duration: Math.floor((Date.now() - startTime) / 1000),
        }));
      }, 100);

      setState(prev => ({
        ...prev,
        isRecording: true,
        duration: 0,
        amplitude: 0,
        amplitudeHistory: [],
        audioBuffer: null,
        error: null,
      }));
    } catch (err) {
      setState(prev => ({
        ...prev,
        error: err instanceof Error ? err.message : 'Recording failed',
      }));
    }
  }, []);

  const stop = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }

    if (stopFnRef.current) {
      stopFnRef.current();
      stopFnRef.current = null;
    }

    const audioBuffer = chunksRef.current.length > 0
      ? Buffer.concat(chunksRef.current)
      : null;

    setState(prev => ({
      ...prev,
      isRecording: false,
      audioBuffer,
    }));

    return audioBuffer;
  }, []);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      if (stopFnRef.current) stopFnRef.current();
    };
  }, []);

  return { ...state, start, stop };
}
