#!/usr/bin/env bash
set -euo pipefail

NAME_PREFIX="${NAME_PREFIX:-carebridge}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-${NAME_PREFIX}-security-lab}"
CONFIRM_DELETE="${CONFIRM_DELETE:-false}"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required." >&2
  exit 1
fi

if ! az group show --name "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
  echo "Resource group ${RESOURCE_GROUP_NAME} does not exist."
  exit 0
fi

echo "Resources currently in ${RESOURCE_GROUP_NAME}:"
az resource list \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --query '[].{name:name,type:type}' \
  --output table

if [[ "${CONFIRM_DELETE}" != 'true' ]]; then
  echo
  echo "No changes made. Re-run with CONFIRM_DELETE=true to delete this exact resource group."
  exit 0
fi

az group delete \
  --name "${RESOURCE_GROUP_NAME}" \
  --yes

echo "Resource-group deletion was requested."
echo "The Key Vault uses purge protection, so its name remains reserved during the seven-day soft-delete period."
