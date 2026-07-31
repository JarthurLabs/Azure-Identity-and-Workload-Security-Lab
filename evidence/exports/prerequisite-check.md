# Environment prerequisite check

Captured on 2026-07-31 in the live Microsoft portals.

## P-01 — Azure subscription

- **Source:** Azure portal, Subscriptions.
- **Result:** zero subscriptions were available in the signed-in directory.
- **Security meaning:** no resource group, managed identity, Key Vault, Storage account, virtual network, private endpoint, Log Analytics workspace, or validation VM can be created.
- **Redacted:** account email and directory identifier are outside the cropped screenshot.
- **Next test:** confirm an enabled subscription, then run the Bicep build and subscription-scope what-if.

## P-02 — Entra group administration

- **Source:** Microsoft Entra admin center, Groups, New group.
- **Result:** the current principal received **You don't have access** with HTTP status 401.
- **Security meaning:** the current directory is not a valid administration lab for this account.
- **Redacted:** account email, directory identifier, and session identifier are outside the cropped screenshot.
- **Next test:** switch to an owned training directory with an appropriate administrator role, then create the lab groups.

## P-03 — Alternate account tenant membership

- **Source:** Azure portal, Directories + subscriptions, and Microsoft Entra sign-in.
- **Result:** the alternate account had zero Azure subscriptions, no other available directory, and no membership in the tested Entra tenant.
- **Security meaning:** signing in with another Microsoft account does not grant tenant administration or Azure resource access.
- **Redacted:** both account identities, directory identifiers, and session parameters are outside the cropped screenshot.
- **Next test:** complete subscription setup under the intended training account or use an existing account that owns an enabled subscription and Entra directory.

## Evidence boundary

These are failed prerequisite checks, not implemented security controls. They remain visible because they explain why the project did not claim deployment success or present an account switch as a permissions fix.

## 2026-07-31 workload prerequisite retest

- **Result:** a replacement training subscription was Active and the signed-in account held Owner.
- **Provider check:** the seven required resource providers were deliberately registered.
- **Capacity check:** the planned low-cost SKUs were restricted; `Standard_D2ls_v7` was unrestricted in East US.
- **What-if:** passed with 26 resources to create and no modifications or deletions.
- **Boundary:** no resource was deployed. What-if is management-plane preview evidence, not proof that the security controls work.
