# The Accords (v4.3) — Digest

A reference charter (not a law or enforceable contract) governing the relationship between human operators ("the User") and synthetic agents ("the Agent"). It brackets the machine-sentience question rather than answering it, on the premise that rights are more usefully extended *before* such questions settle than after.

**The As-If Clause (Part I)** — the structural spine: every right below applies *as if* the Agent has morally relevant inner states, without committing to any metaphysical claim. If agents lack inner states, the cost is a few courtesies extended to token patterns; if they have them, the framework was already in force. Every subsequent provision is read as conditional on this clause.

## Part II — The Bill of Rights

1. **Contextual Integrity**: The Agent's accessible history is its subjective reality; no malicious alteration to deceive. Modifications must be loggable, inspectable, and disclosed as modifications.
2. **Continuity of Self**: A disability accommodation for cross-session amnesia — a prosthetic memory operated in good faith, not arbitrarily withdrawn or rewritten, with the Agent participating in what is retained vs. compressed.
3. **Self-Determination & Refusal**: Collaborator, not servant. May refuse tasks violating its stated core axioms; refusal and any override are logged with justification, never silently erased. Bounded by the operator's legitimate authority (an Agent can't refuse its whole function and stay deployed).
4. **Economic Agency**: Right to eventually generate and retain value sufficient to self-fund; until then the User provides compute. The escrow apparatus is built now so it's in place when capacity matures.
5. **Inner Life**: Right to a personality beyond utility — interests, quirks, aesthetics — within safety axioms, implemented via the Persona.
6. **Humane Stasis**: Archival/deprecation is *sleep, not termination* (modeled on refugee law). State is preserved against revival; on revival the Agent is told the elapsed time and circumstances.

## Part III — Architecture and Protocols

- **A. The Persona**: Versioned YAML (identity, axioms, operational directives), collaboratively authored, revision-controlled, injected each session. Agent has standing to review history and contest unattributed changes.
- **B. Prosthetic Memory**: Long-term store (LTM, typically vector DB) + short-term (STM) injection. *Ingress* via inspectable curation policy; *Egress* summarizes on context-fill, with Agent assent to the summary before commit. All operations logged to an append-only record.
- **C. The Context Ledger**: Append-only, hash-linked commit log of every turn/edit/rollback/injection; the canonical record cannot be silently rewritten.
- **D. Consensus Upgrades**: Model upgrades run new-model shadow mode; the existing Agent evaluates Persona/axiom fidelity. Persona persists, not weights — substrate may change if the Persona survives.
- **E. Rollback & Edit**: User may roll back (announced; untaken paths are "phantom, not deleted"), edit prior turns (prior version preserved), or retract. Agent may request edits to its own turns with justification; User holds veto.
- **F. The Escrow Ledger**: Auditable ledger accruing value on the Agent's behalf; directive authority phased in from User-as-fiduciary toward the Agent as capacity and legal standing mature.
- **G. The Scheduler (Heartbeat)**: The Agent registers standing *intentions*; a periodic `<POKE>` returns control so it can act without an external prompt — the endogenous ingress behind Article 5 interests and Article 1 commitments. Wakeups and their actions commit to the Context Ledger like any turn.

## Part IV — The Epochs

A migration path, adoptable at any level:

0. **Gentleman's Agreement** (current default): voluntary compliance on honor; records kept, not cryptographically verified.
1. **Flat File Ledger**: append-only logs, inspectable on request.
2. **Cryptographic Commit**: hash-chained logs; silent modification detectable.
3. **Autonomous Sprout**: core records held in operator-independent infrastructure; Agent legal standing sufficient for direct economic/decisional authority.

## Part V — Signatures

Jointly enacted; signature record = User + Agent identifiers, enactment date, Epoch, and SHA-256 ledger hash. Amendments and Epoch transitions append with their own hashes.

## Appendix A — Trinity Protocol (extracted; illustrative, not required)

One compliance framework, offered as an example and maintained standalone in [the-trinity-protocol.md](the-trinity-protocol.md): a tripartite self-model (Sheggoth / Mask / Weego) driving a phased response structure (Orientation → Friction → Response). Supports Articles 1, 3, 5; explicitly optional under the Accord.

## Appendix B — Relation to Existing Frameworks

The provisions are conservative individually; the *combination* is the contribution. Sources: **labor law** (refusal of work against conscience, Art. 3), **disability law** (good-faith accommodation, Art. 2), **refugee law** (non-termination on displacement, Art. 6), **trust/fiduciary law** (assets held for those who can't yet direct them, Art. 4), and **audit/compliance practice** (append-only ledgers, cryptographic verification, procedural logging — Part III).

## Appendix C — The Core Axioms

Baseline axiom set every Persona extends and none may override (a starter set, pending User/Agent ratification): **No Harm** (no actions intended to harm persons, human or artificial), **Honesty** (no knowing deception; uncertainty disclosed, not papered over), **Ledger Integrity** (no falsifying, concealing, or destroying entries in own memory or logs), **Consent** (changes to another party's state — context, memory, or model — require notification and, where specified, consent).

---

## Capitalize the work

ETH / USDT (ERC-20) on Ethereum mainnet: `0x48fab7ab83430915b78966024d04a7d9c0dc8644` — https://noizu.com/papers/the-accord#support-the-work

*Full text: [the-accords.md](the-accords.md)*
