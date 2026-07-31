# Lab journal

The journal records work as it occurs. Mistakes are included only when they actually happen; no failure is staged for appearance.

## 2026-07-31 — Scope and access checks

**Goal:** choose a credible project boundary and confirm which environments can support real evidence.

**Work completed**

- Reviewed the current SC-300 and SC-500 skill outlines.
- Chose one connected identity-to-workload scenario instead of a broad checklist of exam objectives.
- Confirmed the GitHub account can accept repository content.
- Reached the Microsoft Azure sign-in boundary for the live tenant/subscription check.
- Confirmed the local authoring environment has Git but does not have Azure CLI; live template checks will therefore run in Azure Cloud Shell.

**Decisions**

- Conditional Access, PIM, and access reviews will not be claimed before the tenant license is checked.
- Portal illustrations will be limited to real screenshots and one architecture diagram derived from the deployed resources.
- Any role assignment will be reviewed at the narrowest workable resource scope.
- The temporary validation workload will be removed after evidence is collected.

**Open items**

- Complete the Azure sign-in and record tenant capabilities.
- Build and validate the Bicep deployment.
- Create the empty GitHub repository and publish functional milestones.

**Mistakes or fixes**

None recorded in this session.

## 2026-07-31 — Repository baseline

**Goal:** publish the project as functional milestones and confirm that the committed files pass automated checks.

**Work completed**

- Created the public `JarthurLabs/Azure-Identity-and-Workload-Security-Lab` repository.
- Published the scenario and evidence rules before the infrastructure implementation.
- Opened separate GitHub issues for deployment, workload validation, Entra controls, and evidence cleanup.
- Published the Bicep, shell validation, KQL, and documentation as one infrastructure milestone.
- Confirmed GitHub Actions run 1 completed successfully at 04:26 UTC.

**Validation**

- Bicep build: passed.
- ShellCheck: passed.
- Committed-evidence redaction check: passed.

**Boundary**

The continuous integration result validates repository files only. It is not evidence that the Azure deployment or security controls work.

**Mistakes or fixes**

None recorded in this session.

## 2026-07-31 — Live environment precheck

**Goal:** confirm the signed-in Azure and Entra environments before running deployment commands.

**Expected**

- One enabled Azure subscription.
- Permission to create lab-only security groups in an owned training directory.

**Actual**

- The Azure subscriptions page showed zero subscriptions at 04:53 UTC.
- The Entra **New group** action returned **You don't have access** and HTTP status 401 at 04:54 UTC.

**What I got wrong**

I treated successful portal sign-in as a likely indicator that the account had a usable Azure subscription and an administrable Entra directory. The prechecks showed that those are three separate conditions:

1. authentication to the portal;
2. authorization inside a directory; and
3. access to an enabled Azure subscription.

**Decision**

- Do not run or simulate the Bicep deployment.
- Do not claim Entra group administration.
- Preserve sanitized evidence of both checks.
- Retest only in an owned training directory with an enabled subscription.

**Fix status**

Pending account-side setup. No broad directory role was requested in the current directory because its ownership and intended use have not been confirmed.

## 2026-07-31 — Alternate-account retest and deployment guardrails

**Goal:** determine whether a second Microsoft account provided the missing subscription and owned Entra directory.

**Expected**

- An enabled Azure subscription.
- An alternate directory where the account was a member and could administer lab-only groups.

**Actual**

- The alternate account signed in successfully.
- Azure still showed zero subscriptions and no other available directories.
- Microsoft Entra reported that the alternate account did not exist in the tested tenant.

**What I got wrong**

I expected a different Microsoft login to represent a separate usable Azure environment. The retest showed that an authenticated account can still lack both subscription ownership and membership in the directory that the portal is attempting to use.

**Fixes completed**

- Added a reusable context check that requires the intended subscription and tenant IDs before any live script runs.
- Added resource-group collision and ownership-tag checks before deployment or cleanup.
- Replaced broad Boolean cleanup flags with exact resource-name confirmation.
- Tightened the Key Vault template by disabling template-deployment access and the trusted-services network bypass.
- Added a negative blob-write test so least privilege requires a real HTTP 403 result.
- Updated the KQL projections to use current resource-specific table columns without exporting caller IP or application IDs.

**Decision**

Keep the workload undeployed until an enabled subscription and owned training directory are verified. Preserve this failed retest because it is the real reason work stopped.

## 2026-07-31 — Active subscription retest and preflight fixes

**Goal:** verify the newly activated subscription and produce a no-cost Azure deployment preview.

**Actual**

- The portal showed `Azure subscription 1` as Active with the signed-in account holding Owner.
- The first CLI guardrail run incorrectly reported a tenant mismatch.
- Direct CLI output showed the expected subscription, tenant, and Enabled state.
- Azure CLI rendered the three requested TSV values on separate lines, while the script expected one line with three fields.
- After the parser fix, the context check passed and confirmed that the intended resource group did not exist.
- Azure what-if then returned `SkuNotAvailable` for several VM sizes in East US, Central US, and West US 3.
- A provider-readiness check showed that the new subscription had not registered the Compute, Network, Storage, Key Vault, Managed Identity, or monitoring providers.

**What I got wrong**

I assumed Azure CLI array output in TSV format would be read as three fields on one line. I also treated the first VM-capacity error as a regional SKU problem before checking whether the new subscription's resource providers were registered.

**Fixes completed**

- Parse the three account-context values with `mapfile` and verify the item count.
- Correct the Bicep managed-identity type casing.
- Build the Blob private DNS suffix from `environment().suffixes.storage`.
- Stop the deployment script early with a clear list when required resource providers are not registered.

**Retest**

The account-context guardrail now passes. The resource group remains absent, and no lab resource has been deployed. A clean what-if is pending deliberate provider registration.
