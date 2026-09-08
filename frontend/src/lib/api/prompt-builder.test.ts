import assert from 'node:assert/strict';
import test from 'node:test';
import { PromptBuilderError } from './prompt-builder';

// Browser-only module — only the error contract is testable under node.
test('PromptBuilderError carries status + retry-after', () => {
  const e = new PromptBuilderError(429, 'Rate limit reached — try again in 60 seconds.', 60);
  assert.equal(e.status, 429);
  assert.equal(e.retryAfter, 60);
  assert.match(e.message, /Rate limit/);

  const plain = new PromptBuilderError(422, 'This tool only builds NPL prompts.');
  assert.equal(plain.retryAfter, null);
  assert.equal(plain.status, 422);
});
