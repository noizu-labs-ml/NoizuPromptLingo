import { Box, Text } from 'ink';
import type { AppPhase } from '../types.js';

const PHASE_ACTIONS: Record<AppPhase, string[]> = {
  idle: ['[r] Record', '[q] Quit'],
  recording: ['[space] Stop', '[esc] Cancel'],
  transcribing: [],
  reviewing_transcript: ['[enter] Generate', '[e] Edit', '[r] Re-record', '[q] Quit'],
  generating_ticket: [],
  previewing_ticket: ['[enter] Save', '[tab] Fields', '[r] Re-record', '[q] Quit'],
  saving: [],
  done: ['[n] New', '[q] Quit'],
  error: ['[r] Retry', '[q] Quit'],
};

interface ActionBarProps {
  phase: AppPhase;
}

export function ActionBar({ phase }: ActionBarProps) {
  const actions = PHASE_ACTIONS[phase];

  return (
    <Box paddingX={1} borderStyle="single" borderTop borderBottom={false} borderLeft={false} borderRight={false}>
      {actions.map((action, i) => (
        <Box key={i} marginRight={2}>
          <Text dimColor>{action}</Text>
        </Box>
      ))}
      {actions.length === 0 && <Text dimColor>Working...</Text>}
    </Box>
  );
}
