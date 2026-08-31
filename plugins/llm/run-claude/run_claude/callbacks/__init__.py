"""
LiteLLM custom callbacks for request/response transformation.

These callbacks allow massaging requests to work with finicky providers
like Groq that have strict input requirements.
"""

from .provider_compat import (
    ProviderCompatCallback,
    standardize_request,
    transform_request_for_provider,
    STRICT_PROVIDERS,
    _is_strict_provider,
)

provider_compat_callback = ProviderCompatCallback()

__all__ = [
    "ProviderCompatCallback",
    "provider_compat_callback",
    "standardize_request",
    "transform_request_for_provider",
    "STRICT_PROVIDERS",
]
