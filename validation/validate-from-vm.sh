#!/usr/bin/env bash
set -euo pipefail

KEY_VAULT_NAME='__KEY_VAULT_NAME__'
STORAGE_ACCOUNT_NAME='__STORAGE_ACCOUNT_NAME__'
MANAGED_IDENTITY_CLIENT_ID='__MANAGED_IDENTITY_CLIENT_ID__'
KEY_VAULT_HOST="${KEY_VAULT_NAME}.vault.azure.net"
STORAGE_HOST="${STORAGE_ACCOUNT_NAME}.blob.core.windows.net"
IMDS_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'

temporary_directory="$(mktemp -d)"
cleanup_temporary_files() {
  rm -rf "${temporary_directory:?}"
}
trap cleanup_temporary_files EXIT

echo "validation_started_utc=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

if getent ahostsv4 "${KEY_VAULT_HOST}" | awk '{print $1}' | grep -q '^10\.20\.2\.'; then
  echo 'key_vault_private_dns=true'
else
  echo 'key_vault_private_dns=false'
  exit 1
fi

if getent ahostsv4 "${STORAGE_HOST}" | awk '{print $1}' | grep -q '^10\.20\.2\.'; then
  echo 'storage_private_dns=true'
else
  echo 'storage_private_dns=false'
  exit 1
fi

key_vault_token_response="$(
  curl --fail --silent --show-error --noproxy '*' \
    --header 'Metadata: true' \
    "${IMDS_ENDPOINT}?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net&client_id=${MANAGED_IDENTITY_CLIENT_ID}"
)"
key_vault_token="$(
  printf '%s' "${key_vault_token_response}" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["access_token"])'
)"
key_vault_authorization_header="${temporary_directory}/key-vault-authorization-header"
printf 'Authorization: Bearer %s\n' "${key_vault_token}" > "${key_vault_authorization_header}"
chmod 600 "${key_vault_authorization_header}"
unset key_vault_token key_vault_token_response
echo 'managed_identity_key_vault_token=true'

key_vault_response_file="${temporary_directory}/key-vault-response.json"
key_vault_status="$(
  curl --silent --show-error --noproxy '*' \
    --output "${key_vault_response_file}" \
    --write-out '%{http_code}' \
    --header "@${key_vault_authorization_header}" \
    "https://${KEY_VAULT_HOST}/secrets/lab-marker?api-version=7.4"
)"
echo "key_vault_secret_read_status=${key_vault_status}"

if [[ "${key_vault_status}" != '200' ]]; then
  exit 1
fi

secret_name="$(
  python3 -c \
    'import json, sys; print(json.load(open(sys.argv[1]))["id"].rstrip("/").split("/")[-2])' \
    "${key_vault_response_file}"
)"

if [[ "${secret_name}" != 'lab-marker' ]]; then
  echo 'key_vault_expected_secret=false'
  exit 1
fi
echo 'key_vault_expected_secret=true'

storage_token_response="$(
  curl --fail --silent --show-error --noproxy '*' \
    --header 'Metadata: true' \
    "${IMDS_ENDPOINT}?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F&client_id=${MANAGED_IDENTITY_CLIENT_ID}"
)"
storage_token="$(
  printf '%s' "${storage_token_response}" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["access_token"])'
)"
storage_authorization_header="${temporary_directory}/storage-authorization-header"
printf 'Authorization: Bearer %s\n' "${storage_token}" > "${storage_authorization_header}"
chmod 600 "${storage_authorization_header}"
unset storage_token storage_token_response
echo 'managed_identity_storage_token=true'

storage_response_file="${temporary_directory}/storage-list-response.xml"
storage_status="$(
  curl --silent --show-error --noproxy '*' \
    --output "${storage_response_file}" \
    --write-out '%{http_code}' \
    --header "@${storage_authorization_header}" \
    --header 'x-ms-version: 2023-11-03' \
    "https://${STORAGE_HOST}/private-data?restype=container&comp=list"
)"
echo "storage_private_container_list_status=${storage_status}"

if [[ "${storage_status}" != '200' ]]; then
  exit 1
fi

echo 'storage_expected_container=true'

denied_write_response_file="${temporary_directory}/storage-denied-write-response.xml"
storage_write_status="$(
  curl --silent --show-error --noproxy '*' \
    --request PUT \
    --output "${denied_write_response_file}" \
    --write-out '%{http_code}' \
    --header "@${storage_authorization_header}" \
    --header 'Content-Length: 0' \
    --header 'x-ms-blob-type: BlockBlob' \
    --header "x-ms-date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')" \
    --header 'x-ms-version: 2023-11-03' \
    "https://${STORAGE_HOST}/private-data/denied-write-probe.txt"
)"
echo "storage_blob_write_denied_status=${storage_write_status}"

if [[ "${storage_write_status}" != '403' ]]; then
  echo 'least_privilege_denied_write=false'
  exit 1
fi

echo 'least_privilege_denied_write=true'
echo 'validation_result=PASS'
