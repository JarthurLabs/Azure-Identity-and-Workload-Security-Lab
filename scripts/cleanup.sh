#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME_PREFIX="${NAME_PREFIX:-carebridge}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-${NAME_PREFIX}-security-lab}"
CONFIRM_RESOURCE_GROUP_NAME="${CONFIRM_RESOURCE_GROUP_NAME:-}"

"${REPOSITORY_ROOT}/scripts/verify-azure-context.sh"

if ! az group show --name "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
  echo "Resource group ${RESOURCE_GROUP_NAME} does not exist."
  exit 0
fi

mapfile -t resource_group_tags < <(
  az group show \
    --name "${RESOURCE_GROUP_NAME}" \
    --query '[tags.purpose, tags.managedBy, tags.environment]' \
    --output tsv
)

if [[ "${#resource_group_tags[@]}" -ne 3 ]]; then
  echo "Azure CLI returned an unexpected resource-group tag format. Refusing cleanup." >&2
  exit 1
fi

purpose_tag="${resource_group_tags[0]}"
managed_by_tag="${resource_group_tags[1]}"
environment_tag="${resource_group_tags[2]}"

if [[ "${purpose_tag}" != 'identity-workload-security-lab' ||
      "${managed_by_tag}" != 'bicep' ||
      "${environment_tag}" != 'training' ]]; then
  echo "Resource-group ownership tags do not match this lab. Refusing cleanup." >&2
  exit 1
fi

echo "Resources currently in ${RESOURCE_GROUP_NAME}:"
az resource list \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --query '[].{name:name,type:type}' \
  --output table

if [[ "${CONFIRM_RESOURCE_GROUP_NAME}" != "${RESOURCE_GROUP_NAME}" ]]; then
  echo
  echo "No changes made. Re-run with CONFIRM_RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME} to delete this exact lab resource group."
  exit 0
fi

az group delete \
  --name "${RESOURCE_GROUP_NAME}" \
  --yes

if [[ "$(az group exists --name "${RESOURCE_GROUP_NAME}")" == 'true' ]]; then
  echo "The resource group still exists after the deletion command." >&2
  exit 1
fi

echo "Validated resource-group deletion."
echo "The Key Vault uses purge protection, so its name remains reserved during the seven-day soft-delete period."
