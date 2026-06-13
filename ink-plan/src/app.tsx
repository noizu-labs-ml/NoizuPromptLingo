import { useReducer, useMemo, useEffect, useCallback } from 'react';
import { Box, Text, useInput, useApp } from 'ink';
import { Spinner } from '@inkjs/ui';
import { Header } from './components/Header.js';
import { RecordingPanel } from './components/RecordingPanel.js';
import { TranscriptPanel } from './components/TranscriptPanel.js';
import { TicketPreview } from './components/TicketPreview.js';
import { MetadataForm } from './components/MetadataForm.js';
import { ActionBar } from './components/ActionBar.js';
import { StatusLine } from './components/StatusLine.js';
import { useRecorder } from './hooks/useRecorder.js';
import { useTranscription } from './hooks/useTranscription.js';
import { useTicketGenerator } from './hooks/useTicketGenerator.js';
import { createClient } from './services/llm.js';
import { saveTicket, resolveOutputDir, getNextId } from './services/filesystem.js';
import type { AppState, AppAction, AppConfig, TicketMetadata } from './types.js';
import { execSync } from 'node:child_process';
import { writeFileSync, readFileSync, unlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const initialState: AppState = {
  phase: 'idle',
  audioBuffer: null,
  transcript: '',
  ticket: null,
  savedPath: null,
  error: null,
};

function reducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'START_RECORDING':
      return { ...state, phase: 'recording', error: null };
    case 'STOP_RECORDING':
      return { ...state, phase: 'transcribing', audioBuffer: action.audioBuffer };
    case 'TRANSCRIPTION_COMPLETE':
      return { ...state, phase: 'reviewing_transcript', transcript: action.transcript };
    case 'TRANSCRIPT_EDITED':
      return { ...state, transcript: action.transcript };
    case 'GENERATION_COMPLETE':
      return { ...state, phase: 'previewing_ticket', ticket: action.ticket };
    case 'METADATA_UPDATED':
      if (!state.ticket) return state;
      return {
        ...state,
        ticket: {
          ...state.ticket,
          metadata: { ...state.ticket.metadata, ...action.metadata },
        },
      };
    case 'SAVE_COMPLETE':
      return { ...state, phase: 'done', savedPath: action.path };
    case 'ERROR':
      return { ...state, phase: 'error', error: action.error };
    case 'RE_RECORD':
      return { ...initialState };
    case 'NEW_TICKET':
      return { ...initialState };
    case 'CANCEL':
      return { ...initialState };
    default:
      return state;
  }
}

interface AppProps {
  config: AppConfig;
}

