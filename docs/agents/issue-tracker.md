# Issue tracker: Linear

Work for this repo lives in Linear, through the `linear-server` MCP tools. GitHub Issues are not used; GitHub only hosts the code and the PRs.

## Where

- **Team:** Kowu Labs (key `KLB`). Pass the team by name or by ID `7f359d33-41d3-44b5-887a-d2eae1a5db9c`.
- **Project:** Infrastructure.
- **Milestones**, in order of work: M0 · Foundations → M1 · Cloud layer → M3 · Cluster → M4 · Platform core → M2 · Hardened hosts → M5 · Data → M6 · Observability → M7 · First tenant → M8 · Rebuild drill. M2 comes after M4 by Oscar's decision (15 Oct 2026).
- **Assignee:** always Oscar (`me`).

## Ticket types (labels)

| Label | What it is | Done when |
| --- | --- | --- |
| `adr` | A decision to argue and record | The ADR is merged in `docs/adr/` |
| `learn` | A concept to learn first, on the Learning Platform | The concept is at least `vu` and the core manipulation redone once from memory |
| `build` | A step with a runnable DoD | Every DoD item passes, checked by running it |
| `debt` | Small leftovers found in review | Every checkbox is ticked |

A `learn` ticket **blocks** the Build that needs its concept. Each milestone ends with one Build whose description says "This is the proof that closes Mx".

## Statuses

Backlog (not next) → Todo (next up) → In Progress (a session is on it) → In Review (he says it is done; the Review session runs) → Done. Canceled for dropped work.

## Conventions

- **Before creating**, check with `list_issues` (project Infrastructure, keyword `query`) that no matching ticket exists.
- **Create / update:** `save_issue` with `team`, `project`, `milestone`, `labels`, `assignee: me`. Write for a human: short sentences, the same term for the same concept.
- **Blocking:** native relations (`blockedBy` / `blocks`), plus a `## Blocked by` section in the body. A ticket is startable when every blocker is Done.
- **Frontier:** open tickets of the current milestone with no open blocker, Todo before Backlog, higher priority first.
- **Ordered lists:** Linear renumbers markdown ordered lists. When numbers carry meaning (frozen DoD items), write them as `**Point 5.**` paragraphs, not as a list.

## The DoD on a Build

- At the start of the first Build session, write the DoD under `## DoD — frozen <date>`, each item checkable by running something. From then on it never changes.
- Review checks each item by running it (read-only on prod). A partial yes is a no.

## Session log

Every session ends with a comment (`save_comment`) on the ticket it worked on, headed `Session · <date> · HH:MM–HH:MM`:

- what was done, with commits / PRs;
- unblocks given, with their rung (1 question · 2 concept · 3 approach);
- review findings, if any;
- verdict **fini / pas fini**;
- *pour la suite*: where he stopped and what the next session assumes.

Predictions, gaps and evidence about concepts go to the Learning Platform, not to Linear.

## Branches and PRs

- Branch from the ticket's `gitBranchName` (e.g. `devsokowu/klb-21-protect-prod-against-destruction`).
- Put the ticket identifier in the PR title or body (`Fixes KLB-21`) so the Linear GitHub integration links the PR and moves the ticket.
- He commits and merges. Close a ticket only after its Review passes.
