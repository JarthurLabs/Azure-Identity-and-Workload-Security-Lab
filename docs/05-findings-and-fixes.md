# Findings and fixes

This file will contain only issues observed in the live lab. Planned “mistakes” are not written as completed work.

## Finding template

### F-XX — Short title

- **Observed (UTC):**
- **Expected:**
- **Actual:**
- **Evidence:**
- **Root cause:**
- **Change:**
- **Retest:**
- **Lesson:**
- **Remaining limitation:**

## Recorded findings

### F-01 — Portal access did not include an Azure subscription

- **Observed (UTC):** 2026-07-31 04:53.
- **Expected:** the signed-in account would expose a lab subscription for the Bicep what-if and deployment.
- **Actual:** the Azure subscriptions grid showed zero subscriptions.
- **Evidence:** [`P-01-no-azure-subscription.jpg`](../evidence/screenshots/P-01-no-azure-subscription.jpg).
- **Root cause:** a Microsoft account and Entra directory existed, but no Azure billing subscription was associated with the signed-in directory.
- **Change:** activate an eligible Azure subscription or switch to an existing directory that contains one.
- **Retest:** pending. The Bicep build and what-if will not be represented as a live Azure validation until `az account show` returns an enabled subscription.
- **Lesson:** signing in to the Azure portal proves identity access, not access to an Azure subscription.
- **Remaining limitation:** no SC-500 workload resource can be deployed.

### F-02 — Current directory principal could not create groups

- **Observed (UTC):** 2026-07-31 04:54.
- **Expected:** create the three lab security groups in the free Entra directory.
- **Actual:** selecting **New group** returned **You don't have access** and HTTP status 401.
- **Evidence:** [`P-02-entra-group-access-denied.jpg`](../evidence/screenshots/P-02-entra-group-access-denied.jpg).
- **Root cause:** the signed-in principal does not currently have a directory role that permits group creation. The reason for that directory-role state has not been confirmed.
- **Change:** use an owned training directory where the account has an appropriate administrator role. Do not add a broad role to an unrelated directory solely to complete the portfolio lab.
- **Retest:** pending. Confirm group creation in the intended training directory before creating pilot members or policies.
- **Lesson:** portal visibility and directory write authority are separate checks.
- **Remaining limitation:** group administration, Conditional Access, PIM, and access-review evidence cannot be produced in the current directory.
