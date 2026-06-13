import type { MallmConfig, ResolvedMallm } from "./schema.js";

export function formatMarkdown(resolved: ResolvedMallm): string {
  const { config: c, source } = resolved;
  const lines: string[] = [];

  lines.push(`# ${c.name}${c.version ? ` (v${c.version})` : ""}`);
  lines.push("");
  lines.push(c.summary);
  lines.push("");

  if (c.description) {
    lines.push(c.description.trim());
    lines.push("");
  }

  if (c.usage) {
    lines.push("## Usage");
    lines.push("");
    lines.push("```");
    lines.push(c.usage.synopsis);
    lines.push("```");
    lines.push("");

    if (c.usage.examples?.length) {
      lines.push("### Examples");
      lines.push("");
      for (const ex of c.usage.examples) {
        lines.push(`**${ex.description}**`);
        lines.push("```sh");
        lines.push(ex.command);
        lines.push("```");
        if (ex.output) {
          lines.push("Output:");
          lines.push("```");
          lines.push(ex.output);
          lines.push("```");
        }
        lines.push("");
      }
    }
  }

  if (c.arguments?.length) {
    lines.push("## Arguments");
    lines.push("");
    lines.push("| Name | Type | Required | Default | Description |");
    lines.push("|------|------|----------|---------|-------------|");
    for (const arg of c.arguments) {
      const req = arg.required ? "yes" : "no";
      const def = arg.default ?? "-";
      const name =
        arg.type === "option" && arg.value
          ? `\`${arg.name} <${arg.value}>\``
          : `\`${arg.name}\``;
      lines.push(`| ${name} | ${arg.type} | ${req} | ${def} | ${arg.description} |`);
    }
    lines.push("");
  }

  if (c.subcommands?.length) {
    lines.push("## Subcommands");
    lines.push("");
    for (const sub of c.subcommands) {
      lines.push(`### \`${sub.name}\``);
      lines.push("");
      lines.push(sub.summary);
      if (sub.description) {
        lines.push("");
        lines.push(sub.description);
      }
      if (sub.arguments?.length) {
        lines.push("");
        lines.push("| Name | Type | Description |");
        lines.push("|------|------|-------------|");
        for (const arg of sub.arguments) {
          lines.push(`| \`${arg.name}\` | ${arg.type} | ${arg.description} |`);
        }
      }
      if (sub.examples?.length) {
        lines.push("");
        for (const ex of sub.examples) {
          lines.push(`\`\`\`sh\n${ex.command}\n\`\`\``);
          lines.push(`_${ex.description}_`);
          lines.push("");
        }
      }
      lines.push("");
    }
  }

  if (c.environment?.length) {
    lines.push("## Environment Variables");
    lines.push("");
    lines.push("| Variable | Required | Default | Description |");
    lines.push("|----------|----------|---------|-------------|");
    for (const env of c.environment) {
      const req = env.required ? "yes" : "no";
      const def = env.default ?? "-";
      lines.push(`| \`${env.name}\` | ${req} | ${def} | ${env.description} |`);
    }
    lines.push("");
  }

  if (c.files?.length) {
    lines.push("## Files");
    lines.push("");
    for (const f of c.files) {
      lines.push(`- \`${f.path}\` — ${f.description}`);
    }
    lines.push("");
  }

  if (c.context) {
    lines.push("## Context for LLM Agents");
    lines.push("");
    if (c.context.when_to_use) {
      lines.push("### When to use");
      lines.push("");
      lines.push(c.context.when_to_use.trim());
      lines.push("");
    }
    if (c.context.when_not_to_use) {
      lines.push("### When NOT to use");
      lines.push("");
      lines.push(c.context.when_not_to_use.trim());
      lines.push("");
    }
    if (c.context.common_patterns?.length) {
      lines.push("### Common Patterns");
      lines.push("");
      for (const pattern of c.context.common_patterns) {
        lines.push(`**${pattern.name}**`);
        if (pattern.description) lines.push(pattern.description);
        lines.push("");
        for (let i = 0; i < pattern.steps.length; i++) {
          lines.push(`${i + 1}. \`${pattern.steps[i]}\``);
        }
        lines.push("");
      }
    }
    if (c.context.gotchas?.length) {
      lines.push("### Gotchas");
      lines.push("");
      for (const g of c.context.gotchas) {
        lines.push(`- ${g}`);
      }
      lines.push("");
    }
  }

  if (c.output) {
    lines.push("## Output");
    lines.push("");
    if (c.output.stdout) lines.push(`- **stdout**: ${c.output.stdout}`);
    if (c.output.stderr) lines.push(`- **stderr**: ${c.output.stderr}`);
    if (c.output.formats?.length)
      lines.push(`- **formats**: ${c.output.formats.join(", ")}`);
    if (c.output.exit_codes) {
      lines.push("");
      lines.push("**Exit codes:**");
      for (const [code, desc] of Object.entries(c.output.exit_codes)) {
        lines.push(`- \`${code}\`: ${desc}`);
      }
    }
    lines.push("");
  }

  if (c.skills?.length) {
    lines.push("## Skills / Extended Documentation");
    lines.push("");
    for (const skill of c.skills) {
      const loc = skill.path ?? skill.url ?? "";
      lines.push(`- **${skill.name}** — ${skill.description}${loc ? ` (${loc})` : ""}`);
    }
    lines.push("");
  }

  if (c.related?.length) {
    lines.push("## Related Commands");
    lines.push("");
    for (const rel of c.related) {
      lines.push(`- \`${rel.name}\` — ${rel.description}`);
    }
    lines.push("");
  }

  if (c.install) {
    lines.push("## Installation");
    lines.push("");
    lines.push(`Method: ${c.install.method}`);
    if (c.install.command) {
      lines.push("```sh");
      lines.push(c.install.command);
      lines.push("```");
    }
    lines.push("");
  }

  lines.push("---");
  lines.push(`_Source: ${source}${resolved.path ? ` (${resolved.path})` : ""}_`);

  return lines.join("\n");
}

export function formatJson(resolved: ResolvedMallm): string {
  return JSON.stringify(
    {
      ...resolved.config,
      _meta: {
        source: resolved.source,
        path: resolved.path,
        generated_at: new Date().toISOString(),
      },
    },
    null,
    2
  );
}
