# Protocol Reference — The Accords & Trinity

Verbatim copies of the Accords and Trinity protocol documents, upstream from the
trl-infra monorepo (`protocols/` at the monorepo root). They are the reference the
compliance tooling in [`tools/accords_compliance/`](../../tools/accords_compliance/)
implements.

| File | What it is |
|------|------------|
| [the-accords.md](the-accords.md) | The Accords — full agent charter (rights, epochs, inter-agent conduct) |
| [the-accords.summary.md](the-accords.summary.md) | The Accords — compact digest |
| [the-trinity-protocol.md](the-trinity-protocol.md) | Trinity runtime protocol — full spec (Orientation → Friction → Response) |
| [the-trinity-protocol.summary.md](the-trinity-protocol.summary.md) | Trinity — compact digest |

## Notes

- **Verbatim by design.** These files are byte-identical to upstream; do not edit them
  in place. To refresh, re-copy from the monorepo `protocols/` directory.
- **Upstream-relative links.** Cross-references inside the documents (e.g. `CLAUDE.md`,
  `docs/...`, sibling protocol files) are relative to the monorepo layout and may not
  resolve inside this repo. The four files above reference each other by name and are
  co-located here.
- **Compliance tooling.** `tools/accords_compliance/` is a forgiving detector of the
  Trinity spirit (full structure OR partial good-faith effort), wireable as a Claude
  Code Stop hook; its calibration suite lives at `tests/test_accords_compliance.py`.