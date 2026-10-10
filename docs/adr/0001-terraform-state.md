# ADR: Terraform State Location

## Context

Choosing the terraform strategy to setup the infrastructure on Hetzner.

## Decision

**The state lives remotely in an object storage**
The state contains secrets information that cannot be shared in the Git repository or Git history for security reasons. Also it prevents against the state not being updated in case an apply is executed locally by an engineer.

**FIRST APPROACH: Hetzner supports for conditional writes and file lock**
The test to realize is to use the expected format and make sure that when executing an apply followed by a plan, the lock is acquired by the apply and the plan fails with 412 Precondition Failed.

**FALLBACK: State serialization in the CI**
If Hetzner doesn't support the use_lockfile that enables locking the state file and preventing concurrent writes, the fallback would be to use GitHub Actions:
- The state file would still live in Hetzner.
- The pipeline would be the sole owner of the write permission against the storage.
- Enable GitHub Actions concurrent feature to prevent multiple apply jobs.
- Local engineers would only have read permission against the storage.

## Consequences

- Make sure to delete the local state file after the boostrap.
Terraform is used to bootstrap the whole infrastructure as well as the bucket. That being said, the bucket configuration lives in its own directory separated from the rest of the infrastructure. The first state is local before being moved to the bucket with `-migrate-state`. The local state needs to be deleted after that.
- Storage keys permissions - Write for the pipeline and read for engineers with `plan -lock=false`

This ADR will be revised after the first test result on the FIRST APPROACH.

## Option A: Tests results

Here's the scenario that was tested:

1. Add a minor change against a terraform file (`bootstrap/minio.tf`): adding a tag
2. Terminal 1: Execute `terraform apply` and stop when prompted for yes or no
```shell
aws s3api head-object \
    --bucket klabs-state-bucket \
    --key bootstrap/terraform.tfstate.tflock \
    --endpoint-url https://fsn1.your-objectstorage.com
```
3. Terminal 2 - Request against the bucket to validate a locking file is in place by the apply command.
4. Terminal 2 - Execute `terraform plan` and expect a locking error.

The result is that despite the locking file is created when using `terraform apply`, the second `plan` command still passed
ovewriting the lock that was in place. The `use_lockfile` is therefore not necessary.

**Conclusion: Option B for apply changes against the state with one CI job.**