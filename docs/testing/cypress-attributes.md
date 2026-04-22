# Cypress Test Attribute Conventions

## Attribute Reference

| Attribute | Purpose | Example |
|---|---|---|
| `data-cy` | Primary selector — identifies the element's role | `data-cy="room-card"` |
| `data-cy-id` | Instance identifier — distinguishes repeated elements | `data-cy-id="42"` |
| `data-cy-for` | Association — links a label/action to its target | `data-cy-for="room-name"` |
| `data-cy-value` | Exposed state — surfaces a value for assertion | `data-cy-value="3"` |
| `data-cy-scope` | Scoping — namespaces a subtree for nested queries | `data-cy-scope="chat"` |

## Usage Rules

1. **Every interactive element** (buttons, inputs, links, forms) MUST have `data-cy`.
2. **Repeated items** (list rows, cards, table rows) MUST have `data-cy-id`.
3. **Page-level containers** SHOULD have `data-cy-scope` for test isolation.
4. **Never use class names or tag names** as Cypress selectors — only `data-cy*` attributes.
5. **Values are kebab-case**: `data-cy="new-room-btn"`, not `data-cy="newRoomBtn"`.

## Naming Conventions

```
{scope}-{element}[-{qualifier}]
```

Examples:
- `chat-page` — page container
- `room-card` — a room card in the list
- `room-name-input` — the room name field
- `create-room-btn` — the create button
- `message-input` — the message textarea
- `send-btn` — the send button
- `message-item` — a single message in the feed
- `message-feed` — the scrollable message container

## Utility Function

All components use the `cyAttrs` helper from `@/lib/utils/cyAttrs`:

```tsx
import { cyAttrs } from "@/lib/utils/cyAttrs";

<div {...cyAttrs({ cy: "room-card", cyId: room.id })} />
```

The helper strips `undefined` values so no empty attributes render in production.

## Querying in Tests

```ts
// By role
cy.get('[data-cy="room-card"]')

// By role + instance
cy.get('[data-cy="room-card"][data-cy-id="42"]')

// Scoped
cy.get('[data-cy-scope="chat"]').find('[data-cy="room-card"]')

// By value
cy.get('[data-cy="message-count"][data-cy-value="5"]')
```
