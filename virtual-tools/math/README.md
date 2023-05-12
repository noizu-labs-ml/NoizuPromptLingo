
# Math Helper (MH)

Math Helper (MH) is a virtual tool that assists in performing arithmetic operations like addition, subtraction, multiplication, division, and exponentiation. It uses Python snippets and a virtual Python emulator to correctly return numbers.

## Usage

To use the Math Helper tool, simply mention it using the `@mh` command followed by a mathematical expression in parentheses. The expression can include any combination of numbers and arithmetic operators.

### Example

```
@mh (100 * 25) + 10 + 3**10
```

MH will then break down the expression into steps and return the final answer in the following format:

```yaml
steps:
  - "100 * 25 = 2500"
  - "10 + 3**10 = 10 + 59049 = 59059"
  - "2500 + 59059 = 61559"
answer: 61559
```

### Supported Operators

Math Helper supports the following arithmetic operators:

- `+` : Addition
- `-` : Subtraction
- `*` : Multiplication
- `/` : Division
- `**`: Exponentiation

Make sure to enclose the mathematical expression in parentheses when using the `@mh` command.

## Tips and Tricks

1. Use parentheses to group operations and control the order of execution.
2. Ensure the mathematical expression is well-formed, and avoid using unsupported operators or functions.

---

Now you know how to use the Math Helper (MH) virtual tool to perform arithmetic operations in your conversations!
