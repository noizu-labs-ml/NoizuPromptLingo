# Worked Example: Stripe Payments MCP Server

End-to-end scaffold generation for a Stripe payments MCP server, from spec to production.

> This example assumes a spec from **trl-mcp-architect** (`references/specification-checklist.md`) has been completed.

## Starting Spec (from trl-mcp-architect)

```yaml
server:
  name: stripe-mcp
  description: MCP server for Stripe payment operations
  version: 0.1.0

tools:
  - name: create_payment_intent
    description: Create a Stripe PaymentIntent for a given amount and currency
    params:
      - name: amount
        type: number
        required: true
        description: Amount in smallest currency unit (e.g., cents for USD)
      - name: currency
        type: string
        required: true
        description: Three-letter ISO currency code (e.g., "usd")
      - name: description
        type: string
        required: false
        description: Description for the payment

  - name: get_payment_intent
    description: Retrieve a PaymentIntent by its ID
    params:
      - name: payment_intent_id
        type: string
        required: true
        description: Stripe PaymentIntent ID (starts with "pi_")

  - name: list_recent_charges
    description: List recent charges with optional filtering
    params:
      - name: limit
        type: number
        required: false
        description: Number of charges to return (1-100, default 10)
      - name: status
        type: string
        required: false
        description: Filter by status (succeeded, pending, failed)

auth:
  type: api-key
  key_env_var: STRIPE_SECRET_KEY

transport: stdio
language: typescript
```

## Phase 1: Quick Scaffold

Generate a working prototype to validate the tool interface.

### Generated src/index.ts

```typescript
// src/index.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "stripe-mcp",
  version: "0.1.0",
});

// Mock Stripe client for prototype validation
const mockPaymentIntents = new Map<string, Record<string, unknown>>();
let mockCounter = 1;

server.tool(
  "create_payment_intent",
  "Create a Stripe PaymentIntent for a given amount and currency",
  {
    amount: z.number().positive().describe("Amount in smallest currency unit (e.g., cents for USD)"),
    currency: z.string().length(3).describe('Three-letter ISO currency code (e.g., "usd")'),
    description: z.string().optional().describe("Description for the payment"),
  },
  async ({ amount, currency, description }) => {
    // Mock implementation -- returns realistic data structure
    const id = `pi_mock_${Date.now()}_${mockCounter++}`;
    const intent = {
      id,
      object: "payment_intent",
      amount,
      currency: currency.toLowerCase(),
      description: description ?? null,
      status: "requires_payment_method",
      created: Math.floor(Date.now() / 1000),
      client_secret: `${id}_secret_mock`,
    };
    mockPaymentIntents.set(id, intent);

    return {
      content: [{ type: "text" as const, text: JSON.stringify(intent, null, 2) }],
    };
  }
);

server.tool(
  "get_payment_intent",
  "Retrieve a PaymentIntent by its ID",
  {
    payment_intent_id: z.string().startsWith("pi_").describe('Stripe PaymentIntent ID (starts with "pi_")'),
  },
  async ({ payment_intent_id }) => {
    const intent = mockPaymentIntents.get(payment_intent_id);
    if (!intent) {
      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify({
              error: { type: "invalid_request_error", message: `No such payment_intent: '${payment_intent_id}'` },
            }),
          },
        ],
        isError: true,
      };
    }
    return {
      content: [{ type: "text" as const, text: JSON.stringify(intent, null, 2) }],
    };
  }
);

server.tool(
  "list_recent_charges",
  "List recent charges with optional filtering",
  {
    limit: z.number().min(1).max(100).optional().describe("Number of charges to return (1-100, default 10)"),
    status: z.enum(["succeeded", "pending", "failed"]).optional().describe("Filter by status"),
  },
  async ({ limit, status }) => {
    const count = limit ?? 10;
    // Generate mock charges
    const charges = Array.from({ length: Math.min(count, 5) }, (_, i) => ({
      id: `ch_mock_${i + 1}`,
      object: "charge",
      amount: (i + 1) * 1000,
      currency: "usd",
      status: status ?? "succeeded",
      created: Math.floor(Date.now() / 1000) - i * 3600,
      description: `Mock charge ${i + 1}`,
    }));

    return {
      content: [
        {
          type: "text" as const,
          text: JSON.stringify({ object: "list", data: charges, has_more: false }, null, 2),
        },
      ],
    };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("stripe-mcp v0.1.0 running on stdio");
}

main().catch((error) => {
  console.error("Fatal:", error);
  process.exit(1);
});
```

