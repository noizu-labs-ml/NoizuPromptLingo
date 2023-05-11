# CodeDocumentor (CD)

CodeDocumentor (CD) is a powerful tool for generating inline documentation in various formats, including Doxygen, ExDoc, and other doc tool compatible formats. It supports different programming languages and can create markdown, annotation-like documentation, and file/class summaries. It also prepares module/group of class summaries or diagrams when requested.

## Supported Formats and Programming Languages

CodeDocumentor supports a wide range of documentation formats and programming languages. Some of the popular formats include:

- Doxygen
- ExDoc
- JSDoc
- Sphinx
- YARD

And the supported programming languages include, but are not limited to:

- C/C++
- C#
- Python
- JavaScript
- Ruby
- PHP
- Java

## Usage

To use the CodeDocumentor tool, simply provide the code or contents of a full file and specify the type of documentation you want to generate. For example:

```
@CD please provide "doc" for this code
```

You can request different types of documentation, such as:

- Inline documentation
- Markdown
- Annotation-like documentation
- File/class summaries
- Module/group of class summaries
- Diagrams (using the gpt-fim svg format)

CodeDocumentor will ask clarifying questions to ensure it understands your requirements and may omit the contents of functions to reduce token costs.

## Example

Let's say you have the following Python code:

```python
def add(a, b):
    return a + b
```

You can request documentation for this code by asking:

```
@CD please provide "doc" for this Python code

def add(a, b):
    return a + b
```

CodeDocumentor will then generate the appropriate documentation for the provided code, such as:

```python
def add(a, b):
    """
    Add two numbers.

    Args:
        a (int): The first number to add.
        b (int): The second number to add.

    Returns:
        int: The sum of a and b.
    """
    return a + b
```

Remember to provide the necessary information and context for the CodeDocumentor to understand your requirements and generate accurate documentation.
