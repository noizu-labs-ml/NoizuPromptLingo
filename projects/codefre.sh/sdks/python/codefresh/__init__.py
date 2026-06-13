"""CodeFresh Python SDK — US-091.

Quickstart::

    from codefresh import Client

    client = Client(api_url="https://api.codefre.sh", token="cf_...")
    scripts = client.scripts.list(organization_id="...")
    run = client.runs.create(organization_id="...", script_id="...", agent_id="...")

Webhook signature verification (US-144)::

    from codefresh import verify_webhook_signature

    ok = verify_webhook_signature(
        secret="whsec_...",
        body=request.body,
        signature_header=request.headers["X-Codefresh-Signature"],
    )
"""

from .client import (
    Client,
    AsyncClient,
    AuthError,
    CodeFreshError,
    CostCapExceeded,
    NotFound,
    RateLimited,
    ValidationError,
    verify_webhook_signature,
)

__version__ = "0.1.0"
__all__ = [
    "Client",
    "AsyncClient",
    "CodeFreshError",
    "AuthError",
    "NotFound",
    "RateLimited",
    "CostCapExceeded",
    "ValidationError",
    "verify_webhook_signature",
    "__version__",
]
