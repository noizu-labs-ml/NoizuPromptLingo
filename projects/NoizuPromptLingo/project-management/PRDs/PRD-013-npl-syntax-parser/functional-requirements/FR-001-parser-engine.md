# FR-001: Parser Engine

**Status**: Draft

## Description

The parser engine provides core functionality to parse NPL documents into structured AST, tokenize content, and extract syntax elements.

## Interface

```python
class NPLParser:
    """Parses NPL documents into structured AST."""

    def parse(self, content: str) -> NPLDocument:
        """Parse NPL content into document AST.

        Args:
            content: Raw NPL document content

        Returns:
            NPLDocument AST with all structural elements

        Raises:
            ParseError: If document contains syntax errors
        """

    def parse_file(self, path: Path) -> NPLDocument:
        """Parse NPL file into document AST.

        Args:
            path: Path to NPL file

        Returns:
            NPLDocument AST

        Raises:
            FileNotFoundError: If file doesn't exist
            ParseError: If document contains syntax errors
        """

    def tokenize(self, content: str) -> list[Token]:
        """Tokenize content into raw tokens.

        Args:
            content: Raw NPL document content

        Returns:
            List of tokens with type and position info
        """

    def get_elements(self, content: str) -> list[SyntaxElement]:
        """Extract all syntax elements from content.

        Args:
            content: Raw NPL document content

        Returns:
            List of all detected syntax elements with metadata
        """
```

## Behavior

- **Given** valid NPL document content
- **When** `parse()` is called
- **Then** returns complete NPLDocument AST with all structural elements preserved

- **Given** malformed NPL document
- **When** `parse()` is called
- **Then** raises ParseError with line/column information

- **Given** NPL document with 155 different syntax elements
- **When** `get_elements()` is called
- **Then** returns list containing all 155 recognized elements

## Edge Cases

- **Empty document**: Returns NPLDocument with empty sections list
- **Unicode characters in syntax**: Properly handles emoji directives and markers
- **Nested structures**: Correctly parses nested fences, boundaries, and directives
- **Incomplete boundaries**: Detects unclosed markers and reports error
- **Mixed line endings**: Normalizes CRLF/LF line endings

## Related User Stories

- US-080: Validate NPL Documents for Syntax Errors
- US-087: AST Representation for Programmatic Analysis
- US-082: Extract Metadata from Agent Definition Files
- US-084: List All Syntax Elements Used in Document

## Test Coverage

Expected test count: 25-30 tests
Target coverage: 100% for parser core
