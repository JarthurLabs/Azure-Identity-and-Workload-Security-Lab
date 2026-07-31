#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME_PREFIX="${NAME_PREFIX:-carebridge}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-${NAME_PREFIX}-security-lab}"
CONFIRM_VM_NAME="${CONFIRM_VM_NAME:-}"

"${REPOSITORY_ROOT}/scripts/verify-azure-context.sh"

resource_group_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.resourceGroupName.value' --output tsv)"
virtual_machine_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.virtualMachineName.value' --output tsv)"
operating_system_disk_id="$(
  az vm show \
    --resource-group "${resource_group_name}" \
    --name "${virtual_machine_name}" \
    --query 'storageProfile.osDisk.managedDisk.id' \
    --output tsv
)"
network_interface_id="$(
  az vm show \
    --resource-group "${resource_group_name}" \
    --name "${virtual_machine_name}" \
    --query 'networkProfile.networkInterfaces[0].id' \
    --output tsv
)"
operating_system_disk_name="${operating_system_disk_id##*/}"
network_interface_name="${network_interface_id##*/}"

echo "Temporary validation VM: ${resource_group_name}/${virtual_machine_name}"

if [[ "${CONFIRM_VM_NAME}" != "${virtual_machine_name}" ]]; then
  echo "No changes made. Re-run with CONFIRM_VM_NAME=${virtual_machine_name} after evidence collection."
  exit 0
fi

az vm delete \
  --resource-group "${resource_group_name}" \
  --name "${virtual_machine_name}" \
  --yes

if az vm show --resource-group "${resource_group_name}" --name "${virtual_machine_name}" >/dev/null 2>&1; then
  echo "The validation VM still exists after the deletion command." >&2
  exit 1
fi

if az disk show --resource-group "${resource_group_name}" --name "${operating_system_disk_name}" >/dev/null 2>&1; then
  echo "The validation VM was deleted, but its operating-system disk still exists." >&2
  exit 1
fi

if az network nic show --resource-group "${resource_group_name}" --name "${network_interface_name}" >/dev/null 2>&1; then
  echo "The validation VM was deleted, but its network interface still exists." >&2
  exit 1
fi

echo "Validated deletion of the temporary VM, operating-system disk, and network interface."
