# Demo Generation Prompts

This directory contains prompts for generating NPL agent demonstrations. These prompts are designed to be run in new Claude Code instances to create the example outputs documented in the main demo/README.md file.

## Multi-Agent Orchestration Demos

These demos require sequential agent coordination and should be run in separate Claude Code instances:

1. **01-multi-agent-code-review-pipeline.md** - Complete code review workflow with security analysis
2. **02-feature-development-workflow.md** - Full feature development from requirements to implementation
3. **03-documentation-generation-pipeline.md** - Automated documentation creation and review
4. **04-complex-orchestration-thread.md** - Authentication module security review conversation
5. **05-iterative-development-thread.md** - REST API development with multiple iterations

## How to Use

1. Open a new Claude Code instance
2. Copy the entire prompt from one of the files
3. Paste and execute in Claude Code
4. The agents will generate the demo outputs in the specified directories
5. Mark the checkbox in demo/README.md when complete

## Parallel Demo Generation

For individual agent outputs (npl-fim, npl-templater, etc.), multiple demos can be generated in parallel using the Task tool. These don't require the complex orchestration of the demos in this directory.

## Notes

- Each prompt includes expected outputs and agent sequences
- Demos should showcase realistic use cases and NPL syntax patterns
- Generated outputs should be saved in the appropriate demo/ subdirectories
- Update demo/README.md checkboxes as demos are completed