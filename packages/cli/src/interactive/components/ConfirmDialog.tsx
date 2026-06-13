import React from "react";
import { Box, Text, useInput } from "ink";

interface ConfirmDialogProps {
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
  isActive?: boolean;
}

export function ConfirmDialog({ message, onConfirm, onCancel, isActive = true }: ConfirmDialogProps) {
  useInput((input, key) => {
    if (input === "y" || input === "Y") onConfirm();
    else if (input === "n" || input === "N" || key.escape) onCancel();
  }, { isActive });

  return (
    <Box borderStyle="round" borderColor="yellow" paddingX={2} paddingY={1} flexDirection="column">
      <Text bold color="yellow">{message}</Text>
      <Text dimColor>Press y to confirm, n to cancel</Text>
    </Box>
  );
}
