# ADR 0005: Host configuration with Ansible, run by the CI (M3)

**Status:** Accepted (15 Oct 2026). Drafted by Claude from the interview, validated by Oscar.

## Context

M3 installs Kubernetes with kubeadm on the three servers created in M1. Something has to install
containerd and kubeadm on them, and do it again every time Terraform recreates a server: M1 proved
that a destroy/apply returns fresh Ubuntu servers with nothing on them.

The route had M2 (hardened hosts, WireGuard) before M3. M2 is moved after M4, so today SSH on the
public IP, allowed from my home IP only, is the only way into the servers (ADR 0004). Only the CI
changes production (ADR 0001, ADR 0003). The repository is public and the GitHub account is on the
Free plan.

## Decision

- **Tool:** Ansible, run in push mode over SSH.
- **Where it runs:** in the CI, on GitHub-hosted runners, like Terraform.
- **How the runner reaches port 22:** a second Hetzner firewall, dedicated to the CI and attached to
  every server by Terraform; Terraform does not manage its rules. At the start of each run, the job
  **replaces** all the rules of that firewall with a single one: TCP 22 from the runner's own IP. At
  the end, it removes it, even when the run failed.
- **When it runs:**
  - automatically right after a `terraform apply` on `cluster`, so recreated servers are configured;
  - when the configuration changes.
  Ansible is idempotent: running it on a server that is already configured changes nothing, so a
  run after every apply is safe.
- **Cleanup:** a scheduled job empties the CI firewall once a day, independently of Ansible.
- **Secrets:** the Hetzner Cloud token (to edit the CI firewall) and the SSH private key live in the
  `production-cluster` Environment, which only `main` can use.

## Why

- I want to learn Ansible.
- Running from the CI keeps one rule for every change to production, as for Terraform.
- It costs nothing: no extra server.
- Pull requests from forks cannot reach the servers. GitHub never passes secrets to `pull_request`
  workflows from a fork, and the Environment only accepts `main`. Without the Hetzner token and the
  SSH key, a modified workflow can neither open the firewall nor log in. The `pull_request_target`
  trigger, which runs with secrets, is never used in this repository.

## What I accept

- If the step that removes the rule fails (Hetzner API down, cancelled job), port 22 stays open to
  a GitHub runner IP until the next Ansible run replaces the rules, or at most until the daily
  cleanup.
- The CI holds an SSH key with root access to every server, in addition to the Hetzner token that
  can already delete them.
- Two tools run in sequence on each change to `cluster`: Terraform, then Ansible.

## Alternatives considered

- **Self-hosted runner in the private network** (the usual setup in companies): rejected. On a
  public repository, a pull request from a fork can rewrite the workflow to target that runner and
  run code inside the private network. Making the repository private would remove the
  Environments, and the main-only protection with them, because the Free plan does not offer them
  on private repositories. It would also cost an extra server.
- **Cloud-init (`user_data` in Terraform):** not chosen, because I want to learn Ansible.
- **Port 22 open to the whole Internet:** GitHub's runner IP ranges are thousands of Azure ranges,
  so allowing them is almost the same as opening to everyone.
- **WireGuard for the runner:** needs the M2 work, which is moved after M4.
- **Pull mode (`ansible-pull` on each node):** no port to open, but no error report in the CI
  and only half of Ansible to learn.
- **Managing the CI firewall rules in Terraform**, so that an apply removes a forgotten rule:
  rejected. The apply only runs when `terraform/cluster` changes, which can take weeks, and an apply
  that overlaps an Ansible run would remove the rule that run is using.

## Reversibility and revisit conditions

Revisit when M2 brings WireGuard: the runner would reach the servers through the tunnel, the CI
firewall and public port 22 would go away, and the playbooks would stay the same.
