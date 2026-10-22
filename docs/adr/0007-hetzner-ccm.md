# ADR 0007: Hetzner CCM Integration

**Status:** Accepted (22 Oct 2026). Written by Oscar.

## Context

M4 introduces the Gateway, which needs to sit behind a load balancer.
Hetzner load balancers are created by the CCM, which requires every kubelet to start with `--cloud-provider=external`. The current cluster doesn't have it.

## Decision

- **Tool:** Hetzner CCM.
- **Ansible:** I will update the current playbook to configure the kubelet with the missing `--cloud-provider=external` flag, add the required `hcloud` Secret (passed through a GitHub Environment secret) with `no_log` enabled, and install the Hetzner CCM component using the Helm module.
- **Hetzner token:** a new read-write token is created for the component instead of reusing the one defined for the CI.
- **Cilium VXLAN tunnel over native routing:** the current configuration works and does not yet require switching to native routing.

## Why

Integrating with Hetzner CCM lets it manage load balancer creation through annotations, and the node lifecycle.
CI and CCM hold two different responsibilities, and their tokens can be revoked independently without impacting each other.

## What I accept

- The token will have the same rights as the one defined for the CI. A token leak allows deleting the servers.
- The token is stored in plain text in etcd and in its backups.
- The cluster is rebuilt, which is fine since it doesn't run any workload yet.

## Alternatives considered

- **Load balancers managed by Terraform:** the downside of this approach is having to remember to define the load balancers manually in Terraform.

## Reversibility and revisit conditions

Revisit if the Hetzner CCM no longer supports automatic load balancer provisioning, or if its licence changes from free to paid.
Revisit native routing with Hetzner once I understand it, along with its advantages and disadvantages.
