# Multi-Agent Code Review Pipeline Demo

## Prompt

Create a demonstration of the Multi-Agent Code Review Pipeline for the NPL project. Generate the following in demo/orchestration/code-review-pipeline/:

1. Create a sample auth-module.py file with intentional code quality issues and potential security vulnerabilities (like SQL injection risks, weak password hashing, missing input validation)

2. Run the pipeline:
   - First use @npl-grader to evaluate the code quality and generate code-quality-score.md with a score around 78-82/100
   - Then use @npl-threat-modeler to identify security vulnerabilities and create security-vulnerabilities.md highlighting 2-3 medium severity risks
   - Finally use @npl-technical-writer to create consolidated-review.md that summarizes findings and prioritizes action items

3. Create an improved version auth-module-fixed.py addressing the issues

4. Re-run the pipeline on the fixed version showing improved scores (92+/100)

Ensure all outputs follow NPL syntax patterns and demonstrate realistic code review scenarios.

## Expected Outputs

- `demo/orchestration/code-review-pipeline/auth-module.py` - Original flawed code
- `demo/orchestration/code-review-pipeline/code-quality-score.md` - Initial grader evaluation
- `demo/orchestration/code-review-pipeline/security-vulnerabilities.md` - Threat analysis
- `demo/orchestration/code-review-pipeline/consolidated-review.md` - Combined findings
- `demo/orchestration/code-review-pipeline/auth-module-fixed.py` - Improved version
- `demo/orchestration/code-review-pipeline/code-quality-score-fixed.md` - Re-evaluation

## Agent Sequence

1. @npl-grader
2. @npl-threat-modeler  
3. @npl-technical-writer
4. (repeat for fixed version)