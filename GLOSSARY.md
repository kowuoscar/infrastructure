# Glossary

The language of Oscar's production platform and of the work that builds it. Learning terms (Concept, Session, Gap, Evidence, Frontier, Review…) belong to the Learning Platform: see `~/workspace/learning/GLOSSARY.md`.

## The platform

**Prod**:
The real infrastructure on Hetzner Cloud and Cloudflare that tenants depend on. Only the CI changes it.
_Avoid_: production cluster, live, the cluster (when Prod is meant)

**Tenant**:
An application that runs on the platform (remote-support-app first, the Learning Platform second).
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
The runnable checks that say a Build is done, frozen before work starts.
_Avoid_: acceptance criteria, checklist

**Closing Build**:
The Build whose DoD closes its Milestone.
_Avoid_: proof ticket, milestone proof

**Build review**:
The check of a finished Build: every DoD item run, adversarial findings, one question on the artefact.
_Avoid_: review (alone: a Learning Platform retrieval session)

**Debt**:
Small leftovers found in a Build review, done like a Build whose checkboxes are its DoD.
_Avoid_: chore, cleanup
