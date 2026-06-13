import { Box, Text } from 'ink';
import { stringify } from 'yaml';
import type { Ticket } from '../types.js';

interface TicketPreviewProps {
  ticket: Ticket;
}

export function TicketPreview({ ticket }: TicketPreviewProps) {
  const yamlStr = stringify(ticket.metadata, { lineWidth: 0 });

  return (
    <Box flexDirection="column" paddingX={1} borderStyle="round">
      <Text bold color="cyan">Ticket Preview</Text>

      <Box marginTop={1} flexDirection="column">
        <Text dimColor>---</Text>
        {yamlStr.trim().split('\n').map((line, i) => {
          const colonIdx = line.indexOf(':');
          if (colonIdx === -1) return <Text key={i}>{line}</Text>;
          return (
            <Text key={i}>
              <Text color="cyan">{line.slice(0, colonIdx)}</Text>
              <Text>{line.slice(colonIdx)}</Text>
            </Text>
          );
        })}
        <Text dimColor>---</Text>
      </Box>

      <Box marginTop={1} flexDirection="column">
        {ticket.body.split('\n').map((line, i) => {
          if (line.startsWith('# ')) return <Text key={i} bold>{line}</Text>;
          if (line.startsWith('## ')) return <Text key={i} bold color="yellow">{line}</Text>;
          if (line.startsWith('- [ ]')) return <Text key={i} color="white">{line}</Text>;
          return <Text key={i} dimColor={line.trim() === ''}>{line || ' '}</Text>;
        })}
      </Box>
    </Box>
  );
}
