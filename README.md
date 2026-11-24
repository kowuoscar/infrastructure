# Kowu Labs infrastructure

A self-managed Kubernetes cluster (kubeadm) on Hetzner Cloud, with DNS for `kowulabs.com` on Cloudflare. Everything is declared in this repository and applied by GitHub Actions: Terraform creates the servers, network, firewalls and DNS records, and Ansible turns the servers into a cluster.

## Architecture

| Node | Type | Private IP | Role |
| --- | --- | --- | --- |
| `klabs-cp-1` | cx23 (2 vCPU, 4 GB) | `10.0.1.10` | control plane, single etcd member |
| `klabs-worker-1` | cx33 (4 vCPU, 8 GB) | `10.0.1.21` | worker |
| `klabs-worker-2` | cx33 (4 vCPU, 8 GB) | `10.0.1.22` | worker |

- **Location:** `fsn1`, Ubuntu 24.04.
- **Network:** Hetzner network `klabs-network` (`10.0.0.0/16`), nodes in `10.0.1.0/24`. Kubernetes traffic stays on the private network.
- **API endpoint:** `k8s-api.kowulabs.com:6443`, a Cloudflare `A` record pointing to the control plane's private IP. Moving to three control planes only changes this record ([ADR 0004](docs/adr/0004-cluster-topology.md)).
- **Kubernetes:** 1.37, containerd 2.4 with the systemd cgroup driver.
- **CNI:** Cilium 1.20 in place of kube-proxy, pods in `10.244.0.0/16`, services in `10.96.0.0/12`, Hubble enabled ([ADR 0006](docs/adr/0006-cluster-networking.md)).
- **Cloud integration:** Hetzner CCM 1.39, kubelets started with `--cloud-provider=external`, no routes in the Hetzner network; Cilium keeps its VXLAN tunnel ([ADR 0007](docs/adr/0007-hetzner-ccm.md)).

## Repository

```
terraform/
  bootstrap/   state bucket and its access policy (applied by hand)
  dns/         Cloudflare zone and records
  cluster/     servers, network, firewalls, SSH keys
ansible/
  site.yml     private network, containerd, kubeadm, Cilium, CCM, worker join
  inventories/prod/hcloud.yml   dynamic inventory from the Hetzner API
.github/
  workflows/   plan, apply and configure pipelines
  scripts/     ci-firewall.sh
docs/adr/      architecture decisions
```

## How changes reach Prod

Only the CI changes Prod. Nothing is applied from a workstation, except `terraform/bootstrap`.

| Trigger | Workflow | What it does |
| --- | --- | --- |
| PR touching `terraform/dns` or `terraform/cluster` | `terraform-plan` | `fmt -check`, `validate`, `plan` for both roots, with read-only credentials |
| Merge to `main` touching `terraform/dns` | `terraform-apply` | applies the DNS root |
| Merge to `main` touching `terraform/cluster` | `terraform-apply-cluster` | applies the cluster root |
| Successful cluster apply, or merge touching `ansible/` | `ansible-cluster` | opens the `ci-ssh` firewall to the runner's IP, waits for cloud-init, runs `site.yml`, closes the firewall |
| Daily, 03:17 UTC | `ci-firewall-cleanup` | empties the `ci-ssh` firewall if no `ansible-cluster` run is active |

The Hetzner state bucket does not lock the state, so each apply workflow runs one job at a time and never cancels a running one ([ADR 0001](docs/adr/0001-terraform-state.md), [ADR 0003](docs/adr/0003-ci-apply.md)). Each root has its own GitHub Environment (`production`, `production-cluster`) holding only its own write credentials.

`site.yml` is idempotent: an initialised control plane or a joined worker is checked for health and skipped. A recreated server is configured again from scratch ([ADR 0005](docs/adr/0005-host-configuration.md)).

## State

All Terraform states live in the versioned bucket `klabs-state-bucket` on Hetzner Object Storage (`fsn1`), one key per root: `bootstrap/`, `dns/`, `cluster/`. The CI key has read-write access; the local key is read-only.

Check that versioning is enabled:

```shell
aws s3api get-bucket-versioning \
  --bucket klabs-state-bucket \
  --endpoint-url https://fsn1.your-objectstorage.com
```

## Access

Until hardening (M2, WireGuard), SSH reaches the servers on their public IP, by key only, from Oscar's IP (firewall `klabs-nodes`) and from the CI runner while `ansible-cluster` runs (firewall `ci-ssh`). If the home IP changes, the firewall rule is fixed through a PR: the CI does not depend on it ([ADR 0004](docs/adr/0004-cluster-topology.md)).

## Costs

Gross prices (20% VAT included), checked 24 Nov 2026: servers from the Hetzner API (`hcloud server-type describe`), Object Storage from [hetzner.com](https://www.hetzner.com/storage/object-storage/) (€6.49 net, 1 TB storage and 1 TB egress included).

| Item | €/month |
| --- | --- |
| `klabs-cp-1`, cx23 | 6.59 |
| `klabs-worker-1`, cx33 | 10.19 |
| `klabs-worker-2`, cx33 | 10.19 |
| Object Storage (state bucket) | 7.79 |
| Domain `kowulabs.com` (Namecheap, €14/year) | 1.17 |
| **Total** | **≈ 36** |

## Decisions

| ADR | Decision |
| --- | --- |
| [0001](docs/adr/0001-terraform-state.md) | Terraform state in Hetzner Object Storage, applies serialised by one CI job |
| [0002](docs/adr/0002-dns-provider.md) | Namecheap as registrar, Cloudflare as authoritative DNS |
| [0003](docs/adr/0003-ci-apply.md) | Terraform applied by GitHub Actions |
| [0004](docs/adr/0004-cluster-topology.md) | One control plane and two workers, private network, DNS API endpoint |
| [0005](docs/adr/0005-host-configuration.md) | Host configuration with Ansible, run by the CI |
| [0006](docs/adr/0006-cluster-networking.md) | Cilium as CNI, replacing kube-proxy |
| [0007](docs/adr/0007-hetzner-ccm.md) | Hetzner CCM for load balancers and node lifecycle |
| [0008](docs/adr/0008-etcd-backup.md) | Weekly etcd snapshots to an Object Lock bucket, 30-day retention |
