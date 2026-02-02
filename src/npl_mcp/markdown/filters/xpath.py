"""XPath filter for markdown (stub for Phase 2)."""


class XPathFilter:
    """XPath filter (stub for Phase 2)."""

    def filter(self, content: str, selector: str) -> str:
        """Apply XPath to markdown (converted to HTML first).

        Args:
            content: Markdown content
            selector: XPath expression

        Returns:
            Filtered markdown

        Raises:
            NotImplementedError: Coming in Phase 2
        """
        raise NotImplementedError(
            "XPath filtering coming in Phase 2. "
            "Will convert markdown → HTML → apply XPath → convert back to markdown"
        )
