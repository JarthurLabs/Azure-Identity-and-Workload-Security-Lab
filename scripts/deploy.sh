#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCATION="${LOCATION:-eastus}"
NAME_PREFIX="${NAME_PREFIX:-carebridge}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-${NAME_PREFIX}-security-lab}"
APPLY="${APPLY:-false}"
RESOURCE_GROUP_NAME="rg-${NAME_PREFIX}-security-lab"

for required_command in az ssh-keygen openssl sed; do
  if ! command -v "${required_command}" >/dev/null 2>&1; then
    echo "Required command is unavailable: ${required_command}" >&2
    exit 1
  fi
done

"${REPOSITORY_ROOT}/scripts/verify-azure-context.sh"

required_resource_providers=(
  'Microsoft.Authorization'
  'Microsoft.Compute'
  'Microsoft.Insights'
  'Microsoft.KeyVault'
  'Microsoft.ManagedIdentity'
  'Microsoft.Network'
  'Microsoft.OperationalInsights'
  'Microsoft.Storage'
)
unregistered_resource_providers=()

for resource_provider in "${required_resource_providers[@]}"; do
  registration_state="$(
    az provider show \
      --namespace "${resource_provider}" \
      --query registrationState \
      --output tsv 2>/dev/null || true
  )"

  if [[ "${registration_state}" != 'Registered' ]]; then
    unregistered_resource_providers+=("${resource_provider}")
  fi
done

if (( "${#unregistered_resource_providers[@]}" > 0 )); then
  echo "Required Azure resource providers are not registered:" >&2
  printf '  - %s\n' "${unregistered_resource_providers[@]}" >&2
  echo "Register them deliberately, wait for completion, and rerun the preview." >&2
  exit 1
fi

if [[ ! "${NAME_PREFIX}" =~ ^[a-z][a-z0-9]{2,11}$ ]]; then
  echo "NAME_PREFIX must be 3-12 lowercase letters or digits and start with a letter." >&2
  exit 1
fi

if [[ "$(az group exists --name "${RESOURCE_GROUP_NAME}")" == 'true' ]]; then
  echo "Resource group ${RESOURCE_GROUP_NAME} already exists. Stop and inspect it before deploying." >&2
  exit 1
fi

temporary_directory="$(mktemp -d)"
cleanup_temporary_files() {
  rm -rf "${temporary_directory:?}"
}
trap cleanup_temporary_files EXIT

ssh-keygen -q -t ed25519 -N '' \
  -C 'carebridge-security-lab-temporary' \
  -f "${temporary_directory}/id_ed25519"

admin_ssh_public_key="$(<"${temporary_directory}/id_ed25519.pub")"
lab_marker_value="$(openssl rand -hex 24)"

echo "Building the Bicep template..."
az bicep build \
  --file "${REPOSITORY_ROOT}/infra/main.bicep" \
  --outfile "${temporary_directory}/main.json"

echo "Previewing subscription-scope changes in ${LOCATION}..."
az deployment sub what-if \
  --name "${DEPLOYMENT_NAME}" \
  --location "${LOCATION}" \
  --template-file "${REPOSITORY_ROOT}/infra/main.bicep" \
  --parameters \
    namePrefix="${NAME_PREFIX}" \
    adminSshPublicKey="${admin_ssh_public_key}" \
    labMarkerValue="${lab_marker_value}"

if [[ "${APPLY}" != 'true' ]]; then
  echo
  echo "What-if completed. Re-run with APPLY=true to create the lab."
  exit 0
fi

echo "Deploying the lab..."
az deployment sub create \
  --name "${DEPLOYMENT_NAME}" \
  --location "${LOCATION}" \
  --template-file "${REPOSITORY_ROOT}/infra/main.bicep" \
  --parameters \
    namePrefix="${NAME_PREFIX}" \
    adminSshPublicKey="${admin_ssh_public_key}" \
    labMarkerValue="${lab_marker_value}" \
  --query properties.outputs \
  --output json

echo
echo "Deployment completed. Run scripts/validate.sh before collecting evidence."
