import { Box, Text, Spacer } from 'ink';

interface StatusLineProps {
  info?: string;
  error?: string;
}

export function StatusLine({ info, error }: StatusLineProps) {
  return (
    <Box paddingX={1}>
      {error ? (
        <Text color="red">{error}</Text>
      ) : info ? (
        <Text dimColor>{info}</Text>
      ) : (
        <Text dimColor>tabbing-plan v0.1.0</Text>
      )}
      <Spacer />
    </Box>
  );
}
