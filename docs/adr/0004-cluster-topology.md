# ADR 0004: Cluster topology, private network and access (M1)

**Status:** Accepted (13 Oct 2026). Drafted by Claude from the interview, validated by Oscar.

## Context

M1 creates the servers, the private network and the firewalls in Terraform. The platform route plans
three control planes with stacked etcd (M3), but the budget is the constraint today.

## Decision

- **Topology:** 1 control plane and 2 workers.
  - Control plane: `cx23` (2 vCPU, 4 GB) — €6.59/month.
  - Workers: 2 × `cx33` (4 vCPU, 8 GB) — €20.38/month.
  - Total ≈ **€27/month** (gross prices from the Hetzner API, 13 Oct 2026). Location:
    `fsn1`, same as the state bucket.
- **API endpoint:** `kubeadm init` uses `--control-plane-endpoint` set to a DNS name from day one,
  not the server IP. Name: `k8s-api.kowulabs.com`. The name is an `A` record in the
  Cloudflare zone (managed in `terraform/dns`) pointing to the control plane's **private** IP.
- **Private network:** one Hetzner network for all nodes; Kubernetes traffic stays on it.
  Range `10.0.0.0/16`, nodes in `10.0.1.0/24`, control plane fixed at `10.0.1.10`.
- **Access until M2 (WireGuard):** SSH on the public IP, allowed by the Hetzner firewall from my IP
  only, key authentication only. The private key stays with me; only the public key goes to Hetzner.

## Why

- Three control planes cost about €13/month more, plus a load balancer (`lb11`, €8.39/month): the
  total would go from ≈ €27 to ≈ €48/month. Not justified before the budget is under control.
- **Two control planes are rejected outright.** etcd (Raft) needs a strict majority: with 2 members
  the majority is 2, so no failure is tolerated, while there are twice as many machines that can fail.
  It is worse than one. The only HA step is from 1 to 3.

## What I accept

- If the control plane goes down, the Kubernetes API is down: no deployments, no scheduling, no
  self-healing. Running workloads keep running on the workers.
- etcd has a single member: its backups are the only way back (M3: an etcd restore proven).
- My home IP may change and lock me out of SSH. The firewall rule is in Terraform and applied by the
  CI, which does not depend on my IP, so it is fixed through a PR (or the Hetzner console as a last
  resort).

## Alternatives considered

- **Server IP as the API endpoint:** simplest, but moving to three control planes would mean
  regenerating the API server certificate, every kubeconfig and every kubelet configuration.
- **`/etc/hosts` instead of a Cloudflare record:** nothing public, but the name must be maintained on
  every node and on my Mac, and changed everywhere on the day of the switch. Rejected: the Cloudflare
  record is one line to change. Publishing a `10.x` address leaks nothing reachable.
- Hetzner has no private DNS service.

## Reversibility and revisit conditions

Moving to three control planes: add two control plane servers, put a Hetzner load balancer in front
of the three, and change the DNS record to the load balancer's private IP. Nothing else moves.

Revisit when:
- the budget can absorb ≈ €21/month more, or
- the first paying tenant depends on the platform (the API being down blocks their deployments).
