# codefresh — Python SDK

Synchronous + async client for the [CodeFresh](https://codefre.sh) eval platform.

## Install

```bash
pip install codefresh
```

## Usage

```python
from codefresh import Client

client = Client(api_url="https://api.codefre.sh", token="cf_...")
scripts = client.scripts.list(organization_id="...")
run = client.runs.create(
    organization_id="...",
    script_id="...",
    agent_id="...",
)
```

Token is read from `CODEFRESH_API_TOKEN` when not passed explicitly.

### Webhook signature verification

```python
from codefresh import verify_webhook_signature

ok = verify_webhook_signature(
    secret="whsec_...",
    body=request.body,
    signature_header=request.headers["X-Codefresh-Signature"],
)
```

## Status

Stage 11 scaffold — published shape is stable, a handful of resource methods
still issue stub requests. Follow along at
https://docs.codefre.sh/sdks/python.
