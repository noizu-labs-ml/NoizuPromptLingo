import * as assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const clipboard = readFileSync(resolve(here, 'clipboard.tsx'), 'utf8');
const dialog = readFileSync(resolve(here, 'confirm-dialog.tsx'), 'utf8');
const lib = readFileSync(resolve(here, '../../lib/clipboard.ts'), 'utf8');

function contract(source: string, pattern: RegExp, message: string) {
  assert.ok(pattern.test(source), message);
}

void test('CopyField renders a labeled reveal row with an accessible copy button', () => {
  contract(clipboard, /export function CopyField/, 'CopyField is exported');
  contract(clipboard, /export function ClipboardButton/, 'ClipboardButton is exported');
  contract(clipboard, /export function useCopied/, 'useCopied is exported');
  contract(clipboard, /authz-reveal__label/, 'CopyField renders the reveal label row');
  contract(clipboard, /authz-reveal__row/, 'CopyField renders the value + button row');
  // Accessible name: explicit copyLabel, else "Copy <label>".
  contract(clipboard, /aria-label=\{copyLabel \?\? `Copy \$\{name\}`\}/, 'copy button has an accessible name');
  contract(clipboard, /from '@\/lib\/clipboard'/, 'kit copies via the shared lib helper');
});

void test('clipboard helper falls back on non-secure contexts', () => {
  contract(lib, /navigator\.clipboard\?\.writeText/, 'uses the async clipboard API when present');
  contract(lib, /execCommand\('copy'\)/, 'falls back to execCommand copy');
  contract(lib, /Promise<boolean>/, 'reports success instead of throwing');
});

void test('ConfirmDialog supports a destructive variant and dismiss paths', () => {
  contract(dialog, /destructive\?: boolean/, 'destructive variant exists');
  contract(dialog, /destructive \? 'sg-btn--danger' : 'sg-btn--black'/, 'destructive uses the danger button style');
  contract(dialog, /<Dialog onClose=\{onClose\}/, 'Headless Dialog handles ESC + backdrop close');
  contract(dialog, /<DialogTitle/, 'dialog exposes an accessible title');
  contract(dialog, /onConfirm\??: \(\) => void \| Promise<void>/, 'confirm accepts sync or async actions');
});
