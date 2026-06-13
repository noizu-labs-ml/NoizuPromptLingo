import { Box, Text } from 'ink';

interface TranscriptPanelProps {
  transcript: string;
}

export function TranscriptPanel({ transcript }: TranscriptPanelProps) {
  return (
    <Box flexDirection="column" paddingX={1} paddingY={1} borderStyle="round">
      <Text bold color="cyan">Transcript</Text>
      <Box marginTop={1}>
        <Text wrap="wrap">
          {transcript || '(empty — no speech detected)'}
        </Text>
      </Box>
    </Box>
  );
}
