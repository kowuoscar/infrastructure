# ADR: Terraform in CI

## Context

Finding the appropriate solution to avoid concurrent writes for Terraform applies
since Hetzner object storage doesn't support state write lock (0001-terraform-state)

## Options

- HCP Terraform **No** - The limitation for the free tier is up to 500 managed resources. This is not a solid reason to opt out from it as I am just running a personal production lab but good to know. Aside from that it adds the cost of management of another tool, new account, new credentials, new permissions instead of having everything in hetzner.
- s3 **No** - It is the strongest alternative as s3 has proven lock functionnalities. The cost is another account to manage with AWS requirements. It's possible to use the free-tier, still it would requires an AWS account, IAM permissions. The cost of management exceeds the value of the intended goal.
- pg **No** - Two issues:
    Database in Kubernetes - It is the same problem with the state files living as Secret in Kubernetes. The state files can not live in a resource they build. In case of issues, terraform can't reach out for diff, not even against old versions.
    Database in another server - cost, another server to setup and monitor outside of Terraform configuration files. The cost of management exceeds the value of the intended goal.
- Kubernetes **No** - The terraform states can not live in the same resources setting up by its files. In case, the etcd is down for example, terraform will be not able to look out for diff for reconciliation.

## Chosen Solution: GitHub Actions

- A GitHub Action that plan on pull requests.
- A GitHub Action (workflow) that runs on apply against main.
- Secrets will live in the repository as GitHub environments variables only accessible by the main branch. This will ensure that pull request branches or workflows can not access the read-write token permissions.
- Only one job is allowed to run at a time with enabled concurrency and cancel-in-progress set to false. Every run should finish before the next one kicks in since they hold different changes.
- **Cost**
    - Dependency to GitHub features (actions and concurrency)
    - It doesn't really prevent from the local applies if the engineer is in possession of the read-write token but sets up the ground for a software factory approach

## Impacts

- This requires setting up a read-write token permission for Hetzner object storage. 
- This also requires a read-write token permission for Cloudflare for DNS related changes.
- Read-only permission for local setup to prevent apply mistakes

- Verified [2026-10-11] - Hetzner read-only permission is configurable and works as expected.
It is done by defining a second project that holds the credentials and adding a policy on the bucket
that hold the state in a different project.
NB - During the test phase, we notice Hetzner sends an empty message which aws cli fails to understand and prints NoneType.Evaluating it requires to add debug to read the HTTP code status and understand the root reason.
Another good to know - the current credentials is still needed for bootstrap (required for adding policies, deleting files)
It will be stored in a password manager outside of my mac and used only in case of needs.

## Revisited

The reasons that allows to revisit this ADR are:
- Hetzner supports terraform state locks
- Another engineer join the projects (local token)