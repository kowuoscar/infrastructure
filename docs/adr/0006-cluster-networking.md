# ADR 0006: Cluster Networking

**Status:** Accepted (21 Oct 2026). Written by Oscar.

## Context

The cluster will host several applications that must be isolated from each other at the network
level. Users of a same application are isolated inside the application, through the JWT session.
Choosing a CNI is required, as it is hard to change once the cluster is up and running. The
servers' private network range is `10.0.0.0/16` (ADR 0004).

## Decision

- **CNI:** Cilium.
- **kube-proxy:** replaced by Cilium.
- **Pod network CIDR:** `10.244.0.0/16`.
- **Service network CIDR:** I kept the kubeadm default, `10.96.0.0/12`.

## Why

- Cilium enforces NetworkPolicies and provides Hubble to observe and debug traffic.
- Replacing kube-proxy with Cilium's eBPF implementation lets me learn eBPF and Kubernetes network
  internals.
- The pod and Service ranges overlap neither each other nor the servers' network.

## What I accept

- Cilium is the most complex of the three.
- Without kube-proxy, Cilium cannot reach the API through its Service IP and needs to be configured
  with the API DNS name (`k8s-api.kowulabs.com:6443`).
- Changing the CNI or the pod range in the future means rebuilding the cluster.

## Alternatives considered

- **Flannel:** rejected, it does not enforce NetworkPolicies.
- **Calico:** a good candidate, but it has no equivalent of Hubble, which I need to learn
  Kubernetes network internals.
- **Keeping kube-proxy:** rejected, Cilium's eBPF replacement is what I want to learn.

## Reversibility and revisit conditions

Revisit when Cilium no longer provides Hubble, changes its license or stops being free.
