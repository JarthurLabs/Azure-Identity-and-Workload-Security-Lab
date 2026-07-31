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
- **Retest:** passed on 2026-07-31. The replacement training subscription returned Enabled and the signed-in account held Owner; see F-04.
- **Lesson:** signing in to the Azure portal proves identity access, not access to an Azure subscription.
- **Remaining limitation:** the original missing-subscription blocker is resolved; provider readiness is tracked separately in F-05.

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

### F-03 — Alternate Microsoft account was not a member of the tested tenant

- **Observed (UTC):** 2026-07-31 05:44.
- **Expected:** the alternate account would expose an enabled Azure subscription and an owned Entra training directory.
- **Actual:** Azure showed zero subscriptions and no alternate directories. Microsoft Entra then reported that the selected account did not exist in the tested tenant and would need to be added as an external user.
- **Evidence:** sanitized portal observations in [`prerequisite-check.md`](../evidence/exports/prerequisite-check.md).
- **Root cause:** Microsoft account authentication did not establish Azure subscription ownership or membership in the existing Entra tenant.
- **Change:** use an account that already owns an enabled training subscription and directory, or complete subscription setup under the intended alternate account before retesting.
- **Retest:** pending. Verify an enabled subscription, the intended tenant ID, and an appropriate directory role before running any deployment or group-creation command.
- **Lesson:** a second authenticated account is not automatically a second Azure environment. Account identity, tenant membership, directory authorization, and subscription access require separate checks.
- **Remaining limitation:** this alternate-account attempt remained blocked. A later active subscription resolved the workload subscription prerequisite, but provider readiness and Entra authorization still require separate retests.

### F-04 — Azure CLI TSV parsing caused a false tenant mismatch

- **Observed (UTC):** 2026-07-31 06:49.
- **Expected:** the context guardrail would accept the active subscription when its IDs and state matched the pinned values.
- **Actual:** the script reported a tenant mismatch even though `az account show` returned the expected tenant and Enabled subscription.
- **Evidence:** Cloud Shell command output recorded in the lab journal; no identifiers are committed.
- **Root cause:** the Azure CLI array query emitted one TSV value per line, but Bash `read` consumed only the first line.
- **Change:** use `mapfile`, require exactly three values, and assign the subscription, tenant, and state by index.
- **Retest:** passed. The guardrail confirmed the expected tenant and enabled subscription.
- **Lesson:** output format assumptions are part of a safety control and need a live retest.
- **Remaining limitation:** the deployment preview still depends on subscription provider readiness.

### F-05 — New subscription resource providers were not registered

- **Observed (UTC):** 2026-07-31 after the context retest.
- **Expected:** Azure what-if would return the proposed resource change set.
- **Actual:** Compute validation returned `SkuNotAvailable` across multiple small and general-purpose VM sizes and regions. A direct provider check then showed the required workload providers were not registered.
- **Evidence:** sanitized Cloud Shell results summarized in the lab journal.
- **Root cause:** the subscription was active, but its workload resource-provider namespaces had not started registration.
- **Change:** register only the seven required providers and add a non-mutating guard. The guard rejects `NotRegistered` but allows `Registering`, because Azure completes registration region by region.
- **Retest:** passed. Registration requests were accepted and regional template validation proceeded.
- **Lesson:** subscription state, provider registration, regional capacity, and quota are separate preflight checks.
- **Remaining limitation:** provider readiness did not resolve the separate VM capacity restriction; see F-06.

### F-06 — Planned VM SKUs were capacity-restricted

- **Observed (UTC):** 2026-07-31 07:34.
- **Expected:** the low-cost `Standard_B1s` validator would pass East US preflight.
- **Actual:** Azure rejected `Standard_B1s` and `Standard_D2ls_v5` after provider registration. A bounded subscription SKU inventory showed unrestricted version-seven D-series options.
- **Evidence:** sanitized what-if and SKU-inventory results summarized in the lab journal.
- **Root cause:** the subscription's current East US capacity restrictions did not permit the originally planned SKUs.
- **Change:** use the smallest suitable unrestricted option found, `Standard_D2ls_v7`, and raise the documented cost ceiling.
- **Retest:** passed. Azure what-if reported 26 resources to create, with no modifications or deletions.
- **Lesson:** a cheap catalog SKU is not deployable evidence until the target subscription and region accept it.
- **Remaining limitation:** what-if proves the proposed management-plane changes only. Deployment and data-plane validation still require explicit cost approval.
