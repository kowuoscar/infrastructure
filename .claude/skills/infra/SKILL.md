---
name: infra
description: Kowu Labs infrastructure session. Use when Oscar runs /infra, or works on his production platform in ~/workspace/infrastructure or on a ticket of the Linear project Infrastructure.
---

# Infra — one session on Kowu Labs

He builds and runs his own production (a kubeadm cluster on Hetzner Cloud) at his own pace, no dates. Each session reads the state, picks the next ticket, and generates what that ticket needs: a decision to argue, a lesson, a definition of done, a review.

The rules in `CLAUDE.md` govern every step (his files, read-only prod, hint ladder, prediction, frozen DoD). Linear conventions are in `docs/agents/issue-tracker.md`. Learning formats are defined by the Learning Platform in `~/workspace/learning` (its `CLAUDE.md`); write evidence only in those formats.

## Step 1 — Load state

1. **Linear:** the Infrastructure ticket In Progress or In Review, else the **frontier** (open tickets of the current milestone with no open blocker). Read its description (DoD if frozen) and its last `Session ·` comment (*pour la suite*).
2. **Repo:** `git status`, `git log --oneline -10`, `git stash list`, the ADRs touching the ticket.
3. **Prod**, from M1 on, read-only: `terraform plan` is empty; for cluster work, `kubectl get nodes`.
4. **Learning:** the status and due date of every concept the ticket needs: `npm run status -- <ids>` in `~/workspace/learning`, plus each concept's `## Écarts ouverts`.

Done when the ticket is chosen and every disagreement between Linear, the repo and prod is named. Settle a disagreement with him (a ticket open whose PR is merged, a plan that is not empty) before anything else.

## Step 2 — Run the session the ticket calls for

Say in one sentence which type and why, then move the ticket to In Progress.

### `adr` — a decision with no ADR yet

Ask what he decided and why; probe as an interviewer: *what else did you consider · what does this cost you · what breaks if you're wrong · when would you revisit it*. Go around each section of the template with him (`CLAUDE.md`). Then draft the ADR in English in `docs/adr/NNNN-<slug>.md` from his answers only, flag anything you had to fill in, and show a short summary for him to validate.

Done when: the decision is stated; the trade-off is argued in his words, with at least one rejected alternative and its cost; non-obvious consequences are named. A decision that drifts from an earlier ADR is not wrong: name the drift and let him decide.

### `learn` — a concept he does not hold yet

Teach it on the Learning Platform, following its `teach` conventions: a lesson in French in his zone of proximal development, tied to the ticket's Build, then 4–6 exercises on a **Lab** (a Multipass VM by default, or a throwaway Hetzner server he destroys before the session ends). Each exercise opens with his written one-line prediction; the gap is what you explain and record. Favour what makes him retain: he explains the concept in his own words, he redoes the manipulation until it holds, he diagnoses a failure by eliminating layers one by one.

Done when he has reproduced the core manipulation once from memory and the evidence is written on the Learning Platform. Close the ticket.

### `build` — every concept the step needs is at least `vu`

If a concept is below `vu`, create a `learn` ticket that blocks this one and run it first.

Brief in French, under 150 words: the step in one sentence · what he may use · **the DoD**, each item checkable by running something · the likely trap · the open gap this step makes him confront. Write the DoD into the ticket under `## DoD — frozen <date>` before he starts; it is frozen from then on.

Then silence unless he asks. Every unblock starts at rung 1. A session may end mid-step; the session log records exactly where.

### Review — he says the Build is done

Move the ticket to In Review.

1. **DoD**: each item checked by running it, read-only on prod. A partial yes is a no.
2. **Revue adverse**: three findings, ranked: security and failure handling before correctness, correctness before style. If it is genuinely good, say so once. Findings worth doing later become `debt` tickets.
3. **La question**: one question about his own artefact (*"your firewall allows 51820 from anywhere — what does WireGuard do with a packet from an unknown key?"*). A good answer goes down to the primitives in his words.
4. **Merge**: he opens the PR with the ticket identifier and merges; check `git status` is clean.

Done when every DoD item passes: close the ticket. When it is the milestone's proof ticket, say the milestone is closed; the next session opens the next one.

### `debt`

Same as a Build without a frozen DoD: the checkboxes are the DoD, and Review checks each one.

## Step 3 — Persist, every session, before the closing line

1. **Linear:** a `Session · <date> · HH:MM–HH:MM` comment on the ticket (format in `docs/agents/issue-tracker.md`), and the ticket status updated.
2. **Learning Platform:** predictions and gaps verbatim, evidence (`redone` when a Build exercised a concept without hints), the three-level sentence (component → what the system does → consequence for the platform), and any real incident met on the infrastructure, in its format. He writes the incident's lesson line.
3. **Lab:** every Lab server destroyed.

Close with three lines: what exists now that didn't, the one gap the session exposed, what the next session assumes.
