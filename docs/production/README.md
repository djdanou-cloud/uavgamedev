# Colonel Air-defense: The Danger Wave — Production Plan (index)

Prefix: `cad`. Engine: Godot 4.7.2 stable (assumed; see 00). Platform: Android / Google Play only.
This directory is the operating system of the studio. Agents execute it card by card; the human verifies it gate by gate.

| # | File | Section | Read by |
|---|------|---------|---------|
| A | [00-assumptions-register.md](00-assumptions-register.md) | Assumptions Register & Locked Decisions | human, agents (when a card cites an A-id) |
| B | [01-design-bible.md](01-design-bible.md) | Implementation-Ready Design Bible (stat tables, Pk matrix, kill chain, economy, waves, tech, doctrine, screens, readability) | agents implementing sim/data/UI cards |
| C | [02-milestones.md](02-milestones.md) | Production Strategy & Milestones (DoD, kill criteria, calendar) | human |
| D | [03-architecture.md](03-architecture.md) | Technical Architecture & Tooling Pipeline (D1–D7) | every agent, every card |
| E | [04-workstreams.md](04-workstreams.md) | Workstream Breakdowns, critical path, full delegation matrix | human, planning agents |
| F | [05-risks.md](05-risks.md) | Risk Management & De-risking Matrix | human (reviewed at every gate) |
| G | [06-qa-release.md](06-qa-release.md) | QA, Hardening & Google Play Release Plan | human, QA/balance agents |
| §7 | [07-task-card-template.md](07-task-card-template.md) | AI Task Card template + standard constraint sets (STD-*) | every agent before starting a card |
| H | [08-ai-operating-manual.md](08-ai-operating-manual.md) | AI Operating Manual (H2 session protocol, H4 metrics); H1 = `/AGENTS.md`; H3 = `/ai/prompts/` | every agent, human |
| I | [09-execution-backlog.md](09-execution-backlog.md) | Execution Backlog: First Playable task cards (I1) + epics to Beta (I2) | human picks cards; agents execute |

Supporting files outside this directory:

| Path | Purpose |
|------|---------|
| `/AGENTS.md` (copy: `/CLAUDE.md`) | The file every agent reads first (H1) |
| `/ai/prompts/*.md` | Paste-ready prompt templates (H3) |
| `/ai/handoffs/_TEMPLATE.md`, `/ai/handoffs/INDEX.md` | Handoff record schema and the live registry of in-flight cards |
| `/ai/logs/_TEMPLATE.md` | Session log schema |
| `/ai/metrics/metrics.csv` | H4 metrics ledger |

Reading order for a new agent: `AGENTS.md` → `07-task-card-template.md` → the card → `03-architecture.md` sections the card cites → `01-design-bible.md` tables the card cites.
Reading order for the human at a gate: `02-milestones.md` (DoD) → `05-risks.md` (indicators) → `ai/handoffs/INDEX.md` (in-flight state) → `ai/metrics/metrics.csv`.

Conventions used in every file: `[VERIFY]` = fact not confirmed against a primary source for the assumed version; `[HUMAN]` = decision or action reserved for the human; `A-nn` = row in the Assumptions Register; `CAD-<MS>-<nnn>` = task card id, `<MS>` ∈ {FP, VS, PA, AL, BE, RC, GO, PL}.
