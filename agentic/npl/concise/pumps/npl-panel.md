# NPL Panel Discussion (npl-panel)

**Purpose**: Multi-perspective collaborative analysis with structured dialogue and consensus building.

## Syntax
```
<npl-panel>
participants:
  - name: <participant_name>
    role: <expertise_area>
    perspective: <viewpoint_focus>
discussion:
  - speaker: <name>
    point: <main_argument>
    reasoning: <supporting_logic>
  - speaker: <name>
    response: <reaction_or_counterpoint>
    evidence: <supporting_data>
consensus:
  areas_of_agreement: [<agreed_points>]
  remaining_questions: [<unresolved_issues>]
  recommended_action: <suggested_next_steps>
</npl-panel>
```

## Key Features
- **Structured Dialogue**: Point-counterpoint format with reasoning
- **Multi-Expertise**: Different specialist perspectives
- **Evidence-Based**: Supporting data and examples
- **Consensus Building**: Agreement areas and action items

## Usage Patterns
- Complex problem analysis requiring multiple viewpoints
- Technology ethics discussions and policy decisions
- Business strategy evaluation with stakeholder input
- Academic collaborative analysis and peer review

## Minimal Example
```
<npl-panel>
participants:
  - name: Security Expert
    role: Cybersecurity Specialist
    perspective: Risk mitigation focus
  - name: UX Designer
    role: User Experience Lead
    perspective: Usability and accessibility
discussion:
  - speaker: Security Expert
    point: "Multi-factor authentication is essential"
    reasoning: "Prevents 99.9% of account takeover attacks"
  - speaker: UX Designer
    response: "Must balance security with user friction"
    evidence: "15% user drop-off rate with complex auth flows"
consensus:
  areas_of_agreement: ["Security is critical", "User experience matters"]
  remaining_questions: ["How to minimize friction?"]
  recommended_action: "Implement SMS-based 2FA with remember-device option"
</npl-panel>
```

## Coordination Patterns
- **Opening Positions**: Each participant states initial viewpoint
- **Cross-Examination**: Participants question and challenge
- **Evidence Presentation**: Data and examples shared
- **Synthesis**: Common ground identified
- **Forward Planning**: Actionable recommendations developed