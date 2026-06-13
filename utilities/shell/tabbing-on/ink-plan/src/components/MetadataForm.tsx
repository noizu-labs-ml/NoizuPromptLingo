import { useState } from 'react';
import { Box, Text, useInput } from 'ink';
import type { TicketType, Priority, TicketMetadata } from '../types.js';

const TICKET_TYPES: TicketType[] = ['user-story', 'bug', 'task'];
const PRIORITIES: Priority[] = ['P0', 'P1', 'P2', 'P3'];

interface MetadataFormProps {
  metadata: TicketMetadata;
  isActive: boolean;
  onUpdate: (updates: Partial<TicketMetadata>) => void;
}

export function MetadataForm({ metadata, isActive, onUpdate }: MetadataFormProps) {
  const [focusedField, setFocusedField] = useState(0);
  const fields = ['type', 'priority'] as const;

  useInput((input, key) => {
    if (!isActive) return;

    if (key.tab) {
      setFocusedField(prev => (prev + 1) % fields.length);
      return;
    }

    const field = fields[focusedField];

    if (key.leftArrow || key.rightArrow) {
      const direction = key.rightArrow ? 1 : -1;

      if (field === 'type') {
        const currentIdx = TICKET_TYPES.indexOf(metadata.issue_type);
        const nextIdx = (currentIdx + direction + TICKET_TYPES.length) % TICKET_TYPES.length;
        onUpdate({ issue_type: TICKET_TYPES[nextIdx] });
      } else if (field === 'priority') {
        const currentIdx = PRIORITIES.indexOf(metadata.priority);
        const nextIdx = (currentIdx + direction + PRIORITIES.length) % PRIORITIES.length;
        onUpdate({ priority: PRIORITIES[nextIdx] });
      }
    }
  }, { isActive });

  return (
    <Box paddingX={1} gap={4}>
      <Box gap={1}>
        <Text bold={focusedField === 0} color={focusedField === 0 ? 'cyan' : undefined}>
          Type:
        </Text>
        <Text bold={focusedField === 0} color={focusedField === 0 ? 'white' : 'gray'}>
          {'◂ '}{metadata.issue_type}{' ▸'}
        </Text>
      </Box>

      <Box gap={1}>
        <Text bold={focusedField === 1} color={focusedField === 1 ? 'cyan' : undefined}>
          Priority:
        </Text>
        <Text bold={focusedField === 1} color={focusedField === 1 ? 'white' : 'gray'}>
          {'◂ '}{metadata.priority}{' ▸'}
        </Text>
      </Box>
    </Box>
  );
}
