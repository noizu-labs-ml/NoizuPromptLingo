import { Box, Text, Spacer } from 'ink';
import type { AppPhase } from '../types.js';

const PHASE_LABELS: Record<AppPhase, string> = {
  idle: 'Ready',
  recording: 'Recording',
  transcribing: 'Transcribing...',
  reviewing_transcript: 'Review Transcript',
  generating_ticket: 'Generating...',
  previewing_ticket: 'Preview Ticket',
  saving: 'Saving...',
  done: 'Saved',
  error: 'Error',
};

interface HeaderProps {
  phase: AppPhase;
  project?: string;
}

export function Header({ phase, project }: HeaderProps) {
  return (
    <Box paddingX={1} borderStyle="single" borderBottom borderLeft={false} borderRight={false} borderTop={false}>
      <Text bold color="cyan">tabbing-plan</Text>
      {project && (
        <>
          <Text dimColor> / </Text>
          <Text color="yellow">{project}</Text>
        </>
      )}
      <Spacer />
      <Text dimColor>{PHASE_LABELS[phase]}</Text>
    </Box>
  );
}
