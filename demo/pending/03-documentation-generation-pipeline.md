# Documentation Generation Pipeline Demo

## Prompt

Create a demonstration of the Documentation Generation Pipeline for the NPL project. Generate the following in demo/orchestration/doc-generation/:

1. Create a sample src/ directory with 3-4 Python files implementing a simple REST API (user management, authentication, data operations)

2. Run the documentation pipeline:
   - Use @npl-grader to analyze the code and identify documentation gaps
   - Use @npl-technical-writer to generate:
     * api-reference.md with complete endpoint documentation
     * user-manual.md with usage instructions
   - Use @npl-persona as a technical reviewer to provide documentation-review.md with feedback

3. Create improved versions of the docs based on the review feedback

4. Include a pipeline-metrics.md showing documentation coverage before/after

Demonstrate how multi-agent collaboration improves documentation quality.

## Expected Outputs

- `demo/orchestration/doc-generation/src/` - Sample API code
- `demo/orchestration/doc-generation/documentation-gaps.md` - Grader analysis
- `demo/orchestration/doc-generation/api-reference.md` - API documentation
- `demo/orchestration/doc-generation/user-manual.md` - User guide
- `demo/orchestration/doc-generation/documentation-review.md` - Technical review
- `demo/orchestration/doc-generation/api-reference-v2.md` - Improved API docs
- `demo/orchestration/doc-generation/user-manual-v2.md` - Improved user guide
- `demo/orchestration/doc-generation/pipeline-metrics.md` - Quality metrics

## Agent Sequence

1. @npl-grader (analyze gaps)
2. @npl-technical-writer (generate docs)
3. @npl-persona (technical reviewer)
4. @npl-technical-writer (improve docs)