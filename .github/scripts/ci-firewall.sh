#!/usr/bin/env bash
# Replaces every rule of the CI firewall (ADR 0005). Terraform creates and attaches it but ignores
# its rules: they belong to the CI.
#
#   ci-firewall.sh open <ipv4>   one rule only: TCP 22 from that address
#   ci-firewall.sh close         no rule at all
#
# Needs HCLOUD_TOKEN. Returns once Hetzner has applied the rules to every server.
set -euo pipefail

FIREWALL_NAME="ci-ssh"
API="https://api.hetzner.cloud/v1"

api() {
  local method=$1 path=$2
  shift 2
  curl -fsS -X "$method" \
    -H "Authorization: Bearer ${HCLOUD_TOKEN:?HCLOUD_TOKEN is not set}" \
    -H "Content-Type: application/json" \
    "$@" "${API}${path}"
}

case "${1:-}" in
  open)
    ip=${2:?usage: ci-firewall.sh open <ipv4>}
    rules=$(jq -nc --arg ip "${ip}/32" --arg desc "GitHub Actions run ${GITHUB_RUN_ID:-manual}" \
      '[{direction: "in", protocol: "tcp", port: "22", source_ips: [$ip], description: $desc}]')
    ;;
  close)
    rules='[]'
    ;;
  *)
    echo "usage: ci-firewall.sh open <ipv4> | close" >&2
    exit 2
    ;;
esac

firewall_id=$(api GET "/firewalls?name=${FIREWALL_NAME}" | jq -er '.firewalls[0].id')

action_ids=$(api POST "/firewalls/${firewall_id}/actions/set_rules" \
  --data "$(jq -nc --argjson rules "$rules" '{rules: $rules}')" | jq -r '.actions[].id')

# set_rules is asynchronous: wait until the rules are live on every server.
for id in $action_ids; do
  status=running
  for _ in $(seq 1 60); do
    status=$(api GET "/actions/${id}" | jq -r '.action.status')
    case "$status" in
      success) break ;;
      error)
        echo "Hetzner action ${id} failed" >&2
        exit 1
        ;;
    esac
    sleep 2
  done
  if [ "$status" != success ]; then
    echo "Hetzner action ${id} still ${status} after 120s" >&2
    exit 1
  fi
done

echo "${FIREWALL_NAME}: $1 applied"
