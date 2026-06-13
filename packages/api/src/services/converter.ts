import type { ArtifactType, ConversionCandidate, Artifact } from "@claude-assist/shared";

interface SourceMessage {
  role: string;
  content: string;
}

export function identifyCandidates(messages: SourceMessage[]): ConversionCandidate[] {
  const candidates: ConversionCandidate[] = [];

  // Look for sequences with repeated tool use patterns (suggests a skill/agent)
  const toolPatterns = findToolPatterns(messages);
  if (toolPatterns.length > 0) {
    for (const pattern of toolPatterns) {
      candidates.push({
        type: "skill",
        startIndex: pattern.start,
        endIndex: pattern.end,
        confidence: 0.7,
        description: `Repeated pattern: ${pattern.description}`,
      });
    }
  }

  // Q&A sequences suggest runbooks
  if (messages.length >= 4) {
    candidates.push({
      type: "runbook",
      startIndex: 0,
      endIndex: messages.length - 1,
      confidence: 0.5,
      description: "Full conversation as step-by-step guide",
    });
  }

  // First user message + assistant response often works as a command
  if (messages.length >= 2) {
    candidates.push({
      type: "command",
      startIndex: 0,
      endIndex: 1,
      confidence: 0.4,
      description: "Initial prompt/response pair",
    });
  }

  return candidates.sort((a, b) => b.confidence - a.confidence);
}

export function convertToArtifact(
  type: ArtifactType,
  messages: SourceMessage[],
  range: [number, number],
  config: { name: string; description: string; conversationId: string },
): Artifact {
  const selected = messages.slice(range[0], range[1] + 1);
  let content: string;

  switch (type) {
    case "agent":
      content = generateAgentDef(config.name, config.description, selected);
      break;
    case "skill":
      content = generateSkillDef(config.name, config.description, selected);
      break;
    case "command":
      content = generateCommandDef(config.name, config.description, selected);
      break;
    case "runbook":
      content = generateRunbook(config.name, config.description, selected);
      break;
    case "snippet":
      content = generateSnippet(config.name, config.description, selected);
      break;
    default:
      content = selected.map((m) => `**${m.role}:** ${m.content}`).join("\n\n");
  }

  return {
    type,
    name: config.name,
    description: config.description,
    content,
    sourceConversationId: config.conversationId,
    sourceMessageRange: range,
  };
}

function generateAgentDef(name: string, description: string, messages: SourceMessage[]): string {
  const systemPrompt = messages
    .filter((m) => m.role === "assistant")
    .map((m) => m.content)
    .join("\n")
    .slice(0, 2000);

  return `# ${name}

${description}

## System Prompt

${systemPrompt}

## Behavior

Extracted from conversation with ${messages.length} messages.
`;
}

function generateSkillDef(name: string, description: string, messages: SourceMessage[]): string {
  const steps = messages
    .filter((m) => m.role === "assistant")
    .map((m, i) => `${i + 1}. ${m.content.split("\n")[0]}`)
    .join("\n");

  return `# ${name}

${description}

## Steps

${steps}
`;
}

function generateCommandDef(name: string, description: string, messages: SourceMessage[]): string {
  const userPrompt = messages.find((m) => m.role === "user")?.content ?? "";
  return `# /${name}

${description}

## Prompt Template

${userPrompt}
`;
}

function generateRunbook(name: string, description: string, messages: SourceMessage[]): string {
  const sections = messages.map((m, i) => {
    const header = m.role === "user" ? `## Step ${Math.floor(i / 2) + 1}: Task` : `### Response`;
    return `${header}\n\n${m.content}`;
  });

  return `# ${name}\n\n${description}\n\n${sections.join("\n\n---\n\n")}`;
}

function generateSnippet(name: string, description: string, messages: SourceMessage[]): string {
  const codeBlocks = messages
    .flatMap((m) => {
      const matches = m.content.match(/```[\s\S]*?```/g);
      return matches ?? [];
    });

  return `# ${name}\n\n${description}\n\n${codeBlocks.join("\n\n") || messages.map((m) => m.content).join("\n")}`;
}

function findToolPatterns(messages: SourceMessage[]): Array<{ start: number; end: number; description: string }> {
  const patterns: Array<{ start: number; end: number; description: string }> = [];
  for (let i = 0; i < messages.length - 3; i++) {
    if (
      messages[i].role === "user" &&
      messages[i + 1].role === "assistant" &&
      messages[i + 2].role === "user" &&
      messages[i + 3].role === "assistant"
    ) {
      patterns.push({
        start: i,
        end: i + 3,
        description: `${messages[i].content.slice(0, 50)}...`,
      });
      break;
    }
  }
  return patterns;
}
