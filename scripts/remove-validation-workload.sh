#!/usr/bin/env bash
set -euo pipefail

NAME_PREFIX="${NAME_PREFIX:-carebridge}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-${NAME_PREFIX}-security-lab}"
CONFIRM_DELETE="${CONFIRM_DELETE:-false}"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required." >&2
  exit 1
fi

resource_group_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.resourceGroupName.value' --output tsv)"
virtual_machine_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.virtualMachineName.value' --output tsv)"

echo "Temporary validation VM: ${resource_group_name}/${virtual_machine_name}"

if [[ "${CONFIRM_DELETE}" != 'true' ]]; then
  echo "No changes made. Re-run with CONFIRM_DELETE=true after evidence collection."
  exit 0
fi

az vm delete \
  --resource-group "${resource_group_name}" \
  --name "${virtual_machine_name}" \
  --yes

echo "The validation VM, OS disk, and network interface were requested for deletion."
