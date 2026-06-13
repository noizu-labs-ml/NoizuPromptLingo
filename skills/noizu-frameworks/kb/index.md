# Noizu Framework KB — Question Index

Route questions to the correct knowledge-base file. Numbers reference `kb/NN-*.md`.
`summary.md` is always loaded; consult it first for quick answers.

---

## Entity & Persistence

| Question | File(s) |
|---|---|
| How do I define an entity? | 02 |
| How do I add persistence to an entity? | 02 |
| What field annotations are available? | 02 |
| How does the EntityReference protocol work? | 01 |
| How do I implement ERP for a custom struct? | 01 |
| How does schema versioning work? | 02 |
| What is sref? | 01 + 02 |
| How do I add PII masking or access restrictions to a field? | 02 |
| How do I generate CRUD operations for an entity? | 02 |
| What field types are supported? | 02 |

---

## GenAI & LLM

| Question | File(s) |
|---|---|
| How do I set up a GenAI thread? | 04 |
| How do I use Anthropic / OpenAI / Gemini? | 05 |
| How do I add a new provider? | 05 |
| What settings can I configure on a thread? | 04 |
| How does tool use / function calling work? | 04 |
| How do I run a local model? | 06 |
| What chat templates are available for local inference? | 07 |
| How does the graph execution model work? | 04 |
| How do I stream responses? | 04 |
| How do I build a multi-turn stateful session? | 04 |
| What providers are supported out of the box? | 05 |
| How do I configure API keys for providers? | 05 |

---

## Distributed Services

| Question | File(s) |
|---|---|
| How do I create a worker pool? | 03 |
| How does cluster coordination work? | 03 |
| What is the difference between s_call! and s_cast!? | 03 |
| How do I pin a call to a specific node? | 03 |
| How do I wake or kill a worker? | 03 |
| What OTP modules does use Noizu.Service generate? | 03 |

---

## Vector Search & RAG

| Question | File(s) |
|---|---|
| How do I define a Weaviate schema? | 08 |
| How do I do vector search? | 08 |
| How do I build a RAG pipeline? | 08 + 13 |
| How do I batch-import objects into Weaviate? | 08 |
| How do I use GraphQL filters in Weaviate? | 08 |
| How do I configure the Weaviate endpoint and API key? | 08 |

---

## Caching

| Question | File(s) |
|---|---|
| How does cache invalidation work? | 09 |
| How do I create a composite cache key? | 09 |
| How do I bust a cache tag? | 09 |
| How do I use Redis as a cache backend? | 09 |
| What is a KeyRing? | 09 |

---

## Auth Tokens

| Question | File(s) |
|---|---|
| How do I generate a smart token? | 10 |
| How do I make a single-use token? | 10 |
| How do I set a token expiry? | 10 |
| How do I restrict a token to an IP range? | 10 |
| How do I authorize a token in a Plug pipeline? | 10 |
| How does the dual-token design work? | 10 |

---

## Database Seeding

| Question | File(s) |
|---|---|
| How do I seed my database? | 11 |
| How do I make seeds idempotent? | 11 |
| How do I share data between seed blocks? | 11 |
| How do I gate seeds to a specific environment? | 11 |
| How do I express seed ordering / dependencies? | 11 |

---

## External Integrations

| Question | File(s) |
|---|---|
| How do I call the GitHub API? | 12 |
| How do I send emails? | 13 |
| How do I use Phoenix templates with SendGrid? | 13 |
| How do I configure SendGrid? | 13 |
| How do I configure the GitHub client? | 12 |

---

## Architecture

| Question | File(s) |
|---|---|
| What depends on what? | 00 |
| How do I add these libraries to my mix.exs? | 00 |
| How do libraries integrate with each other? | 13 |
| What is the overall design philosophy? | 00 |
| Where do I start if I'm new to the ecosystem? | 00 + summary |
| What is the ERP and why does everything use it? | 01 |
