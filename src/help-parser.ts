import type { MallmConfig } from "./schema.js";

export function parseHelp(app: string, helpText: string): MallmConfig {
  const lines = helpText.split("\n");
  const summary = extractSummary(lines);
  const args = extractArguments(lines);
  const subcommands = extractSubcommands(lines);

  return {
    mallm: "1.0",
    name: app,
    summary: summary || `${app} command (auto-generated from --help)`,
    description: helpText,
    arguments: args.length > 0 ? args : undefined,
    subcommands: subcommands.length > 0 ? subcommands : undefined,
    context: {
      gotchas: [
        "This documentation was auto-generated from --help output and may be incomplete.",
        "Create a mallm.yaml for richer LLM-friendly documentation.",
      ],
    },
  };
}

function extractSummary(lines: string[]): string | null {
  for (const line of lines.slice(0, 5)) {
    const trimmed = line.trim();
    if (
      trimmed &&
      !trimmed.startsWith("Usage:") &&
      !trimmed.startsWith("usage:") &&
      !trimmed.startsWith("-")
    ) {
      return trimmed;
    }
  }
  return null;
}

function extractArguments(
  lines: string[]
): NonNullable<MallmConfig["arguments"]> {
  const args: NonNullable<MallmConfig["arguments"]> = [];
  let inOptions = false;

  for (const line of lines) {
    if (/^(options|flags|arguments):/i.test(line.trim())) {
      inOptions = true;
      continue;
    }
    if (inOptions && /^\S/.test(line) && line.trim() !== "") {
      inOptions = false;
    }

    if (!inOptions) continue;

    const match = line.match(
      /^\s+(--?\S+)(?:\s+<(\S+)>)?(?:,\s*(--?\S+)(?:\s+<(\S+)>)?)?\s{2,}(.+)/
    );
    if (match) {
      const name = match[3] || match[1];
      const valueName = match[4] || match[2];
      args.push({
        name: name!,
        type: valueName ? "option" : "flag",
        value: valueName || undefined,
        description: match[5]!.trim(),
      });
    }
  }
  return args;
}

function extractSubcommands(
  lines: string[]
): NonNullable<MallmConfig["subcommands"]> {
  const subs: NonNullable<MallmConfig["subcommands"]> = [];
  let inCommands = false;

  for (const line of lines) {
    if (/^(commands|subcommands):/i.test(line.trim())) {
      inCommands = true;
      continue;
    }
    if (inCommands && /^\S/.test(line) && line.trim() !== "") {
      inCommands = false;
    }

    if (!inCommands) continue;

    const match = line.match(/^\s+(\S+)\s{2,}(.+)/);
    if (match) {
      subs.push({
        name: match[1]!,
        summary: match[2]!.trim(),
      });
    }
  }
  return subs;
}
