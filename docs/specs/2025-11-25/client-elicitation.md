<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/client/elicitation -->
<!-- Fetched: 2026-06-13 -->

# Elicitation

The Model Context Protocol (MCP) provides a standardized way for servers to request additional information from users through the client during interactions. This flow allows clients to maintain control over user interactions and data sharing while enabling servers to gather necessary information dynamically.

Elicitation supports two modes:

* **Form mode**: Servers can request structured data from users with optional JSON schemas to validate responses
* **URL mode**: Servers can direct users to external URLs for sensitive interactions that must *not* pass through the MCP client

## Capabilities

Clients that support elicitation **MUST** declare the `elicitation` capability during initialization:

```json
{
  "capabilities": {
    "elicitation": {
      "form": {},
      "url": {}
    }
  }
}
```

For backwards compatibility, an empty capabilities object is equivalent to declaring support for `form` mode only.

Clients declaring the `elicitation` capability **MUST** support at least one mode (`form` or `url`).

Servers **MUST NOT** send elicitation requests with modes that are not supported by the client.

## Protocol Messages

### Elicitation Requests

All elicitation requests **MUST** include:

| Name      | Type   | Options       | Description                                                                            |
| --------- | ------ | ------------- | -------------------------------------------------------------------------------------- |
| `mode`    | string | `form`, `url` | The mode of the elicitation. Optional for form mode (defaults to `"form"` if omitted). |
| `message` | string |               | A human-readable message explaining why the interaction is needed.                     |

### Form Mode Elicitation Requests

Form mode requests **MUST** either specify `mode: "form"` or omit the `mode` field, and include:

| Name              | Type   | Description                                                    |
| ----------------- | ------ | -------------------------------------------------------------- |
| `requestedSchema` | object | A JSON Schema defining the structure of the expected response. |

#### Requested Schema

The schema is restricted to flat objects with primitive properties only:

1. **String Schema** - with optional `minLength`, `maxLength`, `pattern`, `format` (`email`, `uri`, `date`, `date-time`), `default`
2. **Number Schema** (or `integer`) - with optional `minimum`, `maximum`, `default`
3. **Boolean Schema** - with optional `default`
4. **Enum Schema** - single-select via `enum` or `oneOf`, multi-select via `array` with `items`

Complex nested structures and arrays of objects are intentionally not supported.

#### Example: Simple Text Request

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "elicitation/create",
  "params": {
    "mode": "form",
    "message": "Please provide your GitHub username",
    "requestedSchema": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        }
      },
      "required": ["name"]
    }
  }
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "action": "accept",
    "content": {
      "name": "octocat"
    }
  }
}
```

### URL Mode Elicitation Requests

URL mode enables servers to direct users to external URLs for out-of-band interactions.

URL mode requests **MUST** specify `mode: "url"` and include:

| Name            | Type   | Description                               |
| --------------- | ------ | ----------------------------------------- |
| `url`           | string | The URL that the user should navigate to. |
| `elicitationId` | string | A unique identifier for the elicitation.  |

> URL mode elicitation is *not* for authorizing the MCP client's access to the MCP server. Instead, it's used when the MCP server needs to obtain sensitive information or third-party authorization on behalf of the user.

### Completion Notifications for URL Mode

Servers **MAY** send a `notifications/elicitation/complete` notification when an out-of-band interaction is completed.

### URL Elicitation Required Error

When a request cannot be processed until an elicitation is completed, the server **MAY** return a `URLElicitationRequiredError` (code `-32042`). The error **MUST** include a list of URL mode elicitations required.

## Response Actions

1. **Accept** (`action: "accept"`): User explicitly approved and submitted with data
2. **Decline** (`action: "decline"`): User explicitly declined the request
3. **Cancel** (`action: "cancel"`): User dismissed without making an explicit choice

## Error Handling

* When a request cannot be processed until an elicitation is completed: `-32042` (`URLElicitationRequiredError`)
* Server sends unsupported mode: `-32602` (Invalid params)

## Security Considerations

1. Servers **MUST NOT** use form mode elicitation to request sensitive information such as passwords, API keys, access tokens, or payment credentials
2. Servers **MUST** use URL mode for interactions involving sensitive information
3. Servers **MUST** bind elicitation requests to the client and user identity
4. Clients **MUST** provide clear indication of which server is requesting information

### Safe URL Handling

MCP servers:
1. **MUST NOT** include sensitive information about the end-user in the URL
2. **MUST NOT** provide a URL which is pre-authenticated to access a protected resource
3. **SHOULD** use HTTPS URLs for non-development environments

MCP clients:
1. **MUST NOT** automatically pre-fetch the URL or any of its metadata
2. **MUST NOT** open the URL without explicit consent from the user
3. **MUST** show the full URL to the user for examination before consent
4. **MUST** open the URL in a secure manner that does not enable the client or LLM to inspect the content or user inputs
5. **SHOULD** highlight the domain of the URL to mitigate subdomain spoofing
