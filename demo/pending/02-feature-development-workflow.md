# Feature Development Workflow Demo

## Prompt

Create a demonstration of the Feature Development Workflow for the NPL project. Generate the following in demo/orchestration/feature-development/:

1. Start with user-stories.md containing requirements for a "User Dashboard Feature" with:
   - View personal metrics
   - Export data to CSV/JSON
   - Real-time updates
   - Mobile responsive design

2. Execute the workflow:
   - Use @npl-persona in Product Manager mode to refine and clarify the requirements
   - Use @npl-thinker to create technical-approach.md analyzing implementation strategies
   - Use @npl-templater to generate the code structure in feature-implementation/ folder
   - Use @npl-fim to create interface-preview.html with an interactive mockup

3. Include a workflow-summary.md documenting how each agent contributed to the final result

Ensure each agent builds upon the previous agent's output demonstrating true orchestration.

## Expected Outputs

- `demo/orchestration/feature-development/user-stories.md` - Initial requirements
- `demo/orchestration/feature-development/refined-requirements.md` - PM refinements
- `demo/orchestration/feature-development/technical-approach.md` - Technical analysis
- `demo/orchestration/feature-development/feature-implementation/` - Generated code
- `demo/orchestration/feature-development/interface-preview.html` - UI mockup
- `demo/orchestration/feature-development/workflow-summary.md` - Process documentation

## Agent Sequence

1. @npl-persona (Product Manager)
2. @npl-thinker
3. @npl-templater
4. @npl-fim