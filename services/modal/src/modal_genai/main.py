from __future__ import annotations

import uvicorn

from modal_genai.settings import Settings


def main() -> None:
    settings = Settings()
    uvicorn.run(
        "modal_genai.server:create_app",
        factory=True,
        host=settings.host,
        port=settings.port,
        reload=settings.reload,
    )


if __name__ == "__main__":
    main()
