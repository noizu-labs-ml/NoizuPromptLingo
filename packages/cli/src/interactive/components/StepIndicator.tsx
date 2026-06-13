import React from "react";
import { Box, Text } from "ink";

interface StepIndicatorProps {
  steps: string[];
  currentStep: number;
}

export function StepIndicator({ steps, currentStep }: StepIndicatorProps) {
  return (
    <Box gap={1}>
      {steps.map((label, i) => (
        <Text key={i}>
          <Text
            color={i === currentStep ? "cyan" : i < currentStep ? "green" : undefined}
            bold={i === currentStep}
            dimColor={i > currentStep}
          >
            {i < currentStep ? "✓" : i + 1}
          </Text>
          <Text
            color={i === currentStep ? "cyan" : undefined}
            dimColor={i > currentStep}
          >
            {" "}{label}
          </Text>
          {i < steps.length - 1 && <Text dimColor> → </Text>}
        </Text>
      ))}
    </Box>
  );
}
