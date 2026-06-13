# @codefresh/sdk — TypeScript SDK

TypeScript / JavaScript client for the [CodeFresh](https://codefre.sh) eval
platform. Runs in Node 18+, Bun, Deno, and edge runtimes.

## Install

```bash
npm install @codefresh/sdk
```

## Usage

```ts
import { Client } from "@codefresh/sdk";

const client = new Client({ apiUrl: "https://api.codefre.sh", token: "cf_..." });
const runs = await client.runs.list(orgId);
```

Token is read from `process.env.CODEFRESH_API_TOKEN` when not passed explicitly.

### Webhook verification

```ts
import { verifyWebhookSignature } from "@codefresh/sdk";

const ok = await verifyWebhookSignature(secret, rawBodyText, sigHeader);
```
