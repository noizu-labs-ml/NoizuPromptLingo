import { useMemo } from 'react';
import { basename, resolve, sep } from 'node:path';
import type { AppConfig, TicketType } from '../types.js';

interface CliOptions {
  project?: string;
  type?: string;
  apiUrl?: string;
  apiKey?: string;
  model?: string;
  whisperModel?: string;
  outputDir?: string;
  noTabbing?: boolean;
}

function inferProject(): string | undefined {
  const cwd = resolve(process.cwd());
  const parts = cwd.split(sep);

  // Walk up looking for a "projects" segment — the next segment is the project name
  for (let i = parts.length - 1; i >= 1; i--) {
    if (parts[i - 1] === 'projects') {
      return parts[i];
    }
  }

  return undefined;
}

export function resolveConfig(opts: CliOptions): AppConfig {
  const apiUrl = opts.apiUrl
    || process.env['LITELLM_API_URL']
    || 'http://inference.noizu.com/v1';

  const apiKey = opts.apiKey
    || process.env['LITELLM_API_KEY']
    || '';

  const model = opts.model
    || process.env['M2T_MODEL']
    || 'gpt-4';

  const whisperModel = opts.whisperModel
    || process.env['M2T_WHISPER_MODEL']
    || 'whisper-1';

  const ticketType = opts.type as TicketType | undefined;
  const project = opts.project || inferProject();

  return {
    project,
    ticketType,
    apiUrl,
    apiKey,
    model,
    whisperModel,
    outputDir: opts.outputDir,
    noTabbing: opts.noTabbing ?? false,
  };
}

export function useConfig(opts: CliOptions): AppConfig {
  return useMemo(() => resolveConfig(opts), [
    opts.project, opts.type, opts.apiUrl, opts.apiKey,
    opts.model, opts.whisperModel, opts.outputDir, opts.noTabbing,
  ]);
}