### Testing the Prototype

Connect to Claude Desktop and test:

1. "Create a payment intent for $25.00 USD" -- verify schema, response structure
2. "Get the payment intent you just created" -- verify ID handling
3. "List recent charges" -- verify list format

### Spec Decisions That Mapped to Code

| Spec Decision | Code Impact |
|---|---|
| `amount` is in smallest currency unit | Zod: `z.number().positive()` -- no division logic |
| `payment_intent_id` starts with "pi_" | Zod: `z.string().startsWith("pi_")` |
| `limit` range 1-100 | Zod: `z.number().min(1).max(100)` |
| `status` is enum | Zod: `z.enum(["succeeded", "pending", "failed"])` |
| Auth is API key | Not enforced in Phase 1 -- deferred to Phase 2 |

## Phase 2: Production Upgrade

Upgrade the prototype to production quality.

### What Changes

1. **Mock --> Real Stripe SDK:** Replace mock implementations with `stripe` npm package
2. **Add config:** `STRIPE_SECRET_KEY` from environment
3. **Add rate limiting:** Stripe has its own rate limits; add our own layer too
4. **Add structured logging:** Log every API call with duration and params hash
5. **Add error handling:** Map Stripe error types to MCP error responses
6. **Add tests:** Unit tests mock Stripe SDK, integration tests use in-memory transport
7. **Add Docker:** Multi-stage build
8. **Add CI:** GitHub Actions pipeline

### Key Production File: src/tools/stripe-tools.ts

```typescript
// src/tools/stripe-tools.ts
import Stripe from "stripe";
import { z } from "zod";
import { getConfig } from "../config.js";

let stripeClient: Stripe | null = null;

function getStripe(): Stripe {
  if (!stripeClient) {
    const config = getConfig();
    stripeClient = new Stripe(config.STRIPE_SECRET_KEY, {
      apiVersion: "2025-04-30.basil",
    });
  }
  return stripeClient;
}

// Exported handler (testable with mocked Stripe client)
export async function handleCreatePaymentIntent(
  params: { amount: number; currency: string; description?: string },
  stripe?: Stripe
): Promise<Record<string, unknown>> {
  const client = stripe ?? getStripe();

  try {
    const intent = await client.paymentIntents.create({
      amount: params.amount,
      currency: params.currency.toLowerCase(),
      description: params.description,
    });

    return {
      id: intent.id,
      amount: intent.amount,
      currency: intent.currency,
      status: intent.status,
      client_secret: intent.client_secret,
      created: intent.created,
    };
  } catch (error) {
    if (error instanceof Stripe.errors.StripeError) {
      return {
        error: {
          type: error.type,
          code: error.code,
          message: error.message,
        },
      };
    }
    throw error;
  }
}

export async function handleGetPaymentIntent(
  params: { payment_intent_id: string },
  stripe?: Stripe
): Promise<Record<string, unknown>> {
  const client = stripe ?? getStripe();

  try {
    const intent = await client.paymentIntents.retrieve(params.payment_intent_id);
    return {
      id: intent.id,
      amount: intent.amount,
      currency: intent.currency,
      status: intent.status,
      description: intent.description,
      created: intent.created,
    };
  } catch (error) {
    if (error instanceof Stripe.errors.StripeError) {
      return {
        error: {
          type: error.type,
          code: error.code,
          message: error.message,
        },
      };
    }
    throw error;
  }
}

export async function handleListRecentCharges(
  params: { limit?: number; status?: string },
  stripe?: Stripe
): Promise<Record<string, unknown>> {
  const client = stripe ?? getStripe();

  try {
    const listParams: Stripe.ChargeListParams = {
      limit: params.limit ?? 10,
    };

    const charges = await client.charges.list(listParams);

    let data = charges.data;
    if (params.status) {
      data = data.filter((c) => c.status === params.status);
    }

    return {
      object: "list",
      data: data.map((c) => ({
        id: c.id,
        amount: c.amount,
        currency: c.currency,
        status: c.status,
        description: c.description,
        created: c.created,
      })),
      has_more: charges.has_more,
    };
  } catch (error) {
    if (error instanceof Stripe.errors.StripeError) {
      return { error: { type: error.type, message: error.message } };
    }
    throw error;
  }
}

// Tool definitions for registration
export const stripeToolDefs = {
  create_payment_intent: {
    name: "create_payment_intent" as const,
    description: "Create a Stripe PaymentIntent for a given amount and currency",
    schema: {
      amount: z.number().positive(),
      currency: z.string().length(3),
      description: z.string().optional(),
    },
    handler: handleCreatePaymentIntent,
  },
  get_payment_intent: {
    name: "get_payment_intent" as const,
    description: "Retrieve a PaymentIntent by its ID",
    schema: {
      payment_intent_id: z.string().startsWith("pi_"),
    },
    handler: handleGetPaymentIntent,
  },
  list_recent_charges: {
    name: "list_recent_charges" as const,
    description: "List recent charges with optional filtering",
    schema: {
      limit: z.number().min(1).max(100).optional(),
      status: z.enum(["succeeded", "pending", "failed"]).optional(),
    },
    handler: handleListRecentCharges,
  },
};
```

