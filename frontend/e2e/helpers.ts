import { expect, type Page } from "@playwright/test";

/**
 * Shared selectors + navigation for the chat-rooms E2E specs.
 * All selectors are CONFIRMED against src/app/app/[orgId]/chat/[roomId]/page.tsx.
 */
export const ORG = process.env.E2E_ORG ?? "TODO-org-slug"; // lock on first run
export const ROOM = process.env.E2E_ROOM ?? "TODO-room-uuid"; // seed/lookup a room

/** /app/:orgSlug/chat/:roomUuid — orgId is the slug, room is UUID (dmitri R3). */
export function roomUrl(org = ORG, room = ROOM): string {
  return `/app/${org}/chat/${room}`;
}

export const sel = {
  thread: "ul.chat-thread",
  message: ".chat-message__body",
  composer: "form.chat-composer",
  composerInput: "#chat-composer-input",
  composerSubmit: 'form.chat-composer button[type="submit"]',
  slugChip: ".chat-room-header__slug",
  // reaction picker — the ＋ toggle + the role=menu popover
  reactionToggle: '[aria-haspopup="true"]',
  reactionMenu: '[role="menu"]',
  reactionOption: '[role="menuitemcheckbox"]',
} as const;

/** Open a room and wait for the thread to be present. */
export async function gotoRoom(page: Page, url = roomUrl()) {
  await page.goto(url);
  await expect(page.locator(sel.thread)).toBeVisible();
}
