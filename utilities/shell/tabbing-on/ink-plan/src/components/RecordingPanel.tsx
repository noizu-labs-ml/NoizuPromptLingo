import { Box, Text } from 'ink';

const BARS = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'];

function formatDuration(seconds: number): string {
  const m = Math.floor(seconds / 60).toString().padStart(2, '0');
  const s = (seconds % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
}

function amplitudeToBar(amp: number): string {
  const idx = Math.min(BARS.length - 1, Math.floor(amp * BARS.length));
  return BARS[idx];
}

interface RecordingPanelProps {
  duration: number;
  amplitude: number;
  amplitudeHistory: number[];
}

export function RecordingPanel({ duration, amplitudeHistory }: RecordingPanelProps) {
  const waveform = amplitudeHistory.slice(-40).map(amplitudeToBar).join('');

  return (
    <Box flexDirection="column" paddingX={1} paddingY={1}>
      <Box gap={2}>
        <Text color="red" bold>●</Text>
        <Text bold>Recording</Text>
        <Text color="white">{formatDuration(duration)}</Text>
      </Box>
      <Box marginTop={1}>
        <Text color="green">{waveform || '▁'.repeat(40)}</Text>
      </Box>
    </Box>
  );
}