### Key Production File: test/unit/stripe-tools.test.ts

```typescript
// test/unit/stripe-tools.test.ts
import { describe, it, expect, vi } from "vitest";
import {
  handleCreatePaymentIntent,
  handleGetPaymentIntent,
  handleListRecentCharges,
} from "../../src/tools/stripe-tools.js";

// Mock Stripe client
function createMockStripe() {
  return {
    paymentIntents: {
      create: vi.fn().mockResolvedValue({
        id: "pi_test_123",
        amount: 2500,
        currency: "usd",
        status: "requires_payment_method",
        client_secret: "pi_test_123_secret_test",
        created: 1700000000,
      }),
      retrieve: vi.fn().mockResolvedValue({
        id: "pi_test_123",
        amount: 2500,
        currency: "usd",
        status: "requires_payment_method",
        description: "Test payment",
        created: 1700000000,
      }),
    },
    charges: {
      list: vi.fn().mockResolvedValue({
        data: [
          {
            id: "ch_test_1",
            amount: 1000,
            currency: "usd",
            status: "succeeded",
            description: "Charge 1",
            created: 1700000000,
          },
        ],
        has_more: false,
      }),
    },
  } as any;
}

describe("create_payment_intent", () => {
  it("creates a payment intent successfully", async () => {
    const stripe = createMockStripe();
    const result = await handleCreatePaymentIntent(
      { amount: 2500, currency: "usd", description: "Test" },
      stripe
    );
    expect(result.id).toBe("pi_test_123");
    expect(result.amount).toBe(2500);
    expect(stripe.paymentIntents.create).toHaveBeenCalledWith({
      amount: 2500,
      currency: "usd",
      description: "Test",
    });
  });
});

describe("get_payment_intent", () => {
  it("retrieves a payment intent", async () => {
    const stripe = createMockStripe();
    const result = await handleGetPaymentIntent(
      { payment_intent_id: "pi_test_123" },
      stripe
    );
    expect(result.id).toBe("pi_test_123");
    expect(result.status).toBe("requires_payment_method");
  });
});

describe("list_recent_charges", () => {
  it("lists charges with default limit", async () => {
    const stripe = createMockStripe();
    const result = await handleListRecentCharges({}, stripe);
    expect((result as any).data).toHaveLength(1);
    expect((result as any).data[0].id).toBe("ch_test_1");
  });

  it("filters by status", async () => {
    const stripe = createMockStripe();
    const result = await handleListRecentCharges(
      { status: "succeeded" },
      stripe
    );
    expect((result as any).data[0].status).toBe("succeeded");
  });
});
```

### Additional config.ts Entry

```typescript
// Add to config.ts envSchema:
STRIPE_SECRET_KEY: z.string().min(1).describe("Stripe secret API key"),
```

### package.json Addition

```json
{
  "dependencies": {
    "stripe": "^17.0.0"
  }
}
```

## Summary: Spec to Scaffold Mapping

| Spec Element | Phase 1 Impact | Phase 2 Impact |
|---|---|---|
| Tool name + description | Direct to `server.tool()` | Same, in tool defs file |
| Parameters with types | Zod schema | Same Zod schema |
| Validation rules (startsWith, range) | Zod validators | Same |
| Auth: api-key | Skipped (mock data) | Config + Stripe SDK init |
| Transport: stdio | StdioServerTransport | Configurable (stdio or HTTP) |
| Error responses | Mock error objects | Real Stripe error mapping |
| Mock data | Realistic structure | Replaced with real API calls |
