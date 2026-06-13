# US-242: Justice System — Player Trials

**Persona:** Jamie — Interactive fiction enthusiast valuing narrative quality and dramatic coherence
**Priority:** P2
**Epic:** Advanced Social & Governance

## Story
As Jamie, I want crimes to trigger formal player-run trials with evidence, arguments, and narrated verdicts so that conflict resolution becomes a piece of collaborative fiction rather than a punish-and-forget system.

## Acceptance Criteria
- [ ] Crimes above a configurable severity threshold (assault, theft over X gold, murder) auto-generate a case file with evidence: combat logs, witness testimony, item transfer records
- [ ] Trial roles are assignable: Judge (elected official or appointed GM, see US-241), Prosecutor (Sheriff or appointed player), Defense Counsel (defendant may choose or be assigned), Jury (3–7 eligible citizens selected from pool)
- [ ] Trial proceeds through structured phases narrated in sequence: Opening Statements, Evidence Presentation, Witness Examination, Closing Arguments, Jury Deliberation, Verdict
- [ ] Each phase has a time limit (configurable, default: 10 minutes real time); if a participant fails to act, the system generates a neutral default action narrated in-character
- [ ] All trial dialogue and evidence presentation delivered through ARIA live region announcements; jury deliberation in a private channel with full SR support
- [ ] Verdicts carry real consequences: Guilty verdicts may result in gold fines (paid from escrow), temporary imprisonment (movement restricted to jail room), or item forfeiture; Not Guilty results in defendant clearing of the charge
- [ ] Defendant may plead guilty before trial for reduced sentence; plea and acceptance narrated as courtroom drama
- [ ] Full trial transcript saved to defendant's record, accessible to defendant, Judge, and GMs; browsable via screen-reader-friendly paginated view

## Notes
The narrative framing is everything here. Jamie doesn't want a bureaucratic form — she wants the system to feel like a courtroom scene from a fantasy novel. Every phase transition should carry prose: "The court falls silent as the prosecution rises to present their first piece of evidence." Evidence items should be described in character: not "combat_log_2026_05_26" but "a sworn account of the altercation, read aloud by the court recorder."

The NPC fallback for missing participants is crucial for completion rate. If the Defense Counsel fails to act during Cross-Examination, the system generates: "Defense counsel offers no rebuttal." This keeps trials from hanging indefinitely.

Jury deliberation is a design challenge for accessibility. The deliberation channel should support a structured vote: each juror issues GUILTY or NOT_GUILTY, with optional brief rationale (140 chars). A quorum rule (majority verdict) prevents single holdouts from blocking. Deliberation transcripts are sealed from public view during the trial, released after verdict.

Anti-abuse considerations: players cannot be jurors in cases involving their clan mates. Defendants cannot be tried twice for the same incident. GMs retain power to dismiss frivolous charges before trial begins. Consider a "public defender" NPC who provides baseline defense if no player volunteers — this ensures defendants aren't helpless even if their friends are offline.

Integration with US-241: the Judge role in trials should prefer the elected city Judge; if vacant, a GM-appointed NPC Judge presides. This creates political incentive to keep the judicial seat filled.
