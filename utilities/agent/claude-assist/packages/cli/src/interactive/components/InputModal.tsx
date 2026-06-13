import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { TextInput } from "@inkjs/ui";

interface InputModalProps {
  label: string;
  placeholder?: string;
  defaultValue?: string;
  onSubmit: (value: string) => void;
  onCancel: () => void;
  isActive?: boolean;
}

export function InputModal({ label, placeholder, defaultValue, onSubmit, onCancel, isActive = true }: InputModalProps) {
  useInput((_input, key) => {
    if (key.escape) onCancel();
  }, { isActive });

  return (
    <Box borderStyle="round" borderColor="cyan" paddingX={2} paddingY={1} flexDirection="column">
      <Text bold color="cyan">{label}</Text>
      <Box marginTop={1}>
        <TextInput
          placeholder={placeholder ?? ""}
          defaultValue={defaultValue ?? ""}
          onSubmit={onSubmit}
        />
      </Box>
      <Text dimColor>Enter to submit, Esc to cancel</Text>
    </Box>
  );
}
