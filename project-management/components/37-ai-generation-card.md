# AI Generation Card

| Field | Value |
|-------|-------|
| **ID** | `ai-generation-card` |
| **Category** | AI-Specific |
| **Used In** | 34-creative-assets-pipeline, 40-mock-mcp-builder, 46-campaigns-ad-groups |

## Description

The prompt-in/candidate-out generation loop repeated across the product's AI-authoring surfaces: submit a prompt or description, review the generated candidate, then accept/reject, regenerate, or publish it as the active output. Covers creative assets, ad copy/landing-page variants, and mock-server tool generation alike. Bundles the accept/reject decision and the bulk/queued-generation view as variants of the same underlying card rather than as separate components, since every observed usage keeps them tightly coupled to the candidate being reviewed.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Prompt input collapsed, showing only the current candidate preview |
| **Expanded** | Prompt/parameters input, candidate preview, and Accept / Reject / Regenerate / Publish actions |
| **Full Page** | Bulk generation queue — queued/running/rate-limited jobs across many candidates at once |

## Props / Configuration

- `prompt` — the input driving generation (free text or structured parameters)
- `candidate` — the current generated output awaiting review
- `status` — `pending` \| `accepted` \| `rejected` \| `published`
- `queue` — for the Full Page variant, the set of in-flight bulk jobs and their rate-limit state

## Interactions

- User submits a prompt → a candidate generates and renders for review
- User accepts or rejects the candidate; accepted candidates become eligible to publish as the active output
- User clicks Regenerate → a new candidate is requested for the same slot
- User submits a bulk batch → jobs enter the queue view and process under the org's rate limit, with queued/running/rate-limited states visible per job
