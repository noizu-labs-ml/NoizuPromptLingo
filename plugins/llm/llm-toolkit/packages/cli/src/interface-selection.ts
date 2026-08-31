export type InterfaceMode = "web" | "tui";

const DEFAULT_INTERFACE_ENV_KEYS = [
  "LLM_TOOLKIT_DEFAULT_INTERFACE",
  "CODE_ASSIST_DEFAUJLT_INTERFACE",
  "CODE_ASSIST_DEFAULT_INTERFACE",
  "CLAUDE_ASSIST_DEFAULT_INTERFACE",
];

const INTERFACE_FLAGS = new Set(["--interface", "--interace"]);

export interface ParsedInvocation {
  command: string;
  args: string[];
  interfaceMode: InterfaceMode;
  warnings: string[];
}

// ⟦𓐝𓇝𓊚𓃘⟧ parseInvocation :: auto-generated pointer for public function parseInvocation
export function parseInvocation(rawArgs: string[], env: NodeJS.ProcessEnv = process.env): ParsedInvocation {
  const warnings: string[] = [];
  let interfaceMode = interfaceFromEnv(env, warnings);
  const args: string[] = [];

  for (let i = 0; i < rawArgs.length; i++) {
    const arg = rawArgs[i];
    if (INTERFACE_FLAGS.has(arg)) {
      const next = rawArgs[i + 1];
      i++;
      const parsed = normalizeInterfaceMode(next);
      if (parsed) {
        interfaceMode = parsed;
      } else {
        warnings.push(`Ignoring invalid interface value: ${next ?? ""}`);
      }
      continue;
    }

    if (arg.startsWith("--interface=") || arg.startsWith("--interace=")) {
      const [, value = ""] = arg.split("=", 2);
      const parsed = normalizeInterfaceMode(value);
      if (parsed) {
        interfaceMode = parsed;
      } else {
        warnings.push(`Ignoring invalid interface value: ${value}`);
      }
      continue;
    }

    args.push(arg);
  }

  const requestedCommand = args[0];
  const command = normalizeCommand(requestedCommand ?? interfaceMode);
  return {
    command,
    args: requestedCommand ? args.slice(1) : [],
    interfaceMode,
    warnings,
  };
}

// ⟦𓀢𓂾𓁴𓂉⟧ normalizeInterfaceMode :: auto-generated pointer for public function normalizeInterfaceMode
export function normalizeInterfaceMode(value: string | undefined | null): InterfaceMode | null {
  const normalized = value?.trim().toLowerCase();
  if (!normalized) return null;
  if (normalized === "web" || normalized === "browser") return "web";
  if (normalized === "tui" || normalized === "terminal" || normalized === "cli" || normalized === "interactive") return "tui";
  return null;
}

function interfaceFromEnv(env: NodeJS.ProcessEnv, warnings: string[]): InterfaceMode {
  for (const key of DEFAULT_INTERFACE_ENV_KEYS) {
    const parsed = normalizeInterfaceMode(env[key]);
    if (parsed) return parsed;
    if (env[key]) warnings.push(`Ignoring invalid ${key}: ${env[key]}`);
  }
  return "web";
}

function normalizeCommand(command: string): string {
  if (command === "web") return "serve";
  if (command === "tui") return "interactive";
  return command;
}
