#!/usr/bin/env tsx
import { render } from 'ink';
import { createElement } from 'react';
import { program } from 'commander';
import { checkSoxInstalled } from './src/services/audio.js';
import { resolveConfig } from './src/hooks/useConfig.js';
import { App } from './src/app.js';

program
  .name('tabbing-plan')
  .description('Voice memo to structured project ticket (tabbing-on)')
  .version('0.1.0')
  .option('-p, --project <name>', 'Target project (e.g., codefre.sh)')
  .option('-t, --type <type>', 'Pre-set ticket type (story|bug|task)')
  .option('--api-url <url>', 'LiteLLM endpoint (env: LITELLM_API_URL)')
  .option('--api-key <key>', 'API key (env: LITELLM_API_KEY)')
  .option('--model <model>', 'Chat model (env: M2T_MODEL)')
  .option('--whisper-model <model>', 'STT model (default: whisper-1)')
  .option('--output-dir <dir>', 'Override output directory')
  .option('--no-tabbing', 'Skip tabbing-on integration')
  .action((opts) => {
    if (!checkSoxInstalled()) {
      console.error(
        'Error: SoX is required for audio recording.\n' +
        'Install with:\n' +
        '  macOS:  brew install sox\n' +
        '  Ubuntu: sudo apt install sox\n' +
        '  Fedora: sudo dnf install sox'
      );
      process.exit(1);
    }

    const config = resolveConfig(opts);

    if (!config.apiKey) {
      console.error(
        'Warning: No API key set. Set LITELLM_API_KEY or use --api-key.\n' +
        'Transcription and ticket generation will fail without it.'
      );
    }

    render(createElement(App, { config }));
  });

program.parse();
