#!/usr/bin/env bash
set -euo pipefail

EXPECTED_SUBSCRIPTION_ID="${EXPECTED_SUBSCRIPTION_ID:-}"
EXPECTED_TENANT_ID="${EXPECTED_TENANT_ID:-}"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required. Run this script from Azure Cloud Shell or install Azure CLI." >&2
  exit 1
fi

if [[ -z "${EXPECTED_SUBSCRIPTION_ID}" || -z "${EXPECTED_TENANT_ID}" ]]; then
  echo "Set EXPECTED_SUBSCRIPTION_ID and EXPECTED_TENANT_ID before running a lab script." >&2
  exit 1
fi

guid_pattern='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
if [[ ! "${EXPECTED_SUBSCRIPTION_ID}" =~ ${guid_pattern} ]]; then
  echo "EXPECTED_SUBSCRIPTION_ID must be a full subscription GUID." >&2
  exit 1
fi

if [[ ! "${EXPECTED_TENANT_ID}" =~ ${guid_pattern} ]]; then
  echo "EXPECTED_TENANT_ID must be a full tenant GUID." >&2
  exit 1
fi

if ! az account set --subscription "${EXPECTED_SUBSCRIPTION_ID}" >/dev/null 2>&1; then
  echo "The expected subscription is not available to the current Azure CLI session." >&2
  exit 1
fi

mapfile -t active_context < <(
  az account show \
    --query '[id, tenantId, state]' \
    --output tsv
)

if [[ "${#active_context[@]}" -ne 3 ]]; then
  echo "Azure CLI returned an unexpected account-context format." >&2
  exit 1
fi

active_subscription_id="${active_context[0]}"
active_tenant_id="${active_context[1]}"
active_state="${active_context[2]}"

if [[ "${active_subscription_id}" != "${EXPECTED_SUBSCRIPTION_ID}" ]]; then
  echo "Azure CLI did not select the expected subscription." >&2
  exit 1
fi

if [[ "${active_tenant_id}" != "${EXPECTED_TENANT_ID}" ]]; then
  echo "The selected subscription belongs to a different tenant than expected." >&2
  exit 1
fi

if [[ "${active_state}" != 'Enabled' ]]; then
  echo "The expected subscription is not enabled." >&2
  exit 1
fi

echo "Azure context verified: expected tenant and enabled subscription."
