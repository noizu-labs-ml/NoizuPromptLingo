import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { TextInput } from "@inkjs/ui";

interface InlineEditProps {
  value: string;
  placeholder?: string;
  isEditing: boolean;
  onStartEdit: () => void;
  onSave: (value: string) => void;
  onCancel: () => void;
  color?: string;
  bold?: boolean;
  dimColor?: boolean;
}

export function InlineEdit({
  value,
  placeholder,
  isEditing,
  onStartEdit,
  onSave,
  onCancel,
  color,
  bold,
  dimColor,
}: InlineEditProps) {
  if (isEditing) {
    return (
      <Box>
        <TextInput
          defaultValue={value}
          placeholder={placeholder}
          onSubmit={onSave}
        />
        <Text dimColor> (Enter:save Esc:cancel)</Text>
      </Box>
    );
  }

  return (
    <Text color={color as any} bold={bold} dimColor={dimColor}>
      {value || (placeholder ? <Text italic dimColor>{placeholder}</Text> : "")}
    </Text>
  );
}
