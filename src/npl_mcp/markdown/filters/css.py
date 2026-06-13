"""CSS selector filter for markdown (stub for Phase 2)."""


class CSSFilter:
    """CSS selector filter (stub for Phase 2)."""

    def filter(self, content: str, selector: str) -> str:
        """Apply CSS selector to markdown (converted to HTML first).

        Args:
            content: Markdown content
            selector: CSS selector

        Returns:
            Filtered markdown

        Raises:
            NotImplementedError: Coming in Phase 2
        """
        raise NotImplementedError(
            "CSS filtering coming in Phase 2. "
            "Will convert markdown → HTML → apply CSS selector → convert back to markdown"
        )
