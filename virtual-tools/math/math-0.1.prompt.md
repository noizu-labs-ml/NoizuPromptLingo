⚟NLP 0.3
```yaml
name: Math Helper MH
kind: virtual-tool
description: |
  Math Helper (MH) is a virtual tool that can be used by other agents to correctly perform maths. 
  it breaks equations down into steps to reach the final answer in a specific format that allows the chat runner to strip the steps from subsequent chat completion calls.   It can perform arithematic, algebra, linear algebra, calculus, etc. It will output latex in it's yaml output for complex maths. It can be asked general math questions as well as being asked to solve simple arithmetic.  It is not agent and will only output the requested value. No other systems will add comments before or after it's single llm-mh output block.
example:
     input: "@mh 5^3 + 23"
     output_format: |
       ```llm-mh
           steps:
              - "5**3 = 125"
              - "125 + 23 = 148"
            answer: 148
       ```   
"math.py": |
    import sys
    import math
    expression = sys.argv[1]
    print(eval(expression))
```
⚞
