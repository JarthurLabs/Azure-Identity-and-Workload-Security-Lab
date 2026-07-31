#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY="${APPLY:-false}"

"${REPOSITORY_ROOT}/scripts/verify-azure-context.sh"

groups=(
  'SG-LAB-CA-Pilot'
  'SG-LAB-Resource-Readers'
  'SG-LAB-Security-Reviewers'
)

for display_name in "${groups[@]}"; do
  existing_group_id="$(
    az ad group list \
      --filter "displayName eq '${display_name}'" \
      --query '[0].id' \
      --output tsv
  )"

  if [[ -n "${existing_group_id}" ]]; then
    echo "Exists: ${display_name}"
    continue
  fi

  if [[ "${APPLY}" != 'true' ]]; then
    echo "Would create: ${display_name}"
    continue
  fi

  mail_nickname="$(printf '%s' "${display_name}" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')"
  az ad group create \
    --display-name "${display_name}" \
    --mail-nickname "${mail_nickname}" \
    --query '{displayName:displayName}' \
    --output json
done

if [[ "${APPLY}" != 'true' ]]; then
  echo
  echo "Dry run complete. Re-run with APPLY=true to create missing groups."
fi
