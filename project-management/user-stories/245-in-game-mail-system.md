# US-245: In-Game Mail System

**Persona:** Lena — Tabletop RPG player with short sessions who needs efficient async communication
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Lena, I want to send and receive mail with items and currency attached so that I can conduct trades, send messages, and stay connected with other players between short play sessions without needing to be online at the same time.

## Acceptance Criteria
- [ ] Mail is composed via `/mail compose [recipient]` opening a sequential form: To (auto-filled), Subject (optional, 60 char max), Message body (500 char max), Attach Items (interactive item picker), Attach Currency (amount field); all fields navigable by screen reader in order
- [ ] Mailboxes are accessible at Inn locations and player-owned homes; `/mail check` works from anywhere for notification of new mail count; reading and item retrieval requires physical mailbox access
- [ ] Inbox displays as a numbered list: message number, sender name, subject or preview (first 40 chars of body if no subject), timestamp, attachment indicator (ITEMS or GOLD badge if applicable)
- [ ] Individual mail is read via `/mail read [number]`; full body narrated, then attachment summary: "Attached: 3 Health Potions, 50 gold. Type `/mail claim [number]` to retrieve."
- [ ] Item claiming is atomic: all attachments claimed together or none; if inventory is full, system warns and does not partially claim; claimed items go to inventory, claimed gold goes to purse
- [ ] Mail retention: unread mail kept for 30 days; read mail kept for 7 days; items on unclaimed mail held in escrow, returned to sender after retention period with notification to both parties
- [ ] Sent mail viewable via `/mail sent`; shows delivery confirmation (mailbox accessed by recipient) or pending status; sender can recall unsent mail (not yet accessed) via `/mail recall [number]`
- [ ] Bulk actions available: `/mail delete all read`, `/mail claim all` (claims all attachments if inventory permits); confirmations required before bulk operations; SR reads confirmation text including item count before proceeding

## Notes
Lena's short session constraint makes async communication essential. She might log on for 20 minutes, need to send payment to a crafting NPC player for a commission, and log off before that player is online. The mail system is her bridge. The design must make this feel fluid rather than bureaucratic.

The physical mailbox requirement (at Inn or home) is a deliberate world-building choice — it creates a reason to visit inns and home bases. However, the `/mail check` anywhere command means Lena isn't blind to incoming mail; she just needs to physically visit a mailbox to interact with it. This is a good tension to maintain.

Screen reader ergonomics for the item attachment flow are the hardest part. The item picker for attachments should present inventory as a flat list with item name, quantity, and a checkbox-style selection mechanic: "Healing Potion x3 — press Space to attach one, A to attach all." Selected attachments should be confirmed in a summary before sending: "You are sending: 1 Healing Potion, 50 gold to Lena the Tailor. Confirm? [Yes] [Edit] [Cancel]."

Gold attachment edge cases: sender's gold is held in escrow immediately on send, not on claim. This prevents the "sell the item twice" scam. If sender's gold balance is insufficient at send time, mail is rejected with a clear error: "Insufficient funds. You attempted to attach 100 gold but have 47."

Anti-spam: players with conduct violations may have mail privileges temporarily restricted. Rate limiting: maximum 20 mails sent per hour. Unsolicited mail from non-friends/non-guildmates can be filtered via `/mail settings filter [all|friends|everyone]`.

Consider allowing mail to NPC merchants as a "commission order" mechanic — sending a mail with materials attached to a crafting NPC triggers a crafting job, completed items mailed back. This deepens the economy without requiring simultaneous presence.
