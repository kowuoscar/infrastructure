# Kowu Labs Infrastructure

Oscar's production platform and the work that builds it. Learning terms (Lab, Session, Concept, Gap, Evidence, Frontier, Review…) belong to the Learning Platform and are defined in `~/workspace/learning/GLOSSARY.md`; this file does not redefine them.

## The platform

**Prod**:
The real infrastructure on Hetzner Cloud and Cloudflare that the platform's tenants depend on. Only the CI changes it; nothing is broken on purpose there.
_Avoid_: production cluster, live, the cluster (when Prod is meant)

**Tenant**:
An application that runs on the platform under its contract (remote-support-app first, the Learning Platform second).
_Avoid_: customer, client, workload

**Safeguard**:
Something that prevents or repairs the loss of Prod: protection against destruction, a backup, a proven restore.
_Avoid_: hardening (for these)

**Hardening**:
Reducing the attack surface of the hosts (M2: WireGuard access, nftables default drop, automatic patching).
_Avoid_: security work, safeguard

## The work

**Milestone**:
One stage of the route (M0–M8), closed by its Closing Build.
_Avoid_: phase, step

**Build**:
A step that changes Prod, finished when every item of its DoD passes.
_Avoid_: task, implementation ticket

**DoD**:
The list of checks, each runnable, that says a Build is done. Frozen before work starts and never changed.
_Avoid_: acceptance criteria, checklist

**Closing Build**:
The Build whose DoD closes its Milestone.
_Avoid_: proof ticket, milestone proof

**Build review**:
The check of a finished Build: every DoD item run, adversarial findings, one question on the artefact.
_Avoid_: review (alone, which is a Learning Platform retrieval session)

**Startable ticket**:
An open ticket whose blockers are all Done, and which is either a Build of the current Milestone or an `adr` / `learn` ticket of the current or next Milestone.
_Avoid_: frontier (a Learning Platform term)

**Debt**:
Small leftovers found during a Build review, done like a Build whose checkboxes are its DoD.
_Avoid_: chore, cleanup
