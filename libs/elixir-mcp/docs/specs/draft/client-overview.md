<!-- 
  Source: https://modelcontextprotocol.io/specification/draft/client
  Fetched: 2026-06-13
  Status: DRAFT (2026-07-28-RC)
  WARNING: This is draft content and may change before final release.
-->

# Client Features Overview

The client side of the Model Context Protocol provides features that servers can request
from clients during operation. The `/specification/draft/client` path redirects to the
Roots page, but the client features are:

* **[Elicitation](/specification/draft/client/elicitation)**: Server-initiated requests for
  additional information from users, supporting form mode (structured data collection) and
  URL mode (out-of-band sensitive interactions)
* **[Sampling](/specification/draft/client/sampling)** (Deprecated): Standardized way for
  servers to request LLM sampling from language models via clients
* **[Roots](/specification/draft/client/roots)** (Deprecated): Standardized way for clients
  to expose filesystem "roots" to servers

These client features are accessed by servers through the Multi Round-Trip Requests (MRTR)
pattern, where the server returns an `InputRequiredResult` containing the request, and the
client responds with `inputResponses` on the next request.
