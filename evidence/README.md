# Evidence index

This directory contains proof from the real Azure and Microsoft Entra lab. Files are added only after validation.

## Evidence register

| ID | Control or test | Source | Captured (UTC) | Status | Artifact |
|---|---|---|---|---|---|
| P-01 | Azure subscription precheck | Azure portal | 2026-07-31 04:53 | Blocked: zero subscriptions | [`P-01-no-azure-subscription.jpg`](screenshots/P-01-no-azure-subscription.jpg) |
| P-02 | Entra directory write precheck | Entra admin center | 2026-07-31 04:54 | Blocked: HTTP 401 | [`P-02-entra-group-access-denied.jpg`](screenshots/P-02-entra-group-access-denied.jpg) |
| P-03 | Alternate-account tenant precheck | Azure portal / Entra sign-in | 2026-07-31 05:44 | Blocked: no subscription or tenant membership | [`prerequisite-check.md`](exports/prerequisite-check.md) |
| E-01 | Tenant capability and license check | Entra admin center / Microsoft Graph | — | Pending | — |
| E-02 | Lab groups and membership | Entra admin center / Microsoft Graph | — | Pending | — |
| E-03 | Conditional Access safety review | Entra admin center | — | License-dependent | — |
| E-04 | Azure resource inventory | Azure CLI | — | Pending | — |
| E-05 | Managed identity and scoped RBAC | Azure CLI / Azure portal | — | Pending | — |
| E-06 | Private data-plane configuration | Azure CLI / Azure portal | — | Pending | — |
| E-07 | Managed-identity allowed reads and denied write | Validation workload logs | — | Pending | — |
| E-08 | Diagnostic query result | Log Analytics | — | Pending | — |
| E-09 | Defender for Cloud or Policy review | Azure portal | — | Pending | — |
| E-10 | Cleanup and retained-resource check | Azure CLI | — | Pending | — |

## Directory layout

- `screenshots/` — cropped JPG or PNG captures from Microsoft portals or the validation workload.
- `exports/` — sanitized text or JSON exported from Azure CLI, Microsoft Graph, or Log Analytics.

## Redaction standard

Remove or mask:

- tenant, subscription, principal, and object IDs;
- personal email addresses and account names;
- public or private IP addresses;
- access tokens, secrets, keys, connection strings, and temporary passwords;
- billing data and unrelated tenant or subscription names.

Lab-only resource names may remain when they do not expose a person or organization.

Each artifact must state:

1. what produced it;
2. when it was captured in UTC;
3. what security claim it supports;
4. what was redacted; and
5. whether it shows configuration, an allowed test, a denied test, or cleanup.

Screenshots are supporting evidence. Sanitized configuration exports and repeatable commands are preferred where possible.

The automated evidence scan checks text files for common identifiers but cannot read text embedded in images. Every screenshot therefore receives a separate manual visual review before publication.
