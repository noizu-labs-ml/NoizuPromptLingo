import { useState, useCallback } from 'react';
import type OpenAI from 'openai';
import { File } from 'node:buffer';

interface TranscriptionState {
  transcript: string;
  isTranscribing: boolean;
  error: string | null;
}

export function useTranscription(client: OpenAI, whisperModel: string) {
  const [state, setState] = useState<TranscriptionState>({
    transcript: '',
    isTranscribing: false,
    error: null,
  });

  const transcribe = useCallback(async (audioBuffer: Buffer) => {
    setState({ transcript: '', isTranscribing: true, error: null });

    let lastError: Error | null = null;
    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        const file = new File([audioBuffer], 'recording.wav', { type: 'audio/wav' });
        const response = await client.audio.transcriptions.create({
          model: whisperModel,
          file,
        });

        setState({ transcript: response.text, isTranscribing: false, error: null });
        return response.text;
      } catch (err) {
        lastError = err instanceof Error ? err : new Error(String(err));
        if (attempt < 2) {
          await new Promise(r => setTimeout(r, 1000 * Math.pow(2, attempt)));
        }
      }
    }

    const msg = lastError?.message || 'Transcription failed';
    setState({ transcript: '', isTranscribing: false, error: msg });
    return null;
  }, [client, whisperModel]);

  const setTranscript = useCallback((text: string) => {
    setState(prev => ({ ...prev, transcript: text }));
  }, []);

  return { ...state, transcribe, setTranscript };
}
