# Waitlist & Email Capture

## Architecture

The waitlist is a client-side form (`waitlist-form.tsx`) that POSTs directly to the Listmonk public subscription API. No server-side proxy or backend is involved.

## Integration Details

| Field | Value |
|-------|-------|
| Endpoint | `https://listmonk.noizu.com/api/public/subscription` |
| Method | POST (JSON) |
| List UUID | `ff9aca9d-3ee5-4d62-9cac-35f3ec598b75` |
| Payload | `{ email, name: "", list_uuids: [LIST_UUID] }` |

## UI States

- **idle** — email input + submit button
- **loading** — button shows "Joining...", input disabled
- **success** — replaced with confirmation message ("You're on the list!")
- **error** — inline error message below input, parsed from Listmonk response or generic network error

## Placement

The form appears twice on the landing page:
1. Hero section (primary CTA: "Get Early Access")
2. Final CTA section (secondary: "Join the Waitlist")

## CORS Consideration

The browser makes a cross-origin request to `listmonk.noizu.com`. Listmonk's public subscription endpoint must have CORS configured to accept requests from `therobotlives.com`.