export function App({ config }: AppProps) {
  const [state, dispatch] = useReducer(reducer, initialState);
  const { exit } = useApp();

  const client = useMemo(() => createClient(config), [config]);
  const recorder = useRecorder();
  const transcription = useTranscription(client, config.whisperModel);
  const generator = useTicketGenerator(client, config.model);

  const handleTranscribe = useCallback(async (buffer: Buffer) => {
    const text = await transcription.transcribe(buffer);
    if (text) {
      dispatch({ type: 'TRANSCRIPTION_COMPLETE', transcript: text });
    } else {
      dispatch({ type: 'ERROR', error: transcription.error || 'Transcription returned empty' });
    }
  }, [transcription]);

  const handleGenerate = useCallback(async (transcript: string) => {
    dispatch({ type: 'GENERATION_COMPLETE', ticket: null as any });
    const ticket = await generator.generate(transcript, config.ticketType);
    if (ticket) {
      const outputDir = resolveOutputDir(config);
      const id = await getNextId(ticket.metadata.issue_type, outputDir);
      ticket.metadata.id = id;
      dispatch({ type: 'GENERATION_COMPLETE', ticket });
    } else {
      dispatch({ type: 'ERROR', error: generator.error || 'Generation failed' });
    }
  }, [generator, config]);

  const handleSave = useCallback(async () => {
    if (!state.ticket) return;
    try {
      const outputDir = resolveOutputDir(config);
      const path = await saveTicket(state.ticket, outputDir);

      if (!config.noTabbing) {
        try {
          const title = `${state.ticket.metadata.id}: ${state.ticket.metadata.title}`;
          execSync(`tabbing-todo add "${title}"`, { stdio: 'ignore' });
        } catch {
          // tabbing-on not installed — non-fatal
        }
      }

      dispatch({ type: 'SAVE_COMPLETE', path });
    } catch (err) {
      dispatch({ type: 'ERROR', error: err instanceof Error ? err.message : 'Save failed' });
    }
  }, [state.ticket, config]);

  const handleEditInEditor = useCallback(() => {
    const editor = process.env['EDITOR'] || process.env['VISUAL'] || 'vi';
    const tmpFile = join(tmpdir(), `m2t-transcript-${Date.now()}.txt`);
    writeFileSync(tmpFile, state.transcript, 'utf-8');

    try {
      process.stdin.setRawMode(false);
      execSync(`${editor} "${tmpFile}"`, { stdio: 'inherit' });
      process.stdin.setRawMode(true);
      const edited = readFileSync(tmpFile, 'utf-8');
      dispatch({ type: 'TRANSCRIPT_EDITED', transcript: edited.trim() });
    } catch {
      // Editor closed without saving or errored
    } finally {
      try { unlinkSync(tmpFile); } catch { /* ignore */ }
    }
  }, [state.transcript]);

  useInput((input, key) => {
    if (input === 'q' && !['recording', 'transcribing', 'generating_ticket', 'saving'].includes(state.phase)) {
      exit();
      return;
    }

    switch (state.phase) {
      case 'idle':
        if (input === 'r' || input === 'R') {
          dispatch({ type: 'START_RECORDING' });
          recorder.start();
        }
        break;

      case 'recording':
        if (input === ' ' || key.return) {
          const buffer = recorder.stop();
          if (buffer) {
            dispatch({ type: 'STOP_RECORDING', audioBuffer: buffer });
            handleTranscribe(buffer);
          }
        }
        if (key.escape) {
          recorder.stop();
          dispatch({ type: 'CANCEL' });
        }
        break;

      case 'reviewing_transcript':
        if (key.return) {
          dispatch({ type: 'GENERATION_COMPLETE', ticket: null as any });
          handleGenerate(state.transcript);
        }
        if (input === 'e') {
          handleEditInEditor();
        }
        if (input === 'r') {
          dispatch({ type: 'RE_RECORD' });
        }
        break;

      case 'previewing_ticket':
        if (key.return) {
          handleSave();
        }
        if (input === 'r') {
          dispatch({ type: 'RE_RECORD' });
        }
        break;

      case 'done':
        if (input === 'n') {
          dispatch({ type: 'NEW_TICKET' });
        }
        break;

      case 'error':
        if (input === 'r') {
          dispatch({ type: 'RE_RECORD' });
        }
        break;
    }
  });

  // Derive display phase (override during async operations)
  const displayPhase = (() => {
    if (transcription.isTranscribing) return 'transcribing' as const;
    if (generator.isGenerating) return 'generating_ticket' as const;
    return state.phase;
  })();

  return (
    <Box flexDirection="column" minHeight={15}>
      <Header phase={displayPhase} project={config.project} />

      <Box flexDirection="column" flexGrow={1} paddingX={1}>
        {state.phase === 'idle' && (
          <Box paddingY={2} justifyContent="center">
            <Text>Press <Text bold color="cyan">r</Text> to start recording your memo</Text>
          </Box>
        )}

        {(state.phase === 'recording' || recorder.isRecording) && (
          <RecordingPanel
            duration={recorder.duration}
            amplitude={recorder.amplitude}
            amplitudeHistory={recorder.amplitudeHistory}
          />
        )}

        {transcription.isTranscribing && (
          <Box paddingY={2} gap={2}>
            <Spinner label="Transcribing audio..." />
          </Box>
        )}

        {state.phase === 'reviewing_transcript' && (
          <TranscriptPanel transcript={state.transcript} />
        )}

        {generator.isGenerating && (
          <Box paddingY={2} gap={2}>
            <Spinner label="Generating ticket..." />
          </Box>
        )}

        {state.phase === 'previewing_ticket' && state.ticket && (
          <>
            <TicketPreview ticket={state.ticket} />
            <MetadataForm
              metadata={state.ticket.metadata}
              isActive={state.phase === 'previewing_ticket'}
              onUpdate={(updates) => dispatch({ type: 'METADATA_UPDATED', metadata: updates })}
            />
          </>
        )}

        {state.phase === 'done' && state.savedPath && (
          <Box flexDirection="column" paddingY={2}>
            <Text color="green" bold>Ticket saved!</Text>
            <Text dimColor>{state.savedPath}</Text>
          </Box>
        )}
      </Box>

      <ActionBar phase={displayPhase} />
      <StatusLine error={state.error || recorder.error || undefined} />
    </Box>
  );
}
