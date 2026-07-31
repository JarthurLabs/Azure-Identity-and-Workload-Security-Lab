#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME_PREFIX="${NAME_PREFIX:-carebridge}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-${NAME_PREFIX}-security-lab}"

"${REPOSITORY_ROOT}/scripts/verify-azure-context.sh"

resource_group_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.resourceGroupName.value' --output tsv)"
virtual_machine_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.virtualMachineName.value' --output tsv)"
key_vault_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.keyVaultName.value' --output tsv)"
storage_account_name="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.storageAccountName.value' --output tsv)"
managed_identity_client_id="$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query 'properties.outputs.managedIdentityClientId.value' --output tsv)"

temporary_script="$(mktemp)"
cleanup_temporary_script() {
  rm -f "${temporary_script:?}"
}
trap cleanup_temporary_script EXIT

sed \
  -e "s/__KEY_VAULT_NAME__/${key_vault_name}/g" \
  -e "s/__STORAGE_ACCOUNT_NAME__/${storage_account_name}/g" \
  -e "s/__MANAGED_IDENTITY_CLIENT_ID__/${managed_identity_client_id}/g" \
  "${REPOSITORY_ROOT}/validation/validate-from-vm.sh" > "${temporary_script}"

echo "Running the private-path test through Azure VM Run Command..."
az vm run-command invoke \
  --resource-group "${resource_group_name}" \
  --name "${virtual_machine_name}" \
  --command-id RunShellScript \
  --scripts "@${temporary_script}" \
  --query 'value[0].message' \
  --output tsv

echo
echo "Review the output before adding a sanitized copy to evidence/exports/."
