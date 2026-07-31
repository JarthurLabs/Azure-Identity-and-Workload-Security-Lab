#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_ROOT="${REPOSITORY_ROOT}/evidence"

mapfile -t evidence_files < <(
  find "${EVIDENCE_ROOT}" -type f \
    ! -name 'README.md' \
    ! -path '*/raw/*' \
    -print
)

if [[ "${#evidence_files[@]}" -eq 0 ]]; then
  echo 'No committed evidence files to scan yet.'
  exit 0
fi

patterns=(
  '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
  '([0-9]{1,3}\.){3}[0-9]{1,3}'
  '(AccountKey|client_secret|access_token|refresh_token)[[:space:]]*[:=]'
)

scan_failed=false
for pattern in "${patterns[@]}"; do
  if grep --extended-regexp --ignore-case --line-number \
    --binary-files=without-match "${pattern}" "${evidence_files[@]}"; then
    scan_failed=true
  fi
done

if [[ "${scan_failed}" == 'true' ]]; then
  echo 'Potential sensitive value found in committed evidence.' >&2
  exit 1
fi

echo 'Evidence redaction scan passed.'
