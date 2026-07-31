#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCATION="${LOCATION:-eastus}"
NAME_PREFIX="${NAME_PREFIX:-carebridge}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-${NAME_PREFIX}-security-lab}"
APPLY="${APPLY:-false}"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required. Run this script from Azure Cloud Shell or install Azure CLI." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "No active Azure CLI session. Run 'az login' first." >&2
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
