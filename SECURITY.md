# Security policy

This repository is a learning lab and must not contain production data or live credentials.

## Reporting a problem

Open a GitHub issue for non-sensitive problems. If a committed file appears to contain a token, secret, personal identifier, or other sensitive value, do not reproduce it in an issue. Revoke or rotate the exposed value first, then use GitHub's private vulnerability reporting feature if it is available for this repository.

## Repository rules

- Use managed identities instead of stored application credentials where supported.
- Never commit Azure access tokens, client secrets, keys, connection strings, temporary passwords, or unredacted configuration exports.
- Treat tenant IDs, subscription IDs, object IDs, email addresses, IP addresses, and billing details as sensitive portfolio data and redact them.
- Keep real evidence in `evidence/`; store unredacted working captures outside the repository.
- Run secret scanning before publishing each evidence milestone.

## Supported versions

Only the current `main` branch is maintained.
