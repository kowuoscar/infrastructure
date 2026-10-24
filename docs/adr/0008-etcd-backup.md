# ADR 0008: etcd Backup

**Status:** Accepted (25 Oct 2026). Decisions by Oscar, written by Claude from his interview.

## Context

etcd is the cluster's database. The cluster runs a single etcd member (ADR 0004): with one member the
quorum is 1, so it tolerates no loss (n − quorum = 0), and losing the disk of `klabs-cp-1` loses the
cluster's state. Everything else (servers, host configuration, Cilium, the CCM) is rebuilt from Git;
what exists only in etcd is not. A snapshot contains every Secret in plain text, the `hcloud` token
included (ADR 0007). M3 requires a backup and a proven restore.

## Decision

- **Tool:** a systemd timer on `klabs-cp-1`, installed by Ansible. It runs `etcdctl snapshot save`
  and uploads the snapshot.
- **Storage:** a dedicated Hetzner Object Storage bucket, created with Object Lock in `COMPLIANCE`
  mode. Object Lock relies on bucket versioning.
- **Write access:** a key from the credentials project (as for the CI, ADR 0003), granted only
  `s3:PutObject` on this bucket by a bucket policy. It has no access to the Terraform state bucket.
- **Read access:** the CI, with a read-only key stored as a GitHub Environment secret. The CI reads
  the snapshot and restores it over SSH.
- **Frequency:** once a week (RPO of 7 days).
- **Retention:** 30 days, applied by the bucket's lifecycle rules. The Object Lock retention is
  equal to the retention: 30 days.

## Why

- A Kubernetes CronJob would depend on the cluster it backs up. The timer depends only on the
  server.
- Two layers protect the snapshots. The `PutObject`-only permission protects against a leak of the
  server's key. Object Lock in `COMPLIANCE` mode protects against a leak of any key, including the
  bootstrap key that has every right on the project: the protection is in the bucket, not in the
  keys.
- With versioning alone, a key holding `s3:DeleteObjectVersion` deletes every snapshot.
- A lock equal to the retention protects each snapshot for its whole life. A shorter lock leaves it
  unprotected until the lifecycle deletes it; a longer one keeps it, and its secrets, beyond the
  retention.
- The cluster holds no state that is not in Git yet, so a weekly snapshot is enough. Without alerts,
  a problem is found late, hence 30 days of retention.

## What I accept

- Up to 7 days of changes are lost when `klabs-cp-1` dies.
- A failing timer warns no one. Until M6 brings alerts, a broken backup can go unnoticed for weeks.
- A secret in a snapshot stays readable until its lock ends; rotating the secret is the only remedy.
- A wrong lock duration cannot be corrected: `COMPLIANCE` mode cannot be ended early.
- The CI read key reads every snapshot, so every secret they contain. A restore goes through a
  shared runner, and the Actions logs are public.
- The server holds an S3 key on its disk.

## Alternatives considered

- **Kubernetes CronJob:** rejected, the backup depends on the cluster it backs up.
- **Scheduled GitHub workflow pulling the snapshot over SSH:** no S3 key on the server, but the
  routine backup would depend on GitHub and its runners (outages, delayed schedules, schedules
  disabled after 60 days without activity on a public repository). The `ci-ssh` firewall rule, the
  SSH root key and a file holding every secret would be exposed every week instead of on the rare
  restore.
- **Versioning without Object Lock:** rejected, it protects only against the keys whose permissions
  are restricted.

## Reversibility and revisit conditions

Revisit the frequency once the cluster carries traffic, and the retention and the silent failure
once M6 brings alerts. Revisit which node takes the snapshot if the cluster moves to three control
planes (ADR 0004). `COMPLIANCE` mode cannot be undone: changing it means a new bucket.
