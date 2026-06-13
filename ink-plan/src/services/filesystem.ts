import { readdir, writeFile, mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import { existsSync } from 'node:fs';
import { stringify } from 'yaml';
import type { Ticket, TicketType, AppConfig } from '../types.js';

const TYPE_DIR_MAP: Record<TicketType, string> = {
  'user-story': 'user-stories',
  'bug': 'bugs',
  'task': 'tasks',
};

const ID_PREFIX_MAP: Record<TicketType, string> = {
  'user-story': 'US',
  'bug': 'BUG',
  'task': 'TASK',
};

export async function getNextId(type: TicketType, dir: string): Promise<string> {
  const prefix = ID_PREFIX_MAP[type];
  const pattern = new RegExp(`^${prefix}-(\\d+)`);
  let maxNum = 0;

  try {
    const files = await readdir(dir);
    for (const file of files) {
      const match = file.match(pattern);
      if (match) {
        const num = parseInt(match[1], 10);
        if (num > maxNum) maxNum = num;
      }
    }
  } catch {
    // Directory doesn't exist yet
  }

  const next = String(maxNum + 1).padStart(3, '0');
  return `${prefix}-${next}`;
}

export async function saveTicket(ticket: Ticket, outputDir: string): Promise<string> {
  const typeDir = TYPE_DIR_MAP[ticket.metadata.issue_type];
  const targetDir = join(outputDir, typeDir);

  if (!existsSync(targetDir)) {
    await mkdir(targetDir, { recursive: true });
  }

  const id = ticket.metadata.id || await getNextId(ticket.metadata.issue_type, targetDir);
  const filename = `${id}-${ticket.metadata.slug}.md`;
  const filepath = join(targetDir, filename);

  const frontmatter = stringify(ticket.metadata, { lineWidth: 0 });
  const content = `---\n${frontmatter}---\n\n${ticket.body}`;

  await writeFile(filepath, content, 'utf-8');
  return filepath;
}

export function resolveOutputDir(config: AppConfig): string {
  if (config.outputDir) return config.outputDir;

  const cwd = process.cwd();

  // If we're inside a projects/<name>/ tree, use its project-management/
  const sep = '/';
  const parts = cwd.split(sep);
  for (let i = parts.length - 1; i >= 1; i--) {
    if (parts[i - 1] === 'projects') {
      const projectRoot = parts.slice(0, i + 1).join(sep);
      const pmDir = join(projectRoot, 'project-management');
      if (existsSync(pmDir)) return pmDir;
      return pmDir; // will be created on save
    }
  }

  // Explicit --project flag: look for projects/<name>/ relative to cwd
  if (config.project) {
    const projectDir = join(cwd, 'projects', config.project, 'project-management');
    if (existsSync(join(cwd, 'projects', config.project))) return projectDir;
  }

  // Fallback: project-management/ in cwd
  return join(cwd, 'project-management');
}
